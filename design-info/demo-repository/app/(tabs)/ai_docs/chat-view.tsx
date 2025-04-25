import {
  BottomSheetFlatList,
  BottomSheetModal,
} from "@gorhom/bottom-sheet";
import {
  Search,
  Image,
  FileText,
  ArrowUp,
  ChevronUp,
  ChevronDown,
  List,
  Plus,
  Clock,
} from "@tamagui/lucide-icons";
import { FlashList } from "@shopify/flash-list";
import * as Burnt from "burnt";
import { Audio } from "expo-av";
import { Recording } from "expo-av/build/Audio";
import * as DocumentPicker from "expo-document-picker";
import * as ImagePicker from "expo-image-picker";
import { router, Stack, useRouter, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useRef, useState } from "react";
import {
  Alert,
  Keyboard,
  KeyboardAvoidingView,
  Platform,
  ReturnKeyTypeOptions,
  TextInput,
  TouchableWithoutFeedback,
  View,
  ActivityIndicator,
  Image as RNImage,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useDispatch, useSelector } from "react-redux";
import useTyperwriter from "react-typewriter-hook";
import {
  Button,
  Input,
  XStack,
  YStack,
  useTheme,
  H2,
  styled,
  Text,
  Theme,
  Paragraph,
  Circle,
  Avatar,
} from "tamagui";

// import { PhotoGallery } from "@/components/ai_doc/photo_gallery";
import { useBottomSheet } from "@/components/ai_doc/bottom-sheet-context";
import {
  ChatContent,
  ChatElement,
  InitChatElement,
} from "@/components/ai_doc/chat";
import { VoiceDialog } from "@/components/ai_doc/voiceDialog";
import { useToast } from "@/hooks/hook-utils";
import { AppDispatch, RootState, model, store, fileSlice } from "@/src/store";
import { chatParams, Send2Model } from "@/src/util/modelActions";
// import { pickDocument } from "@/components/utils/filesystem";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { pickImage, takePhoto } from "@/components/utils/filesystem";
import { terminateCurrentConnection } from "@/src/util/sseService";
import { LinearGradient } from "expo-linear-gradient";
import { toast } from "@/components/styled/toast";
import { useGlobalContext } from "@/components/system/globalContext";
import { SvgXml } from "react-native-svg";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";
import { isAxiosSuccess } from "@/components/utils";

const StyledButton = styled(Button, {
  alignItems: "center",
  justifyContent: "center",
  padding: 0,
  minWidth: 0, // reset any default Button padding & size
  // shadowColor: "#6C6C6C",
  // shadowOffset: {
  //   width: 0,
  //   height: 2,
  // },
  // shadowOpacity: 0.5,
  // shadowRadius: 6
});

// const InputContainer = styled(XStack, {
//   backgroundColor: "white",
//   borderColor: "#e1e1e1", // Change to your preferred border color
//   alignItems: "center",
//   flex: 1,
//   shadowColor: "#6C6C6C",
//   shadowOffset: {
//     width: 0,
//     height: 1,
//   },
//   shadowOpacity: 0.2,
//   shadowRadius: 6,
// });
export function InputViewTitle() {
  const titleName = "生成你的专属方案";
  const [showFullText, setShowFullText] = useState(true); // 初始化显示文本
  const [trigger, setTrigger] = useState(false); // 初始化没有打字效果
  const typewriterText = useTyperwriter(trigger ? titleName : " ") || "";

  // 分割文本
  const middleIndex = Math.floor(titleName.length / 2);

  // 当前显示的文本长度是否超过了中间位置
  const isBeyondMiddle = typewriterText.length > middleIndex;

  // 根据当前打字机效果的进度分割文本
  const firstPart = isBeyondMiddle
    ? typewriterText.substring(0, middleIndex) //超过中点只显示一半
    : typewriterText; //没有超过中点显示全部加载

  const secondPart = isBeyondMiddle
    ? typewriterText.substring(middleIndex)
    : "";

  useEffect(() => {
    // 1s后开始打字效果
    const timeout = setTimeout(() => {
      setShowFullText(false);
      setTrigger(true);
    }, 1000);
    // 文本悬停时间
    const interval = setInterval(() => {
      setTrigger((t) => !t);
    }, 10000);

    return () => {
      clearTimeout(timeout);
      clearInterval(interval);
    };
  }, []);

  return (
    <YStack
      alignItems="flex-start"
      paddingTop="$10"
      height="$13"
      paddingLeft={40}
    >
      <H2 color="#000000">
        {showFullText ? titleName.substring(0, middleIndex) : firstPart}
      </H2>
      <XStack padding="$2" />
      <H2 color="#000000" paddingLeft="$10">
        {showFullText ? titleName.substring(middleIndex) : secondPart}
      </H2>
    </YStack>
  );
}

