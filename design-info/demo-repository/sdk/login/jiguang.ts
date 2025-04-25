import { SplashScreen } from "expo-router";
import { Platform, Dimensions } from "react-native";
import { slices, store } from "@/src/store";
import { setAuthMethod as setAuthMethodAction } from "@/src/slices/authSlice";
import { toast } from "@/components/styled/toast";
import { Component } from "react";

// 获取屏幕尺寸
const windowWidth = Dimensions.get("window").width;
const windowHeight = Dimensions.get("window").height;

/**
 * 模拟的LoginService类
 *
 * 注意：此类不再使用极光SDK，而是提供相同的接口以保持代码兼容性
 * 短信验证码功能通过后端API实现，不需要极光SDK
 */
export default class LoginService extends Component {
  static loginListener: any;

  /**
   * 初始化 （包含预取号）
   * @returns 预取号结果
   */
  static async init(): Promise<any> {
    console.log("LoginService.init() - 极光SDK已移除，此方法不再执行实际操作");
    return { code: 7000 }; // 模拟成功
  }

  static async goToLoginPage() {
    console.log("LoginService.goToLoginPage() - 极光SDK已移除，此方法不再执行实际操作");
    SplashScreen.hideAsync();
  }

  static async getToken() {
    console.log("LoginService.getToken() - 极光SDK已移除，此方法不再执行实际操作");
    return { code: 2000, content: {} }; // 模拟成功
  }

  static setAuthMethod(method: string) {
    // 更新 Redux 状态
    console.log("setAuthMethod:", method);
    store.dispatch(slices.auth.actions.setAuthMethod(method));
    return method;
  }

  static async getVerificationCode(params: {
    phoneNumber: string;
    signID?: string;
    templateID?: string;
  }) {
    console.log("LoginService.getVerificationCode() - 极光SDK已移除，此方法不再执行实际操作");
    console.log("验证码请求参数:", params);
    return { code: 8000 }; // 模拟成功
  }

  static async dismissLoginPage() {
    console.log("LoginService.dismissLoginPage() - 极光SDK已移除，此方法不再执行实际操作");
  }

  static async removeLoginListener() {
    console.log("LoginService.removeLoginListener() - 极光SDK已移除，此方法不再执行实际操作");
  }
}
