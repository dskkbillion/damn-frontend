import { router, Stack, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { SafeAreaView } from "react-native";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  Input,
  Paragraph,
  Separator,
  TextArea,
  XStack,
  YStack,
} from "tamagui";

/**
 * params:
 * orderId: 订单id (required)
 * application: 申请类型 (required)
 * role: 角色 (required)
 */
import headerComponent from "@/components/headerShown";
import { SelectItem } from "@/components/orders/selectItem";
import ServiceComponent from "@/components/orders/service_comp";
import { QueryDict } from "@/components/queryDict";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function ApplicationSubmission() {
  const params = useLocalSearchParams();
  const id = params.orderId;
  const application = params.application;
  const role = params.role;

  const order = useSelector((state: RootState) => state.order.order);
  const dispatch = useDispatch<AppDispatch>();

  const [reasonLabel, setReasonLabel] = useState("");
  const [additionalInfo, setAdditionalInfo] = useState("");
  const [refundPrice, setRefundPrice] = useState("");

  const [reasons, setReasons] = useState([] as any);
  const { dictData } = useGlobalContext();

  const handleComfirm = useCallback(async () => {
    let params;
    let res;
    switch (application) {
      case "replenish_materials":
        params = {
          orderId: Number(id),
          type: "replenish_materials",
          reasonValue: "deficiency",
          reasonLabel,
          remarks: additionalInfo,
        };
        break;
      case "reform":
        params = {
          orderId: Number(id),
          type: "reform",
          reasonValue: "reason",
          reasonLabel,
          remarks: additionalInfo,
        };
        break;
      case "platform":
        params = {
          orderId: Number(id),
          type: "platform",
          memberType: role,
          reasonValue: "reason",
          reasonLabel,
          remarks: additionalInfo,
        };
        break;
      case "refuse":
        params = {
          orderId: Number(id),
          type: "refuse",
          reasonValue: "reason",
          reasonLabel,
          remarks: additionalInfo,
        };
        break;
      case "refund":
        if (!reasonLabel) {
          alert("申请原因不能为空，请选择");
          return;
        }
        // if (!refundPrice) {
        //   alert("请输入退款金额");
        //   return;
        // }
        params = {
          orderItemId: order?.items?.[0].id,
          memberType: role === "buyer" ? "buyer" : "seller",
          refundReason: reasonLabel,
          refundExplain: additionalInfo,
          auditType: role === "buyer" ? "seller" : "buyer",
          // refundPrice: Number(refundPrice),
        };
        res = await dispatch(slices.order.actions.applyRefund(params));
        try {
          if (isAxiosSuccess(res.type)) {
            alert("申请提交成功");
            dispatch(slices.order.actions.setChanged());
            router.back();
          } else {
            alert("您已申请过售后,请等待处理");
            router.back();
          }
        } catch (err) {
          alert(err);
        }

        return;
    }
    if (!reasonLabel) {
      alert("请选择申请原因");
      return;
    }
    if (!additionalInfo) {
      alert("请填写补充说明");
      return;
    }
    try {
      const res = await dispatch(slices.order.actions.addOrderDemand(params));
      console.log("res", res);
      if (isAxiosSuccess(res.type)) {
        await dispatch(
          slices.order.actions.queryOrderDetail({ id: Number(id) })
        );
        await dispatch(
          slices.order.actions.queryDemandList({
            orderId: Number(id),
            memberType: role === "buyer" ? "buyer" : "seller",
            type: application as
              | "refuse"
              | "material"
              | "delivery"
              | "platform",
          })
        );
        alert("申请提交成功");
        if (role === "buyer" && order?.state !== "canceled") {
          router.push(`/(tabs)/profile/orders/${order?.id}/`);
        } else {
          router.back();
        }
      } else {
        alert("申请提交失败");
      }
    } catch (error) {
      console.log("fail to addOrderDemand", error);
    }
  }, [id, reasonLabel, additionalInfo, role, application]);

  const selectReasonLabel = (value: string) => {
    setReasonLabel(value);
  };

  const getTitle = (application: string) => {
    if (application === "refund") {
      return "申请退款";
    } else {
      return QueryDict(dictData?.order_request_type, application as string)
        .label;
    }
  };

  // 获取订单详情
  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(id) }));
  }, [id]);

  console.log("11111", reasons);

  useEffect(() => {
    if (role === "buyer") {
      if (application === "platform") {
        setReasons([
          "卖家延迟交付",
          "卖家未交付",
          "卖家承诺不履行",
          "卖家服务态度（辱骂、骚扰）",
          "卖家服务质量（不符合要求）",
          "其他",
        ]);
      } else if (application === "refund") {
        setReasons([
          "卖家延迟交付",
          "卖家未交付",
          "卖家承诺不履行",
          "卖家服务态度（辱骂、骚扰）",
          "卖家服务质量（不符合要求）",
          "其他",
        ]);
      } else if (application === "reform") {
        setReasons(["交付不满意", "交付未达到服务要求", "其他"]);
      } else {
        setReasons(["其他"]);
      }
    }

    if (role === "seller") {
      if (application === "platform") {
        setReasons([
          "买家拒绝收货",
          "买家涉及辱骂、骚扰",
          "卖家服务态度（辱骂、骚扰）",
          "其他",
        ]);
      } else {
        setReasons(["材料缺失", "材料错误", "材料未达到服务要求", "其他"]);
      }
    }
  }, [application]);

  return (
    <YStack flex={1}>
      <Stack.Screen
        options={{
          headerTransparent: true,
          header: () =>
            headerComponent({
              title: getTitle(String(application)),
              canBack: true,
            }),
        }}
      />

      <SafeAreaView style={{ flex: 1 }} />

      <KeyboardAwareScrollView
        resetScrollToCoords={{ x: 0, y: 0 }}
        extraScrollHeight={50}
        scrollEnabled
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        {/* service box */}
        <YStack
          flexDirection="column"
          marginTop="$8"
          backgroundColor="#fff"
          padding="$3"
        >
          <ServiceComponent item={order?.items?.[0]} />

          <Separator style={{ marginTop: 30 }} />

          <XStack flexDirection="row" alignItems="center" paddingVertical="$3">
            <Paragraph>订单编号: {order?.orderSn}</Paragraph>
          </XStack>
          <XStack flexDirection="row" alignItems="center">
            <Paragraph>申请时间: {new Date().toLocaleString()}</Paragraph>
          </XStack>
        </YStack>

        {/* application */}
        <YStack
          flexDirection="column"
          marginTop="$3"
          backgroundColor="#fff"
          padding="$3"
        >
          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>申请类型</Paragraph>
            <Paragraph style={{ fontWeight: 500 }}>
              {application === "refund"
                ? "申请退款"
                : QueryDict(dictData?.order_request_type, application).label}
            </Paragraph>
          </XStack>
          {/* reason */}
          <XStack
            flexDirection="row"
            alignItems="center"
            marginTop={30}
            justifyContent="space-between"
          >
            <Paragraph>申请原因</Paragraph>
            <SelectItem
              label={
                application === "refund"
                  ? "申请退款"
                  : QueryDict(dictData?.order_request_type, application).label
              }
              items={reasons}
              onValueChange={selectReasonLabel}
            />
          </XStack>
        </YStack>

        <YStack
          flexDirection="column"
          height={global.screenHeight * 0.3}
          backgroundColor="#fff"
          padding="$3"
          marginTop="$3"
          justifyContent="center"
        >
          <Paragraph>
            请在此处输入
            <Paragraph>
              {application === "refund" ? "退款原因" : "补充说明"}
            </Paragraph>
          </Paragraph>

          <TextArea
            marginTop="$2"
            width="98%"
            height="80%"
            alignSelf="center"
            boxSizing="border-box"
            backgroundColor="#EDEDED"
            placeholder={
              application === "platform"
                ? "有助于帮助平台更好的理解问题..."
                : role === "buyer"
                ? "有助于帮助卖家更好的理解问题..."
                : "有助于帮助买家更好的理解问题..."
            }
            value={additionalInfo}
            onChangeText={(text) => setAdditionalInfo(text)}
          />
        </YStack>

        {application === "refund" && (
          <YStack
            flexDirection="column"
            backgroundColor="#fff"
            padding="$3"
            paddingVertical="$5"
            marginTop="$3"
          >
            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="space-between"
            >
              <Paragraph>退款金额</Paragraph>
              <Input
                value={refundPrice}
                onChangeText={(text) => {
                  if (/^\d*\.?\d*$/.test(text)) {
                    const maxPrice = order?.payPrice || 0;
                    const inputPrice = Number(text);

                    if (inputPrice > maxPrice) {
                      setRefundPrice(String(maxPrice));
                    } else {
                      setRefundPrice(text);
                    }
                  }
                }}
                placeholder={`最多可退 ${order?.payPrice || 0} 元`}
                keyboardType="decimal-pad"
                textAlign="right"
                backgroundColor="#EDEDED"
                borderRadius="$2"
                paddingVertical="$2"
                paddingHorizontal="$3"
                unstyled
              />
            </XStack>
          </YStack>
        )}
      </KeyboardAwareScrollView>

      <YStack
        position="absolute"
        width="100%"
        height={global.screenHeight * 0.08}
        backgroundColor="#fff"
        bottom={0}
        left={0}
        paddingVertical="$3"
        justifyContent="center"
        alignItems="center"
      >
        <ShowDialog application={application} handleComfirm={handleComfirm} />
      </YStack>
    </YStack>
  );
}

