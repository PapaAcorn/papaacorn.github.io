//
//  ConversionSpeechService.swift
//  Metricize
//

import Foundation
#if os(iOS)
import AVFoundation
import Speech
#endif

enum ConversionSpeechError: Error, Equatable {
    case unavailable
    case permissionDenied
    case recognitionFailed
}

@Observable
final class ConversionSpeechService {
    var isListening = false
    var authorizationStatus: String = "notDetermined"

    #if os(iOS)
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    #endif

    func requestAuthorization() async -> Bool {
        #if os(iOS)
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    self.authorizationStatus = String(describing: status)
                }
                continuation.resume(returning: status == .authorized)
            }
        }
        #else
        false
        #endif
    }

    func startListening(onResult: @escaping (String) -> Void, onError: @escaping (ConversionSpeechError) -> Void) {
        #if os(iOS)
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")), recognizer.isAvailable else {
            onError(.unavailable)
            return
        }

        speechRecognizer = recognizer
        stopListening()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            onError(.recognitionFailed)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            onError(.recognitionFailed)
            return
        }

        recognitionRequest.shouldReportPartialResults = false
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        }

        let inputNode = audioEngine.inputNode
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result {
                    onResult(result.bestTranscription.formattedString)
                    self.stopListening()
                } else if error != nil {
                    onError(.recognitionFailed)
                    self.stopListening()
                }
            }
        }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
        } catch {
            stopListening()
            onError(.recognitionFailed)
        }
        #else
        onError(.unavailable)
        #endif
    }

    func stopListening() {
        #if os(iOS)
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        #endif
    }
}
