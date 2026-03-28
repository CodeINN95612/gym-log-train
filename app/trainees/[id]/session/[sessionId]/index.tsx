import React, { useState, useRef, useEffect, useCallback } from 'react';
import { ScrollView, View, Text, Pressable, Alert, ActivityIndicator, Vibration } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSession } from '../../../../../hooks/useSession';
import { endSession } from '../../../../../db/sessions';
import { addSet, updateSet, deleteSet, removeExerciseFromSession } from '../../../../../db/exercise-logs';
import { ExerciseLogBlock } from '../../../../../components/sessions/ExerciseLogBlock';
import { RestTimer } from '../../../../../components/sessions/RestTimer';
import { EmptyState } from '../../../../../components/ui/EmptyState';
import { Button } from '../../../../../components/ui/Button';
import { formatDate } from '../../../../../utils/date';

export default function SessionScreen() {
  const { id, sessionId } = useLocalSearchParams<{ id: string; sessionId: string }>();
  const sid = parseInt(sessionId);
  const router = useRouter();
  const db = useSQLiteContext();
  const { session, loading, reload } = useSession(sid);

  // Rest timer state
  const [restDuration, setRestDuration] = useState(90);
  const [restRemaining, setRestRemaining] = useState<number | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const startRestTimer = useCallback((duration?: number) => {
    const d = duration ?? restDuration;
    if (timerRef.current) clearInterval(timerRef.current);
    setRestRemaining(d);
    timerRef.current = setInterval(() => {
      setRestRemaining((prev) => {
        if (prev === null || prev <= 1) {
          clearInterval(timerRef.current!);
          Vibration.vibrate([0, 400, 100, 400]);
          return null;
        }
        return prev - 1;
      });
    }, 1000);
  }, [restDuration]);

  useEffect(() => {
    return () => { if (timerRef.current) clearInterval(timerRef.current); };
  }, []);

  const isReadOnly = !!(session?.ended_at);

  const handleAddSet = async (sessionExerciseId: number) => {
    const exercise = session?.exercises.find((e) => e.id === sessionExerciseId);
    const nextSetNumber = (exercise?.sets.length ?? 0) + 1;
    await addSet(db, sessionExerciseId, nextSetNumber, null, null, null);
    await reload();
    if (!isReadOnly) startRestTimer();
  };

  const handleUpdateSet = async (setId: number, reps: number | null, weight: number | null, duration: number | null) => {
    await updateSet(db, setId, reps, weight, duration);
  };

  const handleDeleteSet = async (setId: number) => {
    await deleteSet(db, setId);
    await reload();
  };

  const handleRemoveExercise = async (sessionExerciseId: number) => {
    Alert.alert('Remove Exercise', 'Remove this exercise and all its sets?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Remove', style: 'destructive', onPress: async () => {
        await removeExerciseFromSession(db, sessionExerciseId);
        await reload();
      }}
    ]);
  };

  const handleEndSession = () => {
    Alert.alert('End Session', 'Mark this session as complete?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'End Session', onPress: async () => {
        if (timerRef.current) clearInterval(timerRef.current);
        setRestRemaining(null);
        await endSession(db, sid);
        await reload();
      }}
    ]);
  };

  const handleSkipTimer = () => {
    if (timerRef.current) clearInterval(timerRef.current);
    setRestRemaining(null);
  };

  const handleAddTime = () => {
    setRestRemaining((prev) => (prev ?? 0) + 30);
  };

  const handleChangeDuration = (seconds: number) => {
    setRestDuration(seconds);
    startRestTimer(seconds);
  };

  if (loading) return <ActivityIndicator color="#6366F1" style={{ marginTop: 80 }} />;
  if (!session) return null;

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      {/* Header */}
      <View className="px-4 pt-3 pb-2 bg-white border-b border-surface">
        <Text className="text-sm text-muted">{formatDate(session.date)}</Text>
        <View className="flex-row items-center justify-between mt-1">
          <Text className="text-base font-semibold text-slate-900">
            {session.exercises.length} exercise{session.exercises.length !== 1 ? 's' : ''}
          </Text>
          {isReadOnly ? (
            <View className="bg-emerald-50 px-2.5 py-1 rounded-full">
              <Text className="text-xs font-semibold text-emerald-600">Completed</Text>
            </View>
          ) : (
            <View className="bg-amber-50 px-2.5 py-1 rounded-full">
              <Text className="text-xs font-semibold text-amber-600">In Progress</Text>
            </View>
          )}
        </View>
      </View>

      {/* Rest Timer — shown between header and content when active */}
      {!isReadOnly && restRemaining !== null && (
        <RestTimer
          remaining={restRemaining}
          total={restDuration}
          selectedDuration={restDuration}
          onSkip={handleSkipTimer}
          onAddTime={handleAddTime}
          onChangeDuration={handleChangeDuration}
        />
      )}

      <ScrollView className="flex-1" contentContainerStyle={{ padding: 16, paddingBottom: 128 }}>
        {session.exercises.length === 0 ? (
          <EmptyState title="No exercises yet" subtitle="Add exercises to log this session" icon="💪" />
        ) : (
          session.exercises.map((ex) => (
            <ExerciseLogBlock
              key={ex.id}
              item={ex}
              isReadOnly={isReadOnly}
              onAddSet={() => handleAddSet(ex.id)}
              onUpdateSet={handleUpdateSet}
              onDeleteSet={handleDeleteSet}
              onRemoveExercise={() => handleRemoveExercise(ex.id)}
            />
          ))
        )}
      </ScrollView>

      {/* Bottom Actions */}
      {!isReadOnly && (
        <View className="absolute bottom-0 left-0 right-0 px-4 pb-6 pt-3 bg-white border-t border-surface gap-2">
          <Pressable
            onPress={() => router.push({ pathname: '/modals/exercise-picker', params: { mode: 'session', targetId: sid.toString() } })}
            className="border border-dashed border-primary rounded-xl py-3 items-center active:opacity-60"
          >
            <Text className="text-primary font-semibold">+ Add Exercise</Text>
          </Pressable>
          <Button label="End Session" onPress={handleEndSession} variant="secondary" fullWidth />
        </View>
      )}
    </SafeAreaView>
  );
}
