import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { PlanDay, PlanDayExercise } from '../types';
import { getPlanDays, getPlanDayExercises } from '../db/plans';

export interface PlanDayWithExercises extends PlanDay {
  exercises: PlanDayExercise[];
}

export function usePlan(traineeId: number) {
  const db = useSQLiteContext();
  const [planDays, setPlanDays] = useState<PlanDayWithExercises[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const days = await getPlanDays(db, traineeId);
    const daysWithExercises = await Promise.all(
      days.map(async (day) => ({
        ...day,
        exercises: await getPlanDayExercises(db, day.id),
      }))
    );
    setPlanDays(daysWithExercises);
    setLoading(false);
  }, [db, traineeId]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { planDays, loading, reload: load };
}
