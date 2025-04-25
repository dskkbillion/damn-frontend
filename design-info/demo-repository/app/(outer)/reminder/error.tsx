import { router, useLocalSearchParams } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { useDispatch } from "react-redux";
import { Button, ButtonText, H2, Paragraph, YStack } from "tamagui";

import { AppDispatch, slices } from "@/src/store";

export default function ErrorPage() {
  const dispatch = useDispatch<AppDispatch>();
  const params = useLocalSearchParams<{ type: string }>();

  const handleRetry = () => {
    // 1. 重置错误状态
    if (params.type === "system") {
      dispatch(slices.sys.actions.resetError());
      dispatch(slices.sys.actions.resetInitialized());
      dispatch(slices.sys.actions.incrementReloadKey());
    } else if (params.type === "auth") {
      dispatch(slices.auth.actions.resetError());
      dispatch(slices.auth.actions.resetInitialized());
      dispatch(slices.auth.actions.incrementReloadKey());
    } else {
      // both
      dispatch(slices.sys.actions.resetError());
      dispatch(slices.sys.actions.resetInitialized());
      dispatch(slices.auth.actions.resetError());
      dispatch(slices.auth.actions.resetInitialized());
      dispatch(slices.auth.actions.incrementReloadKey());
      dispatch(slices.sys.actions.incrementReloadKey());
    }

    // 2. 返回根路由
    router.replace("/");
  };

  const handleBackToHome = () => {
    router.replace("/(tabs)/homepage");
  };

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <YStack
        flex={1}
        height="100%"
        alignItems="center"
        justifyContent="center"
        space="$4"
        padding="$4"
      >
        <H2 textAlign="center" color="$brown">
          插入图片
        </H2>
        <Paragraph textAlign="center" color="$gray10">
          请检查网络连接
        </Paragraph>

        <YStack space="$3" marginTop="$6" width="100%" alignItems="center">
          <Button
            backgroundColor="$brown"
            onPress={handleRetry}
            justifyContent="center"
            alignItems="center"
            width="80%"
            height="$4"
            borderRadius="$4"
            unstyled
          >
            <ButtonText color="#fff" fontSize={16}>
              重新连接
            </ButtonText>
          </Button>

          <Button
            backgroundColor="transparent"
            onPress={handleBackToHome}
            paddingHorizontal="$6"
            borderRadius="$4"
            height="$3"
          >
            <ButtonText color="$blue">返回首页</ButtonText>
          </Button>
        </YStack>
      </YStack>
    </SafeAreaView>
  );
}
