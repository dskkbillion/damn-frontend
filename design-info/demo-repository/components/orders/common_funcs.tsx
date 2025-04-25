import { ChevronDown } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo } from "react";
import { Alert } from "react-native";
import {
  Accordion,
  ButtonText,
  H2,
  Paragraph,
  XStack,
  YStack,
  Button,
  Square,
  Separator,
} from "tamagui";

import TabsComponent from "./tabs_comp";
import { goToChat } from "../chat/goToChat";
import { QueryDict } from "../queryDict";
import { getFilePath, PickUpButton } from "../utils/filesystem";

import { AppDispatch, RootState, slices } from "@/src/store";
import { useGlobalContext } from "../system/globalContext";
import { useSelector } from "react-redux";
import { toast } from "../styled/toast";
import { FileDownloader } from "../styled/file_downloader";
import { alert } from "../styled/alert";

// 获取订单状态文字
export const renderText = ({
  state,
  role,
  autoMaterialLeftTime,
  is_refund,
  refundState,
}: {
  state: string;
  role: string;
  autoMaterialLeftTime?: any;
  is_refund?: boolean;
  refundState?: string;
}) => {
  let text = "";

  if (is_refund && refundState) {
    if (refundState === "audit_refused") {
      text = "退款审核被拒绝，可与卖家协商后申请平台介入";
    } else if (refundState === "audit_pass") {
      text = "退款审核通过，等待退款";
    } else if (refundState === "audit_wait") {
      text = "退款审核中，请耐心等待";
    }
    return text;
  }

  switch (state) {
    case "buyAwaitingSubmission":
      text =
        role === "seller"
          ? "等待买家提供所需材料"
          : "卖家请求重传/补充材料，请尽快补充避免影响接单"; // buyer
      return text;
    case "awaitingSubmission":
      text =
        role === "seller" ? "等待买家提供所需材料" : "等待您提供卖家所需材料"; // buyer
      return text;
    case "awaitingStart":
      return `等待卖家确认接单,${autoMaterialLeftTime?.hours}时${autoMaterialLeftTime.minutes}分${autoMaterialLeftTime.seconds}秒后未接单，此订单将自动取消`;
    case "awaitingDelivery":
      text =
        role === "seller"
          ? "订单开始！请注意您需要在xxx前完成交付"
          : "等待卖家交付";
      return text;
    case "awaitingConfirmation":
      text =
        role === "seller" ? "您已完成交付，等待买家确认" : "等待您确认交付"; // seller
      return text;
    case "applyForRefuse":
      text =
        role === "seller"
          ? "您已拒绝买家的交付申请"
          : "您的交付申请被拒绝，如有问题请申请平台介入"; // buyer
      return text;
    case "sellerSupplementaryMaterials":
      text = role === "seller" ? "等待您重新交付" : "等待卖家重新交付"; // buyer
      return text;
    case "awaitingEvaluation":
      text =
        role === "seller"
          ? "订单已完成,等待买家做出评价"
          : "订单已完成,您可以在30天内对订单做出评价";
      return text;
    case "orderCompleted":
      text =
        role === "seller"
          ? "买家已评价，本次订单结束"
          : "您已评价，本次订单结束";
      return text;
    case "awaitingPayment":
      text = "等待买家付款";
      return text;

    case "AfterSaleRejection":
      text = role === "seller" ? "买家已拒绝售后申请" : "您的售后申请被拒绝";
      return text;
    case "applyingForMediation":
      text = role === "seller" ? "买家已申请平台介入" : "您已申请平台介入";
      return text;

    case "canceled":
      text = "订单已取消";
      return text;

    case "afterSale":
      return "售后中";

    default:
      return "当前状态未知，请联系客服";
  }
};

// 添加 GetButtonsParams 接口
interface GetButtonsParams {
  state: string;
  role: string;
  is_refund: boolean;
  refundState?: string; // 添加可选的 refundState
}

/**
 * @description 获取按钮列表
 * @param state 订单状态
 * @param role 角色
 * @param is_refund 是否退款
 * @param refundState 退款状态
 * @returns 按钮列表
 */
