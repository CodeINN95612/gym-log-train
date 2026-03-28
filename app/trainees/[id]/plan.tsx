import React, { useState } from 'react';
import { View, Text, ScrollView, Alert, Pressable } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { usePlan, PlanDayWithExercises } from '../../../hooks/usePlan';
import { WeekDayRow } from '../../../components/plan/WeekDayRow';
import { PlanExerciseItem } from '../../../components/plan/PlanExerciseItem';
import { upsertPlanDay, deletePlanDay, removeExerciseFromPlanDay } from '../../../db/plans';
import { WEEKDAY_NAMES } from '../../../utils/weekdays';

export default function PlanScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const traineeId = parseInt(id);
  const router = useRouter();
  const db = useSQLiteContext();
  const { planDays, reload } = usePlan(traineeId);
  const [expandedDay, setExpandedDay] = useState<number | null>(null);

  const planDayMap = new Map(planDays.map((d) => [d.weekday, d]));

  const handleDayPress = async (weekday: number) => {
    const existing = planDayMap.get(weekday);
    if (existing) {
      setExpandedDay(expandedDay === weekday ? null : weekday);
    } else {
      await upsertPlanDay(db, traineeId, weekday, null);
      await reload();
      setExpandedDay(weekday);
    }
  };

  const handleRemoveDay = async (planDay: PlanDayWithExercises) => {
    Alert.alert('Remove Day', `Remove ${WEEKDAY_NAMES[planDay.weekday]} from the plan?`, [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Remove', style: 'destructive', onPress: async () => {
        await deletePlanDay(db, planDay.id);
        await reload();
        setExpandedDay(null);
      }}
    ]);
  };

  const handleRemoveExercise = async (planDayExerciseId: number) => {
    await removeExerciseFromPlanDay(db, planDayExerciseId);
    await reload();
  };

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1" contentContainerClassName="pb-10">
        <Text className="px-4 pt-4 pb-2 text-sm text-muted">Tap a day to enable it or expand its exercises. Tap again to collapse.</Text>
        {[0, 1, 2, 3, 4, 5, 6].map((weekday) => {
          const planDay = planDayMap.get(weekday);
          const isExpanded = expandedDay === weekday;
          return (
            <View key={weekday}>
              <WeekDayRow weekday={weekday} planDay={planDay} onPress={() => handleDayPress(weekday)} />
              {isExpanded && planDay && (
                <View className="bg-slate-50 border-b border-border">
                  {planDay.exercises.map((ex) => (
                    <PlanExerciseItem key={ex.id} item={ex} onRemove={() => handleRemoveExercise(ex.id)} />
                  ))}
                  <View className="flex-row gap-2 px-4 py-3">
                    <Pressable
                      onPress={() => router.push({ pathname: '/modals/exercise-picker', params: { mode: 'plan', targetId: planDay.id.toString() } })}
                      className="flex-1 border border-dashed border-primary rounded-xl py-2.5 items-center active:opacity-60"
                    >
                      <Text className="text-sm text-primary font-medium">+ Add Exercise</Text>
                    </Pressable>
                    <Pressable
                      onPress={() => handleRemoveDay(planDay)}
                      className="border border-dashed border-danger rounded-xl px-4 py-2.5 items-center active:opacity-60"
                    >
                      <Text className="text-sm text-danger font-medium">Remove Day</Text>
                    </Pressable>
                  </View>
                </View>
              )}
            </View>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}
