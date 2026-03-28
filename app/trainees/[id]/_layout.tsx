import React from 'react';
import { Stack } from 'expo-router';

export default function TraineeLayout() {
  return (
    <Stack screenOptions={{ headerBackTitle: 'Back' }}>
      <Stack.Screen name="index" options={{ title: 'Trainee' }} />
      <Stack.Screen name="plan" options={{ title: 'Weekly Plan' }} />
      <Stack.Screen name="history" options={{ title: 'Session History' }} />
      <Stack.Screen name="session/new" options={{ title: 'Start Session' }} />
      <Stack.Screen name="session/[sessionId]/index" options={{ title: 'Session' }} />
      <Stack.Screen name="progress" options={{ title: 'Progress' }} />
    </Stack>
  );
}
