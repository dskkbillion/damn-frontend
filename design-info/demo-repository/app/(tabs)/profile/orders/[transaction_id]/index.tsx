import { ChevronDown, ChevronLeft, ChevronRight } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import React, { memo, useCallback, useEffect, useState } from "react";
import { FlatList } from "react-native";
import FastImage from "react-native-fast-image";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H5,
  Paragraph,
  XStack,
  YStack,
  Accordion,
  Square,
  H2,
  Input,
  Label,
  Switch,
  ScrollView,
  Portal,
  styled,
  Separator,
} from "tamagui";

import { goToChat } from "@/components/chat/goToChat";
import BottomSheet from "@/components/orders/bottomsheet_order";
import {
  renderTabFileContent,
  SubmissionDetail,
} from "@/components/orders/common_funcs";
import { DeliveryResComp } from "@/components/orders/delivery_comp";
import { DemandTimeLineComponent } from "@/components/orders/demandTimeline";
import {
  ButtomButton,
  MaterialProvider,
  useMaterial,
} from "@/components/orders/fixed_bottom_buyer";
import ServiceComponent from "@/components/orders/service_comp";
import StarRating from "@/components/orders/star_rating";
import TabsComponent, {
  TabFileContent,
  TabTextContent,
} from "@/components/orders/tabs_comp";
import { TimeLineComponent } from "@/components/orders/timeline";
import { QueryDict } from "@/components/queryDict";
import {
  BottomMultiplePicker,
  BottomImagePickerSheet,
} from "@/components/styled/bottomsheet_picker";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { ImagePreviewEditComp } from "@/components/styled/preview_image";
import { toast } from "@/components/styled/toast";
import {
  getFilePath,
  goToUpload,
  PreviewComp,
} from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";
import { MaterialDemandDetail } from "@/components/orders/material_comp";
import { useGlobalContext } from "@/components/system/globalContext";

const OrderInProgress = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const params = useLocalSearchParams();
  const id = params.transaction_id;
  const orderData = useSelector((state: RootState) => state.order.order);
  const orderState = useSelector((state: RootState) => state.order.orderState);
  const changed = useSelector((state: RootState) => state.order.changed);

  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(id) }));
    dispatch(fileSlice.file.actions.setOrderId(Number(id)));
  }, [dispatch, orderState, changed]);

  useEffect(() => {
    dispatch(slices.order.actions.clearOrderDetail());
    dispatch(fileSlice.file.actions.clearAllImages());
    dispatch(fileSlice.file.actions.clearAllFiles());
  }, [id]);

  return (
    <MaterialProvider>
      {/* background */}
      <XStack
        position="absolute"
        left={0}
        top={0}
        width={global.screenWidth}
        height={global.screenHeight * 0.25}
        backgroundColor="$brown"
      />
      {/* back button */}
      <Button
        backgroundColor="transparent"
        position="absolute"
        top={global.screenHeight * 0.06}
        left={global.screenWidth * 0.05}
        onPress={() => router.push("/(tabs)/profile/orders")}
        unstyled
      >
        <ChevronLeft size={35} color="#fff" />
      </Button>
      {/* timeline */}
      <XStack
        flexDirection="row"
        justifyContent="center"
        marginTop={global.screenHeight * 0.12}
        alignSelf="center"
        flexGrow={1}
      >
        <TimeLineComponent
          state={orderData?.state}
          role="buyer"
          order={orderData}
        >
          <OrderContent state={orderData?.state} order={orderData} />
          <ButtomButton state={orderData?.state} isDialog />
        </TimeLineComponent>
      </XStack>
    </MaterialProvider>
  );
});

export default OrderInProgress;
/*
 ____________________________________________________________
 根据状态渲染不同的页面
 ____________________________________________________________
*/

const OrderContent = ({ state, ...props }) => {
  // if (props.order?.buyerRefundFlag) {
  //   return <BuyerRefundPage order={props.order} />;
  // }
  switch (state) {
    // 已支付：等待提交要求
    case "awaitingSubmission":
      return <AwaitingSubmissionForBuyer order={props.order} />;
    // 已提交要求：等待开始
    case "awaitingStart":
    case "buyAwaitingSubmission":
      return <AwaitingStartForBuyer order={props.order} />;
    // 已开始：等待交付
    case "awaitingDelivery":
      return <AwaitingDeliveryForBuyer order={props.order} />;
    // 已交付：等待确认
    case "awaitingConfirmation":
    case "sellerSupplementaryMaterials":
    case "applyForRefuse":
      return <AwaitingConfirmForBuyer order={props.order} />;
    case "awaitingEvaluation":
      return <AwaitingEvaluationForBuyer />;
    case "orderCompleted":
      return <OrderCompelet order={props.order} />;
    case "afterSale":
      return <AfterSale />;
  }
};

