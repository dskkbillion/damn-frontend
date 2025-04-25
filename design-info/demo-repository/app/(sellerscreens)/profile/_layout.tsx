import { Stack } from "expo-router";
import React from "react";

import headerComponent from "@/components/headerShown";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function ProfileSellerLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: false,
          headerTransparent: false,
        }}
      />

      {/* orders -> [transcation_id] -> [application] */}
      <Stack.Screen
        name="orders"
        options={{
          headerShown: false,
          headerTitle: "订单管理",
          header: () => headerComponent({ title: "订单管理", canBack: true }),
        }}
      />

      <Stack.Screen
        name="authentication"
        options={{
          headerShown: false,
          headerTitle: "认证管理",
          header: () => headerComponent({ title: "认证管理", canBack: true }),
        }}
      />

      <Stack.Screen
        name="wallet"
        options={{
          headerShown: false,
        }}
      />

      <Stack.Screen
        name="notification"
        options={{
          headerShown: false,
        }}
      />

      <Stack.Screen
        name="timeManage"
        options={{
          headerShown: true,
          headerTitle: "时间管理",
          header: () => headerComponent({ title: "时间管理", canBack: true }),
        }}
      />
    </Stack>
  );
}
