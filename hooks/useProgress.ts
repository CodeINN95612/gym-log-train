import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { ProgressPoint, ExercisePR, Exercise } from '../types';
import { getExerciseHistory, getAllPRs, getLoggedExercises, getTraineeStats } from '../db/progress';

export function useProgress(traineeId: number, exerciseId: number | null) {
  const db = useSQLiteContext();
  const [points, setPoints] = useState<ProgressPoint[]>([]);
  const [loading, setLoading] = useState(false);

  const load = useCallback(async () => {
    if (!exerciseId) { setPoints([]); return; }
    setLoading(true);
    const data = await getExerciseHistory(db, traineeId, exerciseId);
    setPoints(data);
    setLoading(false);
  }, [db, traineeId, exerciseId]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { points, loading, reload: load };
}

export function useAllPRs(traineeId: number) {
  const db = useSQLiteContext();
  const [prs, setPrs] = useState<ExercisePR[]>([]);
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [stats, setStats] = useState({ session_count: 0, exercise_count: 0, first_date: null as string | null });
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const [prData, exerciseData, statsData] = await Promise.all([
      getAllPRs(db, traineeId),
      getLoggedExercises(db, traineeId),
      getTraineeStats(db, traineeId),
    ]);
    setPrs(prData);
    setExercises(exerciseData);
    setStats(statsData);
    setLoading(false);
  }, [db, traineeId]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { prs, exercises, stats, loading, reload: load };
}