export const AwaitingSubmissionForBuyer = ({ order }) => {
  const {
    textMaterialsVos,
    fileMaterialsVos,
    feature,
    files,
    setFeature,
    setFiles,
  } = useMaterial();
  const [popup, setPopup] = useState(false);
  const orderMaterials = order?.orderMaterials;
  const dispatch = useDispatch<AppDispatch>();
  const materialFiles = useSelector(
    (state: RootState) => state.file.materialFiles
  );
  const [isOpen, setIsOpen] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const [previewPopup, setPreviewPopup] = useState(false);

  const renderTabTextContent = (item) => {
    const handleInputChange = (index, value) => {
      setFeature((prev) => ({
        ...prev,
        [index]: value,
      }));
    };

    return (
      <YStack style={{ flex: 1 }}>
        <YStack style={{ flex: 1, justifyContent: "center", padding: 16 }}>
          {textMaterialsVos.map((item, index) => (
            <YStack key={index} marginBottom={16}>
              <Paragraph marginBottom="$2">
                {index + 1}. {item?.question}
              </Paragraph>
              <Input
                width="100%"
                height={40}
                placeholder="请输入"
                value={feature[index]}
                onChangeText={(value) => handleInputChange(index, value)}
              />
            </YStack>
          ))}
        </YStack>
      </YStack>
    );
  };

  const deleteFile = (index: number) => {
    dispatch(fileSlice.file.actions.deleteFile(index));
  };

  useEffect(() => {
    const files = materialFiles?.[order?.id];
    if (Array.isArray(files) && files.length > 0) {
      setFiles(files.map((file) => file.fileUrl));
    }
  }, [materialFiles]);

  return (
    <KeyboardAwareScrollView
      style={{ flex: 1, width: "100%" }}
      resetScrollToCoords={{ x: 0, y: 0 }}
      extraScrollHeight={50}
      scrollEnabled
      contentContainerStyle={{ paddingBottom: 100 }}
    >
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}

      <YStack marginBottom={50} backgroundColor="#fff" padding="$3">
        <ServiceComponent item={order.items[0]} />
      </YStack>
      <YStack flexDirection="column" backgroundColor="#fff" padding="$3">
        <H5 marginBottom="$3">要求提交</H5>
        <TabsComponent
          tab1Content={renderTabTextContent(order)}
          tab2Content={renderTabFileContent({
            orderId: order?.id,
            uploadFiles: materialFiles,
            deleteFile,
            setIsOpen,
            setPreviewUri,
            setPreviewPopup,
          })}
        />
      </YStack>
      {/* 底部弹窗：选择上传类型 */}
      <BottomMultiplePicker
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        position={0}
        zIndex={100000}
        limit={9}
        type="material"
      />
    </KeyboardAwareScrollView>
  );
};

const AwaitingStartForBuyer = ({ order }) => {
  const dispatch = useDispatch<AppDispatch>();
  const demandList = useSelector((state: RootState) => state.order.demandList);
  const orderMaterials = order?.orderMaterials;
  const textMaterials = {} as any;
  const filesMaterials = {} as any;
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  // const timeLeft = useCountdown({targetTimestamp: })
  // 遍历orderMaterials数组，提取数据
  orderMaterials.forEach((material, index) => {
    textMaterials[index] = material.feature;
    filesMaterials[index] = material.files;
  });

  let currentDemand = {} as any;
  if (demandList && Object.keys(demandList).length > 0) {
    currentDemand = demandList[demandList.length - 1];
  }

  useEffect(() => {
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: order.id,
        memberType: "seller",
        type: "material",
      })
    );
  }, [order, dispatch]);

  return (
    <YStack flex={1} flexGrow={1}>
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}

      <FlatList
        data={Array.from(
          { length: orderMaterials.length },
          (_, index) => index
        )}
        renderItem={({ item, index }) => (
          <YStack flex={1}>
            {index === 0 && (
              <MaterialDemandDetail
                role="buyer"
                order={order}
                materialDemand={currentDemand}
              />
            )}
            <SubmissionDetail
              key={index}
              item={item}
              index={index}
              role="buyer"
              length={order?.orderMaterials.length}
              tab1Content={
                <TabTextContent textMaterial={textMaterials[index]} />
              }
              tab2Content={
                <TabFileContent
                  filesMaterial={filesMaterials[index]}
                  setPreviewPopup={setPreviewPopup}
                  setPreviewUri={setPreviewUri}
                />
              }
              expandLatest
            />
          </YStack>
        )}
        contentContainerStyle={{ paddingBottom: 100 }}
      />
    </YStack>
  );
};

