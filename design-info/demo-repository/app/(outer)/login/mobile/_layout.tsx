import { Stack } from "expo-router";

export default function MobileLoginLayout() {
  return (
    <Stack>
      <Stack.Screen name="mobileLogin" options={{ headerShown: false }} />
      <Stack.Screen name="verifyCode" options={{ headerShown: false }} />
    </Stack>
  );
}

// 添加unstable_settings配置，确保初始路由正确设置
export const unstable_settings = {
  initialRouteName: 'mobileLogin',
};