const ShowDialog = memo(
  ({ application, handleComfirm }: { application; handleComfirm }) => {
    switch (application) {
      case "replenish_materials":
        return (
          <AlertDialogComponent
            title="材料申请"
            description="确认申请？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="70%"
              height="80%"
              backgroundColor="$brown"
              marginBottom={20}
            >
              <ButtonText color="#fff" alignSelf="center">
                提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        );
      case "refund":
        return (
          <AlertDialogComponent
            title="申请退款"
            description="确认申请退款？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="70%"
              height="80%"
              backgroundColor="$brown"
              marginBottom={20}
            >
              <ButtonText color="#fff" alignSelf="center">
                提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        );
      case "platform":
        return (
          <AlertDialogComponent
            title="申请平台介入"
            description="确认申请平台介入？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="70%"
              height="80%"
              backgroundColor="$brown"
              marginBottom={20}
            >
              <ButtonText color="#fff" alignSelf="center">
                提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        );
      case "refuse":
        return (
          <AlertDialogComponent
            title="拒绝订单"
            description="确认拒绝订单？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="70%"
              height="80%"
              backgroundColor="$brown"
              marginBottom={20}
            >
              <ButtonText color="#fff" alignSelf="center">
                提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        );
      case "reform":
        return (
          <AlertDialogComponent
            title="申请卖家重新交付"
            description="确认申请卖家重新交付？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="70%"
              height="80%"
              backgroundColor="$brown"
              marginBottom={20}
            >
              <ButtonText color="#fff" alignSelf="center">
                提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        );
    }
  }
);
