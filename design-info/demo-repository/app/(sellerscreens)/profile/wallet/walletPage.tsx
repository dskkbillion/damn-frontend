import { AppDispatch, RootState, slices } from "@/src/store";
import { router } from "expo-router";
import { useEffect } from "react";
import { Text } from "react-native";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  Paragraph,
  Separator,
  XStack,
  YStack,
} from "tamagui";

export default function WalletPage() {
  const dispatch = useDispatch<AppDispatch>();
  const wallet = useSelector((state: RootState) => state.user.wallet);

  useEffect(() => {
    dispatch(slices.user.actions.fetchBalance({}));
  }, []);

  return (
    <YStack width="100%" height="100%" backgroundColor="$background">
      <YStack
        flexDirection="column"
        margin="4%"
        backgroundColor="$gray0"
        borderRadius={20}
        paddingHorizontal="4%"
      >
        <XStack
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$6"
          alignItems="center"
        >
          <Text style={{ fontSize: 18 }}>账户余额</Text>
          <XStack>
            <Text style={{ fontSize: 10, fontWeight: "500" }}>¥</Text>
            <Text style={{ fontSize: 30, fontWeight: "500" }}>
              {wallet?.amount}
            </Text>
          </XStack>
        </XStack>
        <XStack flexDirection="row" space="$4" justifyContent="space-evenly">
          <YStack alignItems="center">
            <Paragraph color="$darkGray">总收入</Paragraph>
            <Paragraph color="$green" size="$4">
              {wallet?.incomeTotal}
            </Paragraph>
          </YStack>
          <YStack alignItems="center">
            <Paragraph color="$darkGray">总支出</Paragraph>
            <Paragraph color="$red" size="$4">
              {wallet?.incomeTotal}
            </Paragraph>
          </YStack>

          <YStack alignItems="center">
            <Paragraph color="$darkGray">可用资金</Paragraph>
            <Paragraph size="$4">{wallet?.useableAmount}</Paragraph>
          </YStack>

          <YStack alignItems="center">
            <Paragraph color="$darkGray">在途资金</Paragraph>
            <Paragraph size="$4">{wallet?.freezeAmount}</Paragraph>
          </YStack>
        </XStack>

        <Separator borderColor="$gray3" />

        <Button
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$3"
          alignItems="center"
          height={80}
          onPress={() => router.push("/profile/wallet/record/recordPage")}
          unstyled
        >
          <Text style={{ fontSize: 18 }}>交易记录</Text>
          <MaterialIcons name="keyboard-arrow-right" size={30} unstyled />
        </Button>
        <Separator borderColor="$gray3" />
        <Button
          flexDirection="row"
          justifyContent="space-between"
          paddingVertical="$3"
          alignItems="center"
          height={50}
          onPress={() => router.push("/profile/wallet/cards")}
          unstyled
        >
          <Text style={{ fontSize: 18 }}>银行卡</Text>
          <MaterialIcons name="keyboard-arrow-right" size={30} unstyled />
        </Button>
      </YStack>

      <YStack flexDirection="column" alignItems="center" marginTop="4%">
        <Button
          backgroundColor="#DDBC98"
          borderWidth="$0"
          paddingHorizontal="8%"
          size="$3"
        >
          <ButtonText color="$text" fontSize={16}>
            提现
          </ButtonText>
        </Button>
      </YStack>
    </YStack>
  );
}
