import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { Exercise } from '../types';
import { getAllExercises } from '../db/library';

export function useLibrary(search = '', category: string | null = null) {
  const db = useSQLiteContext();
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const data = await getAllExercises(db, search, category);
    setExercises(data);
    setLoading(false);
  }, [db, search, category]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { exercises, loading, reload: load };
}
