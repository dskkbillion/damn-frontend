import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import Icon from "react-native-vector-icons/Ionicons";
import { Button, XStack, YStack } from "tamagui";

import {
  ButtonSwitchComp,
  RenderContentType,
} from "@/components/ButtonSwitchComp";
import ServiceAll from "@/components/orders/service_all";
import ServiceInProgress from "@/components/orders/service_inprogress";
import ServicePostSale from "@/components/orders/service_postsale";
import ServiceToBeEvaluated from "@/components/orders/service_tobeevaluated";
import ServiceToBePaid from "@/components/orders/service_tobepaid";

export default function OrdersScreen() {
  const params = useLocalSearchParams<{
    type_id: string;
  }>();

  const initialIndex = params.type_id;

  const renderContent: RenderContentType = ({ type }: { type: string }) => {
    switch (type) {
      case "全部":
        return <ServiceAll role="buyer" />;
      case "待付款":
        return <ServiceToBePaid />;
      case "进行中":
        return <ServiceInProgress role="buyer" />;
      case "已收货":
        return <ServiceToBeEvaluated role="buyer" />;
      case "售后":
        return <ServicePostSale role="buyer" />;
      default:
        return <Text>0</Text>;
    }
  };

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
              router.push("/(tabs)/profile");
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
            onPress={() => router.push("/(tabs)/profile/orders/search")}
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
          names={["全部", "待付款", "进行中", "已收货", "售后"]}
          initialIndex={initialIndex}
          fontSize={13}
          // fontSize={global.screenWidth < 480 ? 14 : 16}
        />
      </YStack>
    </SafeAreaView>
  );
}