export const getButtons = ({
  state,
  role,
  is_refund,
  refundState,
}: GetButtonsParams) => {
  // 单独处理退款情况

  if (is_refund) {
    if (refundState === "wait_audit") {
      if (role === "buyer") {
        return ["联系卖家", "查看进度"];
      } else {
        return ["联系买家", "处理退款", "查看进度"];
      }
    } else if (refundState === "audit_pass") {
      return ["删除记录", "售后详情", "查看订单"];
    } else if (refundState === "audit_refused") {
      if (role === "buyer") {
        return ["联系卖家", "售后详情", "查看进度"];
      } else {
        return ["联系买家", "处理退款", "查看进度"];
      }
    }
  }

  switch (state) {
    // 订单开始前
    case "awaitingPayment":
      return ["继续支付"];
    case "awaitingSubmission":
      return ["联系卖家", "查看进度"];
    case "awaitingStart":
      if (role === "buyer") {
        return ["联系卖家", "查看进度"];
      } else {
        return ["联系买家", "材料有问题 ?", "确认接单"];
      }

    // 订单进行中
    case "awaitingDelivery":
    case "awaitingConfirmation":
    case "sellerSupplementaryMaterials":
    case "applyForRefuse":
      if (role === "buyer") {
        return ["联系卖家", "查看进度"];
      } else {
        return ["联系买家", "查看进度"];
      }
    // 交付后
    case "awaitingEvaluation":
      if (role === "buyer") {
        return ["去评价"];
      } else {
        return ["查看进度"];
      }
    case "orderCompleted":
      if (role === "buyer") {
        return ["删除记录", "查看订单", "添加评价"];
      } else {
        return ["删除记录", "查看订单"];
      }
    case "buyAwaitingSubmission":
      if (role === "buyer") {
        return ["联系卖家", "查看进度"];
      } else {
        return [];
      }
    case "canceled":
      return ["删除记录", "查看订单"];
    default:
      return [];
  }
};

// 处理订单详情获取
export const fetchOrderDetail = async (
  dispatch: AppDispatch,
  item: any,
  setIssuePopup: (value: boolean) => void
) => {
  try {
    await dispatch(slices.order.actions.queryOrderDetail({ id: item.id }));
    setIssuePopup(true);
  } catch (e) {
    console.log("fetch order error", e);
  }
};

// 处理订单记录删除
export const deleteRecord = async (
  dispatch: AppDispatch,
  id: number,
  role: string
) => {
  Alert.alert("删除订单记录", "确定要删除此订单记录吗？", [
    {
      text: "取消",
      style: "cancel",
    },
    {
      text: "确定",
      onPress: async () => {
        let res;
        try {
          if (role === "buyer") {
            res = await dispatch(
              slices.order.actions.deleteBuyerOrder({ orderId: id })
            ).unwrap(); // 使用 unwrap() 等待操作完成
          } else {
            res = await dispatch(
              slices.order.actions.deleteSellerOrder({ orderId: id })
            ).unwrap();
          }
          alert({
            message: "删除订单记录成功",
          });
          // 等待状态更新后再触发刷新
          setTimeout(() => {
            dispatch(slices.order.actions.setChanged());
          }, 100);
        } catch (error) {
          alert({
            message: "删除订单记录失败",
          });
          console.error("Delete record error:", error);
        }
      },
    },
  ]);
};

// 处理售后记录删除
export const deleteRefund = async (
  dispatch: AppDispatch,
  id: number,
  role: string
) => {
  Alert.alert("删除售后记录", "确定要删除此售后记录吗？", [
    {
      text: "取消",
      style: "cancel",
    },
    {
      text: "确定",
      onPress: async () => {
        try {
          await dispatch(
            slices.order.actions.deleteRefund({ ids: [id] })
          ).unwrap(); // 使用 unwrap() 等待操作完成

          alert({
            message: "删除售后记录成功",
          });
          // 等待状态更新后再触发刷新
          setTimeout(() => {
            dispatch(slices.order.actions.setChanged());
          }, 100);
        } catch (error) {
          alert({
            message: "删除售后记录失败",
          });
          console.error("Delete record error:", error);
        }
      },
    },
  ]);
};

export const goToSellerPage = (sellerId: number) => {
  router.push({
    pathname: "/(outer)/home/user_profile",
    params: {
      memberId: sellerId,
    },
  });
};

// // 处理退款和平台介入
// export const handleIssuePopup = (
//   selectedVal: string,
//   item: any,
//   role: string,
//   setIssuePopup: (value: boolean) => void
// ) => {
//   setIssuePopup(false);

