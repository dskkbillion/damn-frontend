import { router } from "expo-router";
import { memo, useEffect, useRef } from "react";
import { Text, View, TouchableWithoutFeedback, Animated, NativeSyntheticEvent, NativeScrollEvent, StatusBar } from "react-native";
import { SvgXml } from "react-native-svg";
import Icon from "react-native-vector-icons/Ionicons";
import { useDispatch, useSelector } from "react-redux";
import { YStack, Theme, XStack, useTheme } from "tamagui";

import ServiceWaterFall from "@/components/homepage/waterfallLayout";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

const HomeScreen = memo(() => {
  const theme = useTheme();
  const dispatch = useDispatch<AppDispatch>();
  const token = useSelector((state: RootState) => state.auth.userToken);

  // 创建动画值用于控制logo的位置和透明度
  const scrollY = useRef(new Animated.Value(0)).current;

  // 计算logo的位置和透明度
  const logoTranslateY = scrollY.interpolate({
    inputRange: [0, 60],
    outputRange: [0, -60],
    extrapolate: 'clamp'
  });

  const logoOpacity = scrollY.interpolate({
    inputRange: [0, 60],
    outputRange: [1, 0],
    extrapolate: 'clamp'
  });

  // 计算背景框的高度变化
  const headerHeight = scrollY.interpolate({
    inputRange: [0, 60],
    outputRange: [150, 90],  // 从150px减小到90px
    extrapolate: 'clamp'
  });

  // 计算搜索框的位置变化 - 初始在logo下方，滚动时固定在顶部
  const searchBarTop = scrollY.interpolate({
    inputRange: [0, 60],
    outputRange: [100, StatusBar.currentHeight || 40],  // 从logo下方移动到顶部
    extrapolate: 'clamp'
  });

  // 使用普通函数处理滚动事件
  const handleScroll = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const offsetY = event.nativeEvent.contentOffset.y;
    scrollY.setValue(offsetY);
  };

  useEffect(() => {
    // 判断用户是否为访客
    const loggingData = {
      path: "/home",
      businessType: "pv",
      businessId: "home",
      feature: {
        is_visitor: !!token,
      },
    };
    dispatch(slices.logging.actions.sendLoggingData(loggingData));
  }, []);

  return (
    <Theme name="light">
      {/* 背景框 - 高度会随滚动变化 */}
      <Animated.View
        style={{
          height: headerHeight,
          backgroundColor: "#B66D0E",
          zIndex: 1
        }}
      >
        {/* Logo - 随滚动上移消失 */}
        <Animated.View
          style={{
            position: "absolute",
            top: 45,
            zIndex: 2,
            width: "100%",
            transform: [{ translateY: logoTranslateY }],
            opacity: logoOpacity
          }}
        >
          <SvgXml
            xml={LOGO_XML_WITHOUT_BACKGROUND}
            width="100%"
            height={55}
          />
        </Animated.View>
      </Animated.View>

      {/* 搜索框 - 初始在logo下方，滚动时固定在顶部 */}
      <Animated.View
        style={{
          position: "absolute",
          top: searchBarTop,
          left: 0,
          right: 0,
          zIndex: 10
        }}
      >
        <TouchableWithoutFeedback
          onPress={() => router.push("/(tabs)/homepage/search")}
        >
          <YStack
            paddingTop="$2"
            width="100%"
            height={40}
            alignItems="center"
          >
            <XStack
              flexDirection="row"
              alignItems="center"
              justifyContent="center"
              backgroundColor="#ffffff"
              width="80%"
              height="100%"
              borderRadius={5}
              paddingVertical="$1"
            >
              <Icon
                alignSelf="center"
                fontSize={16}
                name="search"
                color="#A4A4A4"
              />
              <Text
                style={{
                  flexDirection: "row",
                  paddingHorizontal: 20,
                  color: "gray",
                  fontSize: 14
                }}
              >
                猜你想搜...
              </Text>
            </XStack>
          </YStack>
        </TouchableWithoutFeedback>
      </Animated.View>

      {/* 内容区域 */}
      <ServiceWaterFall
        showListHeaderComponent
        itemVisiblePercentThreshold={70}
        source="home"
        onScroll={handleScroll}
        scrollEventThrottle={16}
      />
    </Theme>
  );
});

export default HomeScreen;
