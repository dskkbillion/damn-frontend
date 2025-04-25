import FontAwesome from "@expo/vector-icons/FontAwesome";
import { FlashList } from "@shopify/flash-list";
import { router } from "expo-router";
import React, { useCallback, useEffect, useState } from "react";
import { Text } from "react-native";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import { YStack, Avatar, useTheme, XStack, Paragraph, Button } from "tamagui";

import { isAxiosSuccess } from "@/components/utils";
import { LOGO_BROWN_XML } from "@/constants/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function MessagesScreen() {
  const theme = useTheme();
  const dispatch = useDispatch<AppDispatch>();
  const chatRoomList = useSelector(
    (state: RootState) => state.msg.chatRoomList
  );
  const [loading, setLoading] = useState(false);

  const changedId = useSelector((state: RootState) => state.msg.changedId);
  const changed = useSelector((state: RootState) => state.msg.changed);
  // get message list
  const fetchChatRoomList = useCallback(async () => {
    setLoading(true);
    await dispatch(slices.msg.actions.getChatRoomList());
    setLoading(false);
  }, [dispatch]);

  const handleRefresh = useCallback(() => {
    console.log("handleRefresh");
    dispatch(slices.msg.actions.resetChatRoomList());
    dispatch(slices.msg.actions.getChatRoomList());
  }, [fetchChatRoomList, dispatch]);

  const handlePress = useCallback(async () => {
    try {
      const params = {
        doctorId: 1,
        type: "ADMIN",
      };

      const res = await dispatch(slices?.msg?.actions?.createRoom(params));
      if (isAxiosSuccess(res.type) && res.payload && "data" in res.payload) {
        router.push({
          pathname: "/(outer)/chatroom",
          params: { chatId: res.payload.data },
        });
      }
    } catch (err) {
      console.error(err);
    }
  }, []);

  useEffect(() => {
    const clearUnRead = async () => {
      if (changedId && changedId !== "") {
        // 先获取聊天室详情
        await dispatch(
          slices.msg.actions.fetchChatroomDetail({ id: Number(changedId) })
        );
        // 清除 changedId
        dispatch(slices.msg.actions.clearChangedId());
        // 在获取完聊天室详情后再刷新列表
        handleRefresh();
      }
    };

    if (changedId) {
      clearUnRead();
    } else {
      handleRefresh();
    }
  }, [handleRefresh, changed, changedId]);

  return (
    <YStack flex={1}>
      {/* 小粽子 */}
      <Button
        flexDirection="row"
        alignItems="center"
        justifyContent="flex-start"
        paddingHorizontal="$5"
        paddingVertical="$3"
        marginBottom="$5"
        backgroundColor="#fff"
        onPress={handlePress}
        width="100%"
        height="12%"
      >
        <Avatar circular size={25}>
          <SvgXml xml={LOGO_BROWN_XML} />
        </Avatar>
        <YStack flexDirection="column" marginHorizontal="$5">
          <Paragraph fontSize={15}>小粽子</Paragraph>
          <Paragraph color="$darkGray" fontSize={15}>
            关于多少看看买家
          </Paragraph>
        </YStack>
      </Button>

      <FlashList
        data={chatRoomList}
        refreshing={loading}
        onRefresh={handleRefresh}
        keyExtractor={(item: any, index) => item?.id.toString()}
        renderItem={({ item, index }) => renderMessage(item)}
        estimatedItemSize={100}
        ListEmptyComponent={() => (
          <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
            暂无消息
          </Paragraph>
        )}
      />
    </YStack>
  );
}

const renderMessage = (item) => {
  let context = null as string | null;

  if (item?.chatMessageNewVo?.context !== null) {
    context = item?.chatMessageNewVo?.context;
  }

  return (
    <Button
      flexDirection="row"
      alignItems="center"
      paddingHorizontal="$5"
      paddingVertical="$4"
      backgroundColor="#ffffff"
      marginBottom={1}
      flex={1}
      onPress={() => {
        router.push({
          pathname: "/(outer)/chatroom",
          params: { chatId: item.id },
        });
      }}
      unstyled
    >
      <Avatar circular backgroundColor="#EDEDED" size={40}>
        {item?.doctor?.avatar && <Avatar.Image src={item?.doctor?.avatar} />}
      </Avatar>
      <YStack flexDirection="column" marginHorizontal="$5">
        <Paragraph fontSize={15}>{item?.doctor?.nickName}</Paragraph>
        {item?.chatMessageNewVo?.type === "text" ? (
          <Paragraph fontSize={15} color="$darkGray">
            {context}
          </Paragraph>
        ) : item?.chatMessageNewVo?.type === "image" ? (
          <XStack alignItems="center" space="$2">
            <Paragraph>图片</Paragraph>
            <FontAwesome name="image" size={14} color="#585D63" />
          </XStack>
        ) : item?.chatMessageNewVo?.type === "audio" ? (
          <XStack alignItems="center" space="$2">
            <Paragraph>语音</Paragraph>
            <FontAwesome name="microphone" size={14} color="#585D63" />
          </XStack>
        ) : (
          <Paragraph fontSize={15} color="$darkGray">
            新消息
          </Paragraph>
        )}
      </YStack>

      {item?.messageNum === undefined || item?.messageNum === 0 ? null : (
        <YStack
          width={20}
          height={20}
          backgroundColor="#EA4738"
          borderRadius={999}
          alignItems="center"
          justifyContent="center"
          marginLeft="auto"
        >
          <Text style={{ color: "white", fontSize: 16 }}>
            {item?.messageNum}
          </Text>
        </YStack>
      )}
    </Button>
  );
};
