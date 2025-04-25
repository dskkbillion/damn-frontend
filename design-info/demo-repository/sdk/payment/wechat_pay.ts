// import * as wechat from "react-native-wechat";
// import crypto from "crypto";
// import { Alert } from "react-native";

// // interface PaymentLoad {
// //   partnerId: string;
// //   prepayId: string;
// //   nonceStr: string;
// //   timeStamp: string;
// //   package: string;
// //   sign: string;
// // }

// export class WechatPay {
//   /**
//    * @description: 调起微信支付
//    */

//   // 1.
//   static async pay(prepayId: string) {
//     const isInstalled = await wechat.isWXAppInstalled();
//     if (!isInstalled) {
//       Alert.alert("请先安装微信");
//       return;
//     }

//     const nonceStr = crypto.randomBytes(16).toString("hex");
//     const res = await wechat.pay({
//       partnerId: "1234567890", // 商户号
//       nonceStr, // 随机字符串
//       timeStamp: Date.now().toString(), // 时间戳
//       package: "Sign=WXPay", // 扩展字段
//       sign: "", // 签名
//     } as wechat.PaymentLoad);
//     if (res.errCode === 0) {
//       Alert.alert("支付成功");
//     } else {
//       Alert.alert("支付失败");
//     }
//   }
// }
