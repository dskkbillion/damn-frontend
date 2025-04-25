import { zIndex } from "@tamagui/themes";
import { useLocalSearchParams } from "expo-router";
import React, { useState, useEffect } from "react";
import { View, StyleSheet, Image } from "react-native";
import Spinner from "react-native-spinkit";
import { SvgXml } from "react-native-svg";
import {
  Button,
  ButtonText,
  H2,
  Paragraph,
  XStack,
  YStack,
  useTheme,
} from "tamagui";
import { LinearGradient } from "tamagui/linear-gradient";

import { applications } from "@/constants/application";
import { LOGO_BROWN_XML } from "@/constants/utils";

// 设置按钮（点击缩放效果、显示加载）
export function ButtonComponent() {
  const [scale, setScale] = useState(1);
  const [showLoading, setShowLoading] = useState(false);
  const [showGenerate, setShowGenerate] = useState(false);

  const theme = useTheme();
  const exampleImage = require("@/assets/PS_Example.png");

  const params = useLocalSearchParams<{ id: string; doc_id: string }>();
  const handleLoadingComplete = () => {
    setShowLoading(false); // 加载完成后不显示加载组件
    setShowGenerate(true);
  };

  return (
    <YStack flex={1}>
      <YStack flexDirection="column" alignItems="center">
        {/* 生成文书按钮 */}
        {!showGenerate && (
          <Button
            width={global.screenWidth * 0.6}
            backgroundColor="#b66d0e"
            marginTop="$3"
            alignSelf="center"
            onPress={() => {
              setShowLoading(true);
            }}
          >
            <ButtonText color="black">生成文书</ButtonText>
          </Button>
        )}
      </YStack>

      {/* 加载进度条（点击按钮后加载） */}
      {showLoading && (
        <Spinner isVisible size={100} type="ChasingDots" color="#ffffff" />
      )}

      {/* 生成内容 */}
      {showGenerate && (
        <YStack flex={1} alignItems="center">
          <XStack padding="$2" />

          <Image
            source={exampleImage}
            style={{
              resizeMode: "stretch",
              height: "100%",
              width: "90%",
            }}
          />
          <Paragraph theme="alt2">点击下图查看文书</Paragraph>

          <XStack space>
            <Button height={30} backgroundColor={"#b66d0e"}>
              <ButtonText fontSize="$3">发送至邮箱</ButtonText>
            </Button>
            <Button height={30} backgroundColor={"#b66d0e"}>
              <ButtonText fontSize="$3">寻找相关服务</ButtonText>
            </Button>
          </XStack>
        </YStack>
      )}
    </YStack>
  );
}

export function LoadingComponent({ show, onLoadComplete }) {
  const [progress, setProgress] = useState(0);
  const [loadingComplete, setLoadingComplete] = useState(false);

  const styles = StyleSheet.create({
    container: {
      justifyContent: "center",
      alignItems: "center",
    },
    progressBarContainer: {
      width: "96.25%",
      height: 20,
      backgroundColor: "#EDEDED",
      borderRadius: 10,
    },
    progressBar: {
      height: "100%",
      backgroundColor: "#B66E0D",
      borderRadius: 10,
    },
  });

  useEffect(() => {
    let interval;
    if (show && progress < 1) {
      interval = setInterval(() => {
        setProgress((currentProgress) => {
          const newProgress = currentProgress + 0.01;
          if (newProgress >= 1) {
            clearInterval(interval);
            setLoadingComplete(true); // 设置加载完成
            // onLoadComplete(); // 调用回调函数
            return 1;
          }
          return newProgress;
        });
      }, 10); // 更新进度的间隔
    }

    return () => {
      if (interval) {
        clearInterval(interval);
      }
    };
  }, [show, progress]);

  useEffect(() => {
    if (loadingComplete) {
      onLoadComplete();
    }
  }, [loadingComplete, onLoadComplete]);

  return (
    <XStack>
      {show && !loadingComplete && (
        <View style={styles.progressBarContainer}>
          <View style={[styles.progressBar, { width: `${progress * 100}%` }]} />
        </View>
      )}
    </XStack>
  );
}
