import { ChevronLeft } from "@tamagui/lucide-icons";
import { Stack, useRouter } from "expo-router";
import { TouchableOpacity } from "react-native";
import { Button } from "tamagui";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function AiDocsProfileLayout() {
  const router = useRouter();
  return (
    <Stack>
      <Stack.Screen
        name="index"
        // getId={({ params }) => params?.doc_id}
        options={{
          headerShown: false,
          headerTransparent: false,
          headerTitle: "项目管理",
          headerLeft: () => (
            <Button
              onPress={() => {
                router.push("/(tabs)/ai_docs/load_portrait");
              }}
              size="$1"
              backgroundColor="transparent"
              pressStyle={{
                backgroundColor: "transparent",
                borderColor: "transparent",
                opacity: 0.8,
              }}
            >
              <ChevronLeft color="#4285F6" />
            </Button>
          ),
        }}
      />

      <Stack.Screen
        name="[match_id]"
        // getId={({ params }) => params?.doc_id}
        options={{
          headerShown: false,
          headerTransparent: false,
          headerTitle: "",
          headerLeft: () => (
            <Button
              onPress={() => {
                router.back();
              }}
              size="$1"
              backgroundColor="transparent"
              pressStyle={{
                backgroundColor: "transparent",
                borderColor: "transparent",
                opacity: 0.8,
              }}
            >
              <ChevronLeft color="#4285F6" />
            </Button>
          ),
        }}
      />
      <Stack.Screen
        name="doc_detail"
        options={{
          presentation: "transparentModal",
          animation: "fade",
          headerTransparent: true,
          headerLeft: () => (
            <Button
              onPress={() => {
                router.back();
              }}
              size="$1"
              backgroundColor="transparent"
              pressStyle={{
                backgroundColor: "transparent",
                borderColor: "transparent",
                opacity: 0.8,
              }}
            >
              <ChevronLeft color="#4285F6" />
            </Button>
          ),
        }}
      />
    </Stack>
  );
}
