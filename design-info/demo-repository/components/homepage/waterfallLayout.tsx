/**
 * @description 首页瀑布流布局
 * @use 首页、搜索页、AI推荐页
 * @params source: "home" | "search" | "ai_home" | "recommend"
 * @params showListHeaderComponent: 是否显示轮播图
 * @params itemVisiblePercentThreshold: 图片可见百分比阈值
 * @params onScroll: 滚动事件回调
 * @params scrollEventThrottle: 滚动事件节流值
 */

import { FlashList } from "@shopify/flash-list";
import { router } from "expo-router";
import React, { useEffect, useRef, memo, useCallback, useState } from "react";
import { View, Text, Dimensions, TouchableWithoutFeedback, NativeSyntheticEvent, NativeScrollEvent } from "react-native";
import FastImage from "react-native-fast-image";
import Icon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import { Card, XStack, YStack, Button } from "tamagui";

import CarouselComp from "@/components/homepage/top_carousel";
import { RecommendDataset } from "@/constants/recommendations";
import { AppDispatch, RootState, slices } from "@/src/store";
import { getFilePath } from "../utils/filesystem";
import { useBottomSheet } from "../ai_doc/bottom-sheet-context";

const ServiceWaterFall = memo(
  ({
    showListHeaderComponent,
    itemVisiblePercentThreshold = 70,
    source = "home",
    priceAlignLeft = false,
    onScroll,
    scrollEventThrottle,
  }: {
    showListHeaderComponent;
    itemVisiblePercentThreshold;
    source: "home" | "search" | "ai_home" | "recommend";
    priceAlignLeft?: boolean;
    onScroll?: (event: NativeSyntheticEvent<NativeScrollEvent>) => void;
    scrollEventThrottle?: number;
  }) => {
    const dispatch = useDispatch<AppDispatch>();
    const homeItemList = useSelector(
      (state: RootState) => state.item.homeItemList
    );
    const searchItemList = useSelector(
      (state: RootState) => state.item.searchItemList
    );

    // 添加一个标志来标识是否为推荐服务数据
    const isRecommendDataset = (source === "home" && !showListHeaderComponent) || source === "recommend";

    const recommendItemList = RecommendDataset.map((service) => ({
      id: 160,
      images: [service["image_url"]],
      score: service["rating"],
      evaluateNum: service["rating_num"],
      service_title: service["service_title"],
      sellingPrice: service.basic.price,
      description: service["description"],
      imageHeight: service.image_height,
      name: service["service_title"],
    }));

    const calculatedHeights = useRef(new Map()); // 存储已经计算并且更新的高度

    const column1Height = useRef(0); // 左侧高度
    const column2Height = useRef(0); // 右侧高度
    const prevGapMap = useRef(new Map()); // 使用 Map 存储前一个图片的高度差
    const changedHeightMap = useRef(new Map()); // 使用 Map 存储高度变化的图片

    const [sourceLoading, setSourceLoading] = useState(false);

    // 定义布局常量
    const containerPadding = 16; // 容器左右内边距
    const middleGap = 16; // 中间间距
    const screenWidth = Dimensions.get("window").width; // 获取屏幕宽度

    const fetchHomeItemList = useCallback(async () => {
      try {
        await dispatch(slices.item.actions?.fetchHomeItemList({}));
      } catch (err) {
        console.log("获取首页商品列表失败", err);
      }
    }, [dispatch]);

    const handleRefresh = useCallback(async () => {
      if (source === "ai_home" || source === "recommend") return;

      setSourceLoading(true);
      try {
        if (source === "home") {
          await dispatch(slices.item.actions?.resetHomeItemList());
          // 清空高度数据
          column1Height.current = 0;
          column2Height.current = 0;
          prevGapMap.current.clear();
          changedHeightMap.current.clear();
          calculatedHeights.current.clear();

          await dispatch(slices.item.actions?.fetchHomeItemList({}));
        } else if (source === "search") {
          // 搜索页面的刷新逻辑
          // await dispatch(slices.item.actions?.resetSearchItemList());
          // ... 搜索页面的其他刷新逻辑
        }
      } catch (err) {
        console.log("刷新失败", err);
      } finally {
        setSourceLoading(false);
      }
    }, [source, dispatch]);

    useEffect(() => {
      handleRefresh();
    }, [fetchHomeItemList]);

    const calculateImageHeight = useCallback((item) => {
      const url = item?.images?.[0];
      console.log("url", url);
      const parts = url.split("_");
      if (parts.length < 2) {
        return 200;
      } else {
        const height = parseInt(parts[parts.length - 2], 10);
        const width = parseInt(parts[parts.length - 1], 10);

        const aspectRatio = height / width;
        const aspectWidth = Math.min(
          width,
          Dimensions.get("window").width * 0.45
        );
        const aspectHeight = Math.min(aspectWidth * aspectRatio, 200);

        return aspectHeight;
      }
    }, []);

    const positionImage = (index, imageHeight) => {
      const found = prevGapMap.current.has(index);

      let prevGap: number;
      let IsShortCol: boolean;

      if (found) {
        prevGap = prevGapMap.current.get(index);
        IsShortCol =
          (prevGap <= 0 && index % 2 === 0) || (prevGap > 0 && index % 2 === 1);
      } else {
        if (index % 2 === 0) {
          prevGap = column1Height.current - column2Height.current;
          IsShortCol = prevGap <= 0;
        } else {
          prevGap = prevGapMap.current.get(index - 1);
          IsShortCol = prevGap > 0;
        }

        prevGapMap.current.set(index, prevGap);
      }

      if (!found) {
        if (IsShortCol && Math.abs(prevGap) > 10 + imageHeight) {
          // console.log("改变高度", index, imageHeight);
          // console.log("prevGap", prevGap);
          // console.log("IsShortCol", IsShortCol);
          imageHeight = Math.abs(prevGap);
          changedHeightMap.current.set(index, imageHeight);
        }
        if (index % 2 == 0) {
          // console.log("column1Height加上", index, imageHeight);
          column1Height.current += imageHeight;
        } else {
          // console.log("column2Height加上", index, imageHeight);
          column2Height.current += imageHeight;
        }
      }

      const changedHeight = changedHeightMap.current.get(index);

      if (changedHeight) {
        return { prevGap, IsShortCol, imageHeight: changedHeight };
      } else {
        return { prevGap, IsShortCol, imageHeight };
      }
    };

    useEffect(() => {
      if (source === "home" && !homeItemList?.products) {
        handleRefresh();
      }
    }, [source]);

    return (
      <FlashList
        data={
          source === "home"
            ? homeItemList?.products
            : source === "search"
              ? searchItemList
              : source === "recommend"
                ? recommendItemList
                : recommendItemList
        }
        keyExtractor={(item: any) => `${item?.id}-${source}`}
        refreshing={source !== "ai_home" && sourceLoading}
        onRefresh={source === "ai_home" ? undefined : handleRefresh}
        onScroll={onScroll}
        scrollEventThrottle={scrollEventThrottle}
        renderItem={({ item, index }) => {
          const height = calculateImageHeight(item);
          return (
            <ItemContent
              item={item}
              index={index}
              height={height}
              positionImage={positionImage}
              source={source}
              containerPadding={containerPadding}
              middleGap={middleGap}
              priceAlignLeft={priceAlignLeft}
            />
          );
        }}
        contentContainerStyle={{
          paddingHorizontal: 0, // 移除容器的水平内边距
          paddingVertical: 8,
          paddingRight: 0, // 移除右侧内边距
        }}
        style={{
          width: screenWidth - 10, // 减小FlashList宽度，确保右侧卡片完整显示
          alignSelf: 'flex-start', // 左对齐
        }}
        ListHeaderComponent={
          source === "home" && showListHeaderComponent ? <CarouselComp /> : null
        }
        numColumns={2}
        estimatedItemSize={2000}
        ListFooterComponent={() => <XStack paddingVertical="$10" />}
        showsVerticalScrollIndicator={false}
      />
    );
  }
);

