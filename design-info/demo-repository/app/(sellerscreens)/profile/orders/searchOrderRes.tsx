import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import Icon from "react-native-vector-icons/Ionicons";
import { Button, XStack, YStack, Text } from "tamagui";

import ServiceAll from "@/components/orders/service_all";

export default function OrdersScreen() {
  const params = useLocalSearchParams();

  const search = params.search as string;
  return (
    <SafeAreaView style={{ backgroundColor: "#EDEDED" }}>
      <YStack
        height={global.screenHeight}
        width={global.screenWidth}
        backgroundColor="#F2F2F2"
      >
        {/* search box */}
        <XStack
          flexDirection="row"
          alignItems="center"
          height="$6"
          paddingVertical="$3"
          paddingHorizontal="$3"
        >
          <ChevronLeft
            color="#4285F6"
            onPress={() => {
              router.back();
            }}
          />

          <Button
            flexDirection="row"
            alignItems="center"
            justifyContent="center"
            backgroundColor="$seachBox"
            width="90%"
            height="100%"
            borderRadius={5}
            marginLeft="$3"
            onPress={() =>
              router.push("/(sellerscreens)/profile/orders/search")
            }
          >
            <Icon
              alignSelf="center"
              fontSize="$3"
              name="search"
              color="#A4A4A4"
            />
            <Text
              style={{
                flexDirection: "row",
                paddingHorizontal: 20,
                color: "gray",
              }}
            >
              {search}
            </Text>
          </Button>
        </XStack>
        <ServiceAll role="seller" search={search} />
      </YStack>
    </SafeAreaView>
  );
}
