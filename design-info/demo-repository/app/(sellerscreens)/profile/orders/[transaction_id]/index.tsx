import {
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  X,
} from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import React, { memo, useCallback, useEffect, useState } from "react";
import { Text, FlatList } from "react-native";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDispatch, useSelector } from "react-redux";
import {
  Accordion,
  Button,
  ButtonText,
  H2,
  H5,
  Paragraph,
  Portal,
  Square,
  TextArea,
  XStack,
  YStack,
} from "tamagui";

import {
  BottomMultiplePicker,
  isImage,
  PreviewBasedOnUrl,
  PreviewComp,
} from "@/components/utils/filesystem";
import BottomSheet from "@/components/orders/bottomsheet_order";
import { renderTabFileContent } from "@/components/orders/common_funcs";
import { DeliveryResComp } from "@/components/orders/delivery_comp";
import { DemandTimeLineComponent } from "@/components/orders/demandTimeline";
import {
  ButtomButton,
  DeliveryProvider,
  useDelivery,
} from "@/components/orders/fixed_bottom_seller";
import ServiceComponent from "@/components/orders/service_comp";
import TabsComponent from "@/components/orders/tabs_comp";
import { TimeLineComponent } from "@/components/orders/timeline";
import { QueryDict } from "@/components/queryDict";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";
import { useGlobalContext } from "@/components/system/globalContext";

const OrderInProgress = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const params = useLocalSearchParams();
  const id = params.transaction_id;
  const orderData = useSelector((state: RootState) => state.order.order);
  const orderState = useSelector((state: RootState) => state.order.orderState);

  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(id) }));
    dispatch(fileSlice.file.actions.setOrderId(Number(id)));
  }, [dispatch, orderState]);

  useEffect(() => {
    dispatch(slices.order.actions.clearOrderDetail());
    dispatch(fileSlice.file.actions.clearAllImages());
    dispatch(fileSlice.file.actions.clearAllFiles());
  }, [id]);

  return (
    <DeliveryProvider>
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
        onPress={() => router.back()}
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
        {/* 如果orderState不等于order中的状态，说明卖家处理了买家的申请，order中的状态回退了，但orderState保持原来的状态
          时间线上仍然显示原有状态
        */}
        <TimeLineComponent
          state={
            orderState === orderData?.state ? orderData?.state : orderState
          }
          role="seller"
          order={orderData}
        >
          <OrderContent state={orderData?.state} order={orderData} />
          <ButtomButton state={orderData?.state} isDialog />
        </TimeLineComponent>
      </XStack>
    </DeliveryProvider>
  );
});

export default OrderInProgress;
/*
-------------------------------------------------------------------------------
*/