const AwaitingDeliveryForBuyer = ({ order }) => {
  useEffect(() => {}, []);
  const goToRefund = useCallback(async () => {
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: order?.id,
        application: "refund",
        role: "buyer",
      },
    });
  }, []);

  return (
    <YStack flex={1} flexGrow={1}>
      <YStack
        width="100%"
        backgroundColor="#fff"
        justifyContent="center"
        paddingVertical="$3"
        alignItems="center"
      >
        <Paragraph>
          您购买的服务包含
          <Paragraph color="$red">{order?.items?.[0]?.editNum}</Paragraph>
          次交付次数
        </Paragraph>
        <H2 fontSize={20} color="$gray8" alignSelf="center" marginVertical="$3">
          卖家暂未交付，请耐心等待
        </H2>
        <Button
          onPress={() =>
            router.push({
              pathname: "/(outer)/order/detail",
              params: {
                orderId: order.id,
                refundId: order.refundId,
                role: "buyer",
              },
            })
          }
          width="100%"
          height={40}
        >
          <ButtonText color="$blue">查看已提交的材料</ButtonText>
          <ChevronRight size="$1" color="$blue" />
        </Button>
      </YStack>
      <ScrollView marginTop="$3">
        <YStack padding="$3" backgroundColor="#fff">
          <ServiceComponent item={order?.items?.[0]} />
        </YStack>

        <YStack
          justifyContent="center"
          alignItems="center"
          width="100%"
          marginTop="20%"
        >
          <AlertDialogComponent
            title="申请退款"
            description="卖家已开始制作，当前申请退款可以需要按比例扣费，是否继续申请退款？"
            handleConfirm={goToRefund}
          >
            <Button
              width="40%"
              height={40}
              backgroundColor="$brown"
              borderRadius={20}
              textAlign="center"
              alignSelf="center"
              justifyContent="center"
              color="#fff"
              unstyled
            >
              <ButtonText> 申请退款{order?.id}</ButtonText>
            </Button>
          </AlertDialogComponent>
          <Paragraph color="$lightGray" marginTop="$3" width="80%">
            卖家已开始制作，当前申请退款可能需要按比例扣费,具体费用请与卖家协商
          </Paragraph>
        </YStack>
      </ScrollView>
    </YStack>
  );
};

