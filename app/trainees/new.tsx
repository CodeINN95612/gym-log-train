import React, { useState } from 'react';
import { View, Text, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { useSQLiteContext } from 'expo-sqlite';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Input } from '../../components/ui/Input';
import { Button } from '../../components/ui/Button';
import { addTrainee } from '../../db/trainees';

export default function NewTraineeScreen() {
  const router = useRouter();
  const db = useSQLiteContext();
  const [name, setName] = useState('');
  const [notes, setNotes] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const handleSave = async () => {
    if (!name.trim()) { setError('Name is required'); return; }
    setSaving(true);
    try {
      await addTrainee(db, name.trim(), notes.trim() || null);
      router.back();
    } catch {
      Alert.alert('Error', 'Could not save trainee');
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-surface" edges={['bottom']}>
      <ScrollView className="flex-1 px-4 pt-6" keyboardShouldPersistTaps="handled">
        <Input label="Full Name" value={name} onChangeText={setName} placeholder="e.g. John Smith" error={error} autoFocus />
        <View className="mt-4">
          <Input label="Notes (optional)" value={notes} onChangeText={setNotes} placeholder="e.g. Goals, injury history..." multiline numberOfLines={4} className="min-h-24" />
        </View>
        <View className="mt-6">
          <Button label="Save Trainee" onPress={handleSave} loading={saving} fullWidth />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
