import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { SessionWithDetail } from '../types';
import { getSession } from '../db/sessions';
import { getSessionExercises, getSets } from '../db/exercise-logs';

export function useSession(sessionId: number) {
  const db = useSQLiteContext();
  const [session, setSession] = useState<SessionWithDetail | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const s = await getSession(db, sessionId);
    if (!s) { setSession(null); setLoading(false); return; }
    const exercises = await getSessionExercises(db, sessionId);
    const exercisesWithSets = await Promise.all(
      exercises.map(async (ex) => ({
        ...ex,
        sets: await getSets(db, ex.id),
      }))
    );
    setSession({ ...s, exercises: exercisesWithSets });
    setLoading(false);
  }, [db, sessionId]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { session, loading, reload: load };
}
