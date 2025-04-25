import { ChevronLeft } from "@tamagui/lucide-icons";
import { Stack, router } from "expo-router";
import { Button } from "tamagui";

export const unstable_settings = {
  initialRouteName: "index",
};

export default function OrdersLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: false,
          headerTitle: "我的订单",
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
        name="postsale"
        options={{
          headerShown: true,
          headerTitle: "退款/售后",
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
        name="[transaction_id]"
        options={{
          headerShown: false,
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
        name="evaluation"
        options={{ headerShown: false, animation: "slide_from_right" }}
      />
      <Stack.Screen
        name="search"
        options={{ headerShown: false, animation: "fade" }}
      />
      <Stack.Screen name="searchOrderRes" options={{ headerShown: false }} />
    </Stack>
  );
}
