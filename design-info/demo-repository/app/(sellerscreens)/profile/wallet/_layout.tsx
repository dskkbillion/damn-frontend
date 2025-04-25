import { Stack } from "expo-router";
import React from "react";

import headerComponent from "@/components/headerShown";

export default function WalletLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="walletPage"
        options={{
          headerShown: true,
          headerTitle: "我的钱包",
          header: () => headerComponent({ title: "我的钱包", canBack: true }),
        }}
      />

      {/* orders -> [transcation_id] -> [application] */}
      <Stack.Screen
        name="record"
        options={{
          headerShown: false,
        }}
      />

      <Stack.Screen
        name="cards"
        options={{
          headerShown: true,
          headerTitle: "银行卡管理",
          header: () => headerComponent({ title: "银行卡管理", canBack: true }),
        }}
      />
    </Stack>
  );
}