const AwaitingConfirmForBuyer = ({ order }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [issuePopup, setIssuePopup] = useState(false);
  const deliveryList = useSelector(
    (state: RootState) => state.order.deliveryList
  );
  const [unprocessedDemand, setUnProcessedDemand] = useState([] as any);
  const demandList = useSelector(
    (state: RootState) => state.order.deliveryDemand
  );
  const orderState = useSelector((state: RootState) => state.order.orderState);

  // 先声明 demandExisted
  const [demandExisted, setDemandExisted] = useState(false);
  // 然后再使用 demandExisted 初始化 accordionValue
  const [accordionValue, setAccordionValue] = useState<string[]>([]);

  const [currentDemand, setCurrentDemand] = useState({} as any);
  const [delivered, setDelivered] = useState(false);
  const [available, setAvailable] = useState(false);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");

  const previewFile = (uri) => {
    setPreviewUri(uri);
    setPreviewPopup(true);
  };

  const handleButtonClick = useCallback(
    (button) => {
      switch (button) {
        case "联系卖家":
          goToChat({ dispatch, tenantId: order?.tenantId });
          return;
        case "查看详情":
        case "处理申请":
          router.push(
            `/(tabs)/profile/orders/${order?.id}/${currentDemand?.id}/detail`
          );
          return;

        case "平台介入":
          router.push({
            pathname: "/(outer)/order/application",
            params: {
              orderId: order?.id,
              application: "platform",
              role: "buyer",
            },
          });
          return;
        default:
          return;
      }
    },
    [currentDemand]
  );

  // 重置所有状态的函数
  const resetStates = useCallback(() => {
    setDemandExisted(false);
    setAccordionValue([]);
    setCurrentDemand({});
    setDelivered(false);
    setAvailable(true);
  }, []);

  // 在组件挂载和order改变时重置状态
  useEffect(() => {
    resetStates();
  }, [order?.id]); // 只在订单ID改变时重置

  // 获取demandList和deliveryList
  useEffect(() => {
    if (order?.id) {
      const params = {
        orderId: Number(order?.id),
        memberType: "buyer",
      };
      dispatch(
        slices.order.actions.queryDemandList({
          ...params,
          type: "delivery",
        })
      );
      dispatch(slices.order.actions.queryDeliveryList(params));
    }
  }, [order?.id]);

  // 处理需求列表变化
  useEffect(() => {
    if (demandList && Array.isArray(demandList) && demandList.length > 0) {
      setDemandExisted(true);
      setCurrentDemand(demandList[demandList.length - 1]);
      setAccordionValue(["item-1"]); // 有需求时展开

      // 判断已交付的情况
      setDelivered(
        currentDemand?.status === "SUCCESS" &&
          orderState === "awaitingConfirmation"
      );

      // 判断是否可以申请修改
      if (
        (currentDemand?.status === "SUCCESS" &&
          orderState === "awaitingConfirmation") ||
        !demandExisted
      ) {
        setAvailable(true);
      } else {
        setAvailable(false);
      }
    } else {
      // 确保当没有申请时重置所有状态
      resetStates();
    }
  }, [demandList, orderState, currentDemand?.status]);

  useEffect(() => {
    if (demandList && deliveryList.length > 0) {
      const unprocessedRes = deliveryList.filter((demand) => {
        return demand.status === "WAIT";
      });
      setUnProcessedDemand(unprocessedRes);
    }
  }, [deliveryList]);

  const handleIssuePopup = () => {
    setIssuePopup(true);
  };
  const handleConfirm = (selectedApplication: string) => {
    let param;
    if (selectedApplication === "我要修改") {
      param = "reform";
    } else {
      param = "refund";
    }
    setIssuePopup(false);
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: order.id,
        application: param,
        role: "buyer",
      },
    });
  };

  if (deliveryList.length === 0 || deliveryList === undefined) {
    return null;
  }

  return (
    <YStack flex={1} flexGrow={1}>
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}

      <FlatList
        data={deliveryList}
        keyExtractor={(item, index) => "delivery" + index}
        contentContainerStyle={{ paddingBottom: 100, marginTop: 10 }}
        showsVerticalScrollIndicator={false}
        renderItem={({ item, index }) => (
          <YStack>
            {index === 0 && (
              <XStack
                width="95%"
                borderRadius={20}
                alignSelf="center"
                backgroundColor="#fff"
                justifyContent="center"
                paddingVertical="$3"
                marginBottom="$3"
              >
                <Accordion
                  type="single"
                  value={accordionValue[0]}
                  onValueChange={(value) =>
                    setAccordionValue(value ? [value] : [])
                  }
                  width="100%"
                  overflow="visible"
                  collapsible
                  borderWidth={0}
                >
                  <Accordion.Item
                    value="item-1"
                    borderRadius={0}
                    borderColor="transparent"
                  >
                    <Accordion.Trigger
                      flexDirection="row"
                      justifyContent="space-between"
                      paddingHorizontal="4%"
                      paddingVertical="$1"
                      style={{ backgroundColor: "#ffffff" }}
                      unstyled
                    >
                      {({ open }: { open: boolean }) => (
                        <>
                          <YStack>
                            <YStack width="100%">
                              <Paragraph>你的申请</Paragraph>
                              {unprocessedDemand &&
                                unprocessedDemand.length > 0 && (
                                  <YStack
                                    width={15}
                                    height={15}
                                    backgroundColor="#EB9091"
                                    borderRadius={999}
                                    alignItems="center"
                                    justifyContent="center"
                                  >
                                    <Paragraph
                                      style={{ color: "#fff", fontSize: 12 }}
                                    >
                                      {unprocessedDemand.length}
                                    </Paragraph>
                                  </YStack>
                                )}
                              <Paragraph color="$lightGray">
                                本服务包含
                                <Paragraph color="$red">
                                  {order?.items?.[0]?.editNum}
                                </Paragraph>
                                次交付次数，现已交付{deliveryList.length}次
                              </Paragraph>
                              <Paragraph color="$brown">
                                交付次数内的申请将会被自动处理
                              </Paragraph>
                            </YStack>
                          </YStack>

                          <Square
                            animation="quick"
                            rotate={open ? "180deg" : "0deg"}
                          >
                            <ChevronDown size="$1" />
                          </Square>
                        </>
                      )}
                    </Accordion.Trigger>
                    <Accordion.Content
                      width="100%"
                      borderRadius={20}
                      height={
                        demandExisted
                          ? global.screenHeight * 0.4
                          : global.screenHeight * 0.2
                      }
                      backgroundColor="#fff"
                    >
                      {demandExisted && (
                        <XStack
                          flex={0}
                          justifyContent="space-between"
                          alignItems="center"
                          backgroundColor="#EDEDED"
                          borderRadius={20}
                          paddingHorizontal="$3"
                        >
                          <YStack alignItems="flex-start">
                            <Paragraph color="$darkGary">最近申请</Paragraph>
                            <Paragraph color="$darkGray">
                              {currentDemand?.createTime}
                            </Paragraph>
                          </YStack>
                          <Button
                            backgroundColor="transparent"
                            borderRadius={20}
                            paddingVertical={3}
                            paddingHorizontal="$3"
                            height={35}
                            unstyled
                            onPress={() =>
                              router.push(
                                `/(tabs)/profile/orders/${order.id}/${currentDemand.id}/delivery/demand_list`
                              )
                            }
                          >
                            <ButtonText color="$blue">查看更多</ButtonText>
                          </Button>
                        </XStack>
                      )}
                      <YStack
                        height={demandExisted ? "60%" : "100%"}
                        flexDirection="column"
                        justifyContent="center"
                        marginBottom="$2"
                        marginTop={demandExisted ? "$8" : "$0"}
                        // marginTop="$8"
                      >
                        {demandExisted ? (
                          <>
                            {/* 需求时间线 */}
                            <DemandTimeLineComponent
                              currentStatus={
                                delivered ? "DELIVERED" : currentDemand?.status
                              }
                              role="buyer"
                              type={currentDemand?.type}
                            />
                            <DemandButtonShow
                              status={
                                delivered ? "DELIVERED" : currentDemand?.status
                              }
                              handleButtonClick={handleButtonClick}
                            />
                          </>
                        ) : (
                          <H2 fontSize={16} color="$gray8" alignSelf="center">
                            暂无申请，等待您确认收货
                          </H2>
                        )}
                      </YStack>
                    </Accordion.Content>
                  </Accordion.Item>
                </Accordion>
              </XStack>
            )}
            <Accordion
              flexDirection="column"
              overflow="visible"
              width="100%"
              type="multiple"
              defaultValue={[(deliveryList.length - 1).toString()]}
            >
              {deliveryList.length === 0 && (
                <Paragraph>卖家，请耐心等待</Paragraph>
              )}

              <Accordion.Item key={index} value={index.toString()}>
                <Accordion.Trigger
                  flexDirection="row"
                  justifyContent="space-between"
                  alignItems="center"
                >
                  {({ open }: { open: boolean }) => (
                    <>
                      <Paragraph>交付 #{index + 1}</Paragraph>

                      <Square
                        animation="quick"
                        rotate={open ? "180deg" : "0deg"}
                      >
                        <ChevronDown size="$1" />
                      </Square>
                    </>
                  )}
                </Accordion.Trigger>
                <Accordion.Content>
                  <DeliveryResComp item={item} previewFile={previewFile} />
                  {index === deliveryList.length - 1 && (
                    <>
                      <Button
                        width="60%"
                        height={global.screenHeight * 0.04}
                        borderColor="rgba(0,0,0,0.5)"
                        borderWidth={1}
                        alignSelf="center"
                        marginTop={30}
                        onPress={() => handleIssuePopup()}
                        // 订单状态为等待确认，且申请不在处理状态中时，按钮不可点击
                        disabled={!available}
                      >
                        <ButtonText>
                          {available ? "对交付不满意 ?" : "已申请卖家重新交付"}
                        </ButtonText>
                      </Button>

                      <BottomSheet
                        isOpen={issuePopup}
                        title={`交付 # ${index + 1} (剩余交付${
                          order?.items?.[0]?.editNum - (index + 1) > 0
                            ? order?.items?.[0]?.editNum - (index + 1)
                            : 0
                        }次)`}
                        onClose={() => setIssuePopup(false)}
                        buttons={["我要修改", "我要退款"]}
                        snapPoints={[50]}
                        handleConfirm={handleConfirm}
                      >
                        <YStack flex={1} alignItems="center">
                          <XStack
                            backgroundColor="#fff"
                            width="90%"
                            paddingHorizontal={10}
                            paddingVertical={2}
                            borderRadius={10}
                            borderWidth={1}
                            borderColor="#ddd"
                            shadowColor="#000" // 阴影效果 (iOS)
                            shadowOffset={{ width: 0, height: 2 }}
                            shadowOpacity={0.5}
                            shadowRadius={4}
                            // elevation={5} // 阴影效果 (Android)
                            borderTopWidth={1} // 高亮效果（上方边缘）
                            borderTopColor="#fff"
                            marginBottom="$5"
                          >
                            <Paragraph color="$brown">
                              剩余交付次数不足时，请先与卖家确认其是否同意再次交付
                            </Paragraph>
                          </XStack>
                          {issuePopup ? (
                            <ServiceComponent
                              item={order?.items?.[0]}
                              isExpanded={false}
                            />
                          ) : (
                            ""
                          )}
                        </YStack>
                      </BottomSheet>
                    </>
                  )}
                </Accordion.Content>
              </Accordion.Item>
            </Accordion>
          </YStack>
        )}
      />
    </YStack>
  );
};

