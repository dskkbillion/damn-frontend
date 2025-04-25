import { Stack } from "expo-router";
import HeaderComponent from "@/components/headerShown";

export default function DemandTypeLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="demand_list"
        options={{
          headerShown: true,
          headerTitle: "申请列表",
          header: () => HeaderComponent({ title: "申请列表", canBack: true }),
        }}
      />
    </Stack>
  );
}
