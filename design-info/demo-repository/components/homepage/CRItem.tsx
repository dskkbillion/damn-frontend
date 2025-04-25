import React from "react";
import {
  StyleProp,
  ViewStyle,
  ViewProps,
  Text,
  Image as ImageNative,
} from "react-native";
import type { AnimateProps } from "react-native-reanimated";
import Animated from "react-native-reanimated";
import { Avatar, Paragraph, XStack, YStack } from "tamagui";

import { sellerDataset } from "@/constants/sellers";
import FastImage from "react-native-fast-image";

interface Props extends AnimateProps<ViewProps> {
  style?: StyleProp<ViewStyle>;
  index?: number;
  is_plural?: boolean; //控制展示一张还是两张
  showIndex?: boolean;
  imgs?: string[];
  item: any;
}

export const CRItem: React.FC<Props> = (props) => {
  const {
    style,
    index,
    is_plural,
    showIndex,
    imgs,
    item,
    ...animatedViewProps
  } = props;
  // 传入参数是plural为true时为一页两张，false时为一页一张
  return (
    <Animated.View style={{ flex: 1 }} {...animatedViewProps}>
      {is_plural ? (
        <PluralItem index={index} imgs={imgs} item={item} />
      ) : (
        <SingleItem index={index} imgs={imgs} item={item} />
      )}
    </Animated.View>
  );
};

const PluralItem: React.FC<Props> = ({ index, imgs, item }) => {
  console.log("长度", item?.length);
  console.log("键", Object.keys(item?.[0]));
  console.log(item?.[1]?.content);
  return (
    <XStack flexDirection="row" space="4%" height="100%" width="100%">
      {item?.map((subItem: any, subIndex: number) => {
        return (
          <XStack
            key={subIndex} // 将 key 放在这里
            flexDirection="row"
            width="44%"
            height="100%"
            backgroundColor="#ffffff"
            borderRadius={8}
          >
            <YStack flex={1} space="2%" height="100%">
              {imgs &&
                imgs[subIndex] && ( // 检查 imgs 和对应的 index
                  <ImageNative
                    source={{ uri: imgs[subIndex] }}
                    resizeMode="cover"
                    style={{ width: "100%", height: "55%" }}
                    borderTopLeftRadius={8}
                    borderTopRightRadius={8}
                  />
                )}
              <XStack flex={0} alignItems="center" marginLeft="4%" space="$3">
                <Text
                  style={{
                    fontSize: 12,
                    marginLeft: "auto",
                    color: "gray",
                    marginRight: "4%",
                  }}
                >
                  {subItem?.createTime}
                </Text>
              </XStack>
              <Text
                numberOfLines={2}
                style={{
                  fontSize: 14,
                  width: "80%",
                  fontWeight: "700",
                  alignSelf: "center",
                  marginTop: "4%",
                }}
              >
                {subItem?.content}
              </Text>
              <Paragraph>{}</Paragraph>
            </YStack>
          </XStack>
        );
      })}
    </XStack>
  );
};

const SingleItem: React.FC<Props> = ({ index, imgs }) => {
  // console.log(isImg);

  const handleImageError = () => {
    // console.log("Error loading image:", img);
    // 可以在这里处理图像加载失败的情况，例如显示默认图片或者其他错误处理逻辑
  };

  return (
    <ImageNative
      source={{ uri: imgs![0] }}
      resizeMode="cover"
      borderRadius={8}
      style={{ width: "100%", height: "100%" }}
      onError={handleImageError}
    />
  );
};
