import React from 'react';
import { View, Text } from 'react-native';
import clsx from 'clsx';

const CATEGORY_COLORS: Record<string, string> = {
  Chest: 'bg-blue-100 text-blue-700',
  Back: 'bg-green-100 text-green-700',
  Shoulders: 'bg-purple-100 text-purple-700',
  Arms: 'bg-orange-100 text-orange-700',
  Legs: 'bg-red-100 text-red-700',
  Core: 'bg-yellow-100 text-yellow-700',
  Cardio: 'bg-pink-100 text-pink-700',
  'Full Body': 'bg-teal-100 text-teal-700',
  Other: 'bg-slate-100 text-slate-600',
};

export function Badge({ label }: { label: string }) {
  const colors = CATEGORY_COLORS[label] ?? 'bg-slate-100 text-slate-600';
  return (
    <View className={clsx('px-2 py-0.5 rounded-full', colors.split(' ')[0])}>
      <Text className={clsx('text-xs font-medium', colors.split(' ')[1])}>{label}</Text>
    </View>
  );
}
