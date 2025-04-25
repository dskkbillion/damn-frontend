import { Stack } from "expo-router";

export default function PostHomepageLayout() {
  return (
    <Stack>
      {/* 发布主页 */}
      <Stack.Screen
        name="index"
        options={{
          headerShown: false,
          headerTransparent: false,
        }}
      />
      {/* 发布服务页 */}
      <Stack.Screen
        name="[id]"
        options={{
          headerShown: false,
        }}
        getId={({ params }) => params?.id}
      />
      {/* 发布故事 */}
      <Stack.Screen
        name="story"
        options={{
          headerShown: false,
        }}
      />
    </Stack>
  );
}
