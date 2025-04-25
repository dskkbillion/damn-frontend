import { ChevronLeft } from "@tamagui/lucide-icons";
import { zIndex } from "@tamagui/themes";
import { Stack, router } from "expo-router";
import { Button, H1, Input, XStack } from "tamagui";

// export const unstable_settings = {
//   initialRouteName: "index",
// };

export default function AiDocsLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{ headerTitle: "主页", headerShown: false }}
      />

      <Stack.Screen
        name="search"
        options={{
          headerShown: false,
          headerTitle: "",
          animation: "fade",
        }}
      />

      <Stack.Screen
        name="searchResult"
        options={{
          headerShown: false,
          headerTitle: "",
          animation: "fade",
        }}
      />
    </Stack>
  );
}
