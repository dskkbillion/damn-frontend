import { Stack } from "expo-router";
import headerComponent from "@/components/headerShown";
export default function DemandLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="detail"
        options={{
          headerShown: true,
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
