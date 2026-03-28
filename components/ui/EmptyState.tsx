import React from 'react';
import { View, Text } from 'react-native';

interface EmptyStateProps {
  title: string;
  subtitle?: string;
  icon?: string;
}

export function EmptyState({ title, subtitle, icon = '📋' }: EmptyStateProps) {
  return (
    <View className="flex-1 items-center justify-center py-20 px-6">
      <View className="w-20 h-20 rounded-3xl bg-indigo-50 items-center justify-center mb-5">
        <Text className="text-4xl">{icon}</Text>
      </View>
      <Text className="text-lg font-bold text-slate-800 text-center">{title}</Text>
      {subtitle && <Text className="text-sm text-muted text-center mt-2 leading-5">{subtitle}</Text>}
    </View>
  );
}
