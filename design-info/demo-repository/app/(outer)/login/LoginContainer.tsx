import { router } from "expo-router";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";

import { loginEventEmitter } from "./eventEmitter";

import { isAxiosSuccess } from "@/components/utils";
import LoginService from "@/sdk/login/jiguang";
import { slices, AppDispatch, RootState } from "@/src/store";
import { toast } from "burnt";

export function LoginContainer() {
  const dispatch = useDispatch<AppDispatch>();
  const source_page = useSelector((state: RootState) => state.auth.source_page);

  useEffect(() => {
    const loginHandler = async (params: any) => {
      try {
        console.log("参数", params);
        const loginRes = await dispatch(slices.auth.actions.userLogin(params));
        if (isAxiosSuccess(loginRes.type)) {
          // 获取用户信息
          if (loginRes.payload?.code === 200) {
            const userRes = await dispatch(
              slices.auth.actions.fetchUserProfile({})
            );
            dispatch(slices.user.actions.setUserInfo(userRes.payload));
            if (isAxiosSuccess(userRes.type)) {
              console.log("获取用户信息成功，正在跳转");
              // 获取来源页面参数
              const sourcePage = source_page || "/(tabs)/homepage";
              // 登录成功后跳转回原页面
              router.replace(sourcePage as any);
            }
          } else {
            toast({
              title: "登陆失败，请尝试其他登录方式",
            });
            loginEventEmitter.emit("setAuthMethod", "all");
          }
          LoginService.dismissLoginPage();
        }
      } catch (error) {
        console.error("登录失败:", error);
        LoginService.dismissLoginPage();
        toast({
          title: "登陆失败，请尝试其他登录方式",
        });
        loginEventEmitter.emit("setAuthMethod", "all");
        LoginService.dismissLoginPage();
      }
    };

    const authMethodHandler = (method: string) => {
      dispatch(slices.auth.actions.setAuthMethod(method));
    };

    loginEventEmitter.on("login", loginHandler);
    loginEventEmitter.on("setAuthMethod", authMethodHandler);

    return () => {
      loginEventEmitter.off("login", loginHandler);
      loginEventEmitter.off("setAuthMethod", authMethodHandler);
    };
  }, [dispatch]);

  return null;
}
