import { Check as CheckIcon } from "@tamagui/lucide-icons";
import { Sheet } from "@tamagui/sheet";
import { router, useRouter } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { useState, useCallback, useEffect } from "react";
import { Platform, TouchableOpacity, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import {
  YStack,
  Separator,
  Theme,
  Button,
  ButtonText,
  XStack,
  Checkbox,
  Text,
  H2,
  Spinner,
} from "tamagui";

import MobileLogin from "./mobile/mobileLogin";

import LoginService from "@/sdk/login/jiguang";
import { AppDispatch, RootState, slices } from "@/src/store";
import { isAxiosSuccess } from "@/components/utils";
// import { LOGO_BROWN_XML } from "@/constants/utils";
// import { toast } from "@/components/styled/toast";
// import { WeChatLogin } from "@/sdk/login/wechat";
import { loginEventEmitter } from "./eventEmitter";
import { toast } from "burnt";

/**
 * @description 登录页面:
 * 1. 只支持短信登录
 * 2. 授权成功后，跳转首页
 *
 * @returns
 */
export default function LoginIndexScreen() {
  const dispatch = useDispatch<AppDispatch>();
  const auth_method = useSelector((state: RootState) => state.auth.auth_method);

  // 注释掉预取号相关代码
  /*
  useEffect(() => {
    const preLogin = async () => {
      try {
        const res: any = await LoginService.init();
        if (res?.code === 7000) {
          // 预取号成功，跳转授权页
          await LoginService.goToLoginPage();
        } else {
          // console.log("预取号失败:", res);
          dispatch(slices.auth.actions.setAuthMethod("all"));
        }
      } catch (error) {
        console.error("预取号失败:", error);
      }
    };

    if (auth_method === "oneKey") {
      preLogin();
    }
  }, [auth_method]);
  */

  console.log("auth_method", auth_method);

  // 直接返回手机登录页面
  return <MobileLogin />;

  /*
  if (auth_method === "mobile") {
    return <MobileLogin />;
  } else if (auth_method === "wechat") {
    return <MultiLoginScreen />; // 临时返回多选登录页面
  } else {
    return <MultiLoginScreen />;
  }
  */
}

/**
/**
 * 登录页面: 此页面处理预取号失败的情况（无法一键登陆）
//  * @param {string} source_page 登录来源
//  * @returns
//  *
//  */
export function MultiLoginScreen() {
  const router = useRouter();
  const source_page = useSelector((state: RootState) => state.auth.source_page);
  const auth_method = useSelector((state: RootState) => state.auth.auth_method);
  const [showTermsModal, setShowTermsModal] = useState(false); // 控制同意条款的模态框显示状态
  const [loginMethod, setLoginMethod] = useState<string>("telephone");

  const [position, setPosition] = useState<number>(0);
  const [checked, setChecked] = useState<boolean>(false);

  // 注释掉预取号相关代码
  /*
  const preLogin = async () => {
    try {
      const res: any = await LoginService.init();
      if (res?.code === 7000) {
        // 预取号成功，跳转授权页
        await LoginService.goToLoginPage();
      }
    } catch (error) {
      toast({
        title: "手机号获取失败，使用验证码登陆",
      });
      slices.auth.actions.setAuthMethod("mobile");
    }
  };
  */

  // 注册登陆组件
  const handleTapEvent = (loginMethod) => {
    setLoginMethod(loginMethod);
    if (!checked) {
      setShowTermsModal(true); // 显示同意条款模态框
    } else {
      handleAgree(); // 如果已经同意条款，直接调用登录逻辑
    }
  };

  // 同意条款后：登陆
  const handleAgree = async () => {
    setShowTermsModal(false);

    if (loginMethod === "telephone") {
      // 确保参数正确传递到下一个页面
      router.push({
        pathname: "/(outer)/login/mobile/mobileLogin",
      });
    } else if (loginMethod === "wechat") {
      // 注释掉微信登录
      // WeChatLogin.applyWechatAuth();
      router.replace(source_page || "/(tabs)/homepage");
    } else {
      router.replace(source_page || "/(tabs)/homepage");
    }
  };

  if (auth_method === "mobile") {
    return <MobileLogin />;
  }

  return (
    <Theme name="light">
      <SafeAreaView>
        <YStack flexDirection="column" alignItems="center">
          <StatusBar style={Platform.OS === "ios" ? "light" : "auto"} />
          <Text
            fontSize={30}
            marginTop="50%"
            marginBottom="50%"
            fontWeight="800"
          >
            多少看看
          </Text>
          {/* <SvgXml xml={LOGO_BROWN_XML} width={100} height={100} /> */}
          <Separator />
          {/* <EditScreenInfo path="app/modal.tsx" /> */}
          <YStack
            alignItems="center"
            justifyContent="center"
            width="100%"
            paddingHorizontal="$8"
            space="$3"
            paddingBottom="$16"
          >
            {/* 注释掉一键登录按钮
            <Button
              backgroundColor="black"
              size="$4"
              onPress={() => preLogin()}
            >
              <ButtonText color="white" width="100%" textAlign="center">
                一键登陆
              </ButtonText>
            </Button>
            */}

            {/* 注释掉微信登录按钮
            <Button
              backgroundColor="$wechat"
              size="$4"
              onPress={() => handleTapEvent("wechat")}
            >
              <ButtonText color="$white" width="100%" textAlign="center">
                微信登陆
              </ButtonText>
            </Button>
            */}

            {/* 只保留手机登录按钮 */}
            <Button
              backgroundColor="black"
              size="$4"
              onPress={() => handleTapEvent("telephone")}
            >
              <ButtonText color="white" width="100%" textAlign="center">
                手机号登录
              </ButtonText>
            </Button>

            <XStack flexDirection="row" alignItems="center" space="$4">
              {/* 注释掉微信图标
              <SvgXml
                xml={`<svg t="1713716554287" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1487" width="200" height="200"><path d="M337.387283 341.82659c-17.757225 0-35.514451 11.83815-35.514451 29.595375s17.757225 29.595376 35.514451 29.595376 29.595376-11.83815 29.595376-29.595376c0-18.49711-11.83815-29.595376-29.595376-29.595375zM577.849711 513.479769c-11.83815 0-22.936416 12.578035-22.936416 23.6763 0 12.578035 11.83815 23.676301 22.936416 23.676301 17.757225 0 29.595376-11.83815 29.595376-23.676301s-11.83815-23.676301-29.595376-23.6763zM501.641618 401.017341c17.757225 0 29.595376-12.578035 29.595376-29.595376 0-17.757225-11.83815-29.595376-29.595376-29.595375s-35.514451 11.83815-35.51445 29.595375 17.757225 29.595376 35.51445 29.595376zM706.589595 513.479769c-11.83815 0-22.936416 12.578035-22.936416 23.6763 0 12.578035 11.83815 23.676301 22.936416 23.676301 17.757225 0 29.595376-11.83815 29.595376-23.676301s-11.83815-23.676301-29.595376-23.6763z" fill="#28C445" p-id="1488"></path><path d="M510.520231 2.959538C228.624277 2.959538 0 231.583815 0 513.479769s228.624277 510.520231 510.520231 510.520231 510.520231-228.624277 510.520231-510.520231-228.624277-510.520231-510.520231-510.520231zM413.595376 644.439306c-29.595376 0-53.271676-5.919075-81.387284-12.578034l-81.387283 41.433526 22.936416-71.768786c-58.450867-41.433526-93.965318-95.445087-93.965317-159.815029 0-113.202312 105.803468-201.988439 233.803468-201.98844 114.682081 0 216.046243 71.028902 236.023121 166.473989-7.398844-0.739884-14.797688-1.479769-22.196532-1.479769-110.982659 1.479769-198.289017 85.086705-198.289017 188.67052 0 17.017341 2.959538 33.294798 7.398844 49.572255-7.398844 0.739884-15.537572 1.479769-22.936416 1.479768z m346.265896 82.867052l17.757225 59.190752-63.630058-35.514451c-22.936416 5.919075-46.612717 11.83815-70.289017 11.83815-111.722543 0-199.768786-76.947977-199.768786-172.393063-0.739884-94.705202 87.306358-171.653179 198.289017-171.65318 105.803468 0 199.028902 77.687861 199.028902 172.393064 0 53.271676-34.774566 100.624277-81.387283 136.138728z" fill="#28C445" p-id="1489"></path></svg>`}
                width={30}
                height={30}
                onPress={() => handleTapEvent("wechat")}
              />
              */}
              <SvgXml
                xml={`<svg t="1713716681050" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="2709" width="200" height="200"><path d="M373.516 377.248h283.676v239.997h-283.676zM627.672 303.448h-224.757c-0.108-0.002-0.235-0.002-0.362-0.002-16.104 0-29.16 13.056-29.16 29.16 0 0.127 0.001 0.255 0.003 0.382v14.74h283.796v-14.76c0.002-0.108 0.002-0.235 0.002-0.362 0-16.104-13.056-29.16-29.16-29.16-0.127 0-0.255 0.001-0.382 0.003zM373.516 691.044c-0.002 0.108-0.002 0.235-0.002 0.362 0 16.104 13.056 29.16 29.16 29.16 0.127 0 0.255-0.001 0.382-0.003h224.618c0.108 0.002 0.235 0.002 0.362 0.002 16.104 0 29.16-13.056 29.16-29.16 0-0.127-0.001-0.255-0.003-0.382v-44.26h-283.676v44.279zM515.354 663.444c0.036 0 0.078 0 0.12 0 12.261 0 22.2 9.939 22.2 22.2 0 12.261-9.939 22.2-22.2 22.2-12.261 0-22.2-9.939-22.2-22.199-0.011-0.254-0.017-0.553-0.017-0.853 0-11.797 9.563-21.36 21.36-21.36 0.259 0 0.518 0.005 0.774 0.014z" p-id="2710"></path><path d="M506.114 32.012c-259.197 0-474.114 214.917-474.114 485.874 1.889 261.088 213.040 472.233 473.949 474.113 271.241 0.001 486.038-214.916 486.038-474.113 0.007-1.002 0.012-2.186 0.012-3.372 0-266.485-216.029-482.514-482.514-482.514-1.186 0-2.37 0.005-3.553 0.013zM686.112 691.044c0.005 0.289 0.008 0.629 0.008 0.969 0 32.76-26.255 59.387-58.87 59.989l-224.333 0.001c-32.343-0.596-58.397-26.695-58.919-59.001v-360.035c-0.005-0.289-0.008-0.629-0.008-0.969 0-32.76 26.255-59.387 58.87-59.989l224.813-0.001c32.343 0.596 58.397 26.695 58.919 59.001v360.035z" p-id="2711"></path></svg>`}
                width={30}
                height={30}
                onPress={() => handleTapEvent("telephone")}
              />
            </XStack>
          </YStack>
          <XStack
            flexDirection="row"
            paddingBottom="$5"
            paddingHorizontal="$8"
            gap="$2"
          >
            <Checkbox
              borderRadius="$5"
              size="$4"
              checked={checked}
              onCheckedChange={() => {
                setChecked(!checked);
              }}
            >
              <Checkbox.Indicator>
                <CheckIcon size={16} />
              </Checkbox.Indicator>
            </Checkbox>
            <Text fontSize="$3" color="gray">
              我已阅读并同意《用户协议》《隐私政策》《儿童/青少年个人信息保护规则》
            </Text>
          </XStack>
        </YStack>
        <Sheet
          forceRemoveScrollEnabled={showTermsModal}
          open={showTermsModal}
          position={position}
          snapPoints={[20]}
          dismissOnOverlayPress
          onOpenChange={() => setShowTermsModal(!showTermsModal)}
          dismissOnSnapToBottom
          onPositionChange={setPosition}
          animation="medium"
        >
          <Sheet.Overlay
            animation="lazy"
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
            backgroundColor="rgba(0, 0, 0, 0.5)"
          />
          <Sheet.Handle />
          <Sheet.Frame
            paddingHorizontal="$8"
            paddingTop="$4"
            justifyContent="center" // 失效，暂时使用paddingTop弥补
            alignItems="center"
            gap="$4"
            backgroundColor="$white"
            unstyled
          >
            <Text fontSize="$3" fontWeight="500">
              请阅读并同意以下协议
            </Text>
            <Button paddingTop="$4" unstyled onPress={() => console.log("11")}>
              <Text flexWrap="wrap" wordWrap="break-word" color="#215476">
                《用户协议》《隐私政策》《儿童/青少年个人信息保护规则》
              </Text>
            </Button>
            <Button
              onPress={handleAgree}
              width="100%"
              marginTop="auto"
              backgroundColor="green"
              size="$3"
            >
              <ButtonText color="white">同意并继续</ButtonText>
            </Button>
          </Sheet.Frame>
        </Sheet>
      </SafeAreaView>
    </Theme>
  );
}

// 修改登录处理函数
const handleLogin = async (method: string) => {
  // 注释掉一键登录和微信登录相关代码
  /*
  if (method === "oneKey") {
    try {
      const res: any = await LoginService.getToken();
      if (res.code === 2000) {
        loginEventEmitter.emit("login", {
          scene: "jiguang_login",
          jiguangContent: res?.content,
        });
      } else {
        LoginService.dismissLoginPage();
        loginEventEmitter.emit("setAuthMethod", "all");
      }
    } catch (error) {
      console.error("授权失败:", error);
      LoginService.dismissLoginPage();
      loginEventEmitter.emit("setAuthMethod", "all");
    }
  } else if (method === "wechat") {
    await LoginService.setAuthMethod("wechat");
  } else
  */
  if (method === "mobile") {
    await LoginService.setAuthMethod("mobile");
    LoginService.dismissLoginPage();
  }
};

// 注释掉一键登录按钮组件
/*
export function OneKeyLoginButton() {
  const [loading, setLoading] = useState(false);

  // const handleOneKeyLogin = async () => {
  //   setLoading(true);
  //   try {
  //     await handleLogin("oneKey");
  //   } finally {
  //     setLoading(false);
  //   }
  // };

  return (
    <Button
      backgroundColor="black"
      size="$4"
      disabled={loading}
      // onPress={handleOneKeyLogin}
    >
      {loading ? (
        <XStack gap="$2" alignItems="center">
          <Spinner size="small" color="white" />
          <ButtonText color="white">登录中...</ButtonText>
        </XStack>
      ) : (
        <ButtonText color="white" width="100%" textAlign="center">
          一键登陆
        </ButtonText>
      )}
    </Button>
  );
}
*/

export function OtherLoginButton() {
  return (
    <Button
      backgroundColor="transparent"
      size="$4"
      onPress={() => {
        slices.auth.actions.setAuthMethod("all");
        LoginService.dismissLoginPage();
      }}
    >
      <ButtonText color="$blue" width="100%" textAlign="center">
        其他登录方式
      </ButtonText>
    </Button>
  );
}
