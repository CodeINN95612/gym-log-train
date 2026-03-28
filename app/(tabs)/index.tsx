import React from 'react';
import { FlatList, Pressable, Text, View, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTrainees } from '../../hooks/useTrainees';
import { TraineeCard } from '../../components/trainees/TraineeCard';
import { EmptyState } from '../../components/ui/EmptyState';

export default function TraineesScreen() {
  const router = useRouter();
  const { trainees, loading } = useTrainees();

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['top']}>
      <View className="px-5 pt-5 pb-3 flex-row items-center justify-between">
        <View>
          <Text className="text-xs font-semibold text-muted uppercase tracking-widest">GymLog</Text>
          <Text className="text-2xl font-bold text-slate-900 mt-0.5">Trainees</Text>
        </View>
        <Pressable
          onPress={() => router.push('/trainees/new')}
          className="bg-primary rounded-xl active:bg-primary-dark flex-row items-center gap-1.5"
          style={{ paddingHorizontal: 14, paddingVertical: 9 }}
        >
          <Ionicons name="add" size={16} color="white" />
          <Text className="text-white font-semibold text-sm">Add</Text>
        </Pressable>
      </View>

      {loading ? (
        <ActivityIndicator color="#6366F1" className="mt-10" />
      ) : (
        <FlatList
          data={trainees}
          keyExtractor={(t) => t.id.toString()}
          contentContainerStyle={{ paddingHorizontal: 20, paddingTop: 8, paddingBottom: 32 }}
          ListEmptyComponent={
            <EmptyState title="No trainees yet" subtitle="Add your first trainee to get started" icon="🏋️" />
          }
          renderItem={({ item }) => (
            <TraineeCard trainee={item} onPress={() => router.push(`/trainees/${item.id}`)} />
          )}
        />
      )}
    </SafeAreaView>
  );
}
