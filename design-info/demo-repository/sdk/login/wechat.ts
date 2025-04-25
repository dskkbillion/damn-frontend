import { Alert, Linking, Platform } from "react-native";
import * as wechat from "react-native-wechat";

export class WeChatLogin {
  // 申请微信登陆授权
  static async applyWechatAuth(): Promise<void> {
    const scope = "snsapi_userinfo";
    const state = "wechat_sdk_demo";
    // sdk
    // 1. 获取code
    // 2. 获取access_token
    // 3. 获取用户信息
    // 4. 保存用户信息
    // 5. 跳转首页
    // 微信登陆后需要手机号验证码注册
    // 1.如果微信登陆返回未登陆，则跳转手机号验证码注册(4008 未注册)
    try {
      const isInstalled = await wechat.isWXAppInstalled();
      console.log("isInstalled", isInstalled);
      if (isInstalled) {
        // 请求授权，拉起微信打开授权登录页
        // const code = await new Promise((resolve, reject) => {
        //   wechat.sendAuthRequest(
        //     scope,
        //     state,
        //     (res: { errCode: number; code: unknown }) => {
        //       if (res.errCode === 0) {
        //         // 用户同意授权
        //         resolve(res?.code);
        //       } else {
        //         reject(res);
        //       }
        //     }
        //   );
        // });
        const res = await wechat.sendAuthRequest(scope, state);
        if (res.errCode === 0) {
          // 获取code后传给后端获取access_token
        } else {
          Alert.alert("授权失败");
        }
      } else {
        if (Platform.OS === "ios") {
          Alert.alert("没有安装微信", "是否安装微信？", [
            { text: "取消", onPress: () => console.log("请先安装微信") },
            { text: "确定", onPress: () => this.installWechat() },
          ]);
        } else {
          Alert.alert("请先安装微信");
        }
      }
    } catch (error: any) {
      console.log(error);
      Alert.alert("登录授权发生错误：", error.message, [{ text: "确定" }]);
    }
  }

  // 跳转Appstore安装微信
  static async installWechat(): Promise<void> {
    const getWeChatUrl =
      "itms-apps://itunes.apple.com/cn/app/%E5%BE%AE%E4%BF%A1/id414478124?mt=8";

    try {
      const supported = await Linking.canOpenURL(getWeChatUrl);

      if (!supported) {
        console.log("Can't handle url", getWeChatUrl);
        Alert.alert("Can't handle url", getWeChatUrl);
        return;
      }
      // 访问下载路径
      await Linking.openURL(getWeChatUrl);
    } catch (error) {
      console.log(error);
      Alert.alert("提示", `An error occurred: ${String(error)}`, [
        { text: "OK", onPress: () => {} },
      ]);
    }
  }
}
