import { router } from "expo-router";
import React, {
  memo,
  useCallback,
  useEffect,
  useMemo,
  useState,
  useRef,
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
import { Paragraph, XStack, YStack, Button, ButtonText } from "tamagui";

import { getButtons, goToSellerPage, handleButtonClick } from "./common_funcs";
import { QueryDict } from "../queryDict";

import { useGlobalContext } from "../system/globalContext";
import { AppDispatch, RootState, slices } from "@/src/store";

const PAGE_SIZE = 5;

const ServicePostSale = memo((props: { role: "seller" | "buyer" }) => {
  const { screenHeight } = useGlobalContext();
  const orderPostSale = useSelector((state: RootState) =>
    props.role === "buyer"
      ? state.orderList.refundListForBuyer
      : state.orderList.refundListForSeller
  );
  const isLoading = useSelector((state: RootState) => state.orderList.loading);
  const hasMore = useSelector((state: RootState) => state.orderList.hasMore);
  const changed = useSelector((state: RootState) => state.order.changed);

  const [pageNum, setPageNum] = useState(1);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const dispatch = useDispatch<AppDispatch>();
  const isRefreshing = useRef(false);

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
      if (isLoading || (!hasMore && !refresh) || isRefreshing.current) {
        return;
      }

      if (refresh) {
        isRefreshing.current = true;
      }

      const params = {
        pageNum: refresh ? 1 : page,
        pageSize: PAGE_SIZE,
      };

      if (props.role === "seller") {
        dispatch(
          slices.orderList.actions.fetchTenantRefundList(params)
        ).finally(() => {
          if (refresh) {
            isRefreshing.current = false;
          }
        });
      } else {
        dispatch(slices.orderList.actions.fetchBuyerRefundList(params)).finally(
          () => {
            if (refresh) {
              isRefreshing.current = false;
            }
          }
        );
      }

      if (refresh) {
        setPageNum(2);
      } else if (hasMore) {
        setPageNum((prevPage) => prevPage + 1);
      }
    },
    [props.role]
  );

  useEffect(() => {
    if (isInitialLoad) {
      handleRefresh();
    }
  }, [props.role]);

  useEffect(() => {
    if (changed && !isInitialLoad) {
      handleRefresh();
      dispatch(slices.order.actions.setChanged());
    }
  }, [changed]);

  const handleRefresh = useCallback(() => {
    if (isRefreshing.current) return;

    dispatch(
      slices.orderList.actions.resetRefundList({
        type: props.role,
      })
    );
    fetchOrderList({ page: 1, refresh: true });
    setIsInitialLoad(false);
  }, [fetchOrderList, props.role]);

  const handleLoadMore = useCallback(() => {
    if (!isLoading && hasMore && pageNum > 1) {
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
        data={orderPostSale}
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

export default ServicePostSale;

const OrderItem = memo(({ item, role }: { item; role }) => {
  const { dictData, screenHeight, screenWidth } = useGlobalContext();
  const dispatch = useDispatch<AppDispatch>();

  // 获取按钮列表
  const buttonList = useMemo(() => {
    return getButtons({
      state: "",
      role,
      is_refund: true,
      refundState: item?.refundState,
    });
  }, [item, role, item?.refundState]);

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
          width={screenWidth * 0.6}
          onPress={() => goToSellerPage(item.tenantId)}
        >
          <Paragraph fontSize={16} marginHorizontal={10}>
            {role === "seller" ? "买家" : "卖家"}:
            {role === "seller" ? item.buyer?.nickName : item.tenant?.nickName}
            {"id" + item.id}
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
          backgroundColor={
            item?.refundState === "audit_refused" ? "$failBox" : "#DAF4E1"
          }
        >
          <Paragraph
            color={
              item?.refundState === "audit_refused" ? "$failText" : "#476F5C"
            }
            fontSize={12}
          >
            {QueryDict(dictData["refund_state"], item?.refundState).label}
          </Paragraph>
        </XStack>
      </XStack>

      <TouchableWithoutFeedback
        onPress={() =>
          router.push({
            pathname: "/(outer)/order/detail",
            params: { orderId: item?.orderId, refundId: item?.id, role },
          })
        }
      >
        <XStack flexDirection="row" alignItems="center" backgroundColor="#fff">
          {/* image of the service */}

          <FastImage
            source={{
              uri: item?.productImage,
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
            width={screenWidth * 0.6}
            space="$1"
          >
            <Text style={{ fontWeight: "800", fontSize: 15 }} numberOfLines={1}>
              {item?.productName}
            </Text>
            <Text style={{ fontWeight: "400", fontSize: 15 }} numberOfLines={1}>
              {item?.productInfo?.description}
            </Text>
            <Paragraph style={{ fontSize: 15, color: "$gray8" }}>
              {item.variantName}
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
                退款原因：
                {item?.refundReason}
              </Paragraph>
            </XStack>
          </YStack>
          {/* price of the service */}
          <YStack
            flexDirection="column"
            height={screenHeight * 0.1}
            width={screenWidth * 0.2}
          >
            <Paragraph style={{ fontSize: 17, fontWeight: "500" }}>
              ¥{item?.productInfo?.sellingPrice}
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
                role: role,
                item,
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
    </View>
  );
});
