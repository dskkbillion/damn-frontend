import { router, useLocalSearchParams } from "expo-router";
import { useEffect, useRef, useState } from "react";
import { TextInput } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useDispatch, useSelector } from "react-redux";
import { Input, YStack, Text, H2, Theme, XStack, Button } from "tamagui";

import { BackButton } from "@/components/styled/back_button";
import { isAxiosSuccess } from "@/components/utils";
import { slices, RootState, AppDispatch } from "@/src/store";
import Loader from "@/components/styled/loader";
import { toast } from "@/components/styled/toast";

export default function VerifyCodeScreen() {
  const userLogin = slices.auth.actions.userLogin;
  const phoneNumber = useLocalSearchParams().phoneNumber as string;

  const [smsCode, setSmsCode] = useState<string[]>(["", "", "", ""]);
  const inputRefs = useRef<(TextInput | null)[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const dispatch = useDispatch<AppDispatch>();
  const source_page = useSelector((state: RootState) => state.auth.source_page);
  const [fullCode, setFullCode] = useState("");

  const handleUserLogin = async (phoneNumber: string, code: string) => {
    setIsLoading(true);

    // 正常登录流程
    const userData = {
      mobile: phoneNumber,
      code,
      scene: "sms_code_login",
    };

    try {
      console.log("code", code);
      const res = await dispatch(userLogin(userData));
      if (isAxiosSuccess(res.type)) {
        if (res?.payload?.code === 200) {
          // 获取用户信息
          const userRes = await dispatch(
            slices.auth.actions.fetchUserProfile({})
          );
          dispatch(slices.user.actions.setUserInfo(userRes.payload));
          if (isAxiosSuccess(userRes.type)) {
            // 获取来源页面参数
            const sourcePage = source_page || "/(tabs)/homepage";
            // 登录成功后跳转回原页面
            router.replace(sourcePage as any);
          }
        } else {
          toast({
            title: "验证码不正确",
          });
        }
      }
    } catch (e) {
      toast({
        title: "登陆失败:" + e,
      });
    } finally {
      setIsLoading(false);
    }
  };

  const reSendCode = async () => {
    const res = await dispatch(
      slices.auth.actions.sendVerifyCode({
        mobile: phoneNumber,
      })
    );
    if (res.payload.code !== 200) {
      toast({
        title: res.payload.msg,
      });
    } else {
      toast({
        title: "验证码已发送",
      });
    }
  };

  useEffect(() => {
    // focus the first input at the beginning
    inputRefs.current[0]?.focus();
  }, []);

  // 开发模式：如果手机号是 18888888888，直接通过验证
  useEffect(() => {
    const handleLogin = async () => {
      if (phoneNumber === "18888888888") {
        try {
          const res = await dispatch(
            userLogin({
              mobile: phoneNumber,
              code: "565656", // 使用任意验证码
              scene: "sms_code_login",
            })
          );

          if (isAxiosSuccess(res.type)) {
            if (res?.payload?.code === 200) {
              const userRes = await dispatch(
                slices.auth.actions.fetchUserProfile({})
              );
              dispatch(slices.user.actions.setUserInfo(userRes.payload));
              if (isAxiosSuccess(userRes.type)) {
                const sourcePage = source_page || "/(tabs)/homepage";
                router.replace(sourcePage as any);
              }
            }
          }
        } catch (e) {
          toast({
            title: "登录失败:" + e,
          });
        } finally {
          setIsLoading(false);
        }
        return;
      }
    };
    handleLogin();
  }, [phoneNumber]);

  const handleChange = (text, index) => {
    const newCode = [...smsCode];
    // 处理粘贴的情况
    if (text.length > 1) {
      // 如果粘贴的内容超过4位，只取前4位
      const pastedText = text.replace(/[^0-9]/g, "").slice(0, 4);
      // 分配到每个输入框
      for (let i = 0; i < pastedText.length; i++) {
        if (i < 4) {
          newCode[i] = pastedText[i];
        }
      }
      setSmsCode(newCode);
      // 如果填满了4位，触发登录
      if (pastedText.length === 4) {
        handleUserLogin(phoneNumber, pastedText);
      }
      return;
    }

    // 只接受数字输入
    const numericText = text.replace(/[^0-9]/g, "");
    newCode[index] = numericText;
    setSmsCode(newCode);

    // forward from empty input
    if (numericText.length === 1 && index < 3) {
      inputRefs.current[index + 1]?.focus();
    }

    // 检查是否所有输入都已完成
    if (newCode.every((digit) => digit !== "")) {
      const code = newCode.join("");
      handleUserLogin(phoneNumber, code);
    }
  };

  const handleKeyPress = (event, index) => {
    // backspace from empty or input
    if (event.nativeEvent.key === "Backspace") {
      const newCode = [...smsCode];
      newCode[index] = ""; // 清空当前输入
      setSmsCode(newCode);
      if (index > 0) {
        inputRefs.current[index - 1]?.focus();
      } else {
        inputRefs.current[0]?.focus();
      }
    }
    // forward from existed input
    else if (smsCode[index] !== "") {
      if (index < 3) {
        const newCode = [...smsCode];
        newCode[index + 1] = event.nativeEvent.key;
        setSmsCode(newCode);
        inputRefs.current[index + 1]?.focus();

        // 检查是否所有输入都已完成
        if (newCode.every((digit) => digit !== "")) {
          const code = newCode.join("");
          handleUserLogin(phoneNumber, code);
        }
      }
    }
  };

  const maskPhoneNumber = (phoneNumber) => {
    return phoneNumber.replace(/^(\d{3})\d{4}(\d{4})$/, "$1****$2");
  };

  const handleFullCodeChange = (text: string) => {
    const cleanText = text.replace(/[^0-9]/g, "").slice(0, 4);
    setFullCode(cleanText);

    // 更新显示的输入框
    const newCode = [...smsCode];
    for (let i = 0; i < 4; i++) {
      newCode[i] = cleanText[i] || "";
    }
    setSmsCode(newCode);

    // 如果是完整的4位验证码，触发登录
    if (cleanText.length === 4) {
      handleUserLogin(phoneNumber, cleanText);
    }
  };

  return (
    <Theme name="light">
      <SafeAreaView style={{ flex: 1 }}>
        <BackButton
          customOnPress={() => {
            // 直接导航到手机登录页面
            router.replace("/(outer)/login/mobile/mobileLogin");
          }}
        />
        <YStack alignItems="center" justifyContent="flex-start">
          <H2 fontSize="$8" paddingTop="$15" color="black" textAlign="center">
            输入4位验证码
          </H2>
          <Text alignSelf="center">
            短信验证码已发送至{maskPhoneNumber(phoneNumber)}
          </Text>

          <TextInput
            style={{
              position: "absolute",
              width: 0,
              height: 0,
              opacity: 0,
            }}
            value={fullCode}
            onChangeText={handleFullCodeChange}
            keyboardType="number-pad"
            textContentType="oneTimeCode"
            autoComplete="one-time-code"
            maxLength={4}
          />

          <XStack
            flexDirection="row"
            justifyContent="center"
            padding="$5"
            space="$2"
          >
            {[0, 1, 2, 3].map((index) => (
              <Input
                width={global.screenWidth / 6 - 20}
                height={global.screenWidth / 6 - 20}
                key={index}
                keyboardType="number-pad"
                maxLength={1}
                onChangeText={(text) => handleChange(text, index)}
                onKeyPress={(event) => handleKeyPress(event, index)}
                ref={(ref) => (inputRefs.current[index] = ref)}
                value={smsCode[index]}
                textAlign="center"
                fontSize={24}
              />
            ))}
          </XStack>
          <Loader loading={isLoading} />

          <Button onPress={reSendCode} unstyled>
            <Text alignSelf="center" color="$blue">
              重新发送
            </Text>
          </Button>
        </YStack>
      </SafeAreaView>
    </Theme>
  );
}
