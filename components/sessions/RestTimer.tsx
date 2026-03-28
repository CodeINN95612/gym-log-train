import React from 'react';
import { View, Text, Pressable } from 'react-native';
import clsx from 'clsx';

const PRESETS = [
  { label: '1:00', seconds: 60 },
  { label: '1:30', seconds: 90 },
  { label: '2:00', seconds: 120 },
  { label: '3:00', seconds: 180 },
];

interface RestTimerProps {
  remaining: number;
  total: number;
  selectedDuration: number;
  onSkip: () => void;
  onAddTime: () => void;
  onChangeDuration: (seconds: number) => void;
}

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
}

export function RestTimer({ remaining, total, selectedDuration, onSkip, onAddTime, onChangeDuration }: RestTimerProps) {
  const progress = total > 0 ? remaining / total : 0;
  const isLow = remaining <= 10;

  return (
    <View className="bg-white border-b border-surface">
      {/* Progress bar */}
      <View className="h-1 bg-slate-100 w-full">
        <View
          className={clsx('h-1', isLow ? 'bg-amber-400' : 'bg-primary')}
          style={{ width: `${progress * 100}%` }}
        />
      </View>

      <View className="px-4 py-3">
        {/* Top row: label + skip */}
        <View className="flex-row items-center justify-between mb-2">
          <Text className="text-xs font-semibold text-muted uppercase tracking-wider">Rest Timer</Text>
          <Pressable onPress={onSkip} className="active:opacity-60">
            <Text className="text-xs font-semibold text-primary">Skip</Text>
          </Pressable>
        </View>

        {/* Countdown + +30 */}
        <View className="flex-row items-center justify-between mb-3">
          <Pressable
            onPress={onAddTime}
            className="bg-indigo-50 rounded-xl active:opacity-70"
            style={{ paddingHorizontal: 14, paddingVertical: 8 }}
          >
            <Text className="text-sm font-bold text-primary">+30s</Text>
          </Pressable>

          <Text
            className={clsx('text-4xl font-bold tabular-nums', isLow ? 'text-amber-500' : 'text-slate-800')}
          >
            {formatTime(remaining)}
          </Text>

          {/* spacer to balance the layout */}
          <View style={{ width: 58 }} />
        </View>

        {/* Preset buttons */}
        <View className="flex-row gap-2">
          {PRESETS.map((p) => (
            <Pressable
              key={p.seconds}
              onPress={() => onChangeDuration(p.seconds)}
              className={clsx(
                'flex-1 py-2 rounded-xl items-center active:opacity-70',
                selectedDuration === p.seconds ? 'bg-primary' : 'bg-slate-100'
              )}
            >
              <Text className={clsx('text-xs font-bold', selectedDuration === p.seconds ? 'text-white' : 'text-slate-500')}>
                {p.label}
              </Text>
            </Pressable>
          ))}
        </View>
      </View>
    </View>
  );
}
