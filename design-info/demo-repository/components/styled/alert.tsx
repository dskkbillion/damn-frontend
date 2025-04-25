import { Alert } from "react-native";

type AlertButton = {
  text: string;
  onPress?: () => void;
  style?: "default" | "cancel" | "destructive";
};

interface AlertProps {
  title?: string;
  message: string;
  buttons?: AlertButton[];
  cancelable?: boolean;
  onDismiss?: () => void;
}

/**
 * 弹出提示框
 * 使用示例：
 * @param param0
 * @returns
 */
export const alert = ({
  title = "提示",
  message,
  buttons = [{ text: "确定" }],
  cancelable = true,
  onDismiss,
}: AlertProps) => {
  return Alert.alert(title, message, buttons, {
    cancelable,
    onDismiss,
  });
};

// 使用示例：
// 只有确定按钮
// alert({ message: "操作成功" });

// 确定和取消按钮
// alert({
//   message: "确定要删除吗？",
//   buttons: [
//     {
//       text: "取消",
//       style: "cancel"
//     },
//     {
//       text: "确定",
//       onPress: () => handleDelete(),
//       style: "destructive"
//     }
//   ]
// });
