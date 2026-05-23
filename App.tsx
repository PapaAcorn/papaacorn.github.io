import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  GestureResponderEvent,
  LayoutChangeEvent,
  PanResponder,
  Pressable,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';

type Direction = 'c-to-f' | 'f-to-c';

type TemperatureAnchor = {
  id: string;
  celsius: number;
  fahrenheit: number;
  tier: number;
  phrase: string;
  tip: string;
};

type Question = {
  key: string;
  anchor: TemperatureAnchor;
  direction: Direction;
};

type QuestionProgress = {
  attempts: number;
  correct: number;
  wrong: number;
  streak: number;
  learned: boolean;
  lastSeen: number;
};

type ProgressByQuestion = Record<string, QuestionProgress>;

type Feedback = {
  correct: boolean;
  selected: number;
  target: number;
  tolerance: number;
};

const STORAGE_KEY = 'metric-sense-temperature-progress-v1';
const LEARNED_STREAK = 5;
const TIP_EVERY_N_QUESTIONS = 3;

const TEMPERATURES: TemperatureAnchor[] = [
  {
    id: 'freezing',
    celsius: 0,
    fahrenheit: 32,
    tier: 1,
    phrase: 'Freezing water',
    tip: '0C is your anchor for freezing: it is 32F, not zero Fahrenheit.',
  },
  {
    id: 'cool-day',
    celsius: 10,
    fahrenheit: 50,
    tier: 1,
    phrase: 'Cool jacket weather',
    tip: '10C lands right on 50F. This is the easiest midpoint to keep in memory.',
  },
  {
    id: 'hot-day',
    celsius: 38,
    fahrenheit: 100,
    tier: 1,
    phrase: 'Very hot outside',
    tip: '100F is about 38C. Think "high thirties Celsius" for triple-digit Fahrenheit heat.',
  },
  {
    id: 'cold-day',
    celsius: 5,
    fahrenheit: 40,
    tier: 2,
    phrase: 'Cold, above freezing',
    tip: '5C is about 40F. From freezing, every 5C adds roughly 9F.',
  },
  {
    id: 'mild-day',
    celsius: 15,
    fahrenheit: 60,
    tier: 2,
    phrase: 'Mild spring day',
    tip: '15C is about 60F. The quick mental ladder is 0C=32F, 10C=50F, 15C=60F.',
  },
  {
    id: 'room-temp',
    celsius: 20,
    fahrenheit: 68,
    tier: 2,
    phrase: 'Comfortable room',
    tip: '20C is 68F, close enough to "about 70F" for everyday comfort.',
  },
  {
    id: 'warm-day',
    celsius: 25,
    fahrenheit: 77,
    tier: 3,
    phrase: 'Warm day',
    tip: '25C is 77F. The mid-twenties Celsius are the upper seventies Fahrenheit.',
  },
  {
    id: 'summer-day',
    celsius: 30,
    fahrenheit: 86,
    tier: 3,
    phrase: 'Summer heat',
    tip: '30C is 86F. Once Celsius reaches the thirties, Fahrenheit is in the high eighties and up.',
  },
  {
    id: 'very-hot-day',
    celsius: 35,
    fahrenheit: 95,
    tier: 3,
    phrase: 'Very hot day',
    tip: '35C is about 95F. Add one small step and you are near 100F.',
  },
];

const QUICK_TIPS = [
  'Fast estimate: double Celsius and add 30. It is imperfect, but useful near outdoor temperatures.',
  'From Fahrenheit to Celsius, subtract 30 and halve it for a quick everyday estimate.',
  'Think in anchors first: 0C=32F, 10C=50F, 20C=68F, and 38C=100F.',
  'Precision is not the goal here. Your brain is learning neighborhoods, not calculator answers.',
  'A 5C move is about a 9F move, so Celsius numbers climb more slowly.',
  'If 15C is about 60F, then 25C is warmer by 10C, or about 18F: upper seventies.',
];

