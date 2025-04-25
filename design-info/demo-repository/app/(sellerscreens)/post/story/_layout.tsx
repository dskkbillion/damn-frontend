import headerComponent from "@/components/headerShown";
import { Stack } from "expo-router";

export default function PostStoryLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="storyEdit"
        options={{
          headerShown: true,
          headerTitle: "我的故事",
          header: () => headerComponent({ title: "我的故事", canBack: true }),
        }}
      />
    </Stack>
  );
}
