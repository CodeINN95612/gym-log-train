import '../global.css';
import React from 'react';
import { Stack } from 'expo-router';
import { SQLiteProvider } from 'expo-sqlite';
import { migrateDb } from '../db/migrations';

export default function RootLayout() {
  return (
    <SQLiteProvider databaseName="gymlog.db" onInit={migrateDb}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="trainees/new" options={{ presentation: 'modal', title: 'New Trainee' }} />
        <Stack.Screen name="trainees/[id]" options={{ headerShown: false }} />
        <Stack.Screen name="modals/exercise-picker" options={{ presentation: 'modal', title: 'Add Exercises' }} />
        <Stack.Screen name="modals/add-exercise" options={{ presentation: 'modal', title: 'New Exercise' }} />
      </Stack>
    </SQLiteProvider>
  );
}
