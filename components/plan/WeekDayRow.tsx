import React from 'react';
import { View, Text, Pressable } from 'react-native';
import clsx from 'clsx';
import { WEEKDAY_NAMES } from '../../utils/weekdays';
import { PlanDayWithExercises } from '../../hooks/usePlan';

interface WeekDayRowProps {
  weekday: number;
  planDay: PlanDayWithExercises | undefined;
  onPress: () => void;
}

export function WeekDayRow({ weekday, planDay, onPress }: WeekDayRowProps) {
  const hasDay = !!planDay;
  return (
    <Pressable
      onPress={onPress}
      className={clsx(
        'flex-row items-center px-4 py-3 border-b border-border bg-white active:bg-slate-50',
      )}
    >
      <View className={clsx('w-10 h-10 rounded-full items-center justify-center mr-3', hasDay ? 'bg-primary' : 'bg-slate-100')}>
        <Text className={clsx('text-sm font-bold', hasDay ? 'text-white' : 'text-muted')}>
          {WEEKDAY_NAMES[weekday].slice(0, 2)}
        </Text>
      </View>
      <View className="flex-1">
        <Text className="text-base font-medium text-slate-900">{WEEKDAY_NAMES[weekday]}</Text>
        {hasDay ? (
          <Text className="text-sm text-muted">
            {planDay.label ? `${planDay.label} · ` : ''}{planDay.exercises.length} exercise{planDay.exercises.length !== 1 ? 's' : ''}
          </Text>
        ) : (
          <Text className="text-sm text-muted">Rest day — tap to add</Text>
        )}
      </View>
      <Text className="text-muted">›</Text>
    </Pressable>
  );
}