//   // 如果是申请平台介入，先检查是否已经申请过
//   if (
//     selectedVal === "申请平台介入" &&
//     (item?.buyerPlatformFlag || item?.sellerPlatformFlag)
//   ) {
//     Alert.alert("重复申请", "已经申请过平台介入，是否继续申请？", [
//       {
//         text: "取消",
//         style: "cancel",
//       },
//       {
//         text: "确定",
//         onPress: () => {
//           router.push({
//             pathname: "/(outer)/order/application",
//             params: {
//               orderId: item.id,
//               application: "platform",
//               role: role,
//             },
//           });
//         },
//       },
//     ]);
//     return;
//   }

//   // 其他情况直接跳转
//   router.push({
//     pathname: "/(outer)/order/application",
//     params: {
//       orderId: item.id,
//       application: selectedVal === "我要退款" ? "refund" : "platform",
//       role,
//     },
//   });
// };

// // 处理材料问题
// export const handleMaterialPopup = (
//   selectedVal: string,
//   item: any,
//   setMaterialPopup: (value: boolean) => void
// ) => {
//   setMaterialPopup(false);
//   router.push({
//     pathname: "/(outer)/order/application",
//     params: {
//       orderId: item.id,
//       application:
//         selectedVal === "请求买家补充材料" ? "replenish_materials" : "refuse",
//       role: "seller",
//     },
//   });
// };

// // 处理确认接单
// export const handleVerifyOrder = async (
//   dispatch: AppDispatch,
//   item: any,
//   selectedVal: string,
//   setComfirmPopup: (value: boolean) => void
// ) => {
//   setComfirmPopup(false);
//   const params = {
//     orderId: Number(item?.id),
//   };
//   if (selectedVal === "确认接单") {
//     try {
//       const res = await dispatch(slices.order.actions.verifyOrder(params));
//       if (isAxiosSuccess(res.type)) {
//         alert("确认订单成功");
//         router.push({
//           pathname: "/(outer)/order/detail",
//           params: {
//             orderId: item.id,
//             role: "seller",
//           },
//         });
//       } else {
//         alert("确认订单失败");
//       }
//     } catch (err) {
//       console.log("fail to verify order", err);
//     }
//   } else {
//     // 拒绝接单
//     router.push({
//       pathname: "/(outer)/order/detail",
//       params: { orderId: item.id, role: "seller", application: "refuse" },
//     });
//   }
// };

/**
 * @description 根据按钮文本处理按钮点击
 * @param param0
 * @returns
 */
export const handleButtonClick = ({
  dispatch,
  button,
  role,
  item,
  setIssuePopup,
  setMaterialPopup,
  setComfirmPopup,
}: {
  dispatch: AppDispatch;
  button: string;
  role: string;
  item: any;
  setIssuePopup?: (value: boolean) => void;
  setMaterialPopup?: (value: boolean) => void;
  setComfirmPopup?: (value: boolean) => void;
}) => {
  let orderId: any;
  let refundId: any;
  let is_refund: boolean = false;

  if (item?.orderId) {
    orderId = item.orderId;
    refundId = item.id;
    is_refund = true;
  } else {
    // 订单列表
    orderId = item.id;
    refundId = item.refundId;
  }

  switch (button) {
    case "继续支付":
      // 等待接口
      return;
    case "联系卖家":
      goToChat({ dispatch, tenantId: item?.tenantId });
      return;
    case "联系买家":
      goToChat({ dispatch, tenantId: item?.buyerId });
      return;
    case "查看进度":
      goToTimeLine(dispatch, item, role);
      return;
    case "查看订单":
      router.push({
        pathname: "/(outer)/order/detail",
        params: {
          orderId,
          refundId,
          role,
        },
      });
      return;
    case "申请售后":
      if (setIssuePopup) {
        fetchOrderDetail(dispatch, item, setIssuePopup);
      }
      return;
    case "平台介入":
      if (item?.buyerPlatformFlag || item?.sellerPlatformFlag) {
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
                  orderId,
                  application: "platform",
                  role,
                },
              });
            },
          },
        ]);
      } else {
        router.push({
          pathname: "/(outer)/order/application",
          params: {
            orderId,
            application: "platform",
            role,
          },
        });
      }
      return;
    case "材料有问题 ?":
      if (setMaterialPopup) {
        setMaterialPopup(true);
      }
      return;
    case "遇到问题 ?":
      if (setIssuePopup) {
        setIssuePopup(true);
      }
      return;
    case "确认接单":
      if (setComfirmPopup) {
        setComfirmPopup(true);
      }
      return;
    case "删除记录":
      if (is_refund) {
        deleteRefund(dispatch, refundId, role);
      } else {
        deleteRecord(dispatch, orderId, role);
      }
      return;
    case "处理退款":
      if (item?.buyerRefundFlag) {
        router.push({
          pathname: "/(outer)/order/refund",
          params: { refund_id: refundId, role: "seller" },
        });
      }
      return;
    case "去评价":
      router.push(`/(tabs)/profile/orders/${item.id}/`);
      return;
    case "添加评价":
      router.push({
        pathname: "/(tabs)/profile/orders/evaluation",
        params: { orderId: item.id },
      });
      return;
    case "售后详情":
      router.push({
        pathname: "/(outer)/order/refund",
        params: { refund_id: refundId, role: "buyer" },
      });
      return;
    default:
      return;
  }
};

