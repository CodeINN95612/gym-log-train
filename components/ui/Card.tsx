import React from 'react';
import { View, ViewProps } from 'react-native';
import clsx from 'clsx';

interface CardProps extends ViewProps {
  children: React.ReactNode;
  className?: string;
}

export function Card({ children, className, style, ...props }: CardProps) {
  return (
    <View
      className={clsx('bg-white rounded-2xl p-4', className)}
      style={[{ shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }, style]}
      {...props}
    >
      {children}
    </View>
  );
}
