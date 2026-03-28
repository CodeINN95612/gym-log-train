import React, { useState } from 'react';
import { View, Text, ScrollView, Alert, Pressable } from 'react-native';
import { useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { addExercise } from '../../db/library';
import { CATEGORIES } from '../../constants/theme';
import clsx from 'clsx';

export default function AddExerciseModal() {
  const router = useRouter();
  const db = useSQLiteContext();
  const [name, setName] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return; }
    setSaving(true);
    try {
      await addExercise(db, name.trim(), category);
      router.back();
    } catch (e: any) {
      if (e?.message?.includes('UNIQUE')) {
        Alert.alert('Duplicate', 'An exercise with this name already exists.');
      } else {
        Alert.alert('Error', 'Could not save exercise');
      }
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1 px-4 pt-6" keyboardShouldPersistTaps="handled" contentContainerClassName="pb-10">
        <Input label="Exercise Name" value={name} onChangeText={setName} placeholder="e.g. Bench Press" error={error} autoFocus />
        <Text className="text-sm font-medium text-slate-700 mt-4 mb-2">Category (optional)</Text>
        <View className="flex-row flex-wrap gap-2">
          {CATEGORIES.map((cat) => (
            <Pressable
              key={cat}
              onPress={() => setCategory(cat === category ? null : cat)}
              className={clsx('px-3 py-2 rounded-xl border', category === cat ? 'bg-primary border-primary' : 'bg-white border-border')}
            >
              <Text className={clsx('text-sm font-medium', category === cat ? 'text-white' : 'text-slate-600')}>{cat}</Text>
            </Pressable>
          ))}
        </View>
        <View className="mt-6">
          <Button label="Save Exercise" onPress={handleSave} loading={saving} fullWidth />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
