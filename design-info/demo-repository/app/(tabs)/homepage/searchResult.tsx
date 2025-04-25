import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import React, { memo } from "react";
import { TouchableWithoutFeedback } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import Icon from "react-native-vector-icons/Ionicons";
import { useSelector } from "react-redux";
import { Paragraph, XStack, YStack } from "tamagui";

import ServiceWaterFall from "@/components/homepage/waterfallLayout";
import { RootState } from "@/src/store";

const SearchResultPage = memo(() => {
  const searchItemList = useSelector(
    (state: RootState) => state.item.searchItemList
  );
  const search = useLocalSearchParams().search;

  return (
    <SafeAreaProvider>
      <YStack
        flexDirection="column"
        alignItems="flex-start"
        width="100%"
        height="15%"
        backgroundColor="$brown"
      >
        <XStack width="100%" height="100%" marginTop="8%" alignItems="center">
          {/*返回按钮  */}
          <TouchableWithoutFeedback onPress={() => router.back()}>
            <XStack>
              <ChevronLeft size="$4" color="white" />
            </XStack>
          </TouchableWithoutFeedback>

          {/* 搜索栏 */}
          <TouchableWithoutFeedback
            onPress={() => router.push("/(tabs)/homepage/search")}
          >
            <XStack
              width="80%"
              height="30%"
              alignItems="center"
              borderRadius={5}
              backgroundColor="#ffffff"
              paddingLeft={20}
              onPress={() => router.push("/(tabs)/homepage/search")}
            >
              <Icon
                alignSelf="center"
                fontSize="$3"
                name="search"
                color="#A4A4A4"
              />
              <Paragraph
                fontSize={16}
                paddingHorizontal="$3"
                color="$lightGray"
              >
                {search}
              </Paragraph>
            </XStack>
          </TouchableWithoutFeedback>
        </XStack>
      </YStack>
      {searchItemList && searchItemList.length === 0 ? (
        <YStack
          flexDirection="column"
          alignItems="center"
          width="100%"
          marginTop="20%"
          height="100%"
        >
          <Paragraph fontSize={16} color="$lightGray">
            没有找到相关的服务
          </Paragraph>
        </YStack>
      ) : (
        <Paragraph>123</Paragraph>
        // <ServiceWaterFall
        //   showListHeaderComponent={false}
        //   itemVisiblePercentThreshold={70}
        //   source="search"
        // />
      )}
    </SafeAreaProvider>
  );
});

export default SearchResultPage;
