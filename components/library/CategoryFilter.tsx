import React from 'react';
import { ScrollView, Pressable, Text } from 'react-native';
import clsx from 'clsx';
import { CATEGORIES } from '../../constants/theme';

interface CategoryFilterProps {
  selected: string | null;
  onSelect: (cat: string | null) => void;
}

export function CategoryFilter({ selected, onSelect }: CategoryFilterProps) {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={{ paddingHorizontal: 16, paddingTop: 6, paddingBottom: 8, gap: 8, alignItems: 'center' }}
    >
      {(['All', ...CATEGORIES] as const).map((cat) => {
        const isAll = cat === 'All';
        const isSelected = isAll ? selected === null : selected === cat;
        return (
          <Pressable
            key={cat}
            onPress={() => onSelect(isAll ? null : (cat === selected ? null : cat))}
            className={clsx('rounded-full active:opacity-70', isSelected ? 'bg-primary' : 'bg-white')}
            style={{ paddingHorizontal: 14, paddingVertical: 7 }}
          >
            <Text className={clsx('text-sm font-semibold', isSelected ? 'text-white' : 'text-slate-500')}>
              {cat}
            </Text>
          </Pressable>
        );
      })}
    </ScrollView>
  );
}
