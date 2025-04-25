import { registerRootComponent } from "expo";
import { useFonts } from "expo-font";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import React, { useEffect, useState } from "react";
import { AppRegistry, Dimensions, LogBox } from "react-native";
import { Provider, useSelector } from "react-redux";
import { PersistGate } from "redux-persist/integration/react";
import { TamaguiProvider, Theme } from "tamagui";

import config from "../tamagui.config";
import { LoginContainer } from "./(outer)/login/LoginContainer";

import { OneKeyLoginButton, OtherLoginButton } from "@/app/(outer)/login/index";
import { AuthSetup } from "@/components/system/authSetup";
import { GlobalContextProvider } from "@/components/system/globalContext";
import { SystemSetup } from "@/components/system/systemSetup";
import { WebSocketProvider } from "@/components/system/webSocketProvider";
import { persistor, RootState, store } from "@/src/store";

// 忽略特定的警告
LogBox.ignoreLogs([
  "Sending `onAnimatedValueUpdate` with no listeners registered",
  "[RemoteTextInput]",
]);

// 显示启动屏幕
SplashScreen.preventAutoHideAsync();
// 注册登陆组件
AppRegistry.registerComponent("oneKeyLogin", () => OneKeyLoginButton);
AppRegistry.registerComponent("otherLogin", () => OtherLoginButton);

export default function RootLayout() {
  const [isReady, setIsReady] = useState(false);
  const [loaded] = useFonts({
    Inter: require("@tamagui/font-inter/otf/Inter-Medium.otf"),
    InterBold: require("@tamagui/font-inter/otf/Inter-Bold.otf"),
  });

  useEffect(() => {
    const prepare = async () => {
      if (loaded) {
        const updateScreenDimensions = () => {
          global.screenHeight = Dimensions.get("window").height;
          global.screenWidth = Dimensions.get("window").width;
        };

        updateScreenDimensions(); // 初始化时设置一次

        const subscription = Dimensions.addEventListener(
          "change",
          updateScreenDimensions
        );

        setIsReady(true);

        return () => {
          subscription?.remove(); // 清理监听器
        };
      }
    };

    prepare();
  }, [loaded]);

  if (!isReady) {
    return null;
  }

  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <TamaguiProvider config={config}>
          <Theme name="light">
            <SetupWrapper />
          </Theme>
        </TamaguiProvider>
      </PersistGate>
    </Provider>
  );
}

// 新增一个包装组件来使用 reloadKey
function SetupWrapper() {
  const reloadSysKey = useSelector((state: RootState) => state.sys.reloadKey);
  const reloadAuthKey = useSelector((state: RootState) => state.auth.reloadKey);
  const reloadKey = reloadAuthKey + reloadSysKey;

  return (
    <>
      <SystemSetup key={`system-${reloadSysKey}`} />
      <AuthSetup key={`auth-${reloadAuthKey}`} />
      <LoginContainer />
      <WebSocketProvider key={`ws-${reloadKey}`}>
        <GlobalContextProvider>
          <RootLayoutView />
        </GlobalContextProvider>
      </WebSocketProvider>
    </>
  );
}

export const unstable_settings = {
  // Ensure any route can link back to `/`
  initialRouteName: "index",
};

export function RootLayoutView() {
  useEffect(() => {
    // 当应用准备好时，隐藏启动屏幕
    const hideSplash = async () => {
      await SplashScreen.hideAsync();
    };

    hideSplash();
  }, []);
  return (
    <Stack
      screenOptions={{
        // 或者使用其他动画选项
        animation: "slide_from_right",
        // animationDuration: 200,
      }}
    >
      <Stack.Screen
        name="index"
        options={{ headerShown: false, gestureEnabled: false }}
      />
      <Stack.Screen
        name="(tabs)"
        options={{ headerShown: false, gestureEnabled: false }}
      />
      <Stack.Screen
        name="(sellerscreens)"
        options={{ headerShown: false, gestureEnabled: false }}
      />
      <Stack.Screen name="(outer)" options={{ headerShown: false }} />
    </Stack>
  );
}

registerRootComponent(RootLayout);
