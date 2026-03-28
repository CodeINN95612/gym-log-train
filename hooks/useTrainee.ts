import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { Trainee } from '../types';
import { getTrainee } from '../db/trainees';

export function useTrainee(id: number) {
  const db = useSQLiteContext();
  const [trainee, setTrainee] = useState<Trainee | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const data = await getTrainee(db, id);
    setTrainee(data);
    setLoading(false);
  }, [db, id]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { trainee, loading, reload: load };
}
