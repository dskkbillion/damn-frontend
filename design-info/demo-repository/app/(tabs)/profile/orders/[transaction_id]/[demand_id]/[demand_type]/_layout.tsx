import { BackButton } from "@/components/styled/back_button";
import { Stack } from "expo-router";
import headerComponent from "@/components/headerShown";

export default function DemandTypeLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="demand_list"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "申请列表", canBack: true }),
        }}
      />
    </Stack>
  );
}
