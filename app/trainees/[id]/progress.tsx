import React, { useState } from 'react';
import { ScrollView, View, Text, Pressable, FlatList, ActivityIndicator } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import clsx from 'clsx';
import { useAllPRs, useProgress } from '../../../hooks/useProgress';
import { PRCard } from '../../../components/progress/PRCard';
import { ProgressChart } from '../../../components/progress/ProgressChart';
import { formatDate } from '../../../utils/date';
import { Exercise } from '../../../types';

type Metric = 'weight' | 'reps' | 'duration' | '1rm';

export default function ProgressScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const traineeId = parseInt(id);

  const { prs, exercises, stats, loading } = useAllPRs(traineeId);
  const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
  const [metric, setMetric] = useState<Metric>('weight');

  const { points, loading: chartLoading } = useProgress(
    traineeId,
    selectedExercise?.id ?? null
  );

  const handleSelectExercise = (ex: Exercise) => {
    setSelectedExercise(ex);
    setMetric('weight');
  };

  // Determine which metric buttons to show for the selected exercise
  const availableMetrics = selectedExercise && points.length > 0
    ? {
        weight: points.some((p) => p.best_weight != null),
        reps: points.some((p) => p.best_reps != null),
        '1rm': points.some((p) => p.estimated_1rm != null),
        duration: points.some((p) => p.best_duration != null),
      }
    : null;

  const METRIC_LABELS: Record<Metric, string> = {
    weight: 'Weight',
    reps: 'Reps',
    '1rm': 'Est. 1RM',
    duration: 'Duration',
  };

  if (loading) {
    return <ActivityIndicator color="#6366F1" style={{ marginTop: 80 }} />;
  }

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1" contentContainerStyle={{ paddingBottom: 40 }}>

        {/* Stats strip */}
        <View className="flex-row gap-3 px-5 pt-5 pb-4">
          {[
            { label: 'Sessions', value: stats.session_count.toString() },
            { label: 'Exercises', value: stats.exercise_count.toString() },
            { label: 'Since', value: stats.first_date ? formatDate(stats.first_date) : '—' },
          ].map((s) => (
            <View key={s.label} className="flex-1 bg-white rounded-2xl py-3 items-center"
              style={{ shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06, shadowRadius: 6, elevation: 2 }}>
              <Text className="text-xl font-bold text-slate-800">{s.value}</Text>
              <Text className="text-xs text-muted mt-0.5">{s.label}</Text>
            </View>
          ))}
        </View>

        {/* PRs section */}
        {prs.length > 0 && (
          <View className="mb-4">
            <Text className="text-base font-bold text-slate-800 px-5 mb-3">Personal Records</Text>
            <FlatList
              horizontal
              data={prs}
              keyExtractor={(p) => p.exercise_id.toString()}
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={{ paddingHorizontal: 20 }}
              renderItem={({ item }) => <PRCard pr={item} />}
            />
          </View>
        )}

        {/* Exercise Progress */}
        <View className="px-5">
          <Text className="text-base font-bold text-slate-800 mb-3">Exercise Progress</Text>

          {exercises.length === 0 ? (
            <View className="items-center py-10 bg-white rounded-2xl">
              <Text className="text-3xl mb-2">📊</Text>
              <Text className="text-sm font-semibold text-slate-600">No sessions logged yet</Text>
              <Text className="text-xs text-muted mt-1">Complete sessions to see progress charts</Text>
            </View>
          ) : (
            <>
              {/* Exercise selector chips */}
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={{ gap: 8, marginBottom: 16 }}
              >
                {exercises.map((ex) => {
                  const isSelected = selectedExercise?.id === ex.id;
                  return (
                    <Pressable
                      key={ex.id}
                      onPress={() => handleSelectExercise(ex)}
                      className={clsx('rounded-full active:opacity-70', isSelected ? 'bg-primary' : 'bg-white')}
                      style={{ paddingHorizontal: 14, paddingVertical: 8,
                        shadowColor: '#64748B', shadowOffset: { width: 0, height: 1 },
                        shadowOpacity: isSelected ? 0 : 0.06, shadowRadius: 4, elevation: isSelected ? 0 : 2 }}
                    >
                      <Text className={clsx('text-sm font-semibold', isSelected ? 'text-white' : 'text-slate-600')}>
                        {ex.name}
                      </Text>
                    </Pressable>
                  );
                })}
              </ScrollView>

              {/* Metric toggle */}
              {availableMetrics && (
                <View className="flex-row gap-2 mb-4">
                  {(Object.keys(METRIC_LABELS) as Metric[])
                    .filter((m) => availableMetrics[m])
                    .map((m) => (
                      <Pressable
                        key={m}
                        onPress={() => setMetric(m)}
                        className={clsx('px-3 py-1.5 rounded-xl active:opacity-70', metric === m ? 'bg-indigo-600' : 'bg-white')}
                        style={metric !== m ? { shadowColor: '#64748B', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.06, shadowRadius: 4, elevation: 2 } : {}}
                      >
                        <Text className={clsx('text-xs font-bold', metric === m ? 'text-white' : 'text-slate-500')}>
                          {METRIC_LABELS[m]}
                        </Text>
                      </Pressable>
                    ))}
                </View>
              )}

              {/* Chart area */}
              <View className="bg-white rounded-2xl p-4"
                style={{ shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }}>
                {!selectedExercise ? (
                  <View className="items-center py-10">
                    <Text className="text-3xl mb-2">👆</Text>
                    <Text className="text-sm font-semibold text-slate-600 text-center">Select an exercise above</Text>
                    <Text className="text-xs text-muted text-center mt-1">to view its progress chart</Text>
                  </View>
                ) : chartLoading ? (
                  <ActivityIndicator color="#6366F1" style={{ marginVertical: 40 }} />
                ) : (
                  <>
                    <Text className="text-sm font-bold text-slate-800 mb-4">{selectedExercise.name}</Text>
                    <ProgressChart points={points} metric={metric} />
                  </>
                )}
              </View>
            </>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
