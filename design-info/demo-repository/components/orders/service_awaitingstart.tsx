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
import { useCountdown } from "../time_processor";

import { AppDispatch, RootState, slices } from "@/src/store";

const PAGE_SIZE = 5;
const STATE = 1;

/**
 * 服务待接单（卖家）state=1 awaitStart
 * @param props
 */
const ServiceAwaitingStart = memo((props: object) => {
  const OrdersAwaitingStart = useSelector(
    (state: RootState) => state.orderList.orderListForSeller?.[STATE]
  );
  const isLoading = useSelector((state: RootState) => state.orderList.loading);
  const hasMore = useSelector((state: RootState) => state.orderList.hasMore);
  const [pageNum, setPageNum] = useState(1);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const dispatch = useDispatch<AppDispatch>();

  const changed = useSelector((state: RootState) => state.order.changed);
  const successToVerifyOrder = useSelector(
    (state: RootState) => state.order.successToVerifyOrder
  );

  // 获取订单列表，仅在组件第一次渲染时更新
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
        type: "seller",
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

  // 自动刷新： 组件初始化时调用（当useSelector中的值发生变化时，如果依赖项变化会重新渲染，否则不会重新渲染）
  useEffect(() => {
    handleRefresh();
  }, [fetchOrderList, changed]);

  // 手动刷新
  const handleRefresh = useCallback(() => {
    dispatch(
      slices.orderList.actions.resetOrderList({
        type: "seller",
        state: STATE,
      })
    );
    fetchOrderList({ page: 1, refresh: true });
    setIsInitialLoad(false);
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
        data={OrdersAwaitingStart}
        renderItem={({ item }) => <OrderItem item={item} />}
        keyExtractor={(item, index) => `${item.id}-${index}`}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.1}
        showsHorizontalScrollIndicator={false}
        ListFooterComponent={() => (
          <Paragraph alignSelf="center" color="$lightGray" marginTop="auto">
            没有更多了
          </Paragraph>
        )}
        contentContainerStyle={{ paddingBottom: global.screenHeight * 0.3 }}
        refreshing={isLoading}
        onRefresh={handleRefresh}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
});

export default ServiceAwaitingStart;

const OrderItem = memo(({ item }: { item: any }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [issuePopup, setIssuePopup] = useState(false);
  const [materialPopup, setMaterialPopup] = useState(false);
  const [comfirmPopup, setComfirmPopup] = useState(false);

  // 获取按钮列表
  const buttonList = useMemo(() => {
    return getButtons({
      state: item.state,
      role: "seller", // 这个组件固定是卖家角色
      is_refund: false,
      refundState: undefined,
    });
  }, [item.state]);

  const autoMaterialTime = useSelector(
    (state: RootState) => state.order.autoMaterialTime
  );
  const autoMaterialLeftTime = useCountdown(autoMaterialTime);

  // 获取状态文本
  const text = useMemo(() => {
    return renderText({
      state: item.state,
      role: "seller",
      autoMaterialLeftTime,
    });
  }, [item.state, autoMaterialLeftTime]);

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
            {item.buyer?.nickName}
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
            {item?.state === "awaitingStart"
              ? "等待您接单"
              : "等待买家补充材料"}
          </Paragraph>
        </XStack>
      </XStack>

      <TouchableWithoutFeedback
        onPress={() =>
          router.push({
            pathname: "/(outer)/order/detail",
            params: {
              orderId: item?.id,
              role: "seller",
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
              width: global.screenHeight * 0.1,
              height: global.screenHeight * 0.1,
              marginHorizontal: 10,
              borderRadius: 5,
              backgroundColor: "#EDEDED",
            }}
            resizeMode={FastImage.resizeMode.stretch}
          />

          {/* details of the service */}
          <YStack
            flexDirection="column"
            height={global.screenHeight * 0.1}
            width={global.screenWidth * 0.6}
            space="$1"
          >
            <Text style={{ fontWeight: "800", fontSize: 15 }} numberOfLines={1}>
              {item.items?.[0].productName}
            </Text>
            <Text style={{ fontWeight: "400", fontSize: 15 }} numberOfLines={1}>
              {item.items.productInfo}...
            </Text>
            <Paragraph fontSize={15} color="$gray8">
              {item.items?.[0]?.variantName}
            </Paragraph>
            <XStack
              flexDirection="row"
              alignItems="center"
              borderRadius={5}
              paddingVertical="$1"
              paddingHorizontal="$2"
              backgroundColor="#F2F2F2"
            >
              <Paragraph color="#B66D0E" fontSize={12} numberOfLines={1}>
                {text}
              </Paragraph>
            </XStack>
          </YStack>
          {/* price of the service */}
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

      {/* 按钮 */}
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
            onPress={() =>
              handleButtonClick({
                dispatch,
                button,
                role: "seller",
                item,
                setIssuePopup,
                setMaterialPopup,
                setComfirmPopup,
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
        role="seller"
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
