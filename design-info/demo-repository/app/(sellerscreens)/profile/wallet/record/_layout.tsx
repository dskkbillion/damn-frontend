import headerComponent from "@/components/headerShown";
import { Stack } from "expo-router";

export default function RecordLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="recordPage"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "明细", canBack: true }),
        }}
      />
      <Stack.Screen
        name="recordDetail"
        options={{
          headerShown: true,
          header: () => headerComponent({ title: "详情", canBack: true }),
        }}
      />
    </Stack>
  );
}
