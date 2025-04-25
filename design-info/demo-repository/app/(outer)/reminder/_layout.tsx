import { Stack } from "expo-router";
import React from "react";

export default function ReminderLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="error"
        options={{ headerShown: false, gestureEnabled: false }}
      />
      <Stack.Screen
        name="payment"
        options={{ headerShown: false, gestureEnabled: false }}
      />
    </Stack>
  );
}