const DemandButtonShow = memo(
  ({
    status,
    handleButtonClick,
  }: {
    status: string;
    handleButtonClick: (button: string) => void;
  }) => {
    let buttons;
    switch (status) {
      case "DELIVERED":
        buttons = ["联系卖家", "查看详情"];
        break;
      case "WAIT":
        buttons = ["联系卖家", "查看详情"];
        break;
      case "SUCCESS":
        buttons = ["联系卖家", "查看详情"];
        break;
      case "FAIL":
        buttons = ["平台介入", "查看详情", "联系买家"];
        break;
      default:
        buttons = ["联系卖家", "查看详情"];
        break;
    }
    return (
      <XStack flex={0} marginLeft="auto" space="$2" marginTop="$3">
        {buttons &&
          buttons.map((button, index) => (
            <Button
              key={index}
              backgroundColor={index === buttons.length - 1 ? "$brown" : "#fff"}
              borderRadius={20}
              borderWidth={1}
              borderColor="$brown"
              paddingVertical={3}
              paddingHorizontal="$3"
              height={35}
              onPress={() => handleButtonClick(button)}
            >
              <ButtonText
                color={index === buttons.length - 1 ? "#fff" : "$brown"}
              >
                {button}
              </ButtonText>
            </Button>
          ))}
      </XStack>
    );
  }
);

