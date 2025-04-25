import { Stack } from "expo-router";

export type LoginLayoutParams = {
  source_page?: string;
};

export default function LoginLayout() {
  return (
    <Stack screenOptions={{ gestureEnabled: false }}>
      <Stack.Screen name="index" options={{ headerShown: false }} />
      <Stack.Screen name="mobile" options={{ headerShown: false }} />
      {/* <Stack.Screen name="auth_buttons" options={{ headerShown: false }} /> */}
      {/* <Stack.Screen name="wechat" options={{ headerShown: false }} /> */}
    </Stack>
  );
}

export const unstable_settings = {
  initialRouteName: 'index',
};
