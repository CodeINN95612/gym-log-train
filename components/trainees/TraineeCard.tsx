import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Trainee } from '../../types';

interface TraineeCardProps {
  trainee: Trainee;
  onPress: () => void;
}

function getInitials(name: string) {
  return name.split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase();
}

const AVATAR_COLORS = [
  { bg: '#EEF2FF', text: '#6366F1' },
  { bg: '#FDF4FF', text: '#A855F7' },
  { bg: '#FFF7ED', text: '#F97316' },
  { bg: '#F0FDF4', text: '#22C55E' },
  { bg: '#FFF1F2', text: '#F43F5E' },
  { bg: '#F0F9FF', text: '#0EA5E9' },
];

export function TraineeCard({ trainee, onPress }: TraineeCardProps) {
  const colorIndex = trainee.id % AVATAR_COLORS.length;
  const { bg, text } = AVATAR_COLORS[colorIndex];

  return (
    <Pressable
      onPress={onPress}
      className="mb-3 rounded-2xl bg-white active:opacity-75"
      style={{ shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }}
    >
      <View className="flex-row items-center px-4 py-3.5">
        <View
          className="w-11 h-11 rounded-full items-center justify-center mr-3"
          style={{ backgroundColor: bg }}
        >
          <Text className="text-sm font-bold" style={{ color: text }}>{getInitials(trainee.name)}</Text>
        </View>
        <View className="flex-1">
          <Text className="text-base font-semibold text-slate-800">{trainee.name}</Text>
          {trainee.notes ? (
            <Text className="text-sm text-muted mt-0.5" numberOfLines={1}>{trainee.notes}</Text>
          ) : null}
        </View>
        <Ionicons name="chevron-forward" size={18} color="#CBD5E1" />
      </View>
    </Pressable>
  );
}
