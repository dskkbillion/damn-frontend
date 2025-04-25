import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { useCallback, useEffect } from "react";
import { Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import Icon from "react-native-vector-icons/Ionicons";
import { Button, XStack, YStack } from "tamagui";

import {
  ButtonSwitchComp,
  RenderContentType,
} from "@/components/ButtonSwitchComp";
import ServiceAll from "@/components/orders/service_all";
import ServiceAwaitingStart from "@/components/orders/service_awaitingstart";
import ServiceInProgress from "@/components/orders/service_inprogress";
import ServicePostSale from "@/components/orders/service_postsale";
import ServiceToBeEvaluated from "@/components/orders/service_tobeevaluated";

export default function OrdersScreen() {
  const params = useLocalSearchParams<{
    type_id: string;
  }>();

  const initialIndex = params.type_id;

  const renderContent: RenderContentType = useCallback(
    ({ type }: { type: string }) => {
      switch (type) {
        case "全部":
          return <ServiceAll role="seller" />;
        // return <ServiceAll />;
        case "待确认":
          return <ServiceAwaitingStart />;
        // return <ServiceAwaitingStart />;
        case "进行中":
          return <ServiceInProgress role="seller" />;
        case "已交付":
          return <ServiceToBeEvaluated role="seller" />;
        case "售后":
          return <ServicePostSale role="seller" />;
        default:
          return <Text>0</Text>;
      }
    },
    []
  );

  useEffect(() => {
    console.log(1111111);
    // refresh
  }, [renderContent]);

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
            backgroundColor="#E8E8E8"
            width="90%"
            height="100%"
            borderRadius={5}
            marginLeft="$3"
            // marginLeft="auto"
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
              搜索订单...
            </Text>
          </Button>
        </XStack>

        <ButtonSwitchComp
          button_num={5}
          is_titled
          renderContent={renderContent}
          names={["全部", "待确认", "进行中", "已交付", "售后"]}
          initialIndex={initialIndex}
          fontSize={13}
          // fontSize={global.screenWidth < 480 ? 14 : 16}
        />
      </YStack>
    </SafeAreaView>
  );
}
