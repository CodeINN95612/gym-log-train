import React from 'react';
import { View, Text, Pressable } from 'react-native';
import { SessionExerciseWithSets } from '../../types';
import { Badge } from '../ui/Badge';
import { SetRow } from './SetRow';
import { Card } from '../ui/Card';

interface ExerciseLogBlockProps {
  item: SessionExerciseWithSets;
  isReadOnly: boolean;
  onAddSet: () => void;
  onUpdateSet: (setId: number, reps: number | null, weight: number | null, duration: number | null) => void;
  onDeleteSet: (setId: number) => void;
  onRemoveExercise: () => void;
}

export function ExerciseLogBlock({ item, isReadOnly, onAddSet, onUpdateSet, onDeleteSet, onRemoveExercise }: ExerciseLogBlockProps) {
  return (
    <Card className="mb-3">
      <View className="flex-row items-start justify-between mb-2">
        <View className="flex-1 gap-1">
          <Text className="text-base font-semibold text-slate-900">{item.exercise_name}</Text>
          {item.exercise_category ? <Badge label={item.exercise_category} /> : null}
        </View>
        {!isReadOnly && (
          <Pressable onPress={onRemoveExercise} className="p-1 active:opacity-60">
            <Text className="text-danger text-xs">Remove</Text>
          </Pressable>
        )}
      </View>
      {item.sets.length > 0 ? (
        <>
          {item.sets.map((s) => (
            <SetRow
              key={s.id}
              set={s}
              isReadOnly={isReadOnly}
              onUpdate={(r, w, d) => onUpdateSet(s.id, r, w, d)}
              onDelete={() => onDeleteSet(s.id)}
            />
          ))}
        </>
      ) : (
        <Text className="text-sm text-muted italic py-1">No sets yet</Text>
      )}
      {!isReadOnly && (
        <Pressable
          onPress={onAddSet}
          className="mt-2 border border-dashed border-primary rounded-lg py-2 items-center active:opacity-60"
        >
          <Text className="text-sm text-primary font-medium">+ Add Set</Text>
        </Pressable>
      )}
    </Card>
  );
}
