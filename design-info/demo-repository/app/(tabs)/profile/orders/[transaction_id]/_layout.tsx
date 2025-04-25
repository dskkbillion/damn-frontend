import { Stack } from "expo-router";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function HomePageLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: false,
        }}
      />

      <Stack.Screen
        name="[demand_id]"
        options={{
          headerShown: false,
          headerTitle: "需求",
        }}
      />

      <Stack.Screen
        name="rePostMaterials"
        options={{
          headerShown: true,
          headerTitle: "重传材料",
        }}
      />
    </Stack>
  );
}