const clamp = (value: number, min: number, max: number) => Math.min(Math.max(value, min), max);

const makeQuestionKey = (anchor: TemperatureAnchor, direction: Direction) => `${anchor.id}:${direction}`;

const createQuestions = (maxTier: number) =>
  TEMPERATURES.filter((anchor) => anchor.tier <= maxTier).flatMap((anchor) => [
    { key: makeQuestionKey(anchor, 'c-to-f'), anchor, direction: 'c-to-f' as const },
    { key: makeQuestionKey(anchor, 'f-to-c'), anchor, direction: 'f-to-c' as const },
  ]);

const getProgress = (progress: ProgressByQuestion, key: string): QuestionProgress => {
  const defaults: QuestionProgress = {
    attempts: 0,
    correct: 0,
    wrong: 0,
    streak: 0,
    learned: false,
    lastSeen: 0,
  };

  return {
    ...defaults,
    ...(progress[key] ?? {}),
  };
};

const getUnlockedTier = (progress: ProgressByQuestion) => {
  let unlockedTier = 1;
  const highestTier = Math.max(...TEMPERATURES.map((anchor) => anchor.tier));

  for (let tier = 1; tier < highestTier; tier += 1) {
    const tierQuestions = createQuestions(tier).filter((question) => question.anchor.tier === tier);
    const tierLearned = tierQuestions.every((question) => getProgress(progress, question.key).learned);
    if (tierLearned) {
      unlockedTier = tier + 1;
    } else {
      break;
    }
  }

  return unlockedTier;
};

const chooseQuestion = (
  questions: Question[],
  progress: ProgressByQuestion,
  previousKey?: string,
) => {
  const weighted = questions.flatMap((question) => {
    const stats = getProgress(progress, question.key);
    const wasWrong = stats.wrong > 0 && stats.streak === 0;
    const weight = stats.learned ? 1 : wasWrong ? 10 : 6 - Math.min(stats.streak, 4);
    return Array.from({ length: weight }, () => question);
  });

  const pool = weighted.filter((question) => question.key !== previousKey);
  const choices = pool.length > 0 ? pool : weighted;
  return choices[Math.floor(Math.random() * choices.length)];
};

const getQuestionCopy = (question: Question) => {
  if (question.direction === 'c-to-f') {
    return {
      prompt: `Set Fahrenheit for ${question.anchor.celsius}C`,
      given: `${question.anchor.celsius}C`,
      target: question.anchor.fahrenheit,
      unit: 'F',
      min: 30,
      max: 100,
      step: 1,
      tolerance: 2,
      correctText: `${question.anchor.celsius}C is about ${question.anchor.fahrenheit}F.`,
    };
  }

  return {
    prompt: `Set Celsius for ${question.anchor.fahrenheit}F`,
    given: `${question.anchor.fahrenheit}F`,
    target: question.anchor.celsius,
    unit: 'C',
    min: 0,
    max: 40,
    step: 1,
    tolerance: 1,
    correctText: `${question.anchor.fahrenheit}F is about ${question.anchor.celsius}C.`,
  };
};

const getStartingSelection = (copy: ReturnType<typeof getQuestionCopy>) => {
  const midpoint = Math.round((copy.min + copy.max) / 2 / copy.step) * copy.step;

  if (Math.abs(midpoint - copy.target) > copy.tolerance) {
    return midpoint;
  }

  return Math.abs(copy.min - copy.target) > copy.tolerance ? copy.min : copy.max;
};