const AwaitingEvaluationForBuyer = () => {
  const dispatch = useDispatch<AppDispatch>();
  const order = useSelector((state: RootState) => state.order.order);
  const {
    evaluation_score,
    setEvaluationScore,
    evaluation_comment,
    setEvaluationComment,
    anonumityFlag,
    setAnonumityFlag,
  } = useMaterial();
  const [ratingLevel, setRatingLevel] = useState("未评分");
  const [firstUpload, setFirstUpload] = useState(true);
  const [pickImagePopup, setPickImagePopup] = useState(false);
  const [modal, setModal] = useState(false);
  const evalImages = useSelector((state: RootState) => state.file.evalImages);
  const [previewIndex, setPreviewIndex] = useState(0);
  const [showAddButton, setShowAddButton] = useState(true);

  const maxLength = 200;

  useEffect(() => {}, []);
  const handleRatingChange = (newRating) => {
    setEvaluationScore(newRating);
    setRatingLevel(renderRatingLvel(newRating));

    function renderRatingLvel(rating: number): string {
      if (rating === 1) {
        return "不满意";
      } else if (rating === 2) {
        return "较不满意";
      } else if (rating === 3) {
        return "一般";
      } else if (rating === 4) {
        return "满意";
      } else if (rating === 5) {
        return "非常满意";
      } else {
        return "未评分";
      }
    }
  };

  const handleImageClick = (index: number) => {
    // 打开蒙版
    setModal(true);
    // 设置预览图片
    setPreviewIndex(index);
  };

  const deleteImage = (index: number) => {
    dispatch(fileSlice.file?.actions.deleteImage(index));
  };

  const handleSubmit = () => {
    if (!evaluation_score) {
      toast({
        title: "请先评分",
        message: "请先评分",
        symbol: "xmark",
        haptic: "error",
      });
      return;
    }
    if (!evaluation_comment.trim() && evalImages.length === 0) {
      toast({
        title: "请先评论或上传图片",
        message: "请先评论或上传图片",
        symbol: "xmark",
        haptic: "error",
      });
      return;
    }

    const images = evalImages.map((image) => image.imgUrl);
    const params = {
      orderId: Number(order.id),
      score: evaluation_score,
      remark: evaluation_comment,
      images,
      anonumityFlag,
    };
    dispatch(slices.order.actions.evaluateOrder(params));
  };

  useEffect(() => {
    if (evalImages.length === 0) {
      setFirstUpload(true);
    }
  }, [evalImages]);

  return (
    <KeyboardAwareScrollView
      style={{ flex: 1, width: "100%" }}
      resetScrollToCoords={{ x: 0, y: 0 }}
      extraScrollHeight={220}
      scrollEnabled
      contentContainerStyle={{ paddingBottom: 100 }}
    >
      {modal && (
        <Portal>
          <ImagePreviewEditComp
            images={evalImages}
            previewIndex={previewIndex}
            modal={modal}
            setModal={setModal}
            deleteImage={deleteImage}
            type="eval"
          />
        </Portal>
      )}
      <YStack backgroundColor="#fff" padding={20}>
        <ServiceComponent item={order?.items?.[0]} />
      </YStack>

      <YStack
        display="flex"
        flexDirection="column"
        justifyContent="flex-start"
        backgroundColor="#fff"
        padding={20}
      >
        <H2 fontSize={14} marginLeft={3}>
          您对本次服务的评价
        </H2>
        <XStack flex={0} alignItems="center" justifyContent="center">
          <StarRating
            maxStars={5}
            initialRating={3}
            onRatingChange={handleRatingChange}
          />
          <Paragraph textAlign="center" marginLeft="auto" color="$darkGray">
            {ratingLevel}
          </Paragraph>
        </XStack>
      </YStack>

      <YStack
        display="flex"
        flexDirection="column"
        backgroundColor="#fff"
        padding={20}
        marginTop={20}
      >
        <H2 fontSize={14}>评论</H2>

        <YStack space="$3" width="100%">
          <Input
            multiline
            numberOfLines={4}
            value={evaluation_comment}
            onChangeText={setEvaluationComment}
            placeholder="请输入您的评论..."
            textAlignVertical="top"
            borderWidth={1}
            borderColor="$borderColor"
            borderRadius="$2"
            padding="$2"
            height={150}
            backgroundColor="#EDEDED"
          />
          <Paragraph fontSize="$2" color="$gray8" marginLeft="auto">
            {evaluation_comment.length}/{maxLength} 字
          </Paragraph>

          <YStack space="$2">
            <Paragraph color="$lightGray" fontSize={12}>
              上传图片(帮助他人更好的了解服务)
            </Paragraph>
            {firstUpload ? (
              <Button
                width="100%"
                height={(global.screenWidth * 0.92 - 20 - 26) / 3}
                backgroundColor="$bottomColor"
                onPress={() => setPickImagePopup(true)}
              >
                <SvgXml
                  height="30%"
                  xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
                />
              </Button>
            ) : (
              <XStack
                flexWrap="wrap"
                gap={10}
                justifyContent="flex-start"
                width="100%"
              >
                {evalImages.map((image, index) => (
                  <Button
                    key={index}
                    onPress={() => handleImageClick(index)}
                    unstyled
                  >
                    <FastImage
                      source={{ uri: getFilePath(image.imgUrl) }}
                      style={{
                        width: (global.screenWidth * 0.8) / 3, // 减去 gap 的宽度
                        aspectRatio: 1,
                      }}
                    />
                  </Button>
                ))}
                {showAddButton && (
                  <Button
                    key="button"
                    width={(global.screenWidth * 0.8) / 3}
                    height={(global.screenWidth * 0.8) / 3}
                    backgroundColor="#EDEDED"
                    alignItems="center"
                    justifyContent="center"
                    onPress={() => setPickImagePopup(true)}
                    unstyled
                  >
                    <SvgXml
                      height="30%"
                      xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
                    />
                  </Button>
                )}
              </XStack>
            )}
          </YStack>

          <XStack space="$3" alignItems="center">
            <Label
              htmlFor="anonymous-switch"
              flex={1}
              fontSize={14}
              color="$darkGray"
            >
              匿名评论
            </Label>
            <Switch
              id="anonymous-switch"
              size="$2"
              checked={anonumityFlag}
              onCheckedChange={setAnonumityFlag}
              backgroundColor={anonumityFlag ? "$brown" : "gray"}
            >
              <Switch.Thumb animation="quick" backgroundColor="#fff" />
            </Switch>
          </XStack>
          <AlertDialogComponent
            title="提交评论"
            description="确定提交评论吗？"
            handleConfirm={handleSubmit}
          >
            <Button
              height={40}
              alignSelf="center"
              marginTop="$3"
              backgroundColor="$brown"
              width="50%"
              color="#fff"
            >
              提交评论
            </Button>
          </AlertDialogComponent>
        </YStack>
      </YStack>
      <BottomImagePickerSheet
        isOpen={pickImagePopup}
        onClose={setPickImagePopup}
        goToUpload={(action) =>
          goToUpload({
            action,
            setPopup: setPickImagePopup,
            setFirstUpload,
            selectionLimit: 9,
            dispatch,
            type: "eval",
          })
        }
      />
    </KeyboardAwareScrollView>
  );
};

