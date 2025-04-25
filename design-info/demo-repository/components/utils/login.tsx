import { router } from "expo-router";
import LoginService from "@/sdk/login/jiguang";
import { AppDispatch, slices } from "@/src/store";
import { useDispatch } from "react-redux";
import { isAxiosSuccess } from "../utils";

export const useLogin = () => {
  const dispatch = useDispatch<AppDispatch>();

  const handleLogin = async (method: string) => {
    if (method === "oneKey") {
      try {
        const res: any = await LoginService.getToken();
        if (res.code === 2000) {
          const params = {
            scene: "jiguang_login",
            jiguangContent: res?.content,
          };
          const loginRes = await dispatch(
            slices.auth.actions.userLogin(params)
          );
          if (isAxiosSuccess(loginRes.type)) {
            LoginService.dismissLoginPage();
            router.replace("/(tabs)/homepage");
          } else {
            router.replace("/");
          }
        } else {
          // 授权失败
          LoginService.dismissLoginPage(); // 关闭授权页面
          slices.auth.actions.setAuthMethod("all"); // 设置授权方法为全部（包含短信、微信）
        }
      } catch (error) {
        console.error("授权失败:", error);
      }
    } else if (method === "wechat") {
      await LoginService.setAuthMethod("wechat");
      // 拉起微信授权页面
      // WeChatLogin.applyWechatAuth();
    } else if (method === "mobile") {
      // console.log("telephone");
      await LoginService.setAuthMethod("mobile");
      LoginService.dismissLoginPage();

      // router.push({
      //   pathname: "/(outer)/login/mobile/mobileLogin",
      // });
    }
    // 处理登录逻辑
  };

  return {
    handleLogin,
  };
};
