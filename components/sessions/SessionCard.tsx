import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Session } from '../../types';
import { formatDate } from '../../utils/date';

interface SessionCardProps {
  session: Session;
  onPress: () => void;
}

export function SessionCard({ session, onPress }: SessionCardProps) {
  const isEnded = !!session.ended_at;

  return (
    <Pressable
      onPress={onPress}
      className="mb-3 rounded-2xl bg-white active:opacity-75"
      style={{ shadowColor: '#64748B', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.08, shadowRadius: 8, elevation: 3 }}
    >
      <View className="flex-row items-center px-4 py-3.5">
        <View className={`w-10 h-10 rounded-xl items-center justify-center mr-3 ${isEnded ? 'bg-emerald-50' : 'bg-amber-50'}`}>
          <Ionicons name={isEnded ? 'checkmark-circle' : 'time-outline'} size={22} color={isEnded ? '#10B981' : '#F59E0B'} />
        </View>
        <View className="flex-1">
          <Text className="text-base font-semibold text-slate-800">{formatDate(session.date)}</Text>
          {session.notes ? (
            <Text className="text-sm text-muted mt-0.5" numberOfLines={1}>{session.notes}</Text>
          ) : (
            <Text className="text-sm text-muted mt-0.5">{isEnded ? 'Completed' : 'In progress'}</Text>
          )}
        </View>
        <Ionicons name="chevron-forward" size={18} color="#CBD5E1" />
      </View>
    </Pressable>
  );
}
