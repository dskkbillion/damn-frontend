import { Stack } from "expo-router";
import React from "react";

export default function OuterLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="home"
        options={{ headerShown: false, gestureEnabled: true }}
      />
      <Stack.Screen name="about" options={{ headerShown: false }} />
      <Stack.Screen name="chatroom" options={{ headerShown: true }} />
      <Stack.Screen name="order" options={{ headerShown: false }} />
      <Stack.Screen name="reminder" options={{ headerShown: false }} />
      <Stack.Screen
        name="login"
        options={{ headerShown: false, gestureEnabled: false }}
      />
    </Stack>
  );
}
