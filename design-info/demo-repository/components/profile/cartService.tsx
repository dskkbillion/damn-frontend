import { memo, useCallback, useEffect, useState } from "react";
import FastImage from "react-native-fast-image";
import { useDispatch, useSelector } from "react-redux";
import {
  Circle,
  Paragraph,
  XStack,
  YStack,
  styled,
  Text,
  Label,
  Button,
} from "tamagui";
import { AppDispatch, slices } from "@/src/store";
import { Link, Stack, router, useRouter } from "expo-router";
import { useNavigation } from "@react-navigation/native";

export const CartServiceComponent = memo(({ item }: { item: any }) => {
  if (!item) {
    return null;
  }
  const product = item?.product;

  return (
    <YStack backgroundColor="#fff" padding="2%">
      <Button
        width="100%"
        flexDirection="row"
        alignItems="center"
        flex={1}
        paddingVertical="$1"
        onPress={() =>
          router.push({
            pathname: "/(outer)/home/itemHomepage",
            params: { id: product?.id },
          })
        }
        unstyled
      >
        <FastImage
          source={{
            uri: product?.images[0],
            priority: FastImage.priority.normal,
          }}
          style={{
            width: 80,
            height: 80,
            marginHorizontal: 10,
            borderRadius: 5,
          }}
          resizeMode={FastImage.resizeMode.stretch}
        />
        {/* details of the service */}
        <YStack
          flexDirection="column"
          height={global.screenHeight * 0.1}
          width="50%"
          space="$1"
        >
          <Paragraph numberOfLines={1} fontWeight="600">
            {product.name}
          </Paragraph>
          <Paragraph numberOfLines={1}>{product?.description}...</Paragraph>
          <Paragraph style={{ fontSize: 15, color: "$gray8" }}>
            {product?.variantName}
          </Paragraph>
        </YStack>
        {/* price of the service */}
        <YStack
          flexDirection="column"
          height={global.screenHeight * 0.1}
          width="20%"
        >
          <Paragraph style={{ fontSize: 17, fontWeight: "500" }}>
            ¥{product?.sellingPrice}
          </Paragraph>
        </YStack>
      </Button>
    </YStack>
  );
});
