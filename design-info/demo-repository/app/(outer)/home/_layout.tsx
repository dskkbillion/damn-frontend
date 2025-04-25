import { ChevronLeft } from "@tamagui/lucide-icons";
import { Stack, useRouter } from "expo-router";
import { TouchableOpacity } from "react-native";
import { Button } from "tamagui";

import headerComponent from "@/components/headerShown";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function HomePageLayout() {
  return (
    <Stack>
      {/* 服务筛选页 */}
      <Stack.Screen
        name="itemHomepage"
        options={{
          headerShown: false,
          headerTitle: "id",
          animation: "simple_push",
        }}
      />
      {/* 评论页 */}
      <Stack.Screen
        name="review"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "评论", canBack: true }),
        }}
      />
      {/* 用户信息页 */}
      <Stack.Screen
        name="user_profile"
        options={{
          headerShown: false,
          animation: "simple_push",
        }}
      />

      {/* 我的故事 */}
      <Stack.Screen
        name="mystory"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "我的故事", canBack: true }),
        }}
      />
    </Stack>
  );
}
