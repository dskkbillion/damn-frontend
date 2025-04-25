import { Stack, useLocalSearchParams } from "expo-router";
import React from "react";

import headerComponent from "@/components/headerShown";

export default function CertificationLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: true,
          headerTitle: "",
          header: () => headerComponent({ title: "认证管理", canBack: true }),
        }}
      />

      <Stack.Screen
        name="[application]"
        options={{
          headerShown: false,
        }}
      />
    </Stack>
  );
}
