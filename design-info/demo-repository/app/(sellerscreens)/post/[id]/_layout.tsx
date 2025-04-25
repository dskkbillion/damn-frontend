import { Stack } from "expo-router";

export default function PostServiceLayout() {
  return (
    <Stack>
      {/* 编辑区 */}
      <Stack.Screen
        name="itemEdit"
        options={{
          headerShown: false,
          headerTransparent: false,
        }}
      />
    </Stack>
  );
}
