import React, { useState } from 'react';
import { FlatList, Pressable, Text, View, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLibrary } from '../../hooks/useLibrary';
import { ExerciseListItem } from '../../components/library/ExerciseListItem';
import { CategoryFilter } from '../../components/library/CategoryFilter';
import { EmptyState } from '../../components/ui/EmptyState';
import { Input } from '../../components/ui/Input';

export default function LibraryScreen() {
  const router = useRouter();
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const { exercises, loading } = useLibrary(search, category);

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['top']}>
      <View className="px-5 pt-5 pb-3 flex-row items-center justify-between">
        <View>
          <Text className="text-xs font-semibold text-muted uppercase tracking-widest">GymLog</Text>
          <Text className="text-2xl font-bold text-slate-900 mt-0.5">Exercises</Text>
        </View>
        <Pressable
          onPress={() => router.push('/modals/add-exercise')}
          className="bg-primary rounded-xl active:bg-primary-dark flex-row items-center gap-1.5"
          style={{ paddingHorizontal: 14, paddingVertical: 9 }}
        >
          <Ionicons name="add" size={16} color="white" />
          <Text className="text-white font-semibold text-sm">Add</Text>
        </Pressable>
      </View>

      <View className="px-5 pb-0">
        <Input placeholder="Search exercises..." value={search} onChangeText={setSearch} />
      </View>

      <CategoryFilter selected={category} onSelect={setCategory} />

      <View className="flex-1 bg-white">
        {loading ? (
          <ActivityIndicator color="#6366F1" style={{ marginTop: 40 }} />
        ) : (
          <FlatList
            data={exercises}
            keyExtractor={(e) => e.id.toString()}
            ListEmptyComponent={
              <EmptyState title="No exercises found" subtitle="Add exercises to your library" icon="🏋️" />
            }
            renderItem={({ item }) => <ExerciseListItem exercise={item} />}
          />
        )}
      </View>
    </SafeAreaView>
  );
}
