import Clipboard from "@react-native-clipboard/clipboard";
import { FlashList } from "@shopify/flash-list";
import { router, Stack, useLocalSearchParams } from "expo-router";
import React, { memo, useCallback, useEffect, useRef, useState } from "react";
import {
  TextInput,
  KeyboardAvoidingView,
  TouchableWithoutFeedback,
  Platform,
  Keyboard,
  View,
} from "react-native";
import FastImage from "react-native-fast-image";
import ImageView from "react-native-image-viewing";
import { SafeAreaView } from "react-native-safe-area-context";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import {
  Avatar,
  Button,
  Input,
  Paragraph,
  Portal,
  Theme,
  XStack,
  YStack,
  styled,
} from "tamagui";

import { VoicePlayer } from "@/components/ai_doc/VoicePlayer";
import { VoiceDialog } from "@/components/ai_doc/voiceDialog";
import headerComponent from "@/components/headerShown";
import { alert } from "@/components/styled/alert";
import { toast } from "@/components/styled/toast";
import { isAxiosSuccess } from "@/components/utils";
import {
  getFilePath,
  pickImage,
  takePhoto,
} from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";

const StyledButton = styled(Button, {
  alignItems: "center",
  justifyContent: "center",
  padding: 0,
  minWidth: 0, // reset any default Button padding & size
});

