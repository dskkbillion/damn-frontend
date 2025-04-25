import headerComponent from "@/components/headerShown";
import { Stack } from "expo-router";

export default function DemandLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="detail"
        options={{
          headerShown: true,
          headerTitle: "需求详情",
          header: () => headerComponent({ title: "需求详情", canBack: true }),
        }}
      />
      <Stack.Screen
        name="[demand_type]"
        options={{
          headerShown: false,
        }}
      />
    </Stack>
  );
}
