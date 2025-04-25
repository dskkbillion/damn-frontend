import { memo, useEffect, useState } from "react";
import { Text } from "react-native";
import EntypoIcon from "react-native-vector-icons/Entypo";
import Icon from "react-native-vector-icons/Ionicons";
import { useDispatch, useSelector } from "react-redux";
import { Button, H2, Paragraph, XStack, YStack } from "tamagui";

import { useCountdown } from "../time_processor";

import { AppDispatch, RootState } from "@/src/store";
/**
 * Represents a timeline component.
 * @param {string} role - The role of the user.
 * @param {ReactNode} children - The child components.
 * @param {any} props - Additional props.
 * @returns {ReactNode} The rendered timeline component.
 */
export function TimeLineComponent({ role, state, order, children, ...props }) {
  // states will be used to render the timeline
  const [mainContent, bottomContent] = children;
  const states = Array.from({ length: 6 }, (_, index) => index);
  const states_text = ["支付", "提交", "接单", "交付", "确认", "评价"];
  const itemWidth = global.screenWidth / states.length;
  const orderState = useSelector((state: RootState) => state.order.orderState);
  const [val, setVal] = useState(0);
  const [selectedVal, setSelectedVal] = useState(val);
  const [isException, setIsException] = useState(false);
  const [isShowBottom, setIsShowBottom] = useState(true);
  const refundDetail = useSelector(
    (state: RootState) => state.order.refundDetail
  );
  const refundId = useSelector((state: RootState) => state.order.refundId);
  const dispatch = useDispatch<AppDispatch>();
  const handlePress = (selectedVal) => {
    setSelectedVal(selectedVal); // set the selected state
  };

  useEffect(() => {
    const toSeriesNumber = (state) => {
      switch (state) {
        case "awaitingSubmission":
          if (role === "buyer") {
            setIsShowBottom(true);
          } else {
            setIsShowBottom(false);
          }
          setVal(1);
          break;
        case "buyAwaitingSubmission":
        case "awaitingStart":
          setIsShowBottom(true);
          setVal(2);
          break;
        case "awaitingDelivery":
          if (role === "buyer") {
            setIsShowBottom(false);
          } else {
            setIsShowBottom(true);
          }
          setVal(3);
          break;
        case "awaitingConfirmation":
        case "sellerSupplementaryMaterials":
        case "applyForRefuse":
          if (role === "buyer") {
            setIsShowBottom(true);
          } else {
            setIsShowBottom(false);
          }
          setVal(4);
          break;
        case "awaitingEvaluation":
          if (role === "buyer") {
            setIsShowBottom(false);
          } else {
            setIsShowBottom(true);
          }
          setVal(5);
          break;
        case "orderCompleted":
          setVal(6);
          break;
        default:
          setVal(0);
      }
    };
    toSeriesNumber(state);
  }, [state]);

  useEffect(() => {
    if (orderState === "refuse") {
      setIsException(true);
    }
  }, [orderState]);

  // useEffect(() => {
  //   if (order?.buyerRefundFlag || order?.tenantRefundFlag) {
  //     dispatch(
  //       slices.order.actions.fetchRefundDetail({ id: Number(refundId) })
  //     );
  //   }
  // }, [order?.buyerRefundFlag, order?.tenantRefundFlag]);

  // console.log("refundId", refundId);

  return (
    <YStack flexDirection="column" width={global.screenWidth} flexGrow={1}>
      <XStack
        flexDirection="row"
        justifyContent="space-evenly"
        alignItems="center"
        width="100%"
        paddingHorizontal={10}
      >
        {states.map((state, index: number) => {
          return (
            <XStack
              key={index}
              flexDirection="row"
              alignItems="center"
              width={state < states.length - 1 ? itemWidth : itemWidth * 0.6}
            >
              <Button
                display="flex"
                flexDirection="column"
                alignItems="center"
                height={50}
                width={state < states.length - 1 ? "60%" : "100%"}
                onPress={() => handlePress(state)}
                unstyled
              >
                {state < val ? (
                  <Icon
                    name="checkmark-circle-outline"
                    size={30}
                    padding={0}
                    color="#EDB466"
                    style={{ marginBottom: -10 }}
                  />
                ) : (
                  <EntypoIcon
                    name="dot-single"
                    size={32}
                    color="#141A1B"
                    style={{ marginBottom: -10 }}
                  />
                )}
                <Paragraph
                  color={state < val ? "#EDB466" : "#141A1B"}
                  fontSize={13}
                >
                  {state < val
                    ? "已" + states_text[state]
                    : "待" + states_text[state]}
                </Paragraph>
              </Button>

              {state < states.length - 1 && (
                <YStack height={50} width="40%">
                  <XStack
                    height={2}
                    backgroundColor="#EDB466"
                    marginTop="50%"
                  />
                </YStack>
              )}
            </XStack>
          );
        })}
      </XStack>

      {/* render notice */}
      <YStack
        flexDirection="column"
        height={110}
        backgroundColor="#fff"
        borderRadius={20}
        marginTop={10}
        padding="$3"
        marginHorizontal={10}
      >
        <RenderNotice
          state={
            state
            // order?.buyerRefundFlag || order?.tenantRefundFlag
            //   ? refundDetail?.refundState
            //   : state
          }
          role={role}
          status={2}
        />
      </YStack>

      {/* scrollview */}
      {isException ? (
        <H2>该订单已取消</H2>
      ) : (
        <>
          <YStack
            flexDirection="column"
            width="100%"
            marginTop="$3"
            flexGrow={1}
          >
            {mainContent}
          </YStack>
          {isShowBottom && (
            <XStack
              position="absolute"
              zIndex={999}
              left={0}
              bottom={0}
              width={global.screenWidth}
              backgroundColor="#fff"
              height={global.screenHeight * 0.1}
            >
              {bottomContent}
            </XStack>
          )}
        </>
      )}
    </YStack>
  );
}

