/**
 * @description 水平的商品展示列表
 * @param data 商品数据（默认使用 homeItemList）
 * @param height 商品高度
 */

import { FlashList } from "@shopify/flash-list";
import { router } from "expo-router";
import React, { memo, useMemo } from "react";
import { View, Text, StyleSheet, TouchableWithoutFeedback } from "react-native";
import FastImage from "react-native-fast-image";
import Icon from "react-native-vector-icons/FontAwesome";
import { useSelector } from "react-redux";
import { Card, XStack, YStack } from "tamagui";

import { RootState } from "@/src/store";

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
});

interface HorizontalItemListProps {
  data?: any[];
  height: number;
  source: string;
}

const HorizontalItemList = memo(
  ({ data, height, source }: HorizontalItemListProps) => {
    const homeItemList = useSelector(
      (state: RootState) => state.item.homeItemList?.products
    );

    // 使用 useMemo 处理数据
    const displayData = useMemo(() => {
      // 如果没有传入 data，使用 homeItemList
      if (!data) {
        return homeItemList || [];
      }
      // 如果传入了 data，使用传入的数据
      return data;
    }, [data, homeItemList]);

    return (
      <FlashList
        data={displayData}
        keyExtractor={(item: any) => item?.id?.toString()}
        renderItem={({ item, index }) => (
          <ItemContent
            item={item}
            index={index}
            height={height}
            source={source}
          />
        )}
        contentContainerStyle={styles.container}
        horizontal
        onEndReachedThreshold={0.1}
        estimatedItemSize={100}
        showsHorizontalScrollIndicator={false}
      />
    );
  }
);

const ItemContent = memo(
  ({
    item,
    index,
    height,
    source,
  }: {
    item: any;
    index: number;
    height: number;
    source: string;
  }) => {
    if (!item) return null;

    return (
      <TouchableWithoutFeedback
        style={{
          marginLeft: index > 0 ? 10 : 0,
        }}
        onPress={() => {
          router.replace({
            pathname: "/(outer)/home/itemHomepage",
            params: {
              id: item?.id,
              source,
            },
          });
        }}
      >
        <Card
          style={{
            width: global.screenWidth * 0.38,
          }}
          pressStyle={{
            transform: [{ scale: 1.02 }],
            shadowColor: "#B66D0E",
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 0.2,
            shadowRadius: 4,
          }}
        >
          <FastImage
            source={{
              uri: item?.images?.[0],
              priority: FastImage.priority.normal,
            }}
            style={{
              height,
              width: "100%",
              borderTopLeftRadius: 8,
              borderTopRightRadius: 8,
            }}
          />

          <YStack padding="$2">
            <XStack marginRight="auto">
              <Icon name="star" size={16} color="#EDB466" />
              <Text style={{ color: "#EDB466", fontWeight: "800" }}>
                {" "}
                {item.score}
              </Text>
              <Text style={{ color: "#797B83" }}> ({item.evaluateNum})</Text>
            </XStack>
            <YStack flex={1} padding="$1" />
            <YStack>
              <XStack marginRight="auto">
                <Text style={{ fontWeight: "500" }}>{item.category}</Text>
              </XStack>
              <YStack flex={1} padding="$1" />
              <XStack>
                <Text
                  numberOfLines={2}
                  ellipsizeMode="tail"
                  style={{
                    maxWidth: "100%",
                    overflow: "hidden",
                    minHeight: 35,
                  }}
                >
                  {item.description}
                </Text>
              </XStack>
            </YStack>
          </YStack>
          <Card.Footer paddingRight="$2">
            <XStack marginLeft="auto">
              <Text>¥{item?.sellingPrice}</Text>
            </XStack>
          </Card.Footer>
          <YStack flex={1} padding="$1" />
        </Card>
      </TouchableWithoutFeedback>
    );
  }
);

export default HorizontalItemList;
