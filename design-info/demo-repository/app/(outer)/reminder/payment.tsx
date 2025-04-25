import ServiceComponent from "@/components/orders/service_comp";
import { QueryDict } from "@/components/queryDict";
import { useGlobalContext } from "@/components/system/globalContext";
import { useCountdown } from "@/components/time_processor";
import { AppDispatch, RootState, slices } from "@/src/store";
import { ArrowLeft, ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { useEffect, useMemo } from "react";
import { SafeAreaView } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H2,
  Paragraph,
  Separator,
  Theme,
  XStack,
  YStack,
} from "tamagui";

export default function PaymentReminder() {
  const { dictData } = useGlobalContext();
  const dispatch = useDispatch<AppDispatch>();
  const order = useSelector((state: RootState) => state.order.order);
  const { orderId, payResCode } = useLocalSearchParams();
  const autoCancelTime = useMemo(() => {
    return order?.autoCancelTime;
  }, [order]);
  const autoCancelLeftTime = useCountdown(autoCancelTime);

  const paymentStatus = useMemo(() => {
    if (Number(payResCode) === 9000 || Number(payResCode) === 200) {
      return "订单支付成功";
    } else if (Number(payResCode) === 8000) {
      return " 正在处理中，请勿重复支付";
    } else if (Number(payResCode) === 6001) {
      return "用户取消支付";
    } else if (Number(payResCode) === 6002) {
      return "网络连接出错";
    } else if (Number(payResCode) === 4000) {
      return "订单支付失败";
    }
    return "订单支付失败";
  }, [payResCode]);

  const handleContinuePayment = () => {
    router.push({
      pathname: "/(tabs)/profile/orders",
      params: {
        type_id: 1,
        isPresented: "true",
      },
    });
  };

  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(orderId) }));
  }, []);

  return (
    <Theme name="light">
      <YStack flex={1}>
        <XStack
          position="relative"
          top={0}
          left={0}
          alignItems="center"
          justifyContent="center"
          backgroundColor="$brown"
          paddingTop="10%"
          height="20%"
        >
          <Button
            height={50}
            position="absolute"
            top="30%"
            left="5%"
            flexDirection="row"
            alignItems="center"
            justifyContent="flex-start"
            space={10}
            onPress={() => {
              router.back();
            }}
            zIndex={1000}
            unstyled
          >
            <ChevronLeft size="$3" color="#fff" />
          </Button>
          <YStack alignItems="center" justifyContent="center">
            <H2 fontWeight="700" fontSize={20} color="#fff">
              {paymentStatus}
            </H2>
            {Number(payResCode) !== 9000 && (
              <Paragraph color="$white">
                {`${autoCancelLeftTime.hours}小时${autoCancelLeftTime.minutes}分钟${autoCancelLeftTime.seconds}秒后自动取消订单`}
              </Paragraph>
            )}
          </YStack>
        </XStack>
        <YStack
          width="98%"
          height="80%"
          padding="$2"
          gap="$1"
          backgroundColor="#fff"
          alignSelf="center"
        >
          <Button width="100%" height={50} justifyContent="center" unstyled>
            <ButtonText fontWeight="700">{order?.buyer?.nickName}</ButtonText>
          </Button>
          {order?.items?.[0] && <ServiceComponent item={order?.items?.[0]} />}

          <Separator style={{ marginVertical: 30 }} />

          <YStack gap="$4">
            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="space-between"
            >
              <Paragraph>订单编号</Paragraph>
              <Paragraph>{order?.orderSn}</Paragraph>
            </XStack>
            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="space-between"
            >
              <Paragraph>订单金额</Paragraph>
              <Paragraph>{order?.totalPrice} ¥</Paragraph>
            </XStack>
            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="space-between"
            >
              <Paragraph>优惠金额</Paragraph>
              <Paragraph>{order?.couponPrice} ¥</Paragraph>
            </XStack>
            <Separator style={{ marginVertical: 10 }} />

            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="space-between"
            >
              <Paragraph>实付款</Paragraph>
              <Paragraph fontWeight="700" fontSize={20}>
                {order?.payPrice} ¥
              </Paragraph>
            </XStack>
          </YStack>
        </YStack>

        <Button
          position="absolute"
          bottom="20%"
          width="50%"
          borderRadius={10}
          marginTop="$5"
          backgroundColor="$brown"
          alignSelf="center"
          height={50}
          justifyContent="center"
          textAlign="center"
          unstyled
          onPress={() =>
            Number(payResCode) === 9000 || Number(payResCode) === 200
              ? router.push(`/(tabs)/profile/orders/${Number(orderId)}`)
              : handleContinuePayment()
          }
        >
          <ButtonText color="#fff" size="$3">
            {Number(payResCode) === 9000 || Number(payResCode) === 200
              ? "去提交材料"
              : "继续支付"}
          </ButtonText>
        </Button>
      </YStack>
    </Theme>
  );
}
