import { ChevronLeft } from "@tamagui/lucide-icons";
import { Stack, router, useSegments } from "expo-router";
import { Button, H1, Paragraph, Separator, View, YStack } from "tamagui";

import headerComponent from "@/components/headerShown";

export default function AccountSecurityLayout() {
  const segments = useSegments();
  return (
    <Stack>
      <Stack.Screen
        name="accountSafePage"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "账户", canBack: true }),
        }}
      />
      <Stack.Screen
        name="EditNicknameScreen"
        options={{
          headerShown:
            segments && segments[segments.length - 1] === "EditNicknameScreen"
              ? true
              : false,
          headerTitle: "编辑昵称",
          header: () => headerComponent({ title: "编辑昵称", canBack: true }),
        }}
      />
      <Stack.Screen
        name="EditAvatarScreen"
        options={{
          headerShown:
            segments && segments[segments.length - 1] === "EditAvatarScreen"
              ? true
              : false,
          headerTitle: "编辑头像",
          header: () => headerComponent({ title: "编辑头像", canBack: true }),
        }}
      />

      <Stack.Screen
        name="deactivation"
        options={{
          header: () =>
            headerComponent({
              title: "账号注销",
              canBack: true,
            }),
        }}
      />
    </Stack>
  );
}
