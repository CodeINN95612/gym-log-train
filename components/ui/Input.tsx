import React from 'react';
import { TextInput, Text, View, TextInputProps } from 'react-native';
import clsx from 'clsx';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
}

export function Input({ label, error, className, ...props }: InputProps) {
  return (
    <View className="gap-1">
      {label && <Text className="text-sm font-medium text-slate-700">{label}</Text>}
      <TextInput
        className={clsx(
          'border border-border rounded-xl px-3 py-3 text-base text-slate-900 bg-white',
          error && 'border-danger',
          className,
        )}
        placeholderTextColor="#94A3B8"
        {...props}
      />
      {error && <Text className="text-xs text-danger">{error}</Text>}
    </View>
  );
}
