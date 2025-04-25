import { router } from "expo-router";
import { Text, TouchableWithoutFeedback } from "react-native";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useSelector } from "react-redux";
import { Avatar, Button, Paragraph, XStack, YStack } from "tamagui";

import { RootState, logout } from "@/src/store";

import { useGlobalContext } from "@/components/system/globalContext";

export default function AccountSafePage() {
  const userProfile = useSelector((state: RootState) => state.user?.data);
  // const dispatch = useDispatch<AppDispatch>();
  // const [cacheSize, setCacheSize] = useState<string>("0MB");
  const { screenHeight } = useGlobalContext();

  const renderItem = ({ title, value = null, ...props }) => {
    return (
      <XStack
        flexDirection="row"
        justifyContent="space-between"
        backgroundColor="$background"
        padding="$3"
        height={screenHeight * 0.06}
        alignItems="center"
        borderRadius={10}
        marginBottom="$2"
        onPress={() => (props.route ? router.push(props.route) : null)}
      >
        {/* left side */}
        <Text>{title}</Text>
        {/* right side */}
        <XStack flex={0} alignItems="center">
          <Paragraph color="$lightGray">{value}</Paragraph>
          {props.route && (
            <MaterialIcons name="keyboard-arrow-right" size={25} unstyled />
          )}
        </XStack>
      </XStack>
    );
  };
  const handleLogout = () => {
    console.log("logout");
    logout();
    // dispatch(slices.auth.actions.logout());
    router.replace("/");
  };

  // 获取缓存大小
  // const updateCacheSize = async () => {
  //   const size = await CacheService.getCacheSize();
  //   setCacheSize(size);
  // };

  // 清除缓存
  // const handleClearCache = () => {
  //   Alert.alert("清除缓存", `确定要清除缓存吗？当前缓存大小：${cacheSize}`, [
  //     {
  //       text: "取消",
  //       style: "cancel",
  //     },
  //     {
  //       text: "确定",
  //       onPress: async () => {
  //         try {
  //           await CacheService.clearAllCache();
  //           await updateCacheSize();
  //           toast("清除成功", "checkmark");
  //         } catch (error) {
  //           toast("清除失败", "error");
  //         }
  //       },
  //     },
  //   ]);
  // };

  // 初始化时获取缓存大小
  // useEffect(() => {
  //   updateCacheSize();
  // }, []);

  return (
    <YStack marginTop="$3">
      <YStack
        flexDirection="column"
        justifyContent="center"
        alignItems="center"
        marginTop="$3"
        space="$2"
        marginBottom="$5"
      >
        <TouchableWithoutFeedback
          onPress={() =>
            router.push("/(tabs)/profile/accountSafe/EditAvatarScreen")
          }
        >
          <Avatar
            size="$10"
            circular
            backgroundColor="$gray8"
            alignSelf="center"
            marginBottom="$1"
          >
            <Avatar.Image src={userProfile?.avatar} />
          </Avatar>
        </TouchableWithoutFeedback>
        <Paragraph fontSize={18}>{userProfile?.nickName}</Paragraph>
      </YStack>
      {renderItem({
        title: "昵称",
        value: userProfile?.nickName,
        route: "/profile/accountSafe/EditNicknameScreen",
      })}
      {renderItem({ title: "第三方账号绑定" })}
      {renderItem({ title: "已绑定手机号", value: userProfile?.mobile })}

      <XStack marginTop="$3" />
      {renderItem({
        title: "账号注销",
        route: "/(tabs)/profile/accountSafe/deactivation",
      })}

      {/* <XStack marginTop="$3" />
      <Button height={screenHeight * 0.06} onPress={handleClearCache}>
        清除缓存
      </Button> */}

      <XStack marginTop="$3" />
      <Button
        flexDirection="row"
        justifyContent="center"
        backgroundColor="$background"
        padding="$3"
        alignItems="center"
        borderRadius={10}
        onPress={handleLogout}
        height="auto"
      >
        <Text>退出登录</Text>
      </Button>
    </YStack>
  );
}
