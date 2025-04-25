import { Stack } from "expo-router";

export default function OuterOrderLayout() {
  return (
    <Stack>
      <Stack.Screen name="refund" options={{ headerShown: false }} />
      <Stack.Screen name="detail" options={{ headerShown: false }} />
      <Stack.Screen name="application" options={{ headerShown: true }} />
    </Stack>
  );
}
