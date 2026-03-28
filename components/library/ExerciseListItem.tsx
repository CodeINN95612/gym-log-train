import React from 'react';
import { View, Text, Pressable } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Exercise } from '../../types';
import { Badge } from '../ui/Badge';

interface ExerciseListItemProps {
  exercise: Exercise;
  onPress?: () => void;
  rightElement?: React.ReactNode;
}

export function ExerciseListItem({ exercise, onPress, rightElement }: ExerciseListItemProps) {
  return (
    <Pressable
      onPress={onPress}
      className="flex-row items-center px-4 py-3.5 bg-white border-b border-surface active:bg-slate-50"
    >
      <View className="w-9 h-9 rounded-xl bg-indigo-50 items-center justify-center mr-3">
        <Ionicons name="fitness-outline" size={18} color="#6366F1" />
      </View>
      <View className="flex-1 gap-1">
        <Text className="text-base text-slate-800 font-medium">{exercise.name}</Text>
        {exercise.category ? <Badge label={exercise.category} /> : null}
      </View>
      {rightElement ?? <Ionicons name="chevron-forward" size={16} color="#CBD5E1" />}
    </Pressable>
  );
}
