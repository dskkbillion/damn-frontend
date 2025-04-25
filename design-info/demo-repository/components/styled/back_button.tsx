import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useRouter } from "expo-router";
import { Button } from "tamagui";

/**
 * @description 返回按钮，用于返回上一级页面, 默认为主题色
 * @returns
 */
export const BackButton = ({
  color = "#B66D0E",
  size = "$2",
  customOnPress,
}: {
  color?: string;
  size?: string;
  customOnPress?: () => void;
}) => {
  // 使用useRouter钩子获取路由实例
  const routerInstance = useRouter();

  const handleBack = () => {
    if (customOnPress) {
      // 如果提供了自定义的onPress函数，则使用它
      customOnPress();
      return;
    }

    try {
      // 尝试导航到首页或其他安全的页面，而不是使用back()
      router.replace("/(tabs)/homepage");
    } catch (error) {
      console.error("导航错误:", error);
    }
  };

  return (
    <Button
      backgroundColor="transparent"
      width="20%"
      padding={size}
      alignItems="center" // 水平居中
      justifyContent="center" // 垂直居中
      onPress={handleBack}
      size={size}
      unstyled
    >
      <ChevronLeft color={color} size={size} />
    </Button>
  );
};
