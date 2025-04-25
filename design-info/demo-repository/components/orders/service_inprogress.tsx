import { router } from "expo-router";
import React, { memo, useCallback, useEffect, useState, useMemo } from "react";
import {
  FlatList,
  View,
  Text,
  TouchableWithoutFeedback,
  ActivityIndicator,
} from "react-native";
import FastImage from "react-native-fast-image";
import Icon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import { Paragraph, XStack, YStack, Button, ButtonText } from "tamagui";

import { OrderBottomSheet } from "./bottomsheet_order";
import {
  getButtons,
  goToSellerPage,
  handleButtonClick,
  renderText,
} from "./common_funcs";
import { PlatformDetail, RefundDetail } from "./service_all";
import { QueryDict } from "../queryDict";
import { useGlobalContext } from "../system/globalContext";
import { useCountdown } from "../time_processor";

import { AppDispatch, RootState, slices } from "@/src/store";

const PAGE_SIZE = 5;
const STATE = 2;
const ServiceInProgress = memo((props: { role: "seller" | "buyer" }) => {
  const OrdersInProgress = useSelector((state: RootState) =>
    props.role === "buyer"
      ? state.orderList.orderListForBuyer?.[STATE]
      : state.orderList.orderListForSeller?.[STATE]
  );
  // const [isLoading, setIsLoading] = useState(false);
  const isLoading = useSelector((state: RootState) => state.orderList.loading);
  const hasMore = useSelector((state: RootState) => state.orderList.hasMore);
  const dispatch = useDispatch<AppDispatch>();
  const [pageNum, setPageNum] = useState(1);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const changed = useSelector((state: RootState) => state.order.changed);
  const order = useSelector((state: RootState) => state.order.order);

  const { screenHeight } = useGlobalContext();

  const fetchOrderList = useCallback(
    ({
      page = 1,
      refresh = false,
      isLoading = false,
      hasMore = true,
    }: {
      page?: number;
      refresh?: boolean;
      isLoading?: boolean;
      hasMore?: boolean;
    }) => {
      if (isLoading || (!hasMore && !refresh)) {
        return;
      }

      const params = {
        type: props.role,
        state: STATE,
        pageNum: refresh ? 1 : page,
        pageSize: PAGE_SIZE,
      };
      dispatch(slices.orderList.actions.fetchOrderList(params));

      if (refresh) {
        setPageNum(2);
      } else {
        if (hasMore) {
          setPageNum((prevPage) => prevPage + 1);
        }
      }
    },
    [props.role]
  );

  // 手动刷新
  const handleRefresh = useCallback(() => {
    dispatch(
      slices.orderList.actions.resetOrderList({
        type: props.role,
        state: STATE,
      })
    );
    fetchOrderList({ page: 1, refresh: true });
    setIsInitialLoad(false);
  }, [fetchOrderList]);

  // 加载更多订单列表 (非第一次加载)
  const handleLoadMore = useCallback(() => {
    if (!isLoading && hasMore && pageNum > 1) {
      console.log("load more");

      fetchOrderList({
        page: pageNum,
        refresh: false,
        isLoading,
        hasMore,
      });
    }
  }, [pageNum, isLoading, props.role]);

  const renderFootComponent = useCallback(() => {
    if (hasMore || isLoading) {
      return (
        <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
          加载中
        </Paragraph>
      );
    } else if (!hasMore && !isLoading && !isInitialLoad) {
      return (
        <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
          没有更多了
        </Paragraph>
      );
    }
  }, [isLoading, hasMore, isInitialLoad, props.role]);

  // 自动刷新： 组件初始化时调用（当useSelector中的值发生变化时，如果依赖项变化会重新渲染，否则会重新渲染）
  useEffect(() => {
    console.log("refresh in useEffect");
    handleRefresh();
  }, [fetchOrderList, changed, props.role]);

  if (isInitialLoad) {
    return (
      <YStack flex={1} justifyContent="center" alignItems="center">
        <ActivityIndicator size="large" color="#0000ff" />
      </YStack>
    );
  }

  return (
    <YStack flexDirection="column">
      <FlatList
        data={OrdersInProgress}
        renderItem={({ item }) => <OrderItem item={item} role={props.role} />}
        keyExtractor={(item, index) => `${item.id}-${index}`}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.1}
        showsHorizontalScrollIndicator={false}
        ListFooterComponent={renderFootComponent}
        contentContainerStyle={{ paddingBottom: screenHeight * 0.3 }}
        refreshing={isLoading}
        onRefresh={handleRefresh}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
});

