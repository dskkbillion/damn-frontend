import { router, useLocalSearchParams } from "expo-router";
import React, {
  memo,
  useCallback,
  useEffect,
  useState,
  useMemo,
  createContext,
  useContext,
} from "react";
import {
  FlatList,
  View,
  Text,
  ActivityIndicator,
  TouchableWithoutFeedback,
} from "react-native";
import FastImage from "react-native-fast-image";
import Icon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import { Paragraph, XStack, YStack, Button, ButtonText, Portal } from "tamagui";

import { getButtons, goToSellerPage } from "./common_funcs";
import { QueryDict } from "../queryDict";
import { useGlobalContext } from "../system/globalContext";
import { useCountdown } from "../time_processor";
import { getFilePath } from "../utils/filesystem";

import { AppDispatch, RootState, slices } from "@/src/store";
import { PaymentBottomSheet } from "../homepage/payment_bottomsheet";

const PAGE_SIZE = 5;
const STATE = 1;

const ServiceToBePaid = memo(() => {
  const orderToBePaid = useSelector(
    (state: RootState) => state.orderList.orderListForBuyer?.[STATE]
  );
  const isLoading = useSelector((state: RootState) => state.orderList.loading);
  const hasMore = useSelector((state: RootState) => state.orderList.hasMore);
  const dispatch = useDispatch<AppDispatch>();
  const [pageNum, setPageNum] = useState(1);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const [refresh, setRefresh] = useState(false);
  const isOrderUpdated = useSelector(
    (state: RootState) => state.order.orderState
  );
  const [isPaymentSheetOpen, setPaymentSheetOpen] = useState(false);
  const { isPresented } = useLocalSearchParams();

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
        type: "buyer",
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
    []
  );

  const handleRefresh = useCallback(() => {
    dispatch(
      slices.orderList.actions.resetOrderList({
        type: "buyer",
        state: STATE,
      })
    );
    fetchOrderList({ page: 1, refresh: true });
    setIsInitialLoad(false);
    setRefresh(false);
  }, [fetchOrderList]);

  // 加载更多订单列表 (非第一次加载)
  const handleLoadMore = useCallback(() => {
    if (!isLoading && hasMore && pageNum > 1) {
      fetchOrderList({
        page: pageNum,
        refresh: false,
        isLoading,
        hasMore,
      });
    }
  }, [pageNum, isLoading]);

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
  }, [isLoading, hasMore, isInitialLoad]);

  const getPurchaseServiceType = (item: any) => {
    const variantName = item?.items?.[0]?.variantName;
    if (variantName.includes("基础")) {
      return "bsc";
    } else if (variantName.includes("标准")) {
      return "std";
    } else {
      return "prem";
    }
  };

  useEffect(() => {
    handleRefresh();
  }, [fetchOrderList, isOrderUpdated, refresh]);

  useEffect(() => {
    if (isPresented === "true") {
      setPaymentSheetOpen(true);
    }
  }, [isPresented]);

  if (isInitialLoad) {
    return (
      <YStack flex={1} justifyContent="center" alignItems="center">
        <ActivityIndicator size="large" color="#0000ff" />
      </YStack>
    );
  }

  return (
    <YStack flex={1}>
      <FlatList
        data={orderToBePaid}
        renderItem={({ item }) => (
          <>
            <OrderItem
              item={item}
              role="buyer"
              setPaymentSheetOpen={setPaymentSheetOpen}
            />
            {isPaymentSheetOpen && (
              <PaymentBottomSheet
                isShow={setPaymentSheetOpen}
                item={item}
                tenantId={item.tenantId}
                purchaseServiceType={getPurchaseServiceType(item)}
                source_page="service_tobepaid"
              />
            )}
          </>
        )}
        keyExtractor={(item, index) => `${item.id}-${index}`}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.1}
        ListFooterComponent={renderFootComponent}
        contentContainerStyle={{ paddingBottom: 20 }}
        onRefresh={handleRefresh}
        refreshing={isLoading}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
});

export default ServiceToBePaid;

