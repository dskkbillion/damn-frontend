import { Button } from "@tamagui/button";
import { PortalProvider } from "@tamagui/portal";
import { Sheet } from "@tamagui/sheet";
import { router } from "expo-router";
import React, { useState } from "react";
import { Alert } from "react-native";
import { ButtonText, Paragraph, XStack } from "tamagui";

import ServiceComponent from "./service_comp";
import { isAxiosSuccess } from "../utils";

import { AppDispatch, slices } from "@/src/store";

/**
 * @description: 订单的 BottomSheet 组件(场景：买家和卖家的申请bottomsheet)
 * @param {issuePopup, materialPopup, comfirmPopup, setIssuePopup, setMaterialPopup, setComfirmPopup, item, role, dispatch}
 * @returns
 */
export const OrderBottomSheet = ({
  issuePopup,
  materialPopup,
  comfirmPopup,
  setIssuePopup,
  setMaterialPopup,
  setComfirmPopup,
  item,
  role,
  dispatch,
}: {
  issuePopup?: boolean;
  materialPopup?: boolean;
  comfirmPopup?: boolean;
  setIssuePopup?: (value: boolean) => void;
  setMaterialPopup?: (value: boolean) => void;
  setComfirmPopup?: (value: boolean) => void;
  item: any;
  role: string;
  dispatch: AppDispatch;
}) => {
  // 处理材料问题
  const handleMaterialPopup = (
    selectedVal: string,
    item: any,
    setMaterialPopup: (value: boolean) => void
  ) => {
    setMaterialPopup(false);
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: item.id,
        application:
          selectedVal === "请求买家补充材料" ? "replenish_materials" : "refuse",
        role: "seller",
      },
    });
  };
  // 处理确认接单
  const handleVerifyOrder = async (
    dispatch: AppDispatch,
    item: any,
    selectedVal: string,
    setComfirmPopup: (value: boolean) => void
  ) => {
    if (selectedVal === "确认接单") {
      Alert.alert("确认接单", "您确定要接受这个订单吗？", [
        {
          text: "取消",
          style: "cancel",
          onPress: () => {
            // 用户点击取消，不关闭底部弹窗
          },
        },
        {
          text: "确定",
          onPress: async () => {
            setComfirmPopup(false);
            const params = {
              orderId: Number(item?.id),
            };
            try {
              const res = await dispatch(
                slices.order.actions.verifyOrder(params)
              );
              if (isAxiosSuccess(res.type)) {
                alert("确认订单成功");
                dispatch(slices.order.actions.setChanged());
                router.push(`/(sellerscreens)/profile/orders/${item.id}`);
              } else {
                alert("确认订单失败");
              }
            } catch (err) {
              console.log("fail to verify order", err);
            }
          },
        },
      ]);
    } else {
      // 拒绝接单
      Alert.alert("拒绝接单", "您确定要拒绝这个订单吗？", [
        {
          text: "取消",
          style: "cancel",
          onPress: () => {
            // 用户点击取消，不关闭底部弹窗
          },
        },
        {
          text: "确定",
          onPress: () => {
            setComfirmPopup(false);
            router.push({
              pathname: "/(outer)/order/application",
              params: {
                orderId: item.id,
                role: "seller",
                application: "refuse",
              },
            });
          },
        },
      ]);
    }
  };

  // 处理退款和平台介入
  const handleIssuePopup = (
    selectedVal: string,
    item: any,
    role: string,
    setIssuePopup: (value: boolean) => void
  ) => {
    setIssuePopup(false);

    // 如果是申请平台介入，先检查是否已经申请过
    if (
      selectedVal === "申请平台介入" &&
      (item?.buyerPlatformFlag || item?.sellerPlatformFlag)
    ) {
      Alert.alert("重复申请", "已经申请过平台介入，是否继续申请？", [
        {
          text: "取消",
          style: "cancel",
        },
        {
          text: "确定",
          onPress: () => {
            router.push({
              pathname: "/(outer)/order/application",
              params: {
                orderId: item.id,
                application: "platform",
                role: role,
              },
            });
          },
        },
      ]);
      return;
    }

    // 其他情况直接跳转
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: item.id,
        application: selectedVal === "我要退款" ? "refund" : "platform",
        role,
      },
    });
  };
  return (
    <BottomSheet
      isOpen={issuePopup || materialPopup || comfirmPopup}
      title={
        issuePopup ? "遇到问题" : materialPopup ? "材料有问题" : "确认接单"
      }
      onClose={
        issuePopup
          ? () => setIssuePopup && setIssuePopup(false)
          : materialPopup
          ? () => setMaterialPopup && setMaterialPopup(false)
          : () => setComfirmPopup && setComfirmPopup(false)
      }
      buttons={
        issuePopup
          ? ["我要退款", "申请平台介入"]
          : materialPopup
          ? ["请求买家补充材料", "拒绝接单"]
          : ["确认接单", "拒绝接单"]
      }
      snapPoints={[40]}
      handleConfirm={(selectedVal) =>
        issuePopup
          ? setIssuePopup &&
            handleIssuePopup(selectedVal, item, role, setIssuePopup)
          : materialPopup
          ? setMaterialPopup &&
            handleMaterialPopup(selectedVal, item, setMaterialPopup)
          : setComfirmPopup &&
            handleVerifyOrder(dispatch, item, selectedVal, setComfirmPopup)
      }
    >
      {issuePopup || materialPopup || comfirmPopup ? (
        <ServiceComponent item={item?.items?.[0]} isExpanded={false} />
      ) : (
        ""
      )}
    </BottomSheet>
  );
};