export default function App() {
  const [progress, setProgress] = useState<ProgressByQuestion>({});
  const [question, setQuestion] = useState<Question>(() => createQuestions(1)[0]);
  const [selection, setSelection] = useState(50);
  const [feedback, setFeedback] = useState<Feedback | null>(null);
  const [showTip, setShowTip] = useState(false);
  const [tipIndex, setTipIndex] = useState(0);
  const [answeredThisSession, setAnsweredThisSession] = useState(0);
  const [trackWidth, setTrackWidth] = useState(1);
  const [hydrated, setHydrated] = useState(false);
  const questionRef = useRef(question);

  const unlockedTier = useMemo(() => getUnlockedTier(progress), [progress]);
  const unlockedQuestions = useMemo(() => createQuestions(unlockedTier), [unlockedTier]);
  const questionCopy = getQuestionCopy(question);
  const currentProgress = getProgress(progress, question.key);
  const learnedCount = unlockedQuestions.filter((item) => getProgress(progress, item.key).learned).length;
  const totalLearnedCount = createQuestions(Math.max(...TEMPERATURES.map((item) => item.tier))).filter(
    (item) => getProgress(progress, item.key).learned,
  ).length;

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((stored) => {
        if (stored) {
          setProgress(JSON.parse(stored));
        }
      })
      .catch(() => {
        setProgress({});
      })
      .finally(() => setHydrated(true));
  }, []);

  useEffect(() => {
    if (hydrated) {
      AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(progress)).catch(() => undefined);
    }
  }, [hydrated, progress]);

  useEffect(() => {
    questionRef.current = question;
    const copy = getQuestionCopy(question);
    setSelection(getStartingSelection(copy));
    setFeedback(null);
  }, [question]);

  useEffect(() => {
    if (!hydrated) {
      return;
    }

    const nextQuestions = createQuestions(getUnlockedTier(progress));
    if (!nextQuestions.some((item) => item.key === questionRef.current.key)) {
      setQuestion(chooseQuestion(nextQuestions, progress, questionRef.current.key));
    }
  }, [hydrated, progress]);

  const setSelectionFromRatio = useCallback(
    (ratio: number) => {
      const raw = questionCopy.min + ratio * (questionCopy.max - questionCopy.min);
      const stepped = Math.round(raw / questionCopy.step) * questionCopy.step;
      setSelection(clamp(stepped, questionCopy.min, questionCopy.max));
    },
    [questionCopy.max, questionCopy.min, questionCopy.step],
  );

  const setSelectionFromEvent = useCallback(
    (event: GestureResponderEvent) => {
      const locationX = event.nativeEvent.locationX ?? 0;
      setSelectionFromRatio(clamp(locationX / trackWidth, 0, 1));
    },
    [setSelectionFromRatio, trackWidth],
  );

  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderGrant: setSelectionFromEvent,
        onPanResponderMove: setSelectionFromEvent,
      }),
    [setSelectionFromEvent],
  );

  const onTrackLayout = (event: LayoutChangeEvent) => {
    setTrackWidth(Math.max(1, event.nativeEvent.layout.width));
  };

  const submitAnswer = () => {
    if (feedback) {
      return;
    }

    const delta = Math.abs(selection - questionCopy.target);
    const correct = delta <= questionCopy.tolerance;
    const now = Date.now();

    setFeedback({
      correct,
      selected: selection,
      target: questionCopy.target,
      tolerance: questionCopy.tolerance,
    });

    setProgress((current) => {
      const stats = getProgress(current, question.key);
      const streak = correct ? stats.streak + 1 : 0;
      return {
        ...current,
        [question.key]: {
          attempts: stats.attempts + 1,
          correct: stats.correct + (correct ? 1 : 0),
          wrong: stats.wrong + (correct ? 0 : 1),
          streak,
          learned: stats.learned || streak >= LEARNED_STREAK,
          lastSeen: now,
        },
      };
    });

    setAnsweredThisSession((count) => count + 1);
  };

  const continueGame = () => {
    const shouldShowTip = answeredThisSession > 0 && answeredThisSession % TIP_EVERY_N_QUESTIONS === 0;
    if (shouldShowTip) {
      setTipIndex((index) => (index + 1) % QUICK_TIPS.length);
      setShowTip(true);
      return;
    }

    setQuestion(chooseQuestion(createQuestions(getUnlockedTier(progress)), progress, question.key));
  };

  const continueFromTip = () => {
    setShowTip(false);
    setQuestion(chooseQuestion(createQuestions(getUnlockedTier(progress)), progress, question.key));
  };

  const nudgeSelection = (amount: number) => {
    if (!feedback) {
      setSelection((value) => clamp(value + amount, questionCopy.min, questionCopy.max));
    }
  };

  const resetProgress = () => {
    setProgress({});
    setQuestion(createQuestions(1)[0]);
    setAnsweredThisSession(0);
    setShowTip(false);
  };

  const answerRatio =
    (selection - questionCopy.min) / Math.max(1, questionCopy.max - questionCopy.min);

  if (showTip) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <StatusBar barStyle="light-content" />
        <View style={styles.tipScreen}>
          <Text style={styles.eyebrow}>Quick temperature sense</Text>
          <Text style={styles.tipTitle}>Loading the next round...</Text>
          <Text style={styles.tipText}>{QUICK_TIPS[tipIndex]}</Text>
          <Pressable style={styles.primaryButton} onPress={continueFromTip}>
            <Text style={styles.primaryButtonText}>Next round</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="light-content" />
      <ScrollView contentContainerStyle={styles.container}>
        <View style={styles.header}>
          <Text style={styles.eyebrow}>Metric Sense</Text>
          <Text style={styles.title}>Temperature Trainer</Text>
          <Text style={styles.subtitle}>
            Build quick intuition for everyday weather temperatures between freezing and 100F.
          </Text>
        </View>

        <View style={styles.statsRow}>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>Tier {unlockedTier}</Text>
            <Text style={styles.statLabel}>Current ladder</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>
              {learnedCount}/{unlockedQuestions.length}
            </Text>
            <Text style={styles.statLabel}>Learned here</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{totalLearnedCount}</Text>
            <Text style={styles.statLabel}>Total learned</Text>
          </View>
        </View>

        <View style={styles.card}>
          <View style={styles.promptRow}>
            <View>
              <Text style={styles.promptLabel}>{question.anchor.phrase}</Text>
              <Text style={styles.prompt}>{questionCopy.prompt}</Text>
            </View>
            <View style={styles.givenPill}>
              <Text style={styles.givenText}>{questionCopy.given}</Text>
            </View>
          </View>

          <View style={styles.answerPanel}>
            <Text style={styles.answerValue}>
              {selection}
              <Text style={styles.answerUnit}>{questionCopy.unit}</Text>
            </Text>
            <Text style={styles.answerHint}>
              Drag the thermometer or tap the nudges to set your estimate.
            </Text>
          </View>

          <View
            style={styles.track}
            onLayout={onTrackLayout}
            {...panResponder.panHandlers}
          >
            <View style={styles.trackFill} />
            <View style={[styles.thumb, { left: `${answerRatio * 100}%` }]}>
              <Text style={styles.thumbText}>{selection}</Text>
            </View>
          </View>

          <View style={styles.scaleRow}>
            <Text style={styles.scaleText}>
              {questionCopy.min}
              {questionCopy.unit}
            </Text>
            <Text style={styles.scaleText}>
              {questionCopy.max}
              {questionCopy.unit}
            </Text>
          </View>

          <View style={styles.nudgeGrid}>
            {[-10, -5, -1, 1, 5, 10].map((amount) => (
              <Pressable
                key={amount}
                style={({ pressed }) => [
                  styles.nudgeButton,
                  pressed && styles.nudgeButtonPressed,
                  feedback && styles.disabledButton,
                ]}
                onPress={() => nudgeSelection(amount)}
              >
                <Text style={styles.nudgeText}>
                  {amount > 0 ? '+' : ''}
                  {amount}
                </Text>
              </Pressable>
            ))}
          </View>

          {feedback ? (
            <View style={[styles.feedback, feedback.correct ? styles.feedbackCorrect : styles.feedbackWrong]}>
              <Text style={styles.feedbackTitle}>{feedback.correct ? 'Nice instinct.' : 'Retest queued.'}</Text>
              <Text style={styles.feedbackText}>
                You chose {feedback.selected}
                {questionCopy.unit}. {questionCopy.correctText} Within {feedback.tolerance}
                {questionCopy.unit} counts as close.
              </Text>
              <Text style={styles.feedbackTip}>{question.anchor.tip}</Text>
              <Pressable style={styles.primaryButton} onPress={continueGame}>
                <Text style={styles.primaryButtonText}>Continue</Text>
              </Pressable>
            </View>
          ) : (
            <Pressable style={styles.primaryButton} onPress={submitAnswer}>
              <Text style={styles.primaryButtonText}>Lock in estimate</Text>
            </Pressable>
          )}
        </View>

        <View style={styles.learningCard}>
          <Text style={styles.learningTitle}>How this module teaches</Text>
          <Text style={styles.learningText}>
            Each prompt must be answered correctly {LEARNED_STREAK} times in a row to become learned.
            Misses return more often, while learned prompts stay in light rotation.
          </Text>
          <View style={styles.progressBar}>
            <View
              style={[
                styles.progressBarFill,
                { width: `${Math.min(100, (currentProgress.streak / LEARNED_STREAK) * 100)}%` },
              ]}
            />
          </View>
          <Text style={styles.progressText}>
            Current prompt streak: {currentProgress.streak}/{LEARNED_STREAK}
          </Text>
        </View>

        <Pressable style={styles.resetButton} onPress={resetProgress}>
          <Text style={styles.resetText}>Reset practice progress</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#111827',
  },
  container: {
    padding: 20,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 18,
  },
  eyebrow: {
    color: '#93c5fd',
    fontSize: 13,
    fontWeight: '800',
    letterSpacing: 1.4,
    marginBottom: 8,
    textTransform: 'uppercase',
  },
  title: {
    color: '#f9fafb',
    fontSize: 36,
    fontWeight: '900',
    letterSpacing: -1.2,
  },
  subtitle: {
    color: '#cbd5e1',
    fontSize: 16,
    lineHeight: 23,
    marginTop: 8,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 14,
  },
  statCard: {
    backgroundColor: '#1f2937',
    borderColor: '#374151',
    borderRadius: 18,
    borderWidth: 1,
    flex: 1,
    padding: 12,
  },
  statValue: {
    color: '#f9fafb',
    fontSize: 18,
    fontWeight: '900',
  },
  statLabel: {
    color: '#9ca3af',
    fontSize: 11,
    fontWeight: '700',
    marginTop: 4,
    textTransform: 'uppercase',
  },
  card: {
    backgroundColor: '#f8fafc',
    borderRadius: 28,
    padding: 20,
  },
  promptRow: {
    alignItems: 'flex-start',
    flexDirection: 'row',
    gap: 12,
    justifyContent: 'space-between',
  },
  promptLabel: {
    color: '#64748b',
    fontSize: 13,
    fontWeight: '800',
    marginBottom: 6,
    textTransform: 'uppercase',
  },
  prompt: {
    color: '#0f172a',
    fontSize: 25,
    fontWeight: '900',
    lineHeight: 31,
    maxWidth: 235,
  },
  givenPill: {
    backgroundColor: '#dbeafe',
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 8,
  },
  givenText: {
    color: '#1d4ed8',
    fontSize: 18,
    fontWeight: '900',
  },
  answerPanel: {
    alignItems: 'center',
    backgroundColor: '#e0f2fe',
    borderRadius: 24,
    marginTop: 22,
    padding: 18,
  },
  answerValue: {
    color: '#075985',
    fontSize: 64,
    fontWeight: '900',
    letterSpacing: -2,
  },
  answerUnit: {
    fontSize: 30,
  },
  answerHint: {
    color: '#0369a1',
    fontSize: 14,
    fontWeight: '700',
    textAlign: 'center',
  },
  track: {
    backgroundColor: '#cbd5e1',
    borderRadius: 999,
    height: 28,
    justifyContent: 'center',
    marginTop: 28,
  },
  trackFill: {
    backgroundColor: '#38bdf8',
    borderRadius: 999,
    height: 10,
    marginHorizontal: 10,
  },
  thumb: {
    alignItems: 'center',
    backgroundColor: '#0f172a',
    borderColor: '#f8fafc',
    borderRadius: 18,
    borderWidth: 3,
    height: 46,
    justifyContent: 'center',
    marginLeft: -23,
    position: 'absolute',
    top: -9,
    width: 46,
  },
  thumbText: {
    color: '#f8fafc',
    fontSize: 13,
    fontWeight: '900',
  },
  scaleRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 12,
  },
  scaleText: {
    color: '#64748b',
    fontSize: 13,
    fontWeight: '800',
  },
  nudgeGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    justifyContent: 'center',
    marginTop: 20,
  },
  nudgeButton: {
    alignItems: 'center',
    backgroundColor: '#e2e8f0',
    borderRadius: 14,
    minWidth: 48,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  nudgeButtonPressed: {
    backgroundColor: '#bfdbfe',
  },
  disabledButton: {
    opacity: 0.45,
  },
  nudgeText: {
    color: '#0f172a',
    fontSize: 15,
    fontWeight: '900',
  },
  primaryButton: {
    alignItems: 'center',
    backgroundColor: '#2563eb',
    borderRadius: 18,
    marginTop: 22,
    padding: 16,
  },
  primaryButtonText: {
    color: '#f8fafc',
    fontSize: 16,
    fontWeight: '900',
  },
  feedback: {
    borderRadius: 22,
    marginTop: 20,
    padding: 16,
  },
  feedbackCorrect: {
    backgroundColor: '#dcfce7',
  },
  feedbackWrong: {
    backgroundColor: '#fee2e2',
  },
  feedbackTitle: {
    color: '#0f172a',
    fontSize: 20,
    fontWeight: '900',
    marginBottom: 8,
  },
  feedbackText: {
    color: '#334155',
    fontSize: 15,
    lineHeight: 21,
  },
  feedbackTip: {
    color: '#0f172a',
    fontSize: 15,
    fontWeight: '800',
    lineHeight: 21,
    marginTop: 12,
  },
  learningCard: {
    backgroundColor: '#1f2937',
    borderRadius: 24,
    marginTop: 16,
    padding: 18,
  },
  learningTitle: {
    color: '#f9fafb',
    fontSize: 18,
    fontWeight: '900',
    marginBottom: 8,
  },
  learningText: {
    color: '#cbd5e1',
    fontSize: 14,
    lineHeight: 21,
  },
  progressBar: {
    backgroundColor: '#374151',
    borderRadius: 999,
    height: 10,
    marginTop: 14,
    overflow: 'hidden',
  },
  progressBarFill: {
    backgroundColor: '#22c55e',
    height: '100%',
  },
  progressText: {
    color: '#9ca3af',
    fontSize: 13,
    fontWeight: '800',
    marginTop: 8,
  },
  resetButton: {
    alignItems: 'center',
    marginTop: 18,
    padding: 12,
  },
  resetText: {
    color: '#93c5fd',
    fontSize: 14,
    fontWeight: '800',
  },
  tipScreen: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
  },
  tipTitle: {
    color: '#f9fafb',
    fontSize: 34,
    fontWeight: '900',
    letterSpacing: -1,
    marginBottom: 16,
  },
  tipText: {
    color: '#dbeafe',
    fontSize: 22,
    fontWeight: '800',
    lineHeight: 32,
  },
});
