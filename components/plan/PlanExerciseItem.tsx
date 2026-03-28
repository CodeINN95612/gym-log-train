import React from 'react';
import { View, Text, Pressable } from 'react-native';
import { PlanDayExercise } from '../../types';
import { Badge } from '../ui/Badge';

interface PlanExerciseItemProps {
  item: PlanDayExercise;
  onRemove: () => void;
}

export function PlanExerciseItem({ item, onRemove }: PlanExerciseItemProps) {
  return (
    <View className="flex-row items-center px-4 py-3 bg-white border-b border-border">
      <View className="flex-1 gap-1">
        <Text className="text-base text-slate-900 font-medium">{item.exercise_name}</Text>
        {item.exercise_category ? <Badge label={item.exercise_category} /> : null}
        {item.notes ? <Text className="text-xs text-muted">{item.notes}</Text> : null}
      </View>
      <Pressable onPress={onRemove} className="ml-2 p-2 active:opacity-60">
        <Text className="text-danger text-lg font-bold">×</Text>
      </Pressable>
    </View>
  );
}