const OrderCompelet = ({ order }: { order: any }) => {
  useEffect(() => {}, []);
  return (
    <YStack flex={1} flexGrow={1} justifyContent="center" alignItems="center">
      <Button
        backgroundColor="$brown"
        height={40}
        width={100}
        onPress={() =>
          router.push({
            pathname: "/(outer)/order/detail",
            params: {
              orderId: order.id,
              refundId: order.refundId,
              role: "buyer",
            },
          })
        }
        marginBottom="20%"
      >
        <ButtonText color="#fff">查看详情</ButtonText>
      </Button>
    </YStack>
  );
};

const AfterSale = () => {
  return (
    <YStack>
      <Paragraph>售后</Paragraph>
    </YStack>
  );
};

// const BuyerRefundPage = memo(({ order }: { order: any }) => {
//   const { dictData } = useGlobalContext();

//   const refundDetail = useSelector(
//     (state: RootState) => state.order.refundDetail
//   );
//   const StyledXstack = styled(XStack, {
//     justifyContent: "space-between",
//   });

//   return (
//     <YStack flex={1}>
//       <YStack backgroundColor="#fff" marginTop="$3" padding="$3">
//         <ServiceComponent item={order?.items?.[0]} />
//       </YStack>
//       <YStack
//         paddingHorizontal="$3"
//         backgroundColor="#fff"
//         gap="$1"
//         paddingVertical="$5"
//       >
//         <StyledXstack>
//           <Paragraph>退款类型</Paragraph>
//           <Paragraph>
//             {QueryDict(dictData["refund_type"], refundDetail?.refundType).label}
//           </Paragraph>
//         </StyledXstack>
//         <StyledXstack>
//           <Paragraph>退款金额</Paragraph>
//           <Paragraph>{refundDetail?.refundPrice}</Paragraph>
//         </StyledXstack>
//         <StyledXstack>
//           <Paragraph>退款原因</Paragraph>
//           <Paragraph>{refundDetail?.refundReason}</Paragraph>
//         </StyledXstack>
//         <YStack>
//           <Paragraph>退款说明</Paragraph>
//           <XStack
//             paddingHorizontal="$3"
//             paddingVertical="$2"
//             width="90%"
//             alignSelf="center"
//             backgroundColor="#EDEDED"
//             borderRadius={20}
//           >
//             <Paragraph>{refundDetail?.refundReason}</Paragraph>
//           </XStack>
//         </YStack>
//         <Separator marginVertical="$2" />
//         <StyledXstack>
//           <Paragraph>申请时间</Paragraph>
//           <Paragraph>{refundDetail?.createTime}</Paragraph>
//         </StyledXstack>
//         <StyledXstack>
//           <Paragraph>处理编号</Paragraph>
//           <Paragraph>{refundDetail?.refundSn}</Paragraph>
//         </StyledXstack>
//       </YStack>
//     </YStack>
//   );
// });
