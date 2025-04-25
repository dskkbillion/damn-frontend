import { ArrowLeft, ArrowDown, ChevronDown, Star } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useMemo, useState } from "react";
import { Image, FlatList } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H2,
  Paragraph,
  Portal,
  Separator,
  XStack,
  YStack,
  Accordion,
  Square,
} from "tamagui";

import { goToChat } from "@/components/chat/goToChat";
import {
  DeliveryDetail,
  handlePlatformIntervene,
  SubmissionDetail,
} from "@/components/orders/common_funcs";
import { DeliveryDemandComp } from "@/components/orders/delivery_comp";
import { MaterialDemandComp } from "@/components/orders/material_comp";
import ServiceComponent from "@/components/orders/service_comp";
import { TabFileContent, TabTextContent } from "@/components/orders/tabs_comp";
import { QueryDict } from "@/components/queryDict";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { PreviewComp } from "@/components/utils/filesystem";
import { AppDispatch, RootState, slices } from "@/src/store";

/**
 * params:
 * orderId: 订单id (required)
 * refundId: 退款id (optional)
 * role: 角色 (required)
 */
const OrderDetailComp = memo(() => {
  const role = useLocalSearchParams().role as "buyer" | "seller";
  const order = useSelector((state: RootState) => state.order.order);
  const id = useLocalSearchParams()?.orderId;
  const refundId = useLocalSearchParams()?.refundId;
  const dispatch = useDispatch<AppDispatch>();
  const refresh = useSelector((state: RootState) => state.order.refresh);
  const loading = useSelector((state: RootState) => state.order.loading);
  const [seriesNumber, setSeriesNumber] = useState(0);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const refundDetail = useSelector(
    (state: RootState) => state.order.refundDetail
  );
  const demandList = useSelector((state: RootState) => state.order.demandList);
  const [platformDetail, setPlatformDetail] = useState<any>(null);

  const materialDemand = useSelector(
    (state: RootState) => state.order.materialDemand
  );

  const deliveryDemand = useSelector(
    (state: RootState) => state.order.deliveryDemand
  );

  const refuseDemand = useSelector(
    (state: RootState) => state.order.refuseDemand
  );

  const platformDemand = useSelector(
    (state: RootState) => state.order.platformDemand
  );

  const evaluationList = useSelector(
    (state: RootState) => state.order.evaluationList
  );

  const { dictData } = useGlobalContext();

  const toSeriesNumber = useCallback((state, role) => {
    switch (state) {
      case "awaitingSubmission":
        return 1;
      case "buyAwaitingSubmission":
      case "awaitingStart":
        return 2;
      case "awaitingDelivery":
        return 3;
      case "awaitingConfirmation":
      case "sellerSupplementaryMaterials":
      case "applyForRefuse":
        return 4;
      case "awaitingEvaluation":
        return 5;
      case "orderCompleted":
      case "afterSale":
        return 6;
      case "canceled":
        return 7;
      default:
        return 0;
    }
  }, []);

  const fetchOrderInfo = useCallback(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(id) }));

    if (refundId) {
      dispatch(
        slices.order.actions.fetchRefundDetail({
          id: Number(refundId),
        })
      );
    }

    // 获取买家的材料申请
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: Number(id),
        memberType: "seller",
        type: "material",
      } as const)
    );

    // 获取卖家的交付申请
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: Number(id),
        memberType: "buyer",
        type: "delivery",
      } as const)
    );

    // 获取卖家的拒绝申请
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: Number(id),
        memberType: "seller",
        type: "refuse",
      } as const)
    );

    // 获取平台介入申请
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: Number(id),
        memberType: role,
        type: "platform",
      } as const)
    );
  }, [id, refundId, dispatch]);

  const applySupplement = useCallback(() => {
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: id,
        application: "replenish_materials",
        role: "seller",
      },
    });
  }, []);

  const handleVerifyOrder = useCallback(async () => {
    const params = {
      orderId: Number(order?.id),
    };
    try {
      const res = await dispatch(slices.order.actions.verifyOrder(params));
      if (isAxiosSuccess(res.type)) {
        alert("确认订单成功");
        router.push(`/(sellerscreens)/profile/orders/${id}/`);
      } else {
        alert("确认订单失败");
      }
    } catch (err) {
      console.log("fail to verify order", err);
    }
  }, [order?.id]);

  // 取消订单
  const cancelOrder = useCallback(async () => {
    const res = await dispatch(
      slices.order.actions.cancelOrder({ orderId: String(order?.id) })
    );
    if (isAxiosSuccess(res.type)) {
      dispatch(slices.order.actions.setChanged());
      alert("取消订单成功");
    }
  }, []);

  useEffect(() => {
    fetchOrderInfo();
  }, [refresh, fetchOrderInfo]);

  useEffect(() => {
    const seriesNumber = toSeriesNumber(
      order?.tenantRefundFlag || order?.buyerRefundFlag
        ? "afterSale"
        : order?.state,
      role
    );
    setSeriesNumber(seriesNumber);
  }, [order?.state, role]);

  const statusText = useMemo(() => {
    if (order?.tenantRefundFlag || order?.buyerRefundFlag) {
      return refundDetail?.refundState
        ? "退款：" +
            QueryDict(dictData["refund_state"], refundDetail.refundState).label
        : "";
    }
    if (order?.buyerPlatformFlag || order?.sellerPlatformFlag) {
      return platformDemand?.length > 0
        ? "平台介入：" +
            QueryDict(dictData["order_demand_status"], platformDemand[0].status)
              .label
        : "";
    }
    return QueryDict(dictData["shop_order_status"], order?.state)?.label;
  }, [order, refundDetail?.refundState, platformDemand, dictData]);

  useEffect(() => {
    return () => {
      dispatch(slices.order.actions.resetRefundDetail());
    };
  }, []);

  useEffect(() => {
    console.log("useEffect triggered - evaluate:", order?.evaluate);
    if (order?.evaluate) {
      console.log("Dispatching queryOrderEvaluation");
      dispatch(
        slices.order.actions.queryOrderEvaluation({ orderId: Number(id) })
      );
    }
  }, [order?.evaluate, id, dispatch]);

  return (
    <YStack flex={1}>
      {/* 文件预览 */}
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}

      {/* 顶部固定状态栏 */}
      <XStack
        paddingVertical={global.screenHeight * 0.03}
        backgroundColor="#EDEDED"
      />
      <Button
        width="100%"
        height={50}
        position="relative"
        top={0}
        left={0}
        flexDirection="row"
        alignItems="center"
        justifyContent="flex-start"
        space={10}
        onPress={() => {
          router.back();
        }}
        unstyled
      >
        <ArrowLeft size="$1" />
        <H2 fontSize={18}>{statusText}</H2>
      </Button>

      <FlatList
        data={[0]}
        keyExtractor={(item) => item.toString()}
        refreshing={loading}
        renderItem={({ item }) => (
          <RenderContent
            order={order}
            materialDemand={materialDemand}
            deliveryDemand={deliveryDemand}
            refuseDemand={refuseDemand}
            platformDemand={platformDemand}
            evaluationList={evaluationList}
            role={role}
            seriesNumber={seriesNumber}
            setPreviewPopup={setPreviewPopup}
            setPreviewUri={setPreviewUri}
          />
        )}
        style={{ backgroundColor: "#EDEDED" }}
        contentContainerStyle={{ paddingBottom: 150 }}
        showsVerticalScrollIndicator={false}
      />

      {/* 只有在需要显示按钮时才显示底部白色框 */}
      {order?.state !== "canceled" &&
        // 买家可以申请退款（但不在退款中）
        ((seriesNumber > 2 &&
          role === "buyer" &&
          !order?.tenantRefundFlag &&
          !order?.buyerRefundFlag) ||
          // 买家可以取消订单
          (seriesNumber === 2 && role === "buyer") ||
          // 可以申请平台介入（但不在平台介入中）
          (seriesNumber > 2 &&
            !order?.buyerPlatformFlag &&
            !order?.sellerPlatformFlag)) && (
          <XStack
            width="100%"
            flex={1}
            height={90}
            backgroundColor="#fff"
            position="absolute"
            bottom={0}
            left={0}
            justifyContent="flex-end"
          >
            {role === "seller" && order?.state === "awaitingStart" ? (
              <ButtonComponent
                state={order?.state}
                applySupplement={applySupplement}
                verifyOrder={handleVerifyOrder}
              />
            ) : (
              <XStack marginRight={20} marginBottom={20} space="$2">
                {/* 平台介入按钮 - 只在未申请平台介入时显示 */}
                {seriesNumber > 2 &&
                  !order?.buyerPlatformFlag &&
                  !order?.sellerPlatformFlag && (
                    <Button
                      height={global.screenHeight * 0.04}
                      borderColor="$brown"
                      paddingHorizontal="$3"
                      borderWidth={1}
                      alignSelf="center"
                      borderRadius={20}
                      textAlign="center"
                      justifyContent="center"
                      onPress={() => {
                        router.push({
                          pathname: "/(outer)/order/application",
                          params: {
                            orderId: id,
                            application: "platform",
                            role,
                          },
                        });
                      }}
                      unstyled
                    >
                      <ButtonText color="$brown">平台介入</ButtonText>
                    </Button>
                  )}

                {/* 退款按钮 - 只在未申请退款时显示 */}
                {seriesNumber > 2 &&
                  role === "buyer" &&
                  !order?.tenantRefundFlag &&
                  !order?.buyerRefundFlag && (
                    <Button
                      height={global.screenHeight * 0.04}
                      borderColor="$brown"
                      paddingHorizontal="$3"
                      borderWidth={1}
                      alignSelf="center"
                      borderRadius={20}
                      textAlign="center"
                      justifyContent="center"
                      onPress={() => {
                        router.push({
                          pathname: "/(outer)/order/application",
                          params: {
                            orderId: id,
                            application: "refund",
                            role,
                          },
                        });
                      }}
                      unstyled
                    >
                      <ButtonText color="$brown">退款</ButtonText>
                    </Button>
                  )}

                {/* 取消订单按钮 */}
                {seriesNumber === 2 && role === "buyer" && (
                  <AlertDialogComponent
                    title="取消订单"
                    description="是否取消订单？"
                    handleConfirm={cancelOrder}
                  >
                    <Button
                      height={global.screenHeight * 0.04}
                      borderColor="$brown"
                      paddingHorizontal="$3"
                      borderWidth={1}
                      alignSelf="center"
                      borderRadius={20}
                      textAlign="center"
                      justifyContent="center"
                      unstyled
                    >
                      <ButtonText color="$brown">取消订单</ButtonText>
                    </Button>
                  </AlertDialogComponent>
                )}
              </XStack>
            )}
          </XStack>
        )}

      {/* </SafeAreaView> */}
    </YStack>
  );
});

