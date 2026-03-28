import { useState, useCallback } from 'react';
import { useSQLiteContext } from 'expo-sqlite';
import { useFocusEffect } from 'expo-router';
import { Session } from '../types';
import { getSessions } from '../db/sessions';

export function useSessions(traineeId: number, limit?: number) {
  const db = useSQLiteContext();
  const [sessions, setSessions] = useState<Session[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    const data = await getSessions(db, traineeId, limit);
    setSessions(data);
    setLoading(false);
  }, [db, traineeId, limit]);

  useFocusEffect(useCallback(() => { load(); }, [load]));

  return { sessions, loading, reload: load };
}
