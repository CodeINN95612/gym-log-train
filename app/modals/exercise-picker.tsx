import React, { useState } from 'react';
import { FlatList, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLibrary } from '../../hooks/useLibrary';
import { CategoryFilter } from '../../components/library/CategoryFilter';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { Badge } from '../../components/ui/Badge';
import { addExerciseToPlanDay } from '../../db/plans';
import { addExerciseToSession } from '../../db/exercise-logs';
import clsx from 'clsx';

export default function ExercisePickerModal() {
  const { mode, targetId } = useLocalSearchParams<{ mode: 'session' | 'plan'; targetId: string }>();
  const router = useRouter();
  const db = useSQLiteContext();
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [saving, setSaving] = useState(false);
  const { exercises, loading } = useLibrary(search, category);

  const toggle = (id: number) => {
    setSelected((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const handleConfirm = async () => {
    if (selected.size === 0) { router.back(); return; }
    setSaving(true);
    try {
      for (const exId of selected) {
        if (mode === 'plan') {
          await addExerciseToPlanDay(db, parseInt(targetId), exId);
        } else {
          await addExerciseToSession(db, parseInt(targetId), exId);
        }
      }
      router.back();
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <View className="px-4 pt-4 pb-2">
        <Input placeholder="Search..." value={search} onChangeText={setSearch} />
      </View>
      <CategoryFilter selected={category} onSelect={setCategory} />
      {loading ? (
        <ActivityIndicator className="mt-8" />
      ) : (
        <FlatList
          data={exercises}
          keyExtractor={(e) => e.id.toString()}
          renderItem={({ item }) => {
            const isSelected = selected.has(item.id);
            return (
              <Pressable
                onPress={() => toggle(item.id)}
                className={clsx('flex-row items-center px-4 py-3 border-b border-border active:bg-slate-50', isSelected && 'bg-blue-50')}
              >
                <View className={clsx('w-5 h-5 rounded border mr-3 items-center justify-center', isSelected ? 'bg-primary border-primary' : 'border-slate-300')}>
                  {isSelected && <Text className="text-white text-xs font-bold">✓</Text>}
                </View>
                <View className="flex-1 gap-1">
                  <Text className="text-base text-slate-900 font-medium">{item.name}</Text>
                  {item.category ? <Badge label={item.category} /> : null}
                </View>
              </Pressable>
            );
          }}
        />
      )}
      <View className="px-4 py-4 bg-white border-t border-border">
        <Button
          label={selected.size > 0 ? `Add ${selected.size} Exercise${selected.size > 1 ? 's' : ''}` : 'Done'}
          onPress={handleConfirm}
          loading={saving}
          fullWidth
        />
      </View>
    </SafeAreaView>
  );
}
