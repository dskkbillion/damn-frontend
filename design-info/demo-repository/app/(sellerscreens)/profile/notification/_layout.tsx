import { Stack } from "expo-router";
import React from "react";

import headerComponent from "@/components/headerShown";

export default function NotificationScreen() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: true,
          headerTransparent: false,
          header: () => headerComponent({ title: "消息通知", canBack: true }),
        }}
      />
      <Stack.Screen
        name="autoReply"
        options={{
          headerShown: true,
          headerTitle: "所有服务默认回复",
          header: () => headerComponent({ title: "设置", canBack: true }),
        }}
      />
    </Stack>
  );
}