export default function ChatView() {
  const theme = useTheme();
  const dispatch = useDispatch<AppDispatch>();
  const router = useRouter();
  const [search, setSearch] = useState("");
  const inputRef = useRef<TextInput>(null);

  const { messages, model_loading, generating, answer } = useSelector(
    (state: RootState) => state.chatBot
  );
  const userId = useSelector((state: RootState) => state.user.data.id);

  const { toastSuccess } = useToast();
  const chatRef = useRef<FlashList<any>>(null);
  const {
    handlePresentModal,
    handleDismissModal,
    presented,
    searchParam, // we will use it later
    setSearchParam,
  } = useBottomSheet();

  const conversation_id = useSelector(
    (state: RootState) => state.chatBot.conversation_id
  );

  const [showOptions, setShowOptions] = useState(false);
  const [keyboardVisible, setKeyboardVisible] = useState(false);
  const chatImages = useSelector((state: RootState) => state?.file?.chatImages);
  const [shouldClear, setShouldClear] = useState(false);

  const { screenWidth, screenHeight } = useGlobalContext();
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

  const handlePlusPress = () => {
    if (keyboardVisible) {
      Keyboard.dismiss();
    }
    setShowOptions(!showOptions);
    if (inputRef.current) {
      inputRef.current.blur();
    }
  };

  // 添加一个强制更新状态的函数
  const [forceUpdate, setForceUpdate] = useState(0);

  const forceRerender = () => {
    setForceUpdate(prev => prev + 1);
  };

  // 添加本地状态管理选择的图片
  const [localImages, setLocalImages] = useState<Array<{imgName: string, imgUrl: string}>>([]);

  const sendImages = async (action: "camera" | "library") => {
    try {
      setShowOptions(false);
      console.log("开始选择图片，方式:", action);

      let result;
      if (action === "camera") {
        result = await ImagePicker.launchCameraAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsEditing: true,
          aspect: [4, 3],
          quality: 0.2, // 大幅降低质量以减小文件大小
        });
      } else {
        result = await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ImagePicker.MediaTypeOptions.Images,
          allowsMultipleSelection: true,
          quality: 0.2, // 大幅降低质量以减小文件大小
        });
      }

      console.log("图片选择结果:", JSON.stringify(result));

      if (!result.canceled && result.assets && result.assets.length > 0) {
        // 先显示本地图片，提供即时预览
        const localImages = result.assets.map((asset) => {
          console.log("选择的图片:", asset.uri);
          return {
            imgName: asset.fileName || `image-${Date.now()}.jpg`,
            imgUrl: asset.uri,
          };
        });

        console.log("处理后的图片数组:", localImages);

        // 更新本地状态，立即显示图片
        setLocalImages(prev => [...prev, ...localImages]);
        console.log("已更新本地图片状态");

        // 同时更新Redux状态，使用本地图片路径
        dispatch(fileSlice.file.actions.setType("chat"));
        dispatch(fileSlice.file.actions.addImage({
          type: "chat",
          images: localImages
        }));

        console.log("图片已添加到Redux store");

        // 强制重新渲染
        forceRerender();

        // 聚焦输入框
        if (inputRef.current) {
          inputRef.current.focus();
        }

        // 在后台尝试上传图片到服务器
        toast({ title: "正在后台上传图片..." });

        // 创建一个上传任务数组
        const uploadTasks = result.assets.map(async (asset, index) => {
          try {
            // 创建FormData对象
            const formData = new FormData();
            formData.append('file', {
              uri: asset.uri,
              type: 'image/jpeg',
              name: asset.fileName || `image-${Date.now()}.jpg`,
            } as any);

            // 设置类型为聊天
            dispatch(fileSlice.file.actions.setType("chat"));

            // 上传图片
            const uploadResult = await dispatch(fileSlice.file.actions.uploadFile(formData));

            console.log(`图片 ${index} 上传结果:`, uploadResult);

            // 检查上传是否成功
            if (uploadResult.type.includes('/fulfilled')) {
              const data = uploadResult.payload;
              if (data && data.code === 200 && data.data && data.data.url) {
                // 上传成功，更新Redux状态中的图片URL
                console.log(`图片 ${index} 上传成功，URL:`, data.data.url);

                // 更新本地状态中的图片URL
                setLocalImages(prev => {
                  const newImages = [...prev];
                  if (newImages[index]) {
                    newImages[index] = {
                      ...newImages[index],
                      imgUrl: data.data.url
                    };
                  }
                  return newImages;
                });

                // 更新Redux状态中的图片URL
                dispatch(fileSlice.file.actions.updateImageUrl({
                  type: "chat",
                  index,
                  url: data.data.url
                }));

                return {
                  success: true,
                  url: data.data.url
                };
              }
            }

            return {
              success: false,
              url: asset.uri
            };
          } catch (error) {
            console.error(`图片 ${index} 上传出错:`, error);
            return {
              success: false,
              url: asset.uri
            };
          }
        });

        // 等待所有上传任务完成
        const uploadResults = await Promise.all(uploadTasks);

        // 检查上传结果
        const successCount = uploadResults.filter(result => result.success).length;
        if (successCount === result.assets.length) {
          toast({ title: "所有图片上传成功" });
        } else if (successCount > 0) {
          toast({ title: `${successCount}/${result.assets.length} 张图片上传成功` });
        } else {
          toast({ title: "图片上传失败，将使用本地图片" });
        }
      } else {
        console.log("用户取消了图片选择或没有选择图片");
      }
    } catch (error) {
      console.error("选择图片时出错:", error);
      toast({ title: "选择图片失败" });
    }
  };

  // 修改removeImage函数同时更新本地状态
  const removeImage = (index: number) => {
    // 更新本地状态
    setLocalImages(prev => prev.filter((_, i) => i !== index));

    // 更新Redux状态
    dispatch(fileSlice.file.actions.setType("chat"));
    dispatch(fileSlice.file.actions.deleteImage(index));
  };

  const triggerModal = () => {
    if (presented) {
      handleDismissModal();
    } else {
      handlePresentModal(0);
    }
  };

  const openHistory = useCallback(() => {
    try {
      router.push("/ai_docs/history");
    } catch (error) {
      console.error("Navigation error:", error);
    }
  }, [router]);

  const startNewChat = useCallback(() => {
    try {
      if (conversation_id !== null && messages.length > 0) {
        // 清除上一次历史会话
        dispatch(model.chatBot.actions.setConversationId(null));
        toastSuccess({ title: "已新建聊天" });
      } else {
        toastSuccess({ title: "已是最新会话" });
      }
    } catch (error) {
      console.error("Create new chat error:", error);
    }
  }, [messages, conversation_id, dispatch]);

  /**
   * 发送消息: 如果当前没有会话, 则创建会话
   */
  const handleSend = useCallback(async () => {
    try {
      // 获取本地图片URL
      const files = chatImages ? chatImages.map((file) => file.imgUrl) : [];

      // 检查是否有内容可发送
      if (!search.trim() && files.length === 0) {
        toast({ title: "内容不能为空" });
        return;
      }

      // 缓存当前输入，然后清空输入框
      const currentMessage = search.trim();
      setSearch("");
      setShouldClear(true);

      console.log("准备发送消息，文本:", currentMessage, "图片:", files);

      // 过滤有效的图片URL，并去重
      // 优先使用非本地图片URL
      const validFiles = [...new Set(files.filter(url => typeof url === 'string' && url.trim() !== ''))] as string[];
      console.log("有效的图片URL (去重后):", validFiles);

      // 检查是否有本地文件路径
      const hasLocalFiles = validFiles.some(url => url.startsWith('file://'));
      if (hasLocalFiles) {
        toast({ title: "图片正在上传中，请稍后再发送" });
        return;
      }

      let currentConversationId = conversation_id;

      // 如果没有会话ID，先创建会话
      if (!currentConversationId) {
        const res = await dispatch(
          model.chatBot.actions.createChatRoom({
            user_id: Number(userId),
            title:
              currentMessage.length > 10
                ? currentMessage.substring(0, 10) + "..."
                : currentMessage || "图片消息",
          })
        ).unwrap(); // 使用 unwrap 来获取实际的 payload

        if (res?.data?.conversation_id) {
          currentConversationId = res.data.conversation_id;
        } else {
          toast({ title: "创建会话失败" });
          return;
        }
      }

      // 缓存用户输入
      dispatch(
        model.chatBot.actions.addUserMessage({
          role: "user",
          content: currentMessage || (validFiles.length > 0 ? "[图片消息]" : ""),
          files: validFiles,
        })
      );

      console.log("已添加用户消息到聊天记录，包含图片:", validFiles);

      // 发送请求
      const params = {
        user_id: Number(userId),
        conversation_id: currentConversationId,
        message: currentMessage || (validFiles.length > 0 ? "[图片消息]" : ""),
        files: validFiles,
      };

      console.log("发送消息参数:", params);
      dispatch(Send2Model(params));

      // 发送后清除已选择的图片
      dispatch(fileSlice.file.actions.setType("chat"));
      dispatch(fileSlice.file.actions.clearImages({ type: "chat" }));
      // 清除本地图片状态
      setLocalImages([]);
      console.log("已清除选择的图片");
    } catch (error) {
      console.error("发送消息失败:", error);
      toast({ title: "发送失败，请重试" });
    }
  }, [search, conversation_id, userId, chatImages, dispatch]);

  const handleInputFocus = () => {
    if (showOptions) {
      setShowOptions(false);
    }
    setTimeout(() => {
      if (chatRef.current && typeof chatRef.current.scrollToOffset === 'function') {
        chatRef.current.scrollToOffset({
          offset: 100000,
          animated: true,
        });
      }
    }, 100);
  };

  // 添加终止 SSE 的函数
  const handleStopGeneration = useCallback(() => {
    console.log("handleStopGeneration 被调用");
    const sseConnection = store.getState().chatBot.isSSEConnected;
    console.log("当前SSE连接状态:", sseConnection);

    try {
      console.log("尝试终止SSE连接");
      // 无论连接状态如何，都尝试终止连接
      terminateCurrentConnection();

      // 强制设置状态为完成
      dispatch(model.chatBot.actions.setDone());
      dispatch(model.chatBot.actions.setSSEConnection(false));

      console.log("SSE连接已终止");

      // 如果当前有未完成的消息，将其标记为已中断
      if (generating && answer) {
        // 将当前的answer添加到消息列表中
        dispatch(
          model.chatBot.actions.finalizeAns({
            content: answer + "\n\n[生成已中断]",
            content_type: "text",
          })
        );
      } else {
        // 即使没有生成内容，也添加一条中断提示消息
        dispatch(
          model.chatBot.actions.finalizeAns({
            content: "您已中断AI助手的回复生成。如需继续对话，请发送新的消息。",
            content_type: "text",
          })
        );
      }

      // 强制更新UI状态
      dispatch(model.chatBot.actions.forceUpdateUI());
    } catch (error) {
      console.error("终止SSE连接时出错:", error);
    }
  }, [dispatch, generating, answer]);

  // 在组件内部添加这个函数
  const handleVoiceSend = useCallback((audioUrl: string) => {
    console.log("收到语音URL:", audioUrl);

    if (!audioUrl) {
      console.error("语音URL为空");
      return;
    }

    // 创建用户消息
    dispatch(
      model.chatBot.actions.addUserMessage({
        role: "user",
        content: "[语音消息]",
        files: [audioUrl]
      })
    );

    // 发送到AI
    const params: chatParams = {
      user_id: Number(userId),
      conversation_id,
      message: "[语音消息]",
      files: [audioUrl]
    };

    dispatch(Send2Model(params));
  }, [dispatch, conversation_id, userId]);

  // 响应消息
  const ResponseChatElement = () => {
    // 如果是 assistant 消息
    let content = "";
    // 获取推理状态
    const isReasoning = useSelector((state: RootState) => state.chatBot.isReasoning);
    const reasoning = useSelector((state: RootState) => state.chatBot.reasoning);

    console.log("ResponseChatElement渲染 - model_loading:", model_loading, "generating:", generating, "isReasoning:", isReasoning);

    if (model_loading) {
      console.log("显示加载状态");
      content = "生成中，请耐心等候...";
    }
    // 如果正在生成，显示实时的 answer
    else if (generating) {
      console.log("显示生成内容:", answer.substring(0, 20) + "...");
      content = answer;
    } else if (!generating && !model_loading && !content) {
      console.log("不显示响应元素");
      return null;
    }

    return (
      <XStack
        alignItems="flex-start"
        paddingHorizontal={16}
        width="100%"
        paddingVertical="$2"
        justifyContent="flex-start"
      >
        {/* 头像 */}
        <Circle
          backgroundColor="#AC702A"
          width={40}
          height={40}
          alignItems="center"
          justifyContent="center"
          marginRight="$2"
        >
          <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width={30} height={30} />
        </Circle>

        <YStack flex={0} alignSelf="flex-start" gap="$2">
          <YStack
            maxWidth={global.screenWidth * 0.75}
            flex={0}
            flexDirection="row"
            backgroundColor="#FFFFFF"
            paddingHorizontal="$3"
            paddingVertical="$3"
            borderRadius={16}
            shadowColor="#000"
            shadowOffset={{
              width: 0,
              height: 1,
            }}
            shadowOpacity={0.1}
            shadowRadius={2}
            elevation={2}
          >
            <Paragraph
              color="#000"
              fontWeight="400"
              lineHeight={20}
            >
              {content}
            </Paragraph>
          </YStack>

          {/* 显示推理状态 */}
          {isReasoning && (
            <XStack
              alignItems="center"
              space="$2"
              backgroundColor="#F5F5F5"
              padding="$2"
              borderRadius={10}
              shadowColor="#000"
              shadowOffset={{
                width: 0,
                height: 1,
              }}
              shadowOpacity={0.1}
              shadowRadius={2}
            >
              <ActivityIndicator size="small" color="#AC702A" />
              <Paragraph fontSize={12} color="$gray11">正在思考中...</Paragraph>
            </XStack>
          )}
        </YStack>
      </XStack>
    );
  };

  // 监听状态变化
  useEffect(() => {
    console.log("状态变化 - model_loading:", model_loading, "generating:", generating, "isSSEConnected:", store.getState().chatBot.isSSEConnected);
  }, [model_loading, generating]);

  // 初始化会话
  useEffect(() => {
    if (!conversation_id) {
      // 初始化&新建会话
      dispatch(model.chatBot.actions.initConversation());
    }

    if (conversation_id) {
      // 切换会话
      dispatch(model.chatBot.actions.clearHistory());
      dispatch(
        model.chatBot.actions.loadHistoryChat({
          conversation_id,
          user_id: userId,
        })
      );
    }
  }, [conversation_id]);

  // 监听chatImages变化，强制组件重新渲染
  useEffect(() => {
    console.log("chatImages已更新:", chatImages);
    // 这里不需要做任何事情，只是为了在chatImages变化时触发重新渲染
  }, [chatImages]);

  return (
    <Theme name="light">
      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <YStack flex={1} backgroundColor="#F8F9FA">
          <Stack.Screen
            options={{
              headerTransparent: true,
              header: () => (
                <XStack
                  justifyContent="space-between"
                  flexDirection="row"
                  alignItems="center"
                  paddingHorizontal={16}
                  paddingTop={50}
                  height={80}
                  backgroundColor="$brown0"
                >
                  <XStack gap="$4" alignItems="center">
                    <StyledButton
                      circular
                      size="$3"
                      borderWidth="0"
                      onPress={openHistory}
                      backgroundColor="transparent"
                    >
                      <Clock size={24} color="$darkGray" />
                    </StyledButton>
                    <StyledButton
                      circular
                      size="$3"
                      borderWidth="0"
                      onPress={startNewChat}
                      backgroundColor="transparent"
                    >
                      <Plus size={24} color="$darkGray" />
                    </StyledButton>
                  </XStack>

                  <XStack alignItems="center" minWidth={80} paddingVertical={8}>
                    <Button
                      backgroundColor="transparent"
                      borderWidth={0}
                      paddingHorizontal={0}
                      paddingVertical={4}
                      onPress={triggerModal}
                      flexDirection="row"
                      alignItems="center"
                      gap="$1"
                      height={32}
                    >
                      <Text color="$darkGray" fontSize={16} lineHeight={24}>
                        匹配
                      </Text>
                      <ChevronDown size={16} color="$black" />
                    </Button>
                  </XStack>
                </XStack>
              ),
            }}
          />
          <SafeAreaView style={{ flex: 0 }}>
            {/* {messages.length === 0 && <InputViewTitle />} */}
            <XStack marginTop={global.screenHeight * 0.05} />
            {messages.length === 0 && (
              <InitChatElement
                userId={userId}
                conversation_id={conversation_id}
              />
            )}
          </SafeAreaView>

          <KeyboardAvoidingView
            behavior={Platform.OS === "ios" ? "padding" : "height"}
            style={{
              flex: 1,
              position: "relative",
              bottom: 10,
              width: "100%",
            }}
          >
            <YStack flex={1}>
              {showOptions && (
                <TouchableWithoutFeedback
                  onPress={() => {
                    Keyboard.dismiss();
                    setShowOptions(false);
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

              <FlashList
                data={messages}
                ref={chatRef}
                extraData={messages} // messages更新后刷新渲染
                keyExtractor={(item) => item?.message_id?.toString() || Math.random().toString()}
                renderItem={({ item, index }) => {
                  return <ChatElement item={item} index={index} />;
                }}
                ListHeaderComponent={<XStack padding="$2" />}
                ListFooterComponent={<ResponseChatElement />}
                contentContainerStyle={{
                  paddingBottom: 120, // 增加底部padding，让内容可以滚动得更高
                }}
                showsVerticalScrollIndicator={false}
                estimatedItemSize={100} // 添加估计的项目大小，提高性能
                onEndReached={() => {
                  // 滚动到底部
                  if (chatRef.current && typeof chatRef.current.scrollToEnd === 'function') {
                    try {
                      chatRef.current.scrollToEnd();
                    } catch (error) {
                      console.log('滚动到底部出错:', error);
                    }
                  }
                }}
              />

              {/* 底部输入区域 */}
              <YStack
                position="absolute"
                bottom={0}
                left={0}
                right={0}
                height={localImages.length > 0 ? 160 : 80}
                backgroundColor="#FFFFFF"
                borderTopWidth={0}
                paddingBottom="$2"
                paddingHorizontal="$2"
              >
                {/* 显示已选择的图片 */}
                {localImages.length > 0 ? (
                  <XStack
                    height={80}
                    width="100%"
                    backgroundColor="$white"
                    alignItems="center"
                    justifyContent="flex-start"
                    paddingHorizontal="$2"
                    gap="$2"
                    marginBottom={5}
                  >
                    {console.log("渲染本地图片:", JSON.stringify(localImages))}
                    {localImages.map((file, index) => {
                      console.log(`渲染本地图片 ${index}:`, JSON.stringify(file));
                      return (
                        <XStack key={`img-${index}`} position="relative">
                          <RNImage
                            source={{ uri: file.imgUrl }}
                            style={{
                              width: 60,
                              height: 60,
                              borderRadius: 8,
                              backgroundColor: "#f0f0f0"
                            }}
                            onError={(error) => console.log("预览图片加载失败:", file.imgUrl, error.nativeEvent.error)}
                            onLoad={() => console.log("预览图片加载成功:", file.imgUrl)}
                          />
                          <StyledButton
                            position="absolute"
                            top={-5}
                            right={-5}
                            size="$1"
                            circular
                            backgroundColor="$red10"
                            onPress={() => removeImage(index)}
                          >
                            <Text color="$white" fontSize={10}>
                              X
                            </Text>
                          </StyledButton>
                        </XStack>
                      );
                    })}
                  </XStack>
                ) : (
                  <XStack height={10} />
                )}

                {/* 输入框和按钮 */}
                <XStack
                  alignItems="center"
                  justifyContent="space-between"
                  backgroundColor="transparent"
                  borderRadius={10}
                  height={50}
                  width="100%"
                  alignSelf="center"
                  gap="$1"
                  paddingHorizontal="$1"
                  marginTop={localImages && localImages.length > 0 ? 0 : 10}
                >
                  <XStack
                    shadowColor="#000"
                    shadowOffset={{
                      width: 0,
                      height: 2,
                    }}
                    shadowOpacity={0.1}
                    shadowRadius={3}
                    backgroundColor="$white"
                    borderRadius={25}
                    height={45}
                    flex={1}
                    alignItems="center"
                    paddingHorizontal="$1"
                  >
                    {/* 语音按钮 */}
                    <VoiceDialog onVoiceSend={handleVoiceSend} />

                    {/* 输入框 */}
                    <Input
                      multiline
                      ref={inputRef}
                      flex={1}
                      placeholder="在此输入"
                      onFocus={handleInputFocus}
                      borderRadius={25}
                      value={search}
                      paddingLeft={10}
                      paddingRight={10}
                      onChangeText={(text) => {
                        if (shouldClear) {
                          setSearch("");
                          setShouldClear(false);
                        } else {
                          // 除所有的行符
                          setSearch(text.replace(/\n/g, ""));
                        }
                      }}
                      returnKeyType="send"
                      onKeyPress={(e) => {
                        if (e.nativeEvent.key === "Enter") {
                          handleSend();
                        }
                      }}
                      borderWidth={0}
                      backgroundColor="$white"
                    />
                  </XStack>

                  {/* 发送按钮 */}
                  {model_loading || generating ? (
                    <StyledButton
                      circular
                      size="$4"
                      borderWidth="0"
                      zIndex={999}
                      onPress={() => {
                        console.log("暂停按钮被点击");
                        // 立即更新UI状态，不等待异步操作完成
                        setShowOptions(false);
                        handleStopGeneration();
                      }}
                      backgroundColor="#E74C3C"
                    >
                      <FontAwesomeIcon
                        name="stop-circle"
                        size={24}
                        color="white"
                      />
                    </StyledButton>
                  ) : search.trim() || (localImages && localImages.length > 0) ? (
                    <StyledButton
                      circular
                      size="$4"
                      borderWidth="0"
                      zIndex={999}
                      onPress={handleSend}
                      backgroundColor="#b66d0e"
                    >
                      <FontAwesomeIcon name="send" size={20} color="white" />
                    </StyledButton>
                  ) : (
                    <StyledButton
                      circular
                      size="$4"
                      borderWidth="0"
                      zIndex={999}
                      onPress={handlePlusPress}
                      backgroundColor="#b66d0e"
                    >
                      <FontAwesomeIcon name="plus" size={20} color="white" />
                    </StyledButton>
                  )}
                </XStack>
              </YStack>

              {/* 显示选项 */}
              {showOptions && (
                <TouchableWithoutFeedback
                  onPress={() => {
                    Keyboard.dismiss();
                    setShowOptions(false);
                  }}
                >
                  <YStack
                    position="absolute"
                    bottom={80}
                    left={0}
                    right={0}
                    height={120}
                    backgroundColor="rgba(0,0,0,0.5)"
                  >
                    <YStack
                      position="absolute"
                      bottom={0}
                      left={0}
                      right={0}
                      height={120}
                      backgroundColor="$white"
                      padding="$2"
                      borderTopLeftRadius={0}
                      borderTopRightRadius={0}
                      shadowColor="#000"
                      shadowOffset={{
                        width: 0,
                        height: -2,
                      }}
                      shadowOpacity={0.1}
                      shadowRadius={3}
                    >
                      <XStack justifyContent="space-around" paddingTop="$2">
                        <YStack alignItems="center" gap="$1">
                          <StyledButton
                            circular
                            size="$5"
                            borderWidth="0"
                            onPress={() => sendImages("camera")}
                            backgroundColor="#F0F2F5"
                          >
                            <FontAwesomeIcon name="camera" size={24} color="#b66d0e" />
                          </StyledButton>
                          <Text fontSize={14} color="#666">拍照</Text>
                        </YStack>
                        <YStack alignItems="center" gap="$1">
                          <StyledButton
                            circular
                            size="$5"
                            borderWidth="0"
                            onPress={() => sendImages("library")}
                            backgroundColor="#F0F2F5"
                          >
                            <FontAwesomeIcon name="image" size={24} color="#b66d0e" />
                          </StyledButton>
                          <Text fontSize={14} color="#666">相册</Text>
                        </YStack>
                      </XStack>
                    </YStack>
                  </YStack>
                </TouchableWithoutFeedback>
              )}
            </YStack>
          </KeyboardAvoidingView>
        </YStack>
      </TouchableWithoutFeedback>
    </Theme>
  );
}
