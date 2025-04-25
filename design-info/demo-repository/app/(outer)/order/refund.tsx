import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  H2,
  Paragraph,
  Separator,
  styled,
  TextArea,
  XStack,
  YStack,
} from "tamagui";

import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import ServiceComponent from "@/components/orders/service_comp";
import { QueryDict } from "@/components/queryDict";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";
import { useGlobalContext } from "@/components/system/globalContext";

const StyledXstack = styled(XStack, {
  justifyContent: "space-between",
});

/**
 * 处理退款页面
 * params:
 * @localSearchParams refund_id: 订单ID
 * role: 角色
 */
const refundPage = memo(() => {
  const refund_id = useLocalSearchParams().refund_id;
  const dispatch = useDispatch<AppDispatch>();
  const refundDetail = useSelector(
    (state: RootState) => state.order.refundDetail
  );
  const order = useSelector((state: RootState) => state.order.order);
  const [auditRemark, setAuditRemark] = useState<string>("");
  const changed = useSelector((state: RootState) => state.order.changed);
  const { dictData } = useGlobalContext();
  const role = useLocalSearchParams().role;
  const isSeller = role === "seller";

  // 获取退款详情
  const fetchRefundDetai = async () => {
    await dispatch(
      slices.order.actions.fetchRefundDetail({ id: Number(refund_id) })
    );
  };

  const agreeRefund = useCallback(async () => {
    console.log("同意退款");
    if (!auditRemark) {
      alert("请输入审核说明");
      return;
    }
    const res = await dispatch(
      slices.order.actions.refundAudit({
        id: Number(refund_id),
        refundState: "audit_pass",
        auditRemark,
      })
    );
    if (isAxiosSuccess(res.type)) {
      alert(`同意退款成功\n审核说明：${auditRemark}`);
      dispatch(slices.order.actions.setChanged());
    } else {
      alert("同意退款失败");
    }
  }, [auditRemark]);

  const refuseRefund = useCallback(async () => {
    console.log("拒绝退款");
    if (!auditRemark) {
      alert("请输入审核说明");
      return;
    }
    const res = await dispatch(
      slices.order.actions.refundAudit({
        id: Number(refund_id),
        refundState: "audit_refused",
        auditRemark,
      })
    );
    if (isAxiosSuccess(res.type)) {
      alert(`拒绝退款成功\n审核说明：${auditRemark}`);
      dispatch(slices.order.actions.setChanged());
    } else {
      alert("拒绝退款失败");
    }
  }, [auditRemark]);

  useEffect(() => {
    fetchRefundDetai();
  }, [refund_id, changed]);

  // 获取订单详情
  useEffect(() => {
    const orderId = refundDetail?.orderId;
    if (orderId) {
      dispatch(
        slices.order.actions.queryOrderDetail({
          id: Number(refundDetail?.orderId),
        })
      );
    }
  }, [refundDetail?.orderItemId]);

  return (
    <YStack backgroundColor="#fff" flex={1}>
      {/* background */}
      <XStack
        position="absolute"
        left={0}
        top={0}
        width={global.screenWidth}
        height="20%"
        backgroundColor="$brown"
      />

      {/* back button */}
      <XStack alignItems="flex-start" marginTop="18%">
        <Button
          backgroundColor="transparent"
          onPress={() => router.back()}
          unstyled
        >
          <ChevronLeft size={35} color="#fff" />
        </Button>

        <YStack alignItems="flex-start" paddingHorizontal="$3">
          <H2 size="$8" color="#fff">
            {refundDetail?.refundState !== "wait_audit"
              ? refundDetail?.refundState === "audit_pass"
                ? "同意退款"
                : "拒绝退款"
              : "买家申请退款"}
          </H2>
          {refundDetail?.refundState === "wait_audit" ? (
            <Paragraph color="#fff">
              买家申请退款，如未处理,{refundDetail?.autoTime}后将自动通过
            </Paragraph>
          ) : (
            <Paragraph color="#fff">
              更新时间：{refundDetail?.updateTime}
            </Paragraph>
          )}
        </YStack>
      </XStack>
      <KeyboardAwareScrollView>
        <YStack backgroundColor="#fff" marginTop="20%" padding="$3">
          <ServiceComponent item={order?.items?.[0]} />
        </YStack>

        <YStack paddingHorizontal="$3" backgroundColor="#fff" gap="$3">
          <StyledXstack>
            <Paragraph fontWeight="600">退款类型</Paragraph>
            <Paragraph>
              {
                QueryDict(dictData["refund_type"], refundDetail?.refundType)
                  .label
              }
            </Paragraph>
          </StyledXstack>
          <StyledXstack>
            <Paragraph fontWeight="600">退款金额</Paragraph>
            <Paragraph>{refundDetail?.refundPrice}</Paragraph>
          </StyledXstack>
          <StyledXstack>
            <Paragraph fontWeight="600">退款原因</Paragraph>
            <Paragraph>{refundDetail?.refundReason}</Paragraph>
          </StyledXstack>
          <YStack gap="$2">
            <Paragraph fontWeight="600">退款说明</Paragraph>
            <XStack
              paddingHorizontal="$3"
              paddingVertical="$2"
              width="90%"
              alignSelf="center"
              backgroundColor="#EDEDED"
              borderRadius={20}
            >
              <Paragraph>{refundDetail?.refundReason}</Paragraph>
            </XStack>
          </YStack>

          <Separator marginVertical="$2" />
          <StyledXstack>
            <Paragraph fontWeight="600">退款编号</Paragraph>
            <Paragraph>{refundDetail?.id}</Paragraph>
          </StyledXstack>
          <StyledXstack>
            <Paragraph fontWeight="600">申请时间</Paragraph>
            <Paragraph>{refundDetail?.createTime}</Paragraph>
          </StyledXstack>
          <StyledXstack>
            <Paragraph fontWeight="600">处理编号</Paragraph>
            <Paragraph>{refundDetail?.refundSn}</Paragraph>
          </StyledXstack>
        </YStack>
        <Separator marginTop="$3" />
        <YStack paddingHorizontal="$3" marginTop="$5" gap="$2">
          <Paragraph fontWeight="600">审核说明</Paragraph>
          {refundDetail?.refundState === "wait_audit" && isSeller ? (
            <TextArea
              placeholder="请输入审核说明"
              value={auditRemark}
              onChangeText={(text) => setAuditRemark(text)}
              width="100%"
              height={100}
              backgroundColor="#EDEDED"
            />
          ) : (
            <XStack
              width="100%"
              height={100}
              backgroundColor="#EDEDED"
              borderRadius={10}
              padding="$3"
            >
              <Paragraph>
                {refundDetail?.auditRemark
                  ? refundDetail?.auditRemark
                  : "暂无说明"}
              </Paragraph>
            </XStack>
          )}
        </YStack>
        {refundDetail?.refundState === "wait_audit" && isSeller && (
          <XStack
            marginTop="$8"
            marginHorizontal="$3"
            justifyContent="center"
            gap="$5"
            marginBottom="$10"
          >
            <AlertDialogComponent
              title="接受退款"
              description="是否确认接受退款？"
              handleConfirm={() => agreeRefund()}
            >
              <Button
                backgroundColor="#caa472"
                borderRadius="$5"
                paddingHorizontal="$5"
                paddingVertical="$2"
                alignSelf="center"
                style={{ color: "white" }}
                height="auto"
              >
                同意退款
              </Button>
            </AlertDialogComponent>
            <AlertDialogComponent
              title="拒绝退款"
              description="是否确认拒绝退款？"
              handleConfirm={() => refuseRefund()}
            >
              <Button
                backgroundColor="#caa472"
                borderRadius="$5"
                paddingHorizontal="$5"
                paddingVertical="$2"
                alignSelf="center"
                style={{ color: "white" }}
                height="auto"
              >
                拒绝退款
              </Button>
            </AlertDialogComponent>
          </XStack>
        )}
      </KeyboardAwareScrollView>
    </YStack>
  );
});

export default refundPage;
