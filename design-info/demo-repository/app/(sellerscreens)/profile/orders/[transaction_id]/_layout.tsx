import { Stack } from "expo-router";

import headerComponent from "@/components/headerShown";

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
          headerTitle: "",
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
        name="reDelivery"
        options={{
          headerShown: true,
          headerTitle: "重新交付",
          header: () =>
            headerComponent({
              title: "重新交付",
              canBack: true,
            }),
        }}
      />
    </Stack>
  );
}
