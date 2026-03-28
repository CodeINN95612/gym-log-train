import React, { useState } from 'react';
import { View, Text, ScrollView, Alert } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { usePlan } from '../../../../hooks/usePlan';
import { createSession } from '../../../../db/sessions';
import { copyPlanDayToSession } from '../../../../db/exercise-logs';
import { todayISO } from '../../../../utils/date';
import { getTodayWeekday, WEEKDAY_NAMES } from '../../../../utils/weekdays';
import { Button } from '../../../../components/ui/Button';
import { Card } from '../../../../components/ui/Card';

export default function NewSessionScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const traineeId = parseInt(id);
  const router = useRouter();
  const db = useSQLiteContext();
  const { planDays } = usePlan(traineeId);
  const [loading, setLoading] = useState(false);

  const todayWeekday = getTodayWeekday();
  const todayPlanDay = planDays.find((d) => d.weekday === todayWeekday);

  const start = async (usePlanDayId: number | null) => {
    setLoading(true);
    try {
      const sessionId = await createSession(db, traineeId, todayISO(), usePlanDayId);
      if (usePlanDayId) {
        await copyPlanDayToSession(db, usePlanDayId, sessionId);
      }
      router.replace(`/trainees/${id}/session/${sessionId}`);
    } catch (e) {
      Alert.alert('Error', 'Could not start session');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1 px-4 pt-6" contentContainerClassName="gap-4 pb-10">
        <Text className="text-base text-slate-700">Starting session for today — <Text className="font-semibold">{WEEKDAY_NAMES[todayWeekday]}</Text></Text>

        {todayPlanDay ? (
          <Card>
            <Text className="text-base font-semibold text-slate-900 mb-1">Today's Plan</Text>
            <Text className="text-sm text-muted mb-3">
              {todayPlanDay.label ? `${todayPlanDay.label} · ` : ''}{todayPlanDay.exercises.length} exercise{todayPlanDay.exercises.length !== 1 ? 's' : ''} planned
            </Text>
            <Button label="Use Today's Plan" onPress={() => start(todayPlanDay.id)} loading={loading} fullWidth />
          </Card>
        ) : null}

        <Card>
          <Text className="text-base font-semibold text-slate-900 mb-1">Ad-hoc Session</Text>
          <Text className="text-sm text-muted mb-3">Start with a blank session and add exercises manually.</Text>
          <Button label="Start Blank Session" onPress={() => start(null)} variant="secondary" loading={loading} fullWidth />
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
}
