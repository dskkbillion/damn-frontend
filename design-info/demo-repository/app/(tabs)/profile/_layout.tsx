import { Stack } from "expo-router";

import headerComponent from "@/components/headerShown";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function ProfileBuyerLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: false,
          headerTransparent: false,
        }}
      />

      <Stack.Screen
        name="saved_list"
        options={{
          headerShown: true,
          headerTitle: "我的收藏",
          header: () => headerComponent({ title: "我的收藏", canBack: true }),
        }}
      />
      <Stack.Screen
        name="likedStory"
        options={{
          headerShown: false,
          headerTitle: "",
        }}
      />
      <Stack.Screen
        name="notification"
        options={{
          headerShown: true,
          headerTitle: "消息通知",
          header: () => headerComponent({ title: "消息通知", canBack: true }),
        }}
      />
      <Stack.Screen
        name="accountSafe"
        options={{
          headerShown: false,
          headerTitle: "账户安全",
          header: () => headerComponent({ title: "账户安全", canBack: true }),
        }}
      />

      <Stack.Screen
        name="orders"
        options={{
          headerShown: false,
          headerTitle: "",
        }}
      />
    </Stack>
  );
}