const RenderContent = memo(
  ({
    order,
    materialDemand,
    deliveryDemand,
    refuseDemand,
    evaluationList,
    platformDemand,
    role,
    seriesNumber,
    setPreviewPopup,
    setPreviewUri,
  }: {
    order: any;
    materialDemand;
    deliveryDemand;
    refuseDemand;
    evaluationList: any[];
    platformDemand: any[];
    role: "buyer" | "seller";
    seriesNumber: number;
    setPreviewPopup: any;
    setPreviewUri: any;
  }) => {
    const dispatch = useDispatch<AppDispatch>();
    const refundDetail = useSelector(
      (state: RootState) => state.order.refundDetail
    );
    const demandList = useSelector(
      (state: RootState) => state.order.demandList
    );
    const { dictData } = useGlobalContext();
    const { textMaterials, filesMaterials } = useMemo(() => {
      const textMaterials = {} as any;
      const filesMaterials = {} as any;

      if (order?.orderMaterials) {
        order.orderMaterials.forEach((material, index) => {
          textMaterials[index] = material.feature;
          filesMaterials[index] = material.files;
        });
      }
      return { textMaterials, filesMaterials };
    }, [order?.orderMaterials]);

    console.log("evaluationList", evaluationList);
    console.log("evaluate", order?.evaluate);
    console.log("RenderContent - order:", order);
    console.log("RenderContent - evaluationList:", evaluationList);
    console.log("RenderContent - condition check:", {
      evaluate: order?.evaluate,
      hasEvaluationList: evaluationList?.length > 0,
      evaluationListLength: evaluationList?.length,
    });

    return (
      <YStack flex={1}>
        <YStack
          width="98%"
          padding="$2"
          space="$1"
          backgroundColor="#fff"
          alignSelf="center"
          borderRadius={20}
        >
          <Button width="100%" height={50} justifyContent="center" unstyled>
            <ButtonText fontWeight="700">{order?.buyer?.nickName}</ButtonText>
          </Button>
          {order?.items?.[0] && <ServiceComponent item={order?.items?.[0]} />}

          <Separator style={{ marginTop: 30 }} />

          {/* <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>商品总价</Paragraph>
            <Paragraph>{order?.totalPrice}</Paragraph>
          </XStack> */}

          {/* 优惠券显示 */}
          {/* <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>优惠券减免</Paragraph>
            <Paragraph>暂未开放</Paragraph>
          </XStack> */}

          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>实付款</Paragraph>
            <Paragraph> {order?.payPrice}</Paragraph>
          </XStack>

          <Separator style={{ marginVertical: 10 }} />

          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>订单编号</Paragraph>
            <Paragraph>{order?.id}</Paragraph>
          </XStack>
          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>付款方式 </Paragraph>
            <Paragraph>
              {QueryDict(dictData?.["payway"], order?.payType).label}
            </Paragraph>
          </XStack>
          <XStack
            flexDirection="row"
            alignItems="center"
            justifyContent="space-between"
          >
            <Paragraph>付款时间 </Paragraph>
            <Paragraph>{order?.payTime}</Paragraph>
          </XStack>
        </YStack>

        {seriesNumber > 1 && (
          <YStack marginTop="$3" gap={0}>
            {order?.orderMaterials?.map((item, index) => (
              <SubmissionDetail
                key={index}
                item={item}
                index={index}
                role={role}
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
                defaultExpanded={false}
                expandLatest={false}
              />
            ))}
          </YStack>
        )}

        {/* 关于材料的申请 */}
        {seriesNumber > 1 &&
          order?.state !== "canceled" &&
          materialDemand &&
          materialDemand.length > 0 && (
            <YStack
              width="100%"
              space="$1"
              backgroundColor="#fff"
              alignSelf="center"
              // marginTop="$3"
            >
              <MaterialDemandComp
                role={role}
                materialDemandList={materialDemand}
              />
            </YStack>
          )}

        {/* 交付 */}
        {seriesNumber > 3 && (
          <XStack>
            {order?.orderDeliveries.map((item, index) => (
              <DeliveryDetail
                key={index}
                item={item}
                index={index}
                totol_num={order?.orderDeliveries.length}
                setPreviewPopup={setPreviewPopup}
                setPreviewUri={setPreviewUri}
              />
            ))}
          </XStack>
        )}

        {/* 交付的申请 */}
        {seriesNumber > 3 && deliveryDemand && deliveryDemand.length > 0 && (
          <YStack
            width="100%"
            space="$1"
            backgroundColor="#fff"
            // marginTop="$3"
          >
            <DeliveryDemandComp
              role={role}
              order={order}
              currentDemand={deliveryDemand?.[deliveryDemand.length - 1]}
            />
          </YStack>
        )}

        {/* 平台介入和退款详情 */}
        {(order?.tenantRefundFlag ||
          order?.buyerRefundFlag ||
          order?.buyerPlatformFlag ||
          order?.sellerPlatformFlag) && (
          <YStack width="100%">
            {/* 平台介入详情 */}
            {(order?.buyerPlatformFlag || order?.sellerPlatformFlag) && (
              <XStack
                height="auto"
                width="100%"
                alignSelf="center"
                backgroundColor="#fff"
                justifyContent="center"
                flex={1}
              >
                <Accordion
                  type="single"
                  width="100%"
                  overflow="visible"
                  collapsible
                  borderWidth={0}
                >
                  <Accordion.Item
                    value="0"
                    borderRadius={0}
                    borderColor="transparent"
                  >
                    <Accordion.Trigger
                      flexDirection="row"
                      justifyContent="space-between"
                    >
                      {({ open }) => (
                        <>
                          <YStack>
                            <YStack width="100%">
                              <Paragraph>平台介入详情</Paragraph>
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
                      paddingVertical="$3"
                    >
                      <YStack padding="$3" space="$2">
                        {platformDemand.map((demand, index) => (
                          <YStack key={index} space="$2">
                            <XStack justifyContent="space-between">
                              <Paragraph fontWeight="700">处理状态</Paragraph>
                              <Paragraph>
                                {
                                  QueryDict(
                                    dictData["order_demand_status"],
                                    demand.status
                                  ).label
                                }
                              </Paragraph>
                            </XStack>
                            <XStack justifyContent="space-between">
                              <Paragraph fontWeight="700">申请类型</Paragraph>
                              <Paragraph>{demand.reasonLabel}</Paragraph>
                            </XStack>
                            <XStack justifyContent="space-between">
                              <Paragraph fontWeight="700">申请原因</Paragraph>
                              <Paragraph>{demand.remarks}</Paragraph>
                            </XStack>
                            <XStack justifyContent="space-between">
                              <Paragraph fontWeight="700">申请时间</Paragraph>
                              <Paragraph>{demand.createTime}</Paragraph>
                            </XStack>
                            {index < demandList.length - 1 && (
                              <Separator marginVertical="$2" />
                            )}
                          </YStack>
                        ))}
                      </YStack>
                    </Accordion.Content>
                  </Accordion.Item>
                </Accordion>
              </XStack>
            )}
          </YStack>
        )}

        {/* 退款详情 */}
        {(order?.tenantRefundFlag || order?.buyerRefundFlag) && (
          <XStack
            height="auto"
            width="100%"
            alignSelf="center"
            backgroundColor="#fff"
            justifyContent="center"
            flex={1}
          >
            <Accordion
              type="single"
              width="100%"
              overflow="visible"
              collapsible
              defaultValue="0"
              borderWidth={0}
            >
              <Accordion.Item
                value="0"
                borderRadius={0}
                borderColor="transparent"
              >
                <Accordion.Trigger
                  flexDirection="row"
                  justifyContent="space-between"
                >
                  {({ open }) => (
                    <>
                      <YStack>
                        <YStack width="100%">
                          <Paragraph>退款详情</Paragraph>
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
                  paddingVertical="$3"
                >
                  <YStack padding="$3" space="$2">
                    {refundDetail && (
                      <YStack space="$2">
                        <XStack justifyContent="space-between">
                          <Paragraph fontWeight="700">退款状态</Paragraph>
                          <Paragraph>
                            {
                              QueryDict(
                                dictData["refund_state"],
                                refundDetail.refundState
                              ).label
                            }
                          </Paragraph>
                        </XStack>
                        <XStack justifyContent="space-between">
                          <Paragraph fontWeight="700">退款原因</Paragraph>
                          <Paragraph>
                            {refundDetail.refundExplain
                              ? refundDetail.refundExplain.trimEnd()
                              : "无"}
                          </Paragraph>
                        </XStack>
                        <XStack justifyContent="space-between">
                          <Paragraph fontWeight="700">退款金额</Paragraph>
                          <Paragraph>¥{refundDetail?.refundPrice}</Paragraph>
                        </XStack>
                        <XStack justifyContent="space-between">
                          <Paragraph fontWeight="700">申请时间</Paragraph>
                          <Paragraph>{refundDetail?.createTime}</Paragraph>
                        </XStack>
                      </YStack>
                    )}
                  </YStack>
                </Accordion.Content>
              </Accordion.Item>
            </Accordion>
          </XStack>
        )}

        {/* 评论详情 */}
        {order?.evaluate && evaluationList?.length > 0 && (
          <YStack
            width="100%"
            backgroundColor="#fff"
            alignSelf="center"
            borderRadius={20}
          >
            <Accordion
              type="single"
              width="100%"
              overflow="visible"
              collapsible
              borderWidth={0}
            >
              <Accordion.Item
                value="0"
                borderRadius={0}
                borderColor="transparent"
              >
                <Accordion.Trigger
                  flexDirection="row"
                  justifyContent="space-between"
                >
                  {({ open }) => (
                    <>
                      <YStack>
                        <Paragraph>
                          评价详情 ({evaluationList.length})
                        </Paragraph>
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
                  paddingVertical="$3"
                >
                  <YStack padding="$3" space="$4">
                    {evaluationList.map((evaluation, evalIndex) => (
                      <YStack key={evalIndex} space="$2">
                        <XStack space="$2" alignItems="center">
                          <Paragraph fontWeight="700">评分</Paragraph>
                          <XStack>
                            {Array(5)
                              .fill(0)
                              .map((_, index) => (
                                <Star
                                  key={index}
                                  size={16}
                                  color={
                                    index < evaluation.score
                                      ? "#FFB800"
                                      : "#D9D9D9"
                                  }
                                  fill={
                                    index < evaluation.score
                                      ? "#FFB800"
                                      : "#D9D9D9"
                                  }
                                />
                              ))}
                          </XStack>
                        </XStack>

                        <YStack space="$2">
                          <Paragraph fontWeight="700">评价内容</Paragraph>
                          <Paragraph>{evaluation.remark}</Paragraph>
                        </YStack>

                        {evaluation.images && evaluation.images.length > 0 && (
                          <YStack space="$2">
                            <Paragraph fontWeight="700">评价图片</Paragraph>
                            <XStack flexWrap="wrap" gap="$2">
                              {evaluation.images.map((image, index) => (
                                <Button
                                  key={index}
                                  width={80}
                                  height={80}
                                  borderRadius={10}
                                  onPress={() => {
                                    setPreviewUri(image);
                                    setPreviewPopup(true);
                                  }}
                                  unstyled
                                >
                                  <Image
                                    source={{ uri: image }}
                                    style={{
                                      width: "100%",
                                      height: "100%",
                                      borderRadius: 10,
                                    }}
                                    resizeMode="cover"
                                  />
                                </Button>
                              ))}
                            </XStack>
                          </YStack>
                        )}

                        {!evaluation.anonymityFlag && (
                          <XStack justifyContent="space-between">
                            <Paragraph fontWeight="700">评价人</Paragraph>
                            <Paragraph>
                              {evaluation.anonymityFlag
                                ? "匿名"
                                : evaluation.buyer?.nickName}
                            </Paragraph>
                          </XStack>
                        )}

                        <XStack justifyContent="space-between">
                          <Paragraph fontWeight="700">评价时间</Paragraph>
                          <Paragraph>{evaluation.createTime}</Paragraph>
                        </XStack>

                        {evalIndex < evaluationList.length - 1 && (
                          <Separator marginVertical="$2" />
                        )}
                      </YStack>
                    ))}
                  </YStack>
                </Accordion.Content>
              </Accordion.Item>
            </Accordion>
          </YStack>
        )}

        {/* 取消订单详情 */}
        {order?.state === "canceled" &&
          refuseDemand &&
          refuseDemand.length > 0 && (
            <YStack
              width="100%"
              backgroundColor="#fff"
              alignSelf="center"
              borderRadius={20}
            >
              <Accordion
                type="single"
                width="100%"
                overflow="visible"
                collapsible
                defaultValue="0"
                borderWidth={0}
              >
                <Accordion.Item
                  value="0"
                  borderRadius={0}
                  borderColor="transparent"
                >
                  <Accordion.Trigger
                    flexDirection="row"
                    justifyContent="space-between"
                  >
                    {({ open }) => (
                      <>
                        <YStack>
                          <YStack width="100%">
                            <Paragraph>取消订单详情</Paragraph>
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
                    paddingVertical="$3"
                  >
                    <YStack padding="$3" space="$2">
                      {refuseDemand.map((demand, index) => (
                        <YStack key={index} space="$2">
                          <XStack justifyContent="space-between">
                            <Paragraph fontWeight="700">处理状态</Paragraph>
                            <Paragraph>
                              {
                                QueryDict(
                                  dictData["order_demand_status"],
                                  demand.status
                                ).label
                              }
                            </Paragraph>
                          </XStack>
                          <XStack justifyContent="space-between">
                            <Paragraph fontWeight="700">拒绝原因</Paragraph>
                            <Paragraph>{demand.reasonLabel}</Paragraph>
                          </XStack>
                          <XStack justifyContent="space-between">
                            <Paragraph fontWeight="700">详细说明</Paragraph>
                            <Paragraph>{demand.remarks}</Paragraph>
                          </XStack>
                          <XStack justifyContent="space-between">
                            <Paragraph fontWeight="700">拒绝时间</Paragraph>
                            <Paragraph>{demand.createTime}</Paragraph>
                          </XStack>
                          {index < refuseDemand.length - 1 && (
                            <Separator marginVertical="$2" />
                          )}
                        </YStack>
                      ))}
                    </YStack>
                  </Accordion.Content>
                </Accordion.Item>
              </Accordion>
            </YStack>
          )}

        <YStack
          flexDirection="column"
          marginTop="$3"
          backgroundColor="#fff"
          paddingHorizontal="$3"
          paddingTop="$1"
          paddingBottom="$3"
          width="98%"
          alignSelf="center"
          borderRadius={20}
        >
          <H2 fontSize={16}>遇到问题？</H2>
          <Button
            width="60%"
            height={35}
            backgroundColor="$brown"
            alignSelf="center"
            borderRadius={20}
            textAlign="center"
            unstyled
            justifyContent="center"
            marginTop="$3"
            onPress={() => {
              handlePlatformIntervene({
                buyerPlatformFlag: order?.buyerPlatformFlag,
                sellerPlatformFlag: order?.sellerPlatformFlag,
                orderId: order?.id,
                role,
              });
            }}
          >
            <ButtonText color="#fff">申请平台介入</ButtonText>
          </Button>
        </YStack>
      </YStack>
    );
  }
);

const ButtonComponent = memo(
  ({
    state,
    applySupplement,
    verifyOrder,
  }: {
    state;
    applySupplement;
    verifyOrder;
  }) => {
    switch (state) {
      case "待付款":
        return (
          <Button
            width="100%"
            height="100%"
            backgroundColor="$brown"
            unstyled
            justifyContent="center"
          >
            <ButtonText color="#fff">立即付款</ButtonText>
          </Button>
        );
      case "awaitingStart":
        return (
          <XStack marginRight={20} marginBottom={20} space="$2">
            <Button
              height={global.screenHeight * 0.04}
              borderColor="$brown"
              paddingHorizontal="$3"
              borderWidth={1}
              alignSelf="center"
              borderRadius={20}
              textAlign="center"
              justifyContent="center"
              unstyled
              onPress={() => applySupplement()}
            >
              <ButtonText color="$brown">材料有问题?</ButtonText>
            </Button>
            <AlertDialogComponent
              title="确认接单"
              description="是否确认接单"
              handleConfirm={() => verifyOrder()}
            >
              <Button
                height={global.screenHeight * 0.04}
                borderColor="$brown"
                paddingHorizontal="$3"
                borderWidth={1}
                alignSelf="center"
                borderRadius={20}
                textAlign="center"
                justifyContent="center"
                unstyled
              >
                <ButtonText color="$brown">确认接单</ButtonText>
              </Button>
            </AlertDialogComponent>
          </XStack>
        );
      case "待收货":
        return (
          <Button
            width="100%"
            height="100%"
            backgroundColor="$brown"
            unstyled
            justifyContent="center"
          >
            <ButtonText color="#fff">确认收货</ButtonText>
          </Button>
        );
    }
  }
);

export default OrderDetailComp;