export const styles = {
  active: {
    color: "blue",
  },
  inactive: {
    color: "gray",
  },
};

const RenderNotice = memo(
  ({
    state,
    role,
    status,
  }: {
    state: string;
    role: string;
    status: number;
  }) => {
    const autoMaterialTime = useSelector(
      (state: RootState) => state.order.autoMaterialTime
    );
    const deliveryTime = useSelector(
      (state: RootState) => state.order.deliveryTime
    );

    const autoMaterialLeftTime = useCountdown(autoMaterialTime);
    const autoOrderReceivinTime = useSelector(
      (state: RootState) => state.order.autoOrderReceivinTime
    );
    const autoOrderReceivinLeftTime = useCountdown(autoOrderReceivinTime);
    const noticeForAwaiting = {
      buyer: {
        awaitingSubmission: {
          title: "等待提交要求",
          content: `${autoMaterialLeftTime.hours}时${autoMaterialLeftTime.minutes}分${autoMaterialLeftTime.seconds}秒后，如您仍未上传订单要求，系统将自动取消该订单并将款项原路返回`,
        },
        awaitingStart: {
          title: "等待卖家接单",
          content: `${autoMaterialLeftTime.hours}时${autoMaterialLeftTime.minutes}分${autoMaterialLeftTime.seconds}秒后，如卖家未响应，系统将对卖家进行积分减扣，该订单将自动取消并将款项原路返回`,
        },
        buyAwaitingSubmission: {
          title: "等待补充材料",
          content: `卖家申请修改，您需要补充材料，${autoMaterialLeftTime.hours}时${autoMaterialLeftTime.minutes}分${autoMaterialLeftTime.seconds}秒后如您仍未上传材料，系统将自动取消该订单并将款项原路返回`,
        },
        awaitingDelivery: {
          title: "等待卖家交付",
          content: `${deliveryTime}前，您将收到交付。如卖家未到期交付，您可以联系客服寻求帮助`,
        },
        awaitingConfirmation: {
          title: "等待确认",
          content: `买家已完成交付，请确认是否收货。${autoOrderReceivinLeftTime.hours}时${autoOrderReceivinLeftTime.minutes}分${autoOrderReceivinLeftTime.seconds}秒后，如您仍未确认收货，系统将自动收货，如订单有问题请联系卖家或申请平台介入`,
        },
        applyForRefuse: {
          title: "您的申请被拒绝",
          content: "卖家拒绝了您的申请，您可以重新提交申请或申请平台介入",
        },
        sellerSupplementaryMaterials: {
          title: "等待卖家重新交付",
          content: `${deliveryTime}，如卖家未重新交付，系统将自动取消该订单并将款项原路返回`,
        },
        awaitingEvaluation: {
          title: "等待评价",
          content: "请对本次服务做出评价",
        },
        orderCompleted: { title: "订单成功结束", content: "订单已完成" },
        // { title: "申请修改", content: "请等待卖家修改" },
        // { title: "申请重做", content: "请等待卖家重做" },
        // { title: "订单成功结束", content: "订单已完成" },
        // "applyForRefuse": { title: "申请退款", content: "请等待卖家同意退款" },
        // { title: "等待款项", content: "请等待款项" },
        // { title: "申请调解", content: "请等待调解" },
      },
      seller: {
        awaitingSubmission: {
          title: "等待提交要求",
          content:
            "xx天xx时xx分后，如买家仍未上传订单要求，系统将自动取消该订单并将款项原路返回",
        },
        awaitingStart: {
          title: "确认是否接单",
          content:
            "xx天xx时xx分后，如您仍未做出回复，系统将对您的卖家积分进行一定的减扣，该订单将自动取消并将款项原路返回",
        },
        awaitingDelivery: {
          title: "已接单，请按时交付",
          content: `${deliveryTime}前，您需要交付最终服务。若未按时交付，平台将会减扣您的积分并按超出交付期开始扣减服务金额`,
        },
        buyAwaitingSubmission: {
          title: "等待补充材料",
          content: `您已申请修改，买家需要补充材料，${autoMaterialLeftTime.hours}时${autoMaterialLeftTime.minutes}分${autoMaterialLeftTime.seconds}秒后买家未补充材料，系统将自动取消该订单并将款项原路返回`,
        },
        awaitingConfirmation: {
          title: "等待买家确认收货",
          content: "您已完成交付，等待买家确认收货",
        },
        applyForRefuse: {
          title: "拒绝买家申请",
          content: "您拒绝了买家的申请",
        },

        sellerSupplementaryMaterials: {
          title: "等待您重新交付",
          content:
            "xx天xx时xx分后，如您未重新交付，系统将对您的积分进行一定的减扣；如遇特殊情况请申请平台介入",
        },
        // { title: "等待买家重传材料", content: "请等待买家重传材料" },
        awaitingEvaluation: {
          title: "等待买家评价",
          content: "卖家已交付，等待买家评价",
        },
        orderCompleted: { title: "订单成功结束", content: "订单已完成" },
        // {
        //   title: "买家申请修改",
        //   content: "当前交付次数已超出订单规格，请您查看申请并确认是否同意",
        // },
        // {
        //   title: "买家申请重做",
        //   content: "当前交付次数已超出订单规格，请您查看申请并确认是否同意",
        // },
        // { title: "买家提交退款", content: "请等待您同意退款" },
        // { title: "等待款项", content: "请等待款项" },
        // { title: "申请调解", content: "请等待调解" },
      },
    };

    const noticeForRefund = {
      buyer: {
        wait_audit: {
          title: "申请退款中",
          content: "已向卖家申请退款，等待卖家处理",
        },
        audit_pass: {
          title: "退款成功",
          content: "卖家已同意退款，款项预计1-3天内返回付款账号",
        },
        audit_refused: {
          title: "退款失败",
          content: "卖家拒绝退款，如需继续退款请申请平台介入",
        },

        // {
        //   title: "买家申请修改",
        //   content: "当前交付次数已超出订单规格，请您查看申请并确认是否同意",
        // },
        // {
        //   title: "买家申请重做",
        //   content: "当前交付次数已超出订单规格，请您查看申请并确认是否同意",
        // },
        // { title: "买家提交退款", content: "请等待您同意退款" },
        // { title: "等待款项", content: "请等待款项" },
        // { title: "申请调解", content: "请等待调解" },
      },
      seller: {
        wait_audit: {
          title: "买家申请退款",
          content: "买家向您申请退款，请及时处理",
        },
        audit_pass: {
          title: "退款成功",
          content: "您已同意退款，本次订单将在退款到账后自动关闭",
        },
        audit_refused: {
          title: "退款失败",
          content: "您已拒绝退款",
        },
      },
    };

    const noticeForSuccess: Record<
      string,
      { title: string; content: string }[]
    > = {
      buyer: [
        { title: "支付成功", content: "订单支付成功" },
        { title: "提交成功", content: "订单提交成功" },
        { title: "接单成功", content: "卖家已接单" },
        { title: "交付成功", content: "卖家已交付" },
        { title: "确认成功", content: "交付已确认" },
        { title: "申请成功", content: "卖家正在修改交付，请您耐心等待" },
        { title: "申请成功", content: "卖家正在重做交付，请您耐心等待" },
        { title: "评价成功", content: "评价成功" },
        { title: "订单关闭成功", content: "订单关闭成功" },
        { title: "退款成功", content: "退款成功" },
        { title: "正在调解", content: "正在调解" },
      ],
      seller: [
        { title: "支付成功", content: "订单支付成功" },
        { title: "提交成功", content: "订单提交成功" },
        { title: "接单成功", content: "卖家已接单" },
        { title: "交付成功", content: "卖家已交付" },
        { title: "确认成功", content: "交付已确认" },
        { title: "申请成功", content: "卖家正在修改交付，请您耐心等待" },
        { title: "申请成功", content: "卖家正在重做交付，请您耐心等待" },
        { title: "评价成功", content: "评价成功" },
        { title: "订单关闭成功", content: "订单关闭成功" },
        { title: "退款成功", content: "退款成功" },
        { title: "正在调解", content: "正在调解" },
      ],
    };
    const noticeForFail: Record<string, { title: string; content: string }[]> =
      {
        buyer: [
          { title: "支付失败", content: "订单支付失败" },
          { title: "提交失败", content: "订单提交失败" },
          { title: "接单失败", content: "卖家未接单" },
          { title: "交付失败", content: "卖家未交付" },
          { title: "确认失败", content: "交付未确认" },
          { title: "申请失败", content: "卖家未修改交付" },
          { title: "申请失败", content: "卖家未重做交付" },
          { title: "评价失败", content: "评价失败" },
          { title: "订单关闭失败", content: "订单关闭失败" },
          { title: "退款失败", content: "退款失败" },
          { title: "调解失败", content: "调解失败" },
        ],
        seller: [
          { title: "支付失败", content: "订单支付失败" },
          { title: "提交失败", content: "订单提交失败" },
          { title: "接单失败", content: "卖家未接单" },
          { title: "交付失败", content: "卖家未交付" },
          { title: "确认失败", content: "交付未确认" },
          { title: "申请失败", content: "卖家未修改交付" },
          { title: "申请失败", content: "卖家未重做交付" },
          { title: "评价失败", content: "评价失败" },
          { title: "订单关闭失败", content: "订单关闭失败" },
          { title: "退款失败", content: "退款失败" },
          { title: "调解失败", content: "调解失败" },
        ],
      };

    let notice: { title: string; content: string } | undefined;

    // 根据不同的 status 返回不同的通知内容
    switch (status) {
      case 0:
        notice = noticeForFail[role][state]; // 失败状态
        break;
      case 1:
        notice = noticeForSuccess[role][state]; // 成功状态
        break;
      case 2:
        if (["audit_pass", "audit_refused", "wait_audit"].includes(state)) {
          notice = noticeForRefund[role][state];
        } else {
          notice = noticeForAwaiting[role][state]; // 等待中状态
        }
        break;
      default:
        return null; // 或者返回一个默认的通知内容
    }

    // 返回指定的通知内容，如果索引无效，则返回一个默认值
    return (
      <YStack>
        {/* <Paragraph>{state}</Paragraph> */}
        <Text style={{ fontSize: 18, fontWeight: "600" }}>{notice?.title}</Text>
        <Text numberOfLines={3} style={{ marginTop: 5 }}>
          {notice?.content}
        </Text>
      </YStack>
    );
  }
);