export const handlePlatformIntervene = ({
  buyerPlatformFlag,
  sellerPlatformFlag,
  orderId,
  role,
}: {
  buyerPlatformFlag: boolean;
  sellerPlatformFlag: boolean;
  orderId: number;
  role: string;
}) => {
  if (buyerPlatformFlag || sellerPlatformFlag) {
    toast({
      title: "已经申请过平台介入",
      symbol: "warning",
    });
  } else {
    Alert.alert("是否申请平台介入？", "申请平台介入后，平台将介入处理", [
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
              orderId,
              application: "platform",
              role,
            },
          });
        },
      },
    ]);
  }
};

// 查看进度
export const goToTimeLine = async (
  dispatch: AppDispatch,
  item: any,
  role: string
) => {
  let orderId: any;
  let refundId: any;
  let is_refund: boolean = false;
  // console.log("item", item);
  if (item?.orderId) {
    // item 是售后详情
    orderId = item.orderId;
    refundId = item.id;
    is_refund = true;
  } else if (item?.refundId) {
    // item 是订单详情
    orderId = item.id;
    refundId = item.refundId;
    is_refund = true;
  } else {
    // item 是订单详情
    orderId = item.id;
    is_refund = false;
  }

  if (is_refund) {
    await dispatch(
      slices.order.actions.fetchRefundDetail({
        id: refundId,
      })
    );
  }
  if (role === "buyer") {
    router.push(`/(tabs)/profile/orders/${orderId}/`);
  } else {
    router.push(`/(sellerscreens)/profile/orders/${orderId}/`);
  }
};

// /**
//  * @description: 订单的 BottomSheet 组件
//  * @param {issuePopup, materialPopup, comfirmPopup, setIssuePopup, setMaterialPopup, setComfirmPopup, item, role, dispatch}
//  * @returns
//  */
// export const OrderBottomSheet = ({
//   issuePopup,
//   materialPopup,
//   comfirmPopup,
//   setIssuePopup,
//   setMaterialPopup,
//   setComfirmPopup,
//   item,
//   role,
//   dispatch,
// }: {
//   issuePopup?: boolean;
//   materialPopup?: boolean;
//   comfirmPopup?: boolean;
//   setIssuePopup?: (value: boolean) => void;
//   setMaterialPopup?: (value: boolean) => void;
//   setComfirmPopup?: (value: boolean) => void;
//   item: any;
//   role: string;
//   dispatch: AppDispatch;
// }) => (
//   <BottomSheet
//     isOpen={issuePopup || materialPopup || comfirmPopup}
//     title={issuePopup ? "遇到问题" : materialPopup ? "材料有问题" : "确认接单"}
//     onClose={
//       issuePopup
//         ? () => setIssuePopup && setIssuePopup(false)
//         : materialPopup
//         ? () => setMaterialPopup && setMaterialPopup(false)
//         : () => setComfirmPopup && setComfirmPopup(false)
//     }
//     buttons={
//       issuePopup
//         ? ["我要退款", "申请平台介入"]
//         : materialPopup
//         ? ["请求买家补充材料", "拒绝接单"]
//         : ["确认接单", "拒绝接单"]
//     }
//     snapPoints={[40]}
//     handleConfirm={(selectedVal) =>
//       issuePopup
//         ? setIssuePopup &&
//           handleIssuePopup(selectedVal, item, role, setIssuePopup)
//         : materialPopup
//         ? setMaterialPopup &&
//           handleMaterialPopup(selectedVal, item, setMaterialPopup)
//         : setComfirmPopup &&
//           handleVerifyOrder(dispatch, item, selectedVal, setComfirmPopup)
//     }
//   >
//     {issuePopup || materialPopup || comfirmPopup ? (
//       <ServiceComponent item={item?.items?.[0]} isExpanded={false} />
//     ) : (
//       ""
//     )}
//   </BottomSheet>
// );