const OrderContent = ({ state, ...props }) => {
  switch (state) {
    case "awaitingSubmission":
      return <AwaitingStartForSeller order={props.order} />;
    case "awaitingStart":
      return <AwaitingStartForSeller order={props.order} />;
    case "awaitingDelivery":
      return <AwaitingDeliveryForSeller order={props.order} />;

    case "awaitingConfirmation":
    case "sellerSupplementaryMaterials":
    case "applyForRefuse":
      return <AwaitingConfirmForSeller order={props.order} />;
    // case "awaitingEvaluation":
    case "awaitingEvaluation":
      console.log("sjsopsjqpjxwjd");
      return <AwaitingEvaluationForSeller order={props.order} />;
    case "orderCompleted":
      return <OrderCompelet order={props.order} />;
    case 7:
      return <Paragraph>8</Paragraph>;
    case 8:
      return <Paragraph>9</Paragraph>;
  }
};
// the page that shows the files uploaded by the buyer
const AwaitingStartForSeller = ({ order }) => {
  const [issuePopup, setIssuePopup] = useState(false);
  const orderMaterials = order?.orderMaterials;

  const textMaterials = {} as any;
  const filesMaterials = {} as any;

  // 遍历orderMaterials数组，提取数据
  orderMaterials.forEach((material, index) => {
    textMaterials[index] = material.feature;
    filesMaterials[index] = material.files;
  });

  const handleIssuePopup = () => {
    setIssuePopup(true);
  };
  const handleConfirm = (selectedApplication: string) => {
    setIssuePopup(false);
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: order.id,
        application: selectedApplication,
      },
    });
  };

  const renderTabTextContent = (index) => {
    const textMaterial = textMaterials[index];
    return (
      <YStack>
        {textMaterial &&
          textMaterial.map((item, index) => (
            <YStack key={index}>
              <Paragraph marginBottom="$2">
                {index + 1}. {item?.question}
              </Paragraph>
              <Paragraph>{item?.answer}</Paragraph>
            </YStack>
          ))}
      </YStack>
    );
  };

  const renderTabFileContent = (index) => {
    const filesMaterial = filesMaterials[index];
    return (
      <YStack flex={1}>
        {Array.isArray(filesMaterial) && filesMaterial.length > 0 ? (
          filesMaterial.map((item, index) => (
            <YStack key={index} backgroundColor="aliceblue" padding="$1">
              <Paragraph>{item}</Paragraph>
            </YStack>
          ))
        ) : (
          <Paragraph alignSelf="center" color="$darkGray">
            暂无文件
          </Paragraph>
        )}
      </YStack>
    );
  };

  return (
    <YStack flex={1} flexGrow={1}>
      {orderMaterials.length > 0 && orderMaterials ? (
        <FlatList
          data={Array.from(
            { length: orderMaterials.length },
            (_, index) => index
          )}
          renderItem={({ item, index }) => (
            <>
              {orderMaterials && index === 0 && (
                <YStack
                  flexDirection="column"
                  backgroundColor="#fff"
                  width="100%"
                  padding="$3"
                  marginBottom={10}
                >
                  <ServiceComponent item={order?.items[0]} />
                  <YStack>
                    <Paragraph>这里是商品规格</Paragraph>
                  </YStack>
                </YStack>
              )}
              <Accordion
                flexDirection="column"
                overflow="visible"
                width="100%"
                type="multiple"
                defaultValue={[(orderMaterials.length - 1).toString()]}
              >
                <Accordion.Item key={item} value={item.toString()}>
                  <Accordion.Trigger
                    flexDirection="row"
                    justifyContent="space-between"
                    // onPress={ setOpenItem((openItem)=> openItem === index ? null : index)} // 切换打开和关闭状态
                  >
                    {({ open }: { open: boolean }) => (
                      <>
                        <Paragraph>买家提交 #{item + 1}</Paragraph>
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
                    <TabsComponent
                      tab1Content={renderTabTextContent(index)}
                      tab2Content={renderTabFileContent(index)}
                    />
                    {item === orderMaterials.length - 1 && (
                      <>
                        <Button
                          width="60%"
                          height={global.screenHeight * 0.04}
                          borderColor="rgba(0,0,0,0.5)"
                          borderWidth={1}
                          alignSelf="center"
                          marginTop={30}
                          onPress={() => handleIssuePopup()}
                        >
                          <ButtonText>材料有问题？</ButtonText>
                        </Button>
                        <BottomSheet
                          isOpen={issuePopup}
                          title="材料有问题"
                          onClose={() => setIssuePopup(false)}
                          buttons={["请求卖家补充材料", "拒绝接单"]}
                          snapPoints={[40]}
                          handleConfirm={handleConfirm}
                        >
                          {issuePopup ? (
                            <ServiceComponent item={order?.items?.[0]} />
                          ) : (
                            ""
                          )}
                        </BottomSheet>
                      </>
                    )}
                  </Accordion.Content>
                </Accordion.Item>
              </Accordion>
            </>
          )}
          contentContainerStyle={{ paddingBottom: global.screenHeight * 0.5 }}
        />
      ) : (
        <Paragraph alignSelf="center" color="$darkGray">
          暂无买家提交的文件
        </Paragraph>
      )}
    </YStack>
  );
};

// 卖家交付
const AwaitingDeliveryForSeller = ({ order }) => {
  const { content, setContent, files, setFiles } = useDelivery();
  const uploadFiles = useSelector(
    (state: RootState) => state.file.deliveryFiles
  ); // 本地存储的文件
  const dispatch = useDispatch<AppDispatch>();

  const deleteFile = (index: number) => {
    dispatch(fileSlice.file.actions.deleteFile(index));
  };

  const [isOpen, setIsOpen] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const [previewPopup, setPreviewPopup] = useState(false);

  useEffect(() => {
    const files = uploadFiles?.[order?.id];
    if (Array.isArray(files) && files.length > 0) {
      setFiles(files.map((file) => file.fileUrl));
    }
  }, [uploadFiles]);

  const renderTabTextContent = () => {
    return (
      <YStack height={200}>
        <TextArea
          width="100%"
          height="100%"
          alignSelf="center"
          boxSizing="border-box"
          backgroundColor="#EDEDED"
          placeholder="在此输入您需要交付的文本信息"
          alignContent="center"
          value={content}
          onChangeText={setContent}
        />
      </YStack>
    );
  };

  return (
    <KeyboardAwareScrollView
      style={{ flex: 1, width: "100%" }}
      resetScrollToCoords={{ x: 0, y: 0 }}
      extraScrollHeight={220}
      scrollEnabled
      contentContainerStyle={{ paddingBottom: 100 }}
    >
      <Button
        onPress={() =>
          router.push({
            pathname: "/(outer)/order/detail",
            params: {
              orderId: order.id,
              refundId: order.refundId,
              role: "seller",
            },
          })
        }
        width="100%"
        height={40}
      >
        <ButtonText color="$blue">查看买家提交的材料</ButtonText>
        <ChevronRight size="$1" color="$blue" />
      </Button>
      <YStack marginBottom={25} backgroundColor="#fff" padding="$3">
        <ServiceComponent item={order?.items?.[0]} />
      </YStack>

      <YStack
        flexDirection="column"
        backgroundColor="#fff"
        paddingHorizontal="$3"
        paddingBottom={100}
      >
        <XStack justifyContent="space-between">
          <H5 marginBottom="$3" fontSize={16}>
            您的交付
          </H5>
        </XStack>
        <TabsComponent
          tab1Content={renderTabTextContent()}
          tab2Content={renderTabFileContent({
            orderId: order?.id,
            uploadFiles,
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
        type="delivery"
      />
      {previewPopup && (
        <PreviewBasedOnUrl
          previewPopup={previewPopup}
          setPreviewPopup={setPreviewPopup}
          previewUri={previewUri}
        />
      )}
    </KeyboardAwareScrollView>
  );
};

const AwaitingConfirmForSeller = ({ order }) => {
  const dispatch = useDispatch<AppDispatch>();

  const deliveryList = useSelector(
    (state: RootState) => state.order.deliveryList
  );
  const demandList = useSelector(
    (state: RootState) => state.order.deliveryDemand
  );
  const approved = useSelector((state: RootState) => state.order.approved);
  const rejected = useSelector((state: RootState) => state.order.rejected);
  // 未处理的需求列表
  const [unprocessedDemand, setUnProcessedDemand] = useState([] as any);

  const orderState = useSelector((state: RootState) => state.order.orderState);
  const [demandExisted, setDemandExisted] = useState(false);
  const [currentDemand, setCurrentDemand] = useState({} as any);
  const [delivered, setDelivered] = useState(false);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const [accordionValue, setAccordionValue] = useState<string[]>(
    demandExisted ? ["item-1"] : []
  );
  const { dictData } = useGlobalContext();

  useEffect(() => {
    if (demandList && demandList.length > 0) {
      setDemandExisted(true);
      setCurrentDemand(demandList[demandList.length - 1]);
      setDelivered(
        currentDemand?.status !== "WAIT" &&
          orderState === "awaitingConfirmation"
          ? true
          : false
      );
    } else {
      setDemandExisted(false);
    }
  }, [demandList]);

  const handleButtonClick = useCallback(
    (button) => {
      switch (button) {
        case "联系买家":
          return;
        case "查看详情":
        case "处理申请":
          if (currentDemand?.id) {
            router.push(
              `/(sellerscreens)/profile/orders/${order.id}/${currentDemand?.id}/detail`
            );
          }

          return;
        case "去重新交付":
          router.push(`/(sellerscreens)/profile/orders/${order.id}/reDelivery`);
          return;
        default:
          return;
      }
    },
    [currentDemand]
  );

  const previewFile = (uri) => {
    setPreviewUri(uri);
    setPreviewPopup(true);
  };

  useEffect(() => {
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
  }, [order]);

  useEffect(() => {
    if (demandList && demandList.length > 0) {
      const unprocessedRes = deliveryList.filter((demand) => {
        return demand.status === "WAIT";
      });
      setUnProcessedDemand(unprocessedRes);
    }
  }, [deliveryList]);

  useEffect(() => {
    if (approved) {
      console.log("approved", approved);
    }
    if (rejected) {
      console.log("rejected", rejected);
    }
  }, [approved, rejected]);

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
        renderItem={({ item, index }) => (
          <YStack width="100%">
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
                  defaultValue="0"
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
                      // borderBottomColor="#F2F2F2"
                      // borderBottomWidth={1}
                      style={{ backgroundColor: "#ffffff" }}
                      unstyled
                    >
                      {({ open }: { open: boolean }) => (
                        <>
                          <YStack>
                            <XStack width="100%">
                              <Paragraph>买家申请</Paragraph>
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
                                    <Text
                                      style={{ color: "#fff", fontSize: 12 }}
                                    >
                                      {unprocessedDemand.length}
                                    </Text>
                                  </YStack>
                                )}
                              <Paragraph color="$lightGray" marginLeft="$3">
                                (买家购买的服务包含
                                <Paragraph color="$red">
                                  {order?.items?.[0]?.editNum}
                                </Paragraph>
                                次交付次数)
                              </Paragraph>
                            </XStack>
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
                    >
                      {demandExisted && (
                        <XStack
                          flex={0}
                          justifyContent="space-between"
                          marginBottom="$3"
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
                                `/(sellerscreens)/profile/orders/${order.id}/${currentDemand?.id}/delivery/demand_list`
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
                      >
                        {demandExisted ? (
                          <>
                            <DemandTimeLineComponent
                              currentStatus={
                                delivered ? "DELIVERED" : currentDemand?.status
                              }
                              role="seller"
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
                            买家暂无申请，等待买家确认收货
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
              <Accordion.Item key={index} value={index.toString()}>
                <Accordion.Trigger
                  flexDirection="row"
                  justifyContent="space-between"
                  alignItems="center"
                >
                  {({ open }: { open: boolean }) => (
                    <>
                      <Paragraph>交付 #{index + 1}</Paragraph>

                      <Paragraph
                        color="$gray8"
                        paddingHorizontal={10}
                        marginLeft="auto"
                      >
                        {item?.createTime}
                      </Paragraph>
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
                </Accordion.Content>
              </Accordion.Item>
            </Accordion>
          </YStack>
        )}
        showsVerticalScrollIndicator={false}
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
        buttons = ["联系买家", "查看详情"];
        break;
      case "WAIT":
        buttons = ["联系买家", "处理申请"];
        break;
      case "SUCCESS":
        buttons = ["联系买家", "查看详情", "去重新交付"];
        // 联系买家、查看详情、去重新交付
        break;
      case "FAIL":
        buttons = ["联系买家", "查看详情"];
        // 联系买家、查看详情
        break;
      default:
        buttons = ["联系买家", "查看详情"];
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

const AwaitingEvaluationForSeller = ({ order }) => {
  const dispatch = useDispatch<AppDispatch>();
  const inviteComment = useCallback(async () => {
    try {
      await dispatch(slices.item.actions.inviteComment({ orderId: order?.id }));
    } catch (error) {
      console.log(error);
    }
  }, [order]);

  return (
    <YStack flex={1}>
      <H2 fontSize={20} color="$gray8" alignSelf="center" marginTop="30%">
        卖家暂未评价，请耐心等待
      </H2>
    </YStack>
  );
};

const OrderCompelet = ({ order }) => {
  const dispatch = useDispatch<AppDispatch>();
  const evaluationList = useSelector(
    (state: RootState) => state.order.evaluationList
  );

  console.log("evaluationList", evaluationList.length);

  useEffect(() => {
    const params = {
      orderId: Number(order?.id),
    };
    dispatch(slices.order.actions.queryOrderEvaluation(params));
  }, [order]);

  if (evaluationList.length === 0 || evaluationList === undefined) {
    return <Paragraph>卖家未评价</Paragraph>;
  }

  return (
    <FlatList
      data={evaluationList}
      keyExtractor={(item) => item.orderId.toString()}
      renderItem={({ item, index }) => (
        <YStack backgroundColor="#fff" padding={10}>
          <Paragraph>需补充前端界面</Paragraph>
          {/* <H2 fontSize={15}>买家评分</H2>
          <XStack space="$2">
            {[...Array(5)].map((_, index) => (
              <Icon name="star" key={index} size={20} />
            ))}
          </XStack>
          <H2 fontSize={15}>买家评价</H2>
          <YStack backgroundColor="$gray8" borderRadius={10} padding={10}>
            <Paragraph color="#fff">这里是评价内容</Paragraph>
          </YStack> */}
        </YStack>
      )}
    />
  );
};
/*
-------------------------------bottom button------------------------------------------------
*/
