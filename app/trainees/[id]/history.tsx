import React from 'react';
import { FlatList, ActivityIndicator } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useSessions } from '../../../hooks/useSessions';
import { SessionCard } from '../../../components/sessions/SessionCard';
import { EmptyState } from '../../../components/ui/EmptyState';

export default function HistoryScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const traineeId = parseInt(id);
  const router = useRouter();
  const { sessions, loading } = useSessions(traineeId);

  if (loading) return <ActivityIndicator className="mt-20" />;

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <FlatList
        data={sessions}
        keyExtractor={(s) => s.id.toString()}
        contentContainerClassName="px-4 pt-4 pb-10"
        ListEmptyComponent={<EmptyState title="No sessions yet" subtitle="Start a session to log workouts" icon="📋" />}
        renderItem={({ item }) => (
          <SessionCard session={item} onPress={() => router.push(`/trainees/${id}/session/${item.id}`)} />
        )}
      />
    </SafeAreaView>
  );
}
