import { Stack, useSegments } from "expo-router";

import headerComponent from "@/components/headerShown";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function AccountSecurityLayout() {
  const segments = useSegments();
  return (
    <Stack>
      <Stack.Screen
        name="aboutUs"
        options={{
          headerShown: true,
          headerTitle: "关于我们",
          header: () => headerComponent({ title: "关于我们", canBack: true }),
        }}
      />
      <Stack.Screen
        name="privacy"
        options={{
          headerShown: true,
          headerTitle: "隐私协议",
          header: () => headerComponent({ title: "隐私协议", canBack: true }),
        }}
      />
      <Stack.Screen
        name="payment"
        options={{
          headerShown: true,
          headerTitle: "支付协议",
          header: () => headerComponent({ title: "支付协议", canBack: true }),
        }}
      />
    </Stack>
  );
}