export default function MessagePage() {
  const dispatch = useDispatch<AppDispatch>();
  const chatId = useLocalSearchParams().chatId;

  const msgList = useSelector((state: RootState) => state.msg.msgList);
  const chatDetail = useSelector((state: RootState) => state.msg.chatRoom);
  const loading = useSelector((state: RootState) => state.msg.loading);
  const hasMoreMessages = useSelector((state: RootState) => state.msg.hasMoreMessages);
  const currentPage = useSelector((state: RootState) => state.msg.currentPage);

  const chatRef = useRef<FlashList<any>>(null);
  const [message, setMessage] = useState("");
  const [modalVisible, setModalVisible] = useState(false);
  const [modalPosition, setModalPosition] = useState({ top: 0, left: 0 });

  const [doctorName, setDoctorName] = useState("");
  const [pressedMessage, setPressedMessage] = useState({
    message_id: null,
    context: "",
  });
  const [showOptions, setShowOptions] = useState(false);
  const [keyboardVisible, setKeyboardVisible] = useState(false);
  const [imagePreview, setImagePreview] = useState("");

  const [modal, setModal] = useState(false);
  const inputRef = useRef<TextInput>(null);
  const [shouldClear, setShouldClear] = useState(false);
  const images = useSelector((state: RootState) => state?.file?.chatImages);
  const userId = useSelector((state: RootState) => state.user.data?.id);
  const [isMember, setIsMember] = useState(false);
  const [hasNewMessages, setHasNewMessages] = useState(false);

  const processedImagesRef = useRef<string[]>([]);

  const fetchMessageList = useCallback(() => {
    dispatch(slices.msg.actions.getMsgList({
      chatId: Number(chatId),
      pageNum: currentPage,
      pageSize: 50 // 每页50条消息
    }));
  }, [dispatch, chatId, currentPage]);

  const handleRefresh = useCallback(() => {
    dispatch(slices.msg.actions.resetMsgList());
    fetchMessageList();
  }, [fetchMessageList, dispatch]);

  const handleLongPress = useCallback(({ isMember, message, layout }) => {
    const { pageX, pageY, width } = layout;
    const modalHeight = 50;
    const modalWidth = 150;

    const top = pageY - modalHeight;
    const left = isMember
      ? pageX + width / 2 - modalWidth / 2
      : pageX + width / 2 - modalWidth / 2;

    setIsMember(isMember);
    setPressedMessage({
      message_id: message.id,
      context: message.context,
    });
    setModalVisible(true);
    setModalPosition({ top, left });
  }, []);

  const handleBackgroundPress = useCallback(() => {
    setModalVisible(false);
    setPressedMessage({ message_id: null, context: "" });
  }, []);

  // 点击图片
  const handleImageClick = useCallback((imageUrl: string) => {
    setImagePreview(imageUrl);
    setModal(true);
  }, []);

  // copy
  const handleCopyEvent = useCallback(() => {
    if (pressedMessage?.context) {
      Clipboard.setString(pressedMessage.context);

      toast({
        title: "已复制到剪贴板",
        symbol: "checkmark",
      });

      setModalVisible(false);
    }
  }, [pressedMessage]);

  const handleRevokeEvent = useCallback(async () => {
    try {
      if (pressedMessage?.message_id) {
        alert({
          message: "确定要撤回这条消息吗？",
          buttons: [
            {
              text: "取消",
              style: "cancel",
            },
            {
              text: "确定",
              async onPress() {
                try {
                  const res = await dispatch(
                    slices.msg.actions.revokeMessage({
                      id: Number(pressedMessage.message_id),
                    })
                  );
                  if (isAxiosSuccess(res.type)) {
                    toast({
                      title: res.payload.data.msg,
                      symbol: "checkmark",
                    });
                    setModalVisible(false);
                  } else {
                    toast({
                      title: res.payload.data.msg,
                      symbol: "xmark",
                    });
                  }
                } catch (e) {
                  console.error(e);
                  toast({
                    title: "撤回失败",
                    symbol: "xmark",
                  });
                }
              },
              style: "default",
            },
          ],
        });
      }
    } catch (e) {
      toast({
        title: "撤回失败",
        symbol: "xmark",
      });
    }
  }, [dispatch, pressedMessage]);

  useEffect(() => {
    // 进入页面时清除图片缓存
    dispatch(fileSlice.file.actions.clearImages({ type: "chat" }));
    handleRefresh();
  }, [handleRefresh]);

  // send message
  const handleSend = useCallback(() => {
    if (message.trim() === "") {
      return;
    }

    const params = {
      chatId: Number(chatId),
      context: message,
      type: "text",
    };

    // 发送消息（axios）
    dispatch(slices.msg.actions.sendMsg(params));
    setHasNewMessages(true);
    setShouldClear(true);
  }, [message, chatId, dispatch]);

  const handleInputFocus = () => {
    if (showOptions) {
      setShowOptions(false);
    }
  };

  const handlePlusPress = () => {
    if (keyboardVisible) {
      Keyboard.dismiss();
    }
    setShowOptions(!showOptions);
    if (inputRef.current) {
      inputRef.current.blur();
    }
  };

  // 发送图片(takePhoto, pickImage)
  const sendImages = async (action: string) => {
    setShowOptions(false);

    try {
      // 发送前清空图片列表
      await dispatch(fileSlice.file.actions.clearImages({ type: "chat" }));
      // 对不同的方式进行图片选择
      if (action === "camera") {
        await takePhoto({ dispatch, type: "chat" });
      } else if (action === "library") {
        await pickImage({ selectionLimit: 9, dispatch, type: "chat" });
      }
    } catch (e) {
      console.log("e", e);
    }
  };

  // 获取聊天室详情
  useEffect(() => {
    dispatch(slices.msg.actions.fetchChatroomDetail({ id: Number(chatId) }));
    return () => {
      if (hasNewMessages) {
        dispatch(slices.msg.actions.setChangedId(String(chatId)));
      }
    };
  }, [chatId, hasNewMessages]);

  // 获取用户详情
  useEffect(() => {
    if (chatDetail?.doctor) {
      setDoctorName(chatDetail?.doctor?.nickName);
    }
  }, [chatDetail]);

  useEffect(() => {
    const keyboardDidShowListener = Keyboard.addListener(
      "keyboardDidShow",
      () => {
        setKeyboardVisible(true);
        setShowOptions(false);
      }
    );
    const keyboardDidHideListener = Keyboard.addListener(
      "keyboardDidHide",
      () => {
        setKeyboardVisible(false);
      }
    );

    return () => {
      keyboardDidShowListener.remove();
      keyboardDidHideListener.remove();
    };
  }, []);

  // 发送图片的 useEffect
  useEffect(() => {
    if (images && images.length > 0) {
      const latestImage = images[images.length - 1];
      const imageUrl = latestImage.imgUrl;

      // 检查图片是否已处理过
      if (!processedImagesRef.current.includes(imageUrl)) {
        // 添加到已处理列表
        processedImagesRef.current.push(imageUrl);

        const params = {
          chatId: Number(chatId),
          context: imageUrl,
          type: "image",
        };
        dispatch(slices.msg.actions.sendMsg(params));
        setHasNewMessages(true);
      }
    }
  }, [images]);

  // 添加处理语音发送的函数
  const handleVoiceSend = useCallback(
    async (audioFile: any) => {
      try {
        console.log("audioFile", audioFile);

        const params = {
          chatId: Number(chatId),
          context: audioFile.url,
          type: "audio", // 使用 voice 类型
        };
        // 发送消息
        dispatch(slices.msg.actions.sendMsg(params));
      } catch (error) {
        console.error("Error sending voice message:", error);
        toast({
          title: "发送语音失败",
          symbol: "xmark",
        });
      }
    },
    [chatId, dispatch]
  );

  useEffect(() => {
    // 组件卸载时清除图片缓存
    return () => {
      dispatch(fileSlice.file.actions.clearImages({ type: "chat" }));
      if (hasNewMessages) {
        dispatch(slices.msg.actions.setChangedId(String(chatId)));
      }
    };
  }, [chatId, hasNewMessages]);

  // 加载更多历史消息
  const loadMoreMessages = useCallback(() => {
    if (hasMoreMessages && !loading) {
      dispatch(slices.msg.actions.loadMoreMessages());
      // 加载下一页数据
      fetchMessageList();
    }
  }, [dispatch, hasMoreMessages, loading, fetchMessageList]);

  useEffect(() => {
    fetchMessageList();
  }, [fetchMessageList, currentPage]); // 当页码变化时重新获取消息

  return (
    <Theme name="light">
      {modal && (
        <Portal>
          <ImageView
            images={[{ uri: imagePreview }]}
            imageIndex={0}
            visible={modal}
            onRequestClose={() => setModal(false)}
            swipeToCloseEnabled
            doubleTapToZoomEnabled
          />
        </Portal>
      )}
      <YStack flex={1} backgroundColor="#fff">
        <Stack.Screen
          options={{
            headerTransparent: true,
            header: () =>
              headerComponent({
                title: doctorName,
                canBack: true,
              }),
          }}
        />
        <SafeAreaView style={{ flex: 0 }} />

        <KeyboardAvoidingView
          behavior={Platform.OS === "ios" ? "padding" : "height"}
          style={{
            flex: 1,
            position: "relative",
            bottom: 30, // 控制底部输入框的位置
            width: "100%",
            backgroundColor: "#EDEDED",
          }}
        >
          <YStack flex={1} backgroundColor="$bottom">
            <YStack flex={1} justifyContent="flex-end" paddingBottom="$5">
              <FlashList
                data={[...msgList].reverse()}
                ref={chatRef}
                inverted
                keyExtractor={(item, index) => "message" + item.id + item.flag}
                renderItem={({ item, index }) => {
                  // 计算 isMember
                  let is_member;

                  // 判断未入库的消息的发送者
                  if (item?.flag === "send") {
                    is_member = true;
                  } else if (item?.flag === "receive") {
                    is_member = false;
                  } else {
                    // 当没有flag时为已入库消息，判断当前用户是否是发送消息的用户
                    is_member =
                      Number(userId) === Number(item?.member?.referId);
                  }

                  return (
                    <ChatElement
                      item={item}
                      isMember={is_member}
                      handleLongPress={handleLongPress}
                      onImageClick={handleImageClick}
                    />
                  );
                }}
                ListHeaderComponent={<XStack padding="$5" />}
                estimatedItemSize={100}
                maintainVisibleContentPosition={{
                  minIndexForVisible: 0,
                  autoscrollToTopThreshold: null,
                }}
                contentContainerStyle={{
                  paddingBottom: 50,
                }}
                showsVerticalScrollIndicator={false}
                drawDistance={500}
                onEndReachedThreshold={0.5}
                onEndReached={loadMoreMessages}
                getItemType={(item) => {
                  return item?.type || "text";
                }}
                ListFooterComponent={
                  loading && hasMoreMessages ? (
                    <XStack padding="$4" justifyContent="center">
                      <Paragraph>加载更多消息...</Paragraph>
                    </XStack>
                  ) : null
                }
              />
            </YStack>

            {/* 点击空白处关闭项 */}
            {showOptions && (
              <TouchableWithoutFeedback
                onPress={() => {
                  Keyboard.dismiss();
                  setShowOptions(false);
                  setModalVisible(false);
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

            <XStack
              position="absolute"
              bottom={showOptions ? 200 : 0}
              gap="$2"
              width="100%"
              backgroundColor="$bottom"
              paddingHorizontal="$2"
              paddingVertical="$2"
              alignItems="center"
            >
              <VoiceDialog onVoiceSend={handleVoiceSend} />

              <XStack
                shadowColor="#000"
                shadowOffset={{
                  width: 0,
                  height: 3,
                }}
                shadowOpacity={0.3}
                shadowRadius={6}
                backgroundColor="#fff"
                borderRadius={10}
                height={50}
                width={global.screenWidth * 0.85}
                alignItems="center"
              >
                {/* 需要解决send键盘的问题 */}
                <Input
                  multiline
                  ref={inputRef}
                  width={global.screenWidth * 0.7}
                  placeholder="在此输入"
                  onFocus={handleInputFocus}
                  borderRadius={10}
                  value={message}
                  onChangeText={(text) => {
                    if (shouldClear) {
                      setMessage("");
                      setShouldClear(false);
                    } else {
                      // 除所有的行符
                      setMessage(text.replace(/\n/g, ""));
                    }
                  }}
                  returnKeyType="send"
                  onKeyPress={(e) => {
                    if (e.nativeEvent.key === "Enter") {
                      handleSend();
                    }
                  }}
                  borderWidth={0}
                />

                <StyledButton
                  circular
                  size="$3"
                  borderWidth="0"
                  zIndex={999}
                  onPress={() => handlePlusPress()}
                >
                  <FontAwesomeIcon name="plus" size={18} color="#585D63" />
                </StyledButton>
              </XStack>
            </XStack>

            {modalVisible && (
              <Portal>
                {/* 背景遮罩 */}
                <TouchableWithoutFeedback onPress={handleBackgroundPress}>
                  <YStack
                    position="absolute"
                    top={0}
                    left={0}
                    right={0}
                    bottom={0}
                    backgroundColor="transparent"
                    zIndex={998}
                  />
                </TouchableWithoutFeedback>
                {/* 操作菜单 - 只在当前消息被长按时显示 */}
                {modalVisible && (
                  <Button
                    position="absolute"
                    top={modalPosition.top}
                    left={modalPosition.left}
                    width={150}
                    height={50}
                    backgroundColor="rgba(0, 0, 0, 0.8)"
                    alignItems="center"
                    justifyContent="center"
                    zIndex={999}
                    borderRadius={10}
                    unstyled
                  >
                    <ChatModal
                      isMember={isMember}
                      onCopy={handleCopyEvent}
                      onRevoke={handleRevokeEvent}
                    />
                  </Button>
                )}
              </Portal>
            )}
          </YStack>

          {showOptions && (
            <YStack
              position="absolute"
              bottom={0}
              width="100%"
              backgroundColor="#EDEDED"
              paddingVertical="$6"
              paddingHorizontal="$8"
              zIndex={999}
              height={200}
            >
              <XStack gap="$6">
                {/* 拍照 */}
                <StyledButton
                  flexDirection="column"
                  alignItems="center"
                  height="auto"
                  onPress={() => sendImages("camera")}
                  backgroundColor="#EDEDED"
                >
                  <XStack backgroundColor="#fff" padding="$2" borderRadius={10}>
                    <FontAwesomeIcon name="camera" size={25} color="#585D63" />
                  </XStack>
                  <Paragraph color="$darkGray">拍照</Paragraph>
                </StyledButton>
                {/* 从相册选择 */}
                <StyledButton
                  flexDirection="column"
                  alignItems="center"
                  height="auto"
                  backgroundColor="#EDEDED"
                  onPress={() => sendImages("library")}
                >
                  <XStack backgroundColor="#fff" padding="$2" borderRadius={10}>
                    <FontAwesomeIcon name="photo" size={25} color="#585D63" />
                  </XStack>
                  <Paragraph color="$darkGray">相册</Paragraph>
                </StyledButton>
              </XStack>
            </YStack>
          )}
        </KeyboardAvoidingView>
      </YStack>
    </Theme>
  );
}

const ChatElement = memo(
  ({
    item,
    isMember,
    handleLongPress,
    onImageClick,
  }: {
    item;
    isMember;
    handleLongPress;
    onImageClick;
  }) => {
    const messageRef = useRef<View>(null);
    const userProfile = useSelector((state: RootState) => state.user.data);

    const renderContent = () => {
      switch (item?.type) {
        case "text":
          return (
            <XStack
              backgroundColor={isMember ? "#B66D0E" : "#fff"}
              padding="$3"
              borderRadius={10}
            >
              <Paragraph
                color={isMember ? "#fff" : "#000"}
                userSelect="none"
                unstyled
              >
                {item?.context}
              </Paragraph>
            </XStack>
          );
        case "image":
          return (
            <TouchableWithoutFeedback
              onPress={() => onImageClick(getFilePath(item?.context))}
            >
              <View>
                <FastImage
                  source={{ uri: getFilePath(item?.context) }}
                  style={{ width: 200, height: 200, borderRadius: 10 }}
                  resizeMode="cover"
                />
              </View>
            </TouchableWithoutFeedback>
          );
        case "audio":
          return (
            <XStack
              backgroundColor={isMember ? "#B66D0E" : "#fff"}
              padding="$3"
              borderRadius={10}
            >
              <VoicePlayer
                uri={getFilePath(item?.context)}
                color={isMember ? "#fff" : "#000"}
              />
            </XStack>
          );
        default:
          return null;
      }
    };

    return (
      <XStack
        justifyContent={isMember ? "flex-end" : "flex-start"}
        alignItems="flex-end"
        paddingLeft={isMember ? 0 : 10}
        paddingRight={isMember ? 10 : 0}
        width="100%"
        paddingBottom="$5"
      >
        {/* 此用户为接收者时，显示发送者的头像 */}
        {!isMember && (
          <Avatar
            circular
            backgroundColor="$white"
            size={50}
            marginRight={10}
            onPress={() => {
              if (item?.member?.referId) {
                router.push({
                  pathname: "/(outer)/home/user_profile",
                  params: {
                    memberId: item?.member?.referId,
                    source: "chatroom",
                  },
                });
              }
            }}
          >
            {item?.member?.avatar ? (
              <Avatar.Image src={getFilePath(item?.member?.avatar)} />
            ) : (
              <Avatar.Fallback backgroundColor="$gray6" />
            )}
          </Avatar>
        )}

        <Button
          ref={messageRef}
          maxWidth={global.screenWidth * 0.8}
          flex={0}
          flexDirection="row"
          justifyContent={isMember ? "flex-end" : "flex-start"}
          backgroundColor="transparent"
          borderRadius={10}
          onLongPress={() => {
            if (messageRef.current) {
              messageRef.current.measure(
                (x, y, width, height, pageX, pageY) => {
                  handleLongPress({
                    isMember,
                    message: {
                      id: item.id,
                      context: item.context,
                    },
                    layout: {
                      width,
                      height,
                      pageX,
                      pageY,
                    },
                  });
                }
              );
            }
          }}
          zIndex={0}
          unstyled
        >
          {renderContent()}
        </Button>

        {isMember && (
          <Avatar circular size={50} backgroundColor="$white" marginLeft={10}>
            {item?.flag === "send" ? (
              <Avatar.Image src={getFilePath(userProfile?.avatar)} />
            ) : item?.member?.avatar ? (
              <Avatar.Image src={getFilePath(item?.member?.avatar)} />
            ) : (
              <Avatar.Fallback backgroundColor="$gray6" />
            )}
          </Avatar>
        )}
      </XStack>
    );
  }
);

const ChatModal = ({
  isMember,
  onCopy,
  onRevoke,
}: {
  isMember: boolean;
  onCopy;
  onRevoke;
}) => {
  return (
    <XStack
      paddingHorizontal="$3"
      flex={1}
      space="$4"
      alignItems="center"
      justifyContent="center"
      zIndex={999}
    >
      <Button alignItems="center" onPress={onCopy} unstyled>
        <AntDesignIcon name="copy1" size={20} color="#fff" />
        <Paragraph color="#fff" fontSize={12}>
          复制
        </Paragraph>
      </Button>
      {isMember ? (
        <Button alignItems="center" onPress={onRevoke} unstyled>
          <AntDesignIcon name="back" size={20} color="#fff" />
          <Paragraph color="#fff" fontSize={12}>
            撤回
          </Paragraph>
        </Button>
      ) : null}
    </XStack>
  );
};