const OrderItem = memo(
  ({
    item,
    role,
    setPaymentSheetOpen,
  }: {
    item: any;
    role: string;
    setPaymentSheetOpen: (isOpen: boolean) => void;
  }) => {
    const autoCancelTime = useMemo(() => {
      return item.autoCancelTime;
    }, [item]);

    const autoCancelLeftTime = useCountdown(autoCancelTime);
    const { dictData } = useGlobalContext();

    // 获取按钮列表
    const buttonList = useMemo(() => {
      return getButtons({
        state: item.state,
        role,
        is_refund: false, // 待付款状态不需要考虑退款
        refundState: undefined,
      });
    }, [item.state, role]);

    // 获取状态文本
    const statusText = useMemo(() => {
      return QueryDict(dictData["shop_order_status"], item.state).label;
    }, [item.state]);

    return (
      <View style={{ marginBottom: 10, flex: 1, backgroundColor: "#fff" }}>
        <XStack
          flexDirection="row"
          alignItems="center"
          backgroundColor="#fff"
          paddingVertical="$3"
        >
          <XStack
            flexDirection="row"
            alignItems="center"
            width={global.screenWidth * 0.6}
            onPress={() => goToSellerPage(item.tenantId)}
          >
            <Paragraph fontSize={16} marginHorizontal={10}>
              {item.tenant?.nickName}
            </Paragraph>
            <Icon name="angle-right" size={20} color="#A5A5A6" />
          </XStack>

          <Paragraph
            fontSize={16}
            marginLeft="auto"
            marginRight={10}
            color="#B66D0E"
          >
            {statusText}
          </Paragraph>
        </XStack>

        <TouchableWithoutFeedback
          onPress={() => {
            setPaymentSheetOpen(true);
          }}
        >
          <XStack
            flexDirection="row"
            alignItems="center"
            backgroundColor="#fff"
          >
            <FastImage
              source={{
                uri: getFilePath(item?.items?.[0]?.productImage),
                priority: FastImage.priority.normal,
              }}
              style={{
                width: global.screenHeight * 0.1,
                height: global.screenHeight * 0.1,
                marginHorizontal: 10,
                borderRadius: 5,
                backgroundColor: "#EDEDED",
              }}
              resizeMode={FastImage.resizeMode.stretch}
            />

            <YStack
              flexDirection="column"
              height={global.screenHeight * 0.1}
              width={global.screenWidth * 0.6}
              space="$1"
            >
              <Text
                style={{ fontWeight: "800", fontSize: 15 }}
                numberOfLines={1}
              >
                {item?.items?.[0]?.productName}
              </Text>
              <Text
                style={{ fontWeight: "400", fontSize: 15 }}
                numberOfLines={1}
              >
                {item?.items?.[0]?.productInfo?.description}...
              </Text>
              <Text style={{ fontSize: 15, color: "$gray8" }}>
                {item?.items?.[0]?.variantName}
              </Text>
              <XStack
                flexDirection="row"
                alignItems="center"
                borderRadius={5}
                paddingVertical="$1"
                paddingHorizontal="$2"
                backgroundColor="#F2F2F2"
              >
                <Paragraph color="#B66D0E" fontSize={12} numberOfLines={1}>
                  订单将在 {autoCancelLeftTime.hours}时
                  {autoCancelLeftTime.minutes}分{autoCancelLeftTime.seconds}
                  秒后自动取消，请及时支付
                </Paragraph>
              </XStack>
            </YStack>
            <YStack
              flexDirection="column"
              height={global.screenHeight * 0.1}
              width={global.screenWidth * 0.2}
            >
              <Paragraph style={{ fontSize: 17, fontWeight: "500" }}>
                ¥{item.payPrice}
              </Paragraph>
            </YStack>
          </XStack>
        </TouchableWithoutFeedback>

        {/* 按钮部分 */}
        <XStack
          flex={0}
          marginLeft="auto"
          space="$2"
          paddingVertical="$3"
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
              onPress={() => setPaymentSheetOpen(true)}
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
      </View>
    );
  }
);
