import React, { useState } from 'react';
import { View, Text, TextInput, Pressable } from 'react-native';
import { ExerciseSet } from '../../types';

interface SetRowProps {
  set: ExerciseSet;
  isReadOnly: boolean;
  onUpdate: (reps: number | null, weight: number | null, duration: number | null) => void;
  onDelete: () => void;
}

export function SetRow({ set, isReadOnly, onUpdate, onDelete }: SetRowProps) {
  const [reps, setReps] = useState(set.reps?.toString() ?? '');
  const [weight, setWeight] = useState(set.weight_kg?.toString() ?? '');
  const [duration, setDuration] = useState(set.duration_seconds?.toString() ?? '');

  const handleBlur = () => {
    onUpdate(
      reps ? parseInt(reps) : null,
      weight ? parseFloat(weight) : null,
      duration ? parseInt(duration) : null,
    );
  };

  return (
    <View className="flex-row items-center gap-2 py-1.5">
      <Text className="text-sm font-bold text-muted w-6">{set.set_number}</Text>
      <View className="flex-row gap-2 flex-1">
        <View className="flex-1 items-center">
          <Text className="text-xs text-muted mb-1">Reps</Text>
          <TextInput
            className="border border-border rounded-lg px-2 py-1.5 text-sm text-center bg-white w-full"
            value={reps}
            onChangeText={setReps}
            onBlur={handleBlur}
            keyboardType="number-pad"
            editable={!isReadOnly}
            placeholderTextColor="#94A3B8"
            placeholder="—"
          />
        </View>
        <View className="flex-1 items-center">
          <Text className="text-xs text-muted mb-1">kg</Text>
          <TextInput
            className="border border-border rounded-lg px-2 py-1.5 text-sm text-center bg-white w-full"
            value={weight}
            onChangeText={setWeight}
            onBlur={handleBlur}
            keyboardType="decimal-pad"
            editable={!isReadOnly}
            placeholderTextColor="#94A3B8"
            placeholder="—"
          />
        </View>
        <View className="flex-1 items-center">
          <Text className="text-xs text-muted mb-1">Sec</Text>
          <TextInput
            className="border border-border rounded-lg px-2 py-1.5 text-sm text-center bg-white w-full"
            value={duration}
            onChangeText={setDuration}
            onBlur={handleBlur}
            keyboardType="number-pad"
            editable={!isReadOnly}
            placeholderTextColor="#94A3B8"
            placeholder="—"
          />
        </View>
      </View>
      {!isReadOnly && (
        <Pressable onPress={onDelete} className="p-1 active:opacity-60 ml-1">
          <Text className="text-danger font-bold text-base">×</Text>
        </Pressable>
      )}
    </View>
  );
}
