import { Redirect } from "expo-router";
import React, { memo } from "react";
import { ActivityIndicator } from "react-native";
import { useSelector } from "react-redux";
import { YStack } from "tamagui";

import { RootState } from "@/src/store";

const App = memo(() => {
  // 系统状态
  const {
    loading: sysLoading,
    error: sysError,
    initilized: sysInitialized,
  } = useSelector((state: RootState) => state.sys);

  const {
    loading: authLoading,
    error: authError,
    initilized: authInitialized,
  } = useSelector((state: RootState) => state.auth);

  // 处理加载状态
  if (sysLoading) {
    return (
      <YStack
        flex={1}
        justifyContent="center"
        alignItems="center"
        backgroundColor="$background"
      >
        <ActivityIndicator size="large" color="$brown" />
      </YStack>
    );
  }
  // 处理错误状态
  if (sysError || authError) {
    let type = "";
    if (sysError && authError) {
      type = "both";
    } else if (sysError) {
      type = "system";
    } else {
      type = "auth";
    }

    console.log("跳转错误页");
    return (
      <Redirect
        href={{
          pathname: "/(outer)/reminder/error",
          params: {
            type,
            message:
              type === "both"
                ? "系统初始化失败，请重试"
                : type === "system"
                  ? "系统初始化失败，请重试"
                  : "用户认证失败，请重新登录",
          },
        }}
      />
    );
  }

  // 系统初始化完成，进入主页
  if (sysInitialized) {
    // 如果用户也初始化完成，或者不需要用户初始化（未登录）
    if (authInitialized || !authLoading) {
      console.log("跳转主页");
      return <Redirect href="/(tabs)/homepage" />;
    }
  }

  // 默认显示加载中
  return (
    <YStack
      flex={1}
      justifyContent="center"
      alignItems="center"
      backgroundColor="$background"
    >
      <ActivityIndicator size="large" color="$brown" />
    </YStack>
  );
});

export default App;
