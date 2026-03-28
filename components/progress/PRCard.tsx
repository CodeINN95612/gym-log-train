import React from 'react';
import { View, Text } from 'react-native';
import { ExercisePR } from '../../types';

interface PRCardProps {
  pr: ExercisePR;
}

export function PRCard({ pr }: PRCardProps) {
  const headline = pr.pr_weight != null
    ? `${pr.pr_weight % 1 === 0 ? pr.pr_weight : pr.pr_weight.toFixed(1)} kg`
    : pr.pr_reps != null
    ? `${pr.pr_reps} reps`
    : pr.pr_duration != null
    ? `${pr.pr_duration}s`
    : '—';

  const subline = pr.pr_1rm != null
    ? `Est. 1RM ${Math.round(pr.pr_1rm)} kg`
    : `${pr.session_count} session${pr.session_count !== 1 ? 's' : ''}`;

  return (
    <View
      className="bg-white rounded-2xl mr-3 p-4"
      style={{ width: 148, shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }}
    >
      <View className="w-8 h-8 rounded-xl bg-indigo-50 items-center justify-center mb-2">
        <Text style={{ fontSize: 16 }}>🏆</Text>
      </View>
      <Text className="text-2xl font-bold text-indigo-600" numberOfLines={1}>{headline}</Text>
      <Text className="text-xs text-muted mt-0.5" numberOfLines={1}>{subline}</Text>
      <Text className="text-sm font-semibold text-slate-700 mt-2" numberOfLines={2}>{pr.exercise_name}</Text>
    </View>
  );
}