/**
 * @description: 展示材料、交付申请的详情组件(用于订单进度,订单详情页面)
 * @param {demandDetail}
 * @returns
 */
export const DemandDetailComponent = memo(
  ({ demandDetail }: { demandDetail: any }) => {
    const { dictData } = useGlobalContext();
    const dict = dictData?.["order_request_type"];
    return (
      <YStack space="$2">
        <XStack flex={0} justifyContent="space-between">
          <Paragraph fontWeight="600">申请类型</Paragraph>
          <Paragraph>{QueryDict(dict, demandDetail?.type).label}</Paragraph>
        </XStack>
        <XStack flex={0} justifyContent="space-between">
          <Paragraph fontWeight="600">具体原因</Paragraph>
          <Paragraph>
            {QueryDict(dict, demandDetail?.reasonLabel).label}
          </Paragraph>
        </XStack>
        <Paragraph fontWeight="600">申请说明</Paragraph>
        <XStack
          flex={0}
          backgroundColor="#EDEDED"
          padding={5}
          paddingHorizontal="$3"
          borderRadius={10}
        >
          {demandDetail?.remarks ? (
            <Paragraph color="$lightGray">
              {QueryDict(dict, demandDetail?.remarks).label}
            </Paragraph>
          ) : (
            <Paragraph color="$lightGray">暂无备注</Paragraph>
          )}
        </XStack>
        <XStack flex={0} justifyContent="space-between">
          <Paragraph fontWeight="600">申请时间</Paragraph>
          <Paragraph>{demandDetail?.createTime}</Paragraph>
        </XStack>
      </YStack>
    );
  }
);

/**
 * @description: 展示买家提交材料的详情
 * @param
 * @returns
 */
export const SubmissionDetail = memo(
  ({
    role,
    length,
    item,
    index,
    tab1Content,
    tab2Content,
    defaultExpanded = true,
    expandLatest = false,
  }: {
    role;
    length;
    item;
    index;
    tab1Content;
    tab2Content;
    defaultExpanded?: boolean;
    expandLatest?: boolean;
  }) => {
    const shouldExpand = expandLatest
      ? index === length - 1 // 如果是expandLatest模式，只展开最后一个
      : defaultExpanded; // 否则使用defaultExpanded的值

    return (
      <Accordion
        flexDirection="column"
        overflow="visible"
        width="100%"
        type="multiple"
        defaultValue={shouldExpand ? [index.toString()] : []}
        gap={0}
      >
        <Accordion.Item value={index.toString()}>
          <Accordion.Trigger flexDirection="row" justifyContent="space-between">
            {({ open }: { open: boolean }) => (
              <>
                <Paragraph>
                  {role === "seller" ? "买家提交" : "你的提交"}
                  <Paragraph>#{index + 1}</Paragraph>
                </Paragraph>
                <Square animation="quick" rotate={open ? "180deg" : "0deg"}>
                  <ChevronDown size="$1" />
                </Square>
              </>
            )}
          </Accordion.Trigger>
          <Accordion.Content>
            <TabsComponent
              tab1Content={tab1Content}
              tab2Content={tab2Content}
            />
            {index === length - 1 && <>{/* 此处显示卖家的申请 */}</>}
          </Accordion.Content>
        </Accordion.Item>
      </Accordion>
    );
  }
);

/**
 * @description: 展示交付的内容（用于detail详情页）
 * @param
 * @returns
 */
