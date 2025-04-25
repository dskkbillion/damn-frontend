import { zIndex } from "@tamagui/themes";
import { useRouter } from "expo-router";
import React, { useState, useEffect, useRef } from "react";
import { Dimensions, Text, View } from "react-native";
import useTyperwriter from "react-typewriter-hook";
import {
  H1,
  H2,
  H3,
  ScrollView,
  XStack,
  YStack,
  Button,
  ButtonText,
  useTheme,
} from "tamagui";

import { AIGuidence } from "@/components/ai_instructions";
import { SelectProfile } from "@/components/select_profile";

export function AIDocsTitle() {
  const titleName = "生成你的专属文书...";
  const [showFullText, setShowFullText] = useState(true); // 初始化显示文本
  const [trigger, setTrigger] = useState(false); // 初始化没有打字效果
  const typewriterText = useTyperwriter(trigger ? titleName : " ") || "";

  // 分割文本
  const middleIndex = Math.floor(titleName.length / 2);

  // 当前显示的文本长度是否超过了中间位置
  const isBeyondMiddle = typewriterText.length > middleIndex;

  // 根据当前打字机效果的进度分割文本
  const firstPart = isBeyondMiddle
    ? typewriterText.substring(0, middleIndex) //超过中点只显示一半
    : typewriterText; //没有超过中点显示全部加载

  const secondPart = isBeyondMiddle
    ? typewriterText.substring(middleIndex)
    : "";

  useEffect(() => {
    // 1s后开始打字效果
    const timeout = setTimeout(() => {
      setShowFullText(false);
      setTrigger(true);
    }, 1000);
    // 文本悬停时间
    const interval = setInterval(() => {
      setTrigger((t) => !t);
    }, 10000);

    return () => {
      clearTimeout(timeout);
      clearInterval(interval);
    };
  });

  return (
    <YStack flex={1} padding="$10">
      <H2 color="#000000">
        {showFullText ? titleName.substring(0, middleIndex) : firstPart}
      </H2>
      <XStack padding="$3" />
      <H2 color="#000000" paddingLeft="$10">
        {showFullText ? titleName.substring(middleIndex) : secondPart}
      </H2>
    </YStack>
  );
}

export default function AiDocsScreen() {
  const router = useRouter();
  const theme = useTheme();

  const screenWidth = Dimensions.get("window").width;
  const screenHeight = Dimensions.get("window").height;

  return (
    <YStack flex={1} justifyContent="center">
      <AIDocsTitle />

      <XStack
        flex={1}
        position="absolute"
        width="100%"
        top={Math.floor(screenHeight * 0.28)}
      >
        <AIGuidence />
      </XStack>

      <Button
        position="absolute"
        bottom={screenHeight * 0.08}
        width="50%%"
        borderColor={"#b66d0e"}
        borderWidth="1"
        borderRadius="$10"
        backgroundColor={"#b66d0e"}
        alignSelf="center"
        onPress={() => router.push("/(tabs)/ai_docs/docs_homepage")}
      >
        <ButtonText color="black" width="100%" textAlign="center">
          开始体验
        </ButtonText>
      </Button>
      {/* <SelectProfile profiles={profiles} /> */}
    </YStack>
  );
}
