import { router, useRouter } from "expo-router";
import { useCallback, useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import {
  Input,
  YStack,
  Text,
  H2,
  Button,
  XStack,
  ButtonText,
  Paragraph,
} from "tamagui";

import { SelectPhoneRegion } from "@/components/select-country-code";
import { ChevronLeft } from "@tamagui/lucide-icons";
import { AppDispatch, RootState, slices, store } from "@/src/store";
import { useDispatch, useSelector } from "react-redux";
import { toast } from "@/components/styled/toast";
// import { TamaguiToast } from "@/components/styled/toast";

export default function MobileLogin() {
  const [phoneNumber, setPhoneNumber] = useState("");
  const auth_method = useSelector((state: RootState) => state.auth.auth_method);
  const dispatch = useDispatch<AppDispatch>();
  // handle phone number change
  /**
   * 处理手机号码变化的函数
   * @param {string} text - 输入的手机号码
   */
  const handlePhoneNumberChange = (text: string) => {
    // 去除字符串的空格
    setPhoneNumber(text.trim());
  };

  const fetchVerificationCode = async () => {
    // 验证手机号格式：必须是11位数字且以1开头（中国手机号格式）
    if (phoneNumber.length !== 11) {
      toast({
        title: "请输入正确的手机号码",
      });
      return;
    }

    // 验证手机号必须以1开头（中国手机号格式）
    if (!phoneNumber.startsWith('1')) {
      toast({
        title: "请输入正确的中国手机号码",
      });
      return;
    }

    // 开发模式：如果手机号是 18888888888，直接通过验证
    if (phoneNumber === "18888888888") {
      router.push({
        pathname: "/(outer)/login/mobile/verifyCode",
        params: { phoneNumber },
      });
    } else {
      dispatch(
        slices.auth.actions.sendVerifyCode({
          mobile: phoneNumber,
        })
      );
    }

    router.push({
      pathname: "/(outer)/login/mobile/verifyCode",
      params: { phoneNumber },
    });
  };

  const StyledBackButton = () => {
    const routerInstance = useRouter();

    const handleBack = (from: string) => {
      if (from === "oneKey") {
        store.dispatch(slices.auth.actions.resetAuth());
      }

      try {
        // 导航到首页或其他安全的页面
        router.replace("/(tabs)/homepage");
      } catch (error) {
        console.error("导航错误:", error);
      }
    };

    return (
      <Button
        backgroundColor="transparent"
        width="20%"
        padding="$2"
        alignItems="center" // 水平居中
        justifyContent="center" // 垂直居中
        onPress={() => handleBack(auth_method)}
        size="$2"
        unstyled
      >
        <ChevronLeft color="$blue" size="$2" />
      </Button>
    );
  };

  return (
    <YStack flex={1} alignItems="center" justifyContent="flex-start">
      <SafeAreaView>
        <StyledBackButton />
        <H2
          fontSize="$8"
          fontWeight="400"
          paddingTop="$15"
          color="#000"
          textAlign="center"
        >
          手机号登陆
        </H2>
        <YStack
          flexDirection="column"
          alignItems="center"
          justifyContent="center"
          width="100%"
          padding="$8"
          gap="$3"
        >
          <XStack width="100%" gap="$2">
            {/* <SelectPhoneRegion /> */}
            <YStack
              paddingHorizontal="$3"
              backgroundColor="$white"
              borderRadius="$4"
              alignItems="center"
              justifyContent="center"
            >
              <Paragraph>+86</Paragraph>
            </YStack>

            <Input
              height="$5"
              flex={1}
              placeholder="请输入手机号码"
              value={phoneNumber}
              onChangeText={handlePhoneNumberChange}
              // textAlign="center"
              fontSize="$3"
            />
          </XStack>
          <XStack flexDirection="row" justifyContent="center">
            <Text>未注册的手机号登陆成功后将自动注册（仅支持中国手机号）</Text>
          </XStack>
          <Button
            backgroundColor="$black"
            width="100%"
            marginTop="$5"
            borderRadius="$10"
            onPress={() => {
              fetchVerificationCode();
            }}
            size="$3"
          >
            <ButtonText color="white" width="100%" textAlign="center">
              验证并登陆
            </ButtonText>
          </Button>
        </YStack>
      </SafeAreaView>
      <XStack
        alignItems="center"
        paddingTop="$5"
        paddingHorizontal="$8"
        space="$2"
      />
    </YStack>
  );
}