export const DeliveryDetail = memo(
  ({
    role,
    totol_num,
    item,
    index,
    setPreviewPopup,
    setPreviewUri,
    setDownloadUri,
  }: {
    role?: string;
    item;
    totol_num: number;
    index;
    setPreviewPopup?: any;
    setPreviewUri?: any;
    setDownloadUri?: any;
  }) => {
    const files = item?.files;

    const previewFile = (uri) => {
      setPreviewUri(uri);
      setPreviewPopup(true);
    };
    return (
      <Accordion
        flexDirection="column"
        overflow="visible"
        width="100%"
        type="multiple"
        defaultValue={[totol_num.toString()]}
      >
        {totol_num === 0 && <Paragraph>暂无交付</Paragraph>}

        <Accordion.Item key={index} value={index.toString()}>
          <Accordion.Trigger
            flexDirection="row"
            justifyContent="space-between"
            alignItems="center"
          >
            {({ open }: { open: boolean }) => (
              <>
                <Paragraph>交付 #{index + 1}</Paragraph>

                <Square animation="quick" rotate={open ? "180deg" : "0deg"}>
                  <ChevronDown size="$1" />
                </Square>
              </>
            )}
          </Accordion.Trigger>
          <Accordion.Content>
            <XStack
              flex={1}
              paddingVertical={10}
              paddingHorizontal={20}
              backgroundColor="#F2F2F2"
              borderRadius={15}
              marginBottom={10}
            >
              <Paragraph>{item?.content}</Paragraph>
            </XStack>
            <YStack padding="$3" gap="$2">
              {Array.isArray(files) &&
                files.length > 0 &&
                files.map((uri, index) => (
                  <XStack
                    alignItems="center"
                    justifyContent="space-between"
                    key={index}
                  >
                    <Button
                      paddingVertical="$3"
                      paddingHorizontal="$2"
                      width="90%"
                      backgroundColor="#EDEDED"
                      flex={0}
                      borderRadius="$2"
                      onPress={() => previewFile(getFilePath(uri))}
                      unstyled
                    >
                      <Paragraph ellipsizeMode="tail" numberOfLines={1}>
                        {uri}
                      </Paragraph>
                    </Button>
                    {/* 下载按钮 : 这里的filename没有参数*/}
                    <FileDownloader url={uri} fileName={String(index)} />
                  </XStack>
                ))}
            </YStack>
            <XStack
              flexDirection="row"
              justifyContent="center"
              alignItems="center"
              height={30}
            >
              <Paragraph color="$lightGray">
                {item?.files?.length}个文件
              </Paragraph>
            </XStack>
          </Accordion.Content>
        </Accordion.Item>
      </Accordion>
    );
  }
);

/**
 * @description: 渲染上传文件的组件（买家要求提交）
 * @param
 * @returns
 */
export const renderTabFileContent = ({
  orderId,
  setIsOpen,
  uploadFiles,
  deleteFile,
  setPreviewUri,
  setPreviewPopup,
}: {
  orderId: number;
  setIsOpen: (isOpen: boolean) => void;
  uploadFiles: any;
  deleteFile: (index: number) => void;
  setPreviewPopup: (previewPopup: boolean) => void;
  setPreviewUri: (uri: string) => void;
}) => {
  const files = uploadFiles?.[orderId];

  let fileNames = [] as string[];
  let fileUris = [] as string[];

  if (files && files !== undefined) {
    fileNames = files.map((file) => file.fileName);
    fileUris = files.map((file) => file.fileUrl);
  }

  const handlePreviewPopup = (uri: string) => {
    setPreviewUri(uri);
    setPreviewPopup(true);
  };

  return (
    <YStack flex={1} width="100%" backgroundColor="#fff" gap="$2">
      {fileNames.length > 0 &&
        fileNames.map((name, index) => (
          <XStack
            width="100%"
            alignItems="center"
            gap="$2"
            key={index}
            justifyContent="space-between"
          >
            <Button
              paddingVertical="$3"
              paddingHorizontal="$2"
              width="80%"
              backgroundColor="#EDEDED"
              flex={0}
              borderRadius="$2"
              onPress={() => handlePreviewPopup(getFilePath(fileUris[index]))}
              unstyled
            >
              <Paragraph numberOfLines={1} ellipsizeMode="tail">
                {name}
              </Paragraph>
            </Button>
            <Button
              unstyled
              paddingHorizontal="$3"
              height="auto"
              onPress={() => deleteFile(index)}
            >
              <ButtonText color="$blue">删除</ButtonText>
            </Button>
          </XStack>
        ))}

      <XStack alignSelf="center">
        <PickUpButton
          width={global.screenWidth - 20}
          height={150}
          setPopup={setIsOpen}
        />
      </XStack>
    </YStack>
  );
};
