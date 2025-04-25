import { Text } from "react-native";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import {
  Button,
  ButtonText,
  Paragraph,
  Separator,
  XStack,
  YStack,
} from "tamagui";

export default function WalletPage() {
  return (
    <YStack width="100%" height="100%" backgroundColor="$background">
      <YStack
        flexDirection="column"
        margin="4%"
        backgroundColor="$gray0"
        borderRadius={20}
        paddingHorizontal="4%"
      >
        {/* 优惠券功能 */}
        {/* <XStack
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$6"
          alignItems="center"
        >
          <Text style={{ fontSize: 18 }}>我的优惠券</Text>
          <XStack>
            <Text style={{ fontSize: 30, fontWeight: "500" }}>3</Text>
            <Text style={{ fontSize: 10, fontWeight: "500" }}>张</Text>
          </XStack>
        </XStack> */}
        <Separator borderColor="$gray3" />

        <XStack
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$3"
          alignItems="center"
        >
          <Text style={{ fontSize: 18 }}>交易记录</Text>
          <MaterialIcons name="keyboard-arrow-right" size={30} unstyled />
        </XStack>
        <Separator borderColor="$gray3" />
        <XStack
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$3"
          alignItems="center"
        >
          <Text style={{ fontSize: 18 }}>银行卡</Text>
          <MaterialIcons name="keyboard-arrow-right" size={30} unstyled />
        </XStack>
      </YStack>
    </YStack>
  );
}