/**
 * A bottom sheet component.
 *
 * @param {any} value - The value associated with the button.
 */

const BottomSheet = ({
  isOpen,
  onClose,
  title,
  children,
  handleConfirm,
  snapPoints = [40],
  zIndex = 100000,
  position = 0,
  buttons,
  ...props
}) => {
  const [currentPosition, setCurrentPosition] = useState(position);
  const [selectedValue, setSelectedValue] = useState(buttons[0]);

  const handleButtonClick = (value) => {
    setSelectedValue(value);
  };

  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => onClose(open)}
        snapPoints={snapPoints}
        dismissOnSnapToBottom
        dismissOnOverlayPress
        position={currentPosition}
        onPositionChange={setCurrentPosition}
        zIndex={zIndex}
        animation="medium"
      >
        <Sheet.Overlay
          animation="lazy"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <Sheet.Frame
          padding="$4"
          alignItems="center"
          space="$5"
          backgroundColor="#fff"
        >
          <Paragraph fontSize={16} fontWeight="500">
            {title}
          </Paragraph>

          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-evenly"
            paddingHorizontal={10}
            width="100%"
          >
            {buttons.map((button, index) => {
              return (
                <Button
                  key={index}
                  backgroundColor="#fff"
                  borderWidth={1}
                  borderColor={button === selectedValue ? "#B66D0E" : "$gray8"}
                  marginHorizontal={10}
                  width={
                    global.screenWidth / buttons.length -
                    20 -
                    10 * (buttons.length - 1)
                  }
                  height={global.screenHeight * 0.04}
                  justifyContent="center"
                  alignItems="center"
                  borderRadius={10}
                  onPress={() => handleButtonClick(button)}
                  unstyled
                >
                  <ButtonText
                    color={button === selectedValue ? "#B66D0E" : "$darkGray"}
                  >
                    {button}
                  </ButtonText>
                </Button>
              );
            })}
          </XStack>
          <XStack
            flexDirection="row"
            width="100%"
            marginHorizontal={10}
            boxSizing="border-box"
          >
            {children}
          </XStack>
          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="center"
            marginTop="auto"
            marginBottom="$3"
            width="100%"
          >
            <Button
              width="90%"
              backgroundColor="$brown"
              color="#fff"
              justifyContent="center"
              alignItems="center"
              alignSelf="center"
              height={global.screenHeight * 0.04}
              circular
              unstyled
              onPress={() => handleConfirm(selectedValue)}
            >
              <ButtonText color="#fff">确定</ButtonText>
            </Button>
          </XStack>
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};

export default BottomSheet;