/**
 * item：
 * height：图片高度
 */
const ItemContent = memo(
  ({
    item,
    index,
    height,
    positionImage,
    source,
    containerPadding,
    middleGap,
    priceAlignLeft = false,
  }: {
    item;
    index;
    height;
    positionImage;
    source: "home" | "search" | "ai_home" | "recommend";
    containerPadding: number;
    middleGap: number;
    priceAlignLeft?: boolean;
  }) => {
    const { presented, handleDismissModal } = useBottomSheet();

    if (!height) {
      return null;
    }
    const { prevGap, IsShortCol, imageHeight } = positionImage(index, height);
    const screenWidth = Dimensions.get("window").width;

    // 计算卡片宽度，确保右侧卡片完整显示
    const totalWidth = screenWidth;
    const leftPadding = containerPadding;
    const rightPadding = containerPadding;
    const availableWidth = totalWidth - leftPadding - rightPadding - middleGap;
    const cardWidth = Math.floor(availableWidth / 2);

    // 根据索引确定是左侧还是右侧卡片
    const isRightCard = index % 2 === 1;

    // 创建卡片容器样式
    const containerStyle = {
      width: cardWidth,
      marginLeft: isRightCard ? middleGap : leftPadding,
      marginRight: isRightCard ? rightPadding + 8 : 0, // 右侧卡片增加右边距
      marginTop: IsShortCol ? 10 - Math.abs(prevGap) : 10,
    };

    // 创建卡片样式
    const cardStyle = {
      width: isRightCard ? '95%' : '100%', // 右侧卡片宽度减少5%
      height: 'auto',
      overflow: 'hidden',
      borderRadius: 8,
      shadowColor: "#B66D0E",
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 3,
      elevation: 2,
    };

    return (
      <View key={item.id} style={containerStyle}>
        <TouchableWithoutFeedback
          onPress={() => {
            if (presented) {
              handleDismissModal();
            }
            router.push({
              pathname: "/(outer)/home/itemHomepage",
              params: {
                id: item?.id,
                source,
                fromRecommend: priceAlignLeft ? "true" : "false"
              },
            });
          }}
        >
          <Card
            style={{
              ...cardStyle,
            }}
            pressStyle={{
              transform: [{ scale: 1.02 }],
              shadowOpacity: 0.2,
              shadowRadius: 5,
            }}
          >
            <FastImage
              source={{
                uri: getFilePath(item?.images?.[0]) || "",
                priority: FastImage.priority.normal,
              }}
              style={{
                borderTopLeftRadius: 8,
                borderTopRightRadius: 8,
                width: "100%",
                height: imageHeight === height ? height : imageHeight,
              }}
              resizeMode={FastImage.resizeMode.stretch}
              onError={() => console.log('图片加载失败:', item?.images?.[0])}
            />
            <YStack padding="$2">
              <XStack marginRight="auto">
                <Icon name="star" size={16} color="#EDB466" />
                <Text style={{ color: "#EDB466", fontWeight: "800" }}>
                  {item?.score ? item?.score : "5.0"}
                </Text>
                <Text style={{ color: "#797B83" }}> ({item?.evaluateNum})</Text>
              </XStack>
              <YStack flex={1} padding="$1" />
              <YStack style={{ flexDirection: "column" }}>
                <XStack marginRight="auto" />
                <YStack flex={1} padding="$1" />
                <XStack>
                  <Text
                    numberOfLines={2}
                    ellipsizeMode="tail"
                    style={{
                      maxWidth: "100%",
                      overflow: "hidden",
                      minHeight: 35,
                      fontSize: 16,
                    }}
                  >
                    {item?.name}
                  </Text>
                </XStack>
              </YStack>
            </YStack>

            {/* 价格显示 - 根据priceAlignLeft属性决定价格显示位置 */}
            {priceAlignLeft ? (
              // 价格在左边
              <XStack
                justifyContent="flex-start"
                alignItems="flex-end"
                paddingHorizontal="$2"
                paddingBottom="$2"
              >
                <Text style={{ fontSize: 15 }}>¥</Text>
                <Text style={{ fontSize: 18, fontWeight: "500" }}>
                  {item?.sellingPrice}
                </Text>
              </XStack>
            ) : (
              // 价格在右边
              <XStack
                justifyContent="flex-end"
                alignItems="flex-end"
                paddingHorizontal="$2"
                paddingBottom="$2"
              >
                <Text style={{ fontSize: 15 }}>¥</Text>
                <Text style={{ fontSize: 18, fontWeight: "500" }}>
                  {item?.sellingPrice}
                </Text>
              </XStack>
            )}

            {/* 一键咨询按钮 - 仅在推荐服务页面显示 */}
            {priceAlignLeft && (
              <XStack
                justifyContent="flex-end"
                paddingHorizontal="$2"
                paddingBottom="$2"
                marginTop="$1"
              >
                <Button
                  size="$2"
                  backgroundColor="#B66D0E" // 棕色主题色
                  color="white"
                  borderRadius="$4"
                  paddingHorizontal="$3" // 增加水平内边距
                  paddingVertical="$1.5" // 增加垂直内边距
                  fontWeight="500"
                  fontSize={13} // 增加字体大小
                  letterSpacing={0.5} // 添加字间距
                  onPress={() => {
                    // 暂不做任何跳转或链接
                    console.log("让ta看看按钮点击");
                  }}
                >
                  让ta看看
                </Button>
              </XStack>
            )}

            <YStack flex={1} padding="$1" />
          </Card>
        </TouchableWithoutFeedback>
      </View>
    );
  }
);

export default ServiceWaterFall;