export default ServiceInProgress;

const OrderItem = memo(({ item, role }: { item: any; role: string }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [issuePopup, setIssuePopup] = useState(false);
  const [materialPopup, setMaterialPopup] = useState(false);
  const [comfirmPopup, setComfirmPopup] = useState(false);
  const [localRefundDetail, setLocalRefundDetail] =
    useState<RefundDetail | null>(null);
  const [platformDemand, setPlatformDemand] = useState([]);
  const { dictData, screenHeight, screenWidth } = useGlobalContext();

  // 先获取退款和平台介入数据
  useEffect(() => {
    const fetchInitialData = async () => {
      if (item?.buyerRefundFlag || item?.tenantRefundFlag) {
        const res = await dispatch(
          slices.order.actions.fetchRefundDetail({
            id: Number(item?.refundId),
          })
        ).unwrap();
        setLocalRefundDetail(res.data);
      }
      if (item?.buyerPlatformFlag || item?.sellerPlatformFlag) {
        const res = await dispatch(
          slices.order.actions.queryDemandList({
            orderId: Number(item?.id),
            memberType: role,
            type: "platform",
          })
        ).unwrap();
        const platformDemand = res.data?.rows.filter(
          (demand) => demand.type === "platform"
        );
        console.log("platformDemand", platformDemand);
        setPlatformDemand(platformDemand);
      }
    };

    fetchInitialData();
  }, [item.id]);

  const statusText = useMemo(() => {
    const is_refund = !!(item?.buyerRefundFlag || item?.tenantRefundFlag);
    if (is_refund && localRefundDetail?.refundState) {
      return (
        "退款: " +
        QueryDict(dictData["refund_state"], localRefundDetail.refundState).label
      );
    }

    return QueryDict(dictData?.["shop_order_status"], item.state).label;
  }, [localRefundDetail, item.state]);

  const platformText = useMemo(() => {
    const localPlatformDetail = platformDemand[
      platformDemand.length - 1
    ] as any;

    if (localPlatformDetail) {
      return (
        "平台介入: " +
        QueryDict(dictData["order_demand_status"], localPlatformDetail?.status)
          .label
      );
    }
  }, [platformDemand, item?.state]);

  // 获取按钮列表
  const buttonList = useMemo(() => {
    const isRefund = !!(item?.buyerRefundFlag || item?.tenantRefundFlag);

    return getButtons({
      state: item.state,
      role,
      is_refund: isRefund,
      refundState: localRefundDetail?.refundState,
    });
  }, [item, role, localRefundDetail?.refundState]);

  const autoMaterialTime = useSelector(
    (state: RootState) => state.order.autoMaterialTime
  );

  const autoMaterialLeftTime = useCountdown(autoMaterialTime);

  const text = renderText({
    state: item.state,
    role,
    autoMaterialLeftTime,
  });

  return (
    <View style={{ marginBottom: 10, flex: 1, backgroundColor: "#fff" }}>
      <YStack position="absolute" justifyContent="center" alignItems="center">
        <ActivityIndicator size="large" />
      </YStack>
      <XStack
        flexDirection="row"
        alignItems="center"
        backgroundColor="#fff"
        paddingVertical="$3"
      >
        <XStack
          flexDirection="row"
          alignItems="center"
          width={screenWidth * 0.6}
          onPress={() => goToSellerPage(item.tenantId)}
        >
          <Paragraph fontSize={16} marginHorizontal={10}>
            {role === "seller" ? "买家" : "卖家"}:
            {role === "seller" ? item.buyer?.nickName : item.tenant?.nickName}
            {/* {item.tenant?.nickName} */}
          </Paragraph>
          <Icon name="angle-right" size={20} color="#A5A5A6" />
        </XStack>

        <XStack
          flexDirection="row"
          alignItems="center"
          marginLeft="auto"
          marginRight={10}
          borderRadius={5}
          paddingVertical="$1"
          paddingHorizontal="$2"
          backgroundColor="#DAF4E1"
        >
          <Paragraph color="#476F5C" fontSize={12}>
            {statusText}
          </Paragraph>
        </XStack>
      </XStack>

      <TouchableWithoutFeedback
        onPress={() =>
          router.push({
            pathname: "/(outer)/order/detail",
            params: {
              orderId: item?.id,
              refundId: item?.refundId,
              role,
            },
          })
        }
      >
        <XStack flexDirection="row" alignItems="center" backgroundColor="#fff">
          {/* image of the service */}
          <FastImage
            source={{
              uri: item?.items?.[0]?.productImage,
              priority: FastImage.priority.normal,
            }}
            style={{
              width: screenHeight * 0.1,
              height: screenHeight * 0.1,
              marginHorizontal: 10,
              borderRadius: 5,
              backgroundColor: "#EDEDED",
            }}
            resizeMode={FastImage.resizeMode.stretch}
          />

          {/* details of the service */}
          <YStack
            flexDirection="column"
            height={screenHeight * 0.1}
            width={screenWidth * 0.5}
            space="$1"
          >
            <Text style={{ fontWeight: "800", fontSize: 15 }} numberOfLines={1}>
              {item.items?.[0]?.productName}
            </Text>
            <Text style={{ fontWeight: "400", fontSize: 15 }} numberOfLines={1}>
              {item.items?.[0]?.productInfo?.description}
            </Text>
            <Text style={{ fontSize: 15, color: "gray" }}>
              {item.items?.[0]?.variantName}
            </Text>
            {platformText !== undefined && platformText && (
              <XStack
                backgroundColor="$failBox"
                paddingVertical="$1"
                paddingHorizontal="$2"
                width={100}
                height={screenHeight * 0.03}
                borderRadius={5}
              >
                <Paragraph fontSize={12} color="$failText">
                  {platformText}
                </Paragraph>
              </XStack>
            )}
          </YStack>
          {/* price of the service */}
          <YStack
            flexDirection="column"
            height={screenHeight * 0.1}
            width={screenWidth * 0.3}
            alignItems="center"
          >
            <Text style={{ fontWeight: "800", fontSize: 15 }}>
              ¥{item.payPrice}
            </Text>
          </YStack>
        </XStack>
      </TouchableWithoutFeedback>

      <XStack
        flexDirection="row"
        alignItems="center"
        paddingHorizontal={10}
        backgroundColor="#fff"
        paddingVertical="$3"
      >
        <Button
          flexDirection="row"
          backgroundColor="#F2F2F2"
          width={screenWidth - 20}
          height={screenHeight * 0.04}
          alignItems="center"
          paddingHorizontal="$3"
          radiused
          unstyled
        >
          <Text style={{ color: "#B66D0E" }}>{text}</Text>
        </Button>
      </XStack>

      {/* 按钮 */}
      <XStack
        flex={0}
        marginLeft="auto"
        space="$2"
        paddingBottom="$3"
        paddingHorizontal="$3"
      >
        {buttonList.map((button, index) => (
          <Button
            key={index}
            backgroundColor="#fff"
            borderRadius={20}
            borderWidth={1}
            borderColor="$brown"
            paddingVertical={3}
            paddingHorizontal="$3"
            height={35}
            flexDirection="row"
            alignItems="center"
            onPress={() =>
              handleButtonClick({
                dispatch,
                button,
                role,
                item,
                setIssuePopup,
                setMaterialPopup,
              })
            }
            unstyled
          >
            <ButtonText
              color={index === buttonList.length - 1 ? "$brown" : "#000"}
            >
              {button}
            </ButtonText>
          </Button>
        ))}
      </XStack>

      <OrderBottomSheet
        item={item}
        role={role}
        dispatch={dispatch}
        issuePopup={issuePopup}
        materialPopup={materialPopup}
        comfirmPopup={comfirmPopup}
        setIssuePopup={setIssuePopup}
        setMaterialPopup={setMaterialPopup}
        setComfirmPopup={setComfirmPopup}
      />
    </View>
  );
});
