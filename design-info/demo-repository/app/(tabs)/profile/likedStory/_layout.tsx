import { Stack } from "expo-router";

import headerComponent from "@/components/headerShown";

export default function LikedStoryLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="storyList"
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen
        name="story"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "故事详情", canBack: true }),
        }}
      />
    </Stack>
  );
}
