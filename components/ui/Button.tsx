import React from 'react';
import { Pressable, Text, ActivityIndicator } from 'react-native';
import clsx from 'clsx';

interface ButtonProps {
  label: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
}

export function Button({ label, onPress, variant = 'primary', size = 'md', disabled, loading, fullWidth }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      className={clsx(
        'items-center justify-center rounded-xl',
        size === 'sm' && 'px-3 py-1.5',
        size === 'md' && 'px-4 py-3',
        size === 'lg' && 'px-6 py-4',
        variant === 'primary' && 'bg-primary active:bg-primary-dark',
        variant === 'secondary' && 'bg-slate-100 active:bg-slate-200',
        variant === 'danger' && 'bg-danger active:bg-red-600',
        variant === 'ghost' && 'bg-transparent',
        (disabled || loading) && 'opacity-50',
        fullWidth && 'w-full',
      )}
    >
      {loading ? (
        <ActivityIndicator color={variant === 'primary' || variant === 'danger' ? 'white' : '#6366F1'} />
      ) : (
        <Text className={clsx(
          'font-semibold',
          size === 'sm' && 'text-sm',
          size === 'md' && 'text-base',
          size === 'lg' && 'text-lg',
          variant === 'primary' && 'text-white',
          variant === 'secondary' && 'text-slate-700',
          variant === 'danger' && 'text-white',
          variant === 'ghost' && 'text-primary',
        )}>
          {label}
        </Text>
      )}
    </Pressable>
  );
}
