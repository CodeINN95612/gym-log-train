import React from 'react';
import { ScrollView, Text, View, Pressable, ActivityIndicator, Alert } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSQLiteContext } from 'expo-sqlite';
import { useTrainee } from '../../../hooks/useTrainee';
import { usePlan } from '../../../hooks/usePlan';
import { useSessions } from '../../../hooks/useSessions';
import { SessionCard } from '../../../components/sessions/SessionCard';
import { WEEKDAY_NAMES } from '../../../utils/weekdays';
import { Card } from '../../../components/ui/Card';
import { Button } from '../../../components/ui/Button';
import { deleteTrainee } from '../../../db/trainees';

export default function TraineeOverviewScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const traineeId = parseInt(id);
  const router = useRouter();
  const db = useSQLiteContext();
  const { trainee, loading } = useTrainee(traineeId);
  const { planDays } = usePlan(traineeId);
  const { sessions } = useSessions(traineeId, 5);

  const handleDelete = () => {
    Alert.alert('Delete Trainee', `Delete ${trainee?.name}? This will also delete all their sessions and plans.`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete', style: 'destructive', onPress: async () => {
          await deleteTrainee(db, traineeId);
          router.back();
        }
      }
    ]);
  };

  if (loading) return <ActivityIndicator className="mt-20" />;
  if (!trainee) return null;

  const planDayMap = new Map(planDays.map((d) => [d.weekday, d]));

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1" contentContainerClassName="px-4 pt-4 pb-10">
        {/* Header */}
        <View className="flex-row items-start justify-between mb-4">
          <View className="flex-1">
            <Text className="text-2xl font-bold text-slate-900">{trainee.name}</Text>
            {trainee.notes ? <Text className="text-sm text-muted mt-1">{trainee.notes}</Text> : null}
          </View>
          <Pressable onPress={handleDelete} className="p-2 active:opacity-60">
            <Text className="text-danger text-sm">Delete</Text>
          </Pressable>
        </View>

        {/* Action buttons */}
        <View className="flex-row gap-3">
          <View className="flex-1">
            <Button label="Start Session" onPress={() => router.push(`/trainees/${traineeId}/session/new`)} fullWidth />
          </View>
          <Pressable
            onPress={() => router.push(`/trainees/${traineeId}/progress`)}
            className="bg-indigo-50 rounded-xl px-4 items-center justify-center active:opacity-70"
          >
            <Text className="text-primary font-semibold text-sm">Progress</Text>
          </Pressable>
        </View>

        {/* Weekly Plan Summary */}
        <View className="mt-6 mb-2 flex-row items-center justify-between">
          <Text className="text-lg font-semibold text-slate-900">Weekly Plan</Text>
          <Pressable onPress={() => router.push(`/trainees/${traineeId}/plan`)} className="active:opacity-60">
            <Text className="text-sm text-primary font-medium">Edit</Text>
          </Pressable>
        </View>
        <Card className="p-0 overflow-hidden">
          {[0, 1, 2, 3, 4, 5, 6].map((day) => {
            const planDay = planDayMap.get(day);
            return (
              <View key={day} className="flex-row items-center px-4 py-2.5 border-b border-border last:border-b-0">
                <View className={`w-8 h-8 rounded-full items-center justify-center mr-3 ${planDay ? 'bg-primary' : 'bg-slate-100'}`}>
                  <Text className={`text-xs font-bold ${planDay ? 'text-white' : 'text-muted'}`}>
                    {WEEKDAY_NAMES[day].slice(0, 2)}
                  </Text>
                </View>
                <Text className="text-sm text-slate-700 flex-1">
                  {planDay ? (planDay.label || `${planDay.exercises.length} exercise${planDay.exercises.length !== 1 ? 's' : ''}`) : 'Rest'}
                </Text>
              </View>
            );
          })}
        </Card>

        {/* Recent Sessions */}
        <View className="mt-6 mb-2 flex-row items-center justify-between">
          <Text className="text-lg font-semibold text-slate-900">Recent Sessions</Text>
          <Pressable onPress={() => router.push(`/trainees/${traineeId}/history`)} className="active:opacity-60">
            <Text className="text-sm text-primary font-medium">See All</Text>
          </Pressable>
        </View>
        {sessions.length === 0 ? (
          <Text className="text-sm text-muted text-center py-4">No sessions yet</Text>
        ) : (
          sessions.map((s) => (
            <SessionCard key={s.id} session={s} onPress={() => router.push(`/trainees/${traineeId}/session/${s.id}`)} />
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}
