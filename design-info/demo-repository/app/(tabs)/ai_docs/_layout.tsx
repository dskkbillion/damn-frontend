import { Stack } from "expo-router";
import React from "react";

import { BottomSheetProvider } from "@/components/ai_doc/bottom-sheet-context";
import headerComponent from "@/components/headerShown";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function AiDocsLayout() {
  return (
    <BottomSheetProvider>
      <Stack
        screenOptions={{
          headerStyle: {
            backgroundColor: "#FFF8F4",
          },
          headerBackVisible: true,
          headerBackTitle: "返回",
        }}
      >
        <Stack.Screen
          name="chat-view"
          options={{ headerTitle: "", headerShown: true }}
        />

        <Stack.Screen
          name="history"
          options={{
            headerTitle: "历史记录",
            headerShown: true,
            headerBackVisible: true,
            headerBackTitle: "返回",
          }}
        />

        <Stack.Screen
          name="[id]"
          options={{
            headerShown: false,
          }}
        />
      </Stack>
    </BottomSheetProvider>
  );
}
