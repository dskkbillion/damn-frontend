import { useCallback, useEffect, useState } from "react";
import { Keyboard, TouchableWithoutFeedback } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  H2,
  Paragraph,
  Switch,
  TextArea,
  XStack,
  YStack,
} from "tamagui";

import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function AutoReplySettingPage() {
  const [content, setContent] = useState("");
  const [show, setShow] = useState(false);
  const autoReplyStatus = useSelector(
    (state: RootState) => state.user.autoReplyStatus
  );
  const [open, setOpen] = useState(autoReplyStatus);
  const dispatch = useDispatch<AppDispatch>();
  const autoReply = useSelector((state: RootState) => state.user.autoReply);

  console.log("autoReplyStatus", autoReplyStatus);

  const setAutoReply = useCallback(
    async (type: "content" | "status") => {
      let params: any;
      if (type === "content" && content === "") {
        alert("设置内容不能为空");
        return;
      }
      if (type === "content") {
        params = {
          recoverContent: content,
        };
      } else {
        params = {
          recoverFlag: !open,
        };
      }

      try {
        const res = await dispatch(slices.user.actions.updateMember(params));
        if (isAxiosSuccess(res.type)) {
          if (type === "content") {
            await dispatch(slices.user.actions.setReplyContent({ content }));
          } else {
            await dispatch(slices.user.actions.setAutoReplyStatus(!open));
          }
          alert("设置成功");
        } else {
          alert("设置自动回复失败");
        }
      } catch (err) {
        alert(err);
      }
    },
    [content]
  );

  // useEffect(() => {
  //   setContent(autoReply);
  // }, [autoReply]);

  return (
    <YStack flex={1} height="100%">
      <XStack
        justifyContent="space-between"
        alignItems="center"
        marginTop="$5"
        marginBottom="$3"
      >
        <YStack paddingHorizontal="$3" alignItems="flex-start">
          <H2 size="$4" paddingVertical="$1">
            自动回复
          </H2>
          <Paragraph color="$lightGray">所有服务默认自动回复</Paragraph>
        </YStack>

        <Switch
          size="$3"
          marginRight="$3"
          checked={open}
          onCheckedChange={() => {
            setOpen(!open);
            setAutoReply("status");
          }}
          style={{ backgroundColor: open ? "$brown" : "$darkGray" }}
        >
          <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
        </Switch>
      </XStack>

      {show && (
        <TouchableWithoutFeedback
          onPress={() => {
            Keyboard.dismiss();
            setShow(false);
          }}
        >
          <YStack
            width="100%"
            height={global.screenHeight}
            position="absolute"
            left={0}
            bottom={300}
            zIndex={888}
          />
        </TouchableWithoutFeedback>
      )}
      <TextArea
        placeholder={autoReply ? autoReply : "设置自动回复的内容"}
        width="100%"
        backgroundColor="#fff"
        height="40%"
        value={content}
        onChangeText={(text) => setContent(text)}
        onFocus={() => setShow(true)}
      />
      <Button
        backgroundColor="#caa472"
        borderRadius="$5"
        paddingHorizontal="$5"
        paddingVertical="$2"
        marginTop="$8"
        alignSelf="center"
        height={35}
        alignItems="center"
        color="#fff"
        onPress={() => setAutoReply("content")}
      >
        提交修改
      </Button>
    </YStack>
  );
}
