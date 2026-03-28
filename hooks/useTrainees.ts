import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { Trainee } from '../types';
import { getAllTrainees } from '../db/trainees';

export function useTrainees() {
  const db = useSQLiteContext();
  const [trainees, setTrainees] = useState<Trainee[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const data = await getAllTrainees(db);
    setTrainees(data);
    setLoading(false);
  }, [db]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { trainees, loading, reload: load };
}
