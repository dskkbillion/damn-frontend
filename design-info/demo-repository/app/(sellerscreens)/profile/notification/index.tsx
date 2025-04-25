import { AppDispatch, slices } from "@/src/store";
import { router } from "expo-router";
import { useCallback, useState } from "react";
import { Text } from "react-native";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useDispatch } from "react-redux";
import { Button, H1, Switch, XStack, YStack } from "tamagui";

export default function NotificationPage() {
  const dispatch = useDispatch<AppDispatch>();
  const RenderItemComponent = ({ title, openStatus, ...props }) => {
    const [opened, setOpened] = useState(openStatus);

    return (
      <XStack
        flexDirection="row"
        justifyContent="space-between"
        backgroundColor="$background"
        padding="$3"
        alignItems="center"
        marginHorizontal="4%"
        borderRadius={10}
        marginVertical="$2"
      >
        {/* left side */}
        <YStack>
          <Text>{title}</Text>
          <Text style={{ color: "gray" }}>
            {props.prompt ? props.prompt.toString() : ""}
          </Text>
        </YStack>

        {/* right side */}
        <Switch
          size="$3"
          checked={opened}
          onCheckedChange={() =>
            setOpened((prevOpened: boolean) => !prevOpened)
          }
          backgroundColor={opened ? "$lightbrown" : "$darkGray"}
        >
          <Switch.Thumb animation="bouncy" backgroundColor="$white" />
        </Switch>
      </XStack>
    );
  };
  return (
    <YStack>
      <H1 fontSize={15} color="$darkGray" marginLeft="4%">
        聊天回复设置
      </H1>

      {/* 自动回复 */}
      <Button
        flexDirection="row"
        justifyContent="space-between"
        backgroundColor="$background"
        padding="$3"
        alignItems="center"
        marginHorizontal="4%"
        borderRadius={10}
        marginVertical="$2"
        onPress={() =>
          router.push("/(sellerscreens)/profile/notification/autoReply")
        }
        unstyled
      >
        <Text>自动回复</Text>
        <MaterialIcons name="keyboard-arrow-right" size={30} unstyled />
      </Button>

      {/* <H1 fontSize={15} color="$darkGray" marginLeft="4%">
        消息提示音
      </H1>
      {RenderItemComponent({ title: "声音", openStatus: true })}
      {RenderItemComponent({ title: "震动", openStatus: true })} */}

      {/* <H1 fontSize={15} color="$darkGray" marginLeft="4%">
        消息提示音
      </H1> */}
      {/* {RenderItemComponent({
        title: "一键免打扰",
        openStatus: true,
        prompt: "只接受‘交易聊天消息’，方便交易",
      })}
      {RenderItemComponent({
        title: "通知消息",
        openStatus: true,
        prompt: "后台接收平台通知",
      })} */}
    </YStack>
  );
}
