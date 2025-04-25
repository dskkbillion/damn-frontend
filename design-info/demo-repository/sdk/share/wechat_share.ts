// 注释掉导入语句
// import { Alert } from "react-native";
// import * as wechat from "react-native-wechat";

// 注释掉微信分享类
/*
export class WechatShare {
  static async h5Share({
    type,
    title,
    description,
    webpageUrl,
    thumbImage,
  }: {
    type: "timeline" | "session";
    title?: string;
    description?: string;
    thumbImage?: string;
    webpageUrl?: string;
    messageAction?: string;
    messageExt?: string;
  }) {
    const isInstalled = await wechat.isWXAppInstalled();
    if (!isInstalled) {
      Alert.alert("请先安装微信");
      return;
    }
    const params = {
      type: "news", // h5分享
      title: title || "多少看看",
      description: description || "来自多少看看的分享",
      thumbImage: thumbImage || "", // 消息缩略图
      webpageUrl: webpageUrl || "", // h5链接
    };
    if (type === "timeline") {
      wechat.shareToTimeline(params as wechat.ShareMetadata);
    } else {
      wechat.shareToSession(params as wechat.ShareMetadata);
    }
  }
}
*/
