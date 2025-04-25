import { ArrowRight, Mic, File, FileText } from "@tamagui/lucide-icons";
import { LinearGradient } from "expo-linear-gradient";
import { useRouter } from "expo-router";
import { memo, useCallback, useEffect, useRef, useState } from "react";
import { Dimensions, Image as RNImage, ActivityIndicator } from "react-native";
import { SvgXml } from "react-native-svg";
import {
  Input,
  YStack,
  Text,
  Button,
  XStack,
  useTheme,
  styled,
  Avatar,
  Square,
  Circle,
  Paragraph,
  TextArea,
  H2,
} from "tamagui";
import { useDispatch, useSelector } from "react-redux";
import type { AppDispatch, RootState } from "@/src/store";

import { ChatMessage } from "./bottom-sheet-context";
import { ImageWithLoading } from "../ImageLoading";

import { userDataset } from "@/constants/users";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";
import { VoiceDialog } from "./voiceDialog";

import { model } from "@/src/store";
import { chatParams, Send2Model } from "@/src/util/modelActions";
import { toast } from "../styled/toast";

export const ChatBubble = styled(Button, {
  backgroundColor: "$white",
  borderRadius: 20,
  padding: 0,
  margin: 0,
  paddingHorizontal: 10,
  paddingVertical: 8,
  height: "auto",
  alignSelf: "flex-start",
  maxWidth: "70%",
  fontSize: 16,
  color: "$black",
});

export function voiceButton({
  audio,
  onClick,
}: {
  audio: any;
  onClick: () => void;
}) {
  // add audio length
  const size = 24;
  return (
    <ChatBubble onPress={onClick}>
      <XStack gap="$1" alignItems="center" justifyContent="center">
        <Mic size={size} />
        <Text>24'</Text>
      </XStack>
    </ChatBubble>
  );
}

export function FileSmallView({ file }: { file: string }) {
  return (
    <XStack width={150} height={50} alignItems="center" justifyContent="center">
      <File size={24} />
      <Text flexWrap="wrap">{file}</Text>
    </XStack>
  );
}

export function ImagesSmallView({ images }: { images: string[] }) {
  // 添加安全检查，确保images是数组
  if (!images || !Array.isArray(images)) {
    return null;
  }

  const screenWidth = Dimensions.get("window").width - 40;
  const imgNum = Math.floor(screenWidth / 80) - 1;
  const moreThanSpace = images.length > imgNum;

  return (
    <XStack gap="$1">
      {images.slice(0, imgNum).map((image, index) => (
        <ImageWithLoading
          key={`image-${index}`}
          source={{ uri: image, width: 80, height: 80 }}
          width={80}
          height={80}
        />
      ))}
      {moreThanSpace && (
        <Square size={80} justifyContent="center" alignItems="center">
          <Text fontSize={25}>...</Text>
        </Square>
      )}
    </XStack>
  );
}

export function ChatContent({
  content,
  isUser,
}: {
  content: string;
  isUser: boolean;
}) {
  // 处理Markdown格式，将*text*转换为普通文本
  const processMarkdown = (text: string) => {
    if (!text) return "";
    // 替换Markdown的*强调*为普通文本
    return text.replace(/\*([^*]+)\*/g, "$1");
  };

  const processedContent = processMarkdown(content);

  return (
    <YStack
      maxWidth={global.screenWidth * 0.75}
      flex={0}
      flexDirection="row"
      backgroundColor={isUser ? "#b66d0e" : "#FFFFFF"}
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
      {processedContent && (
        <Paragraph
          color={isUser ? "#fff" : "#000"}
          fontWeight="400"
          lineHeight={20}
        >
          {processedContent}
        </Paragraph>
      )}
    </YStack>
  );
}

export function ChatContentStream({
  content,
  isUser,
}: {
  content: ChatMessage;
  isUser: boolean;
}) {
  const route = useRouter();
  const typingSpeed = 10;
  const maxCharacters = 500;
  const [displayedText, setDisplayedText] = useState("");
  const [showNavigateButton, setShowNavigateButton] = useState(false);

  useEffect(() => {
    let index = 0;
    const timer = setInterval(() => {
      setDisplayedText((prev) => prev + content.text?.charAt(index));
      index++;
      if (index === maxCharacters || index === content.text?.length) {
        clearInterval(timer);
        setShowNavigateButton(true);
      }
    }, typingSpeed);

    return () => clearInterval(timer); // Cleanup on component unmount
  }, [content.text, typingSpeed]);

  return (
    <YStack flex={1}>
      {content.text && (
        <YStack flex={1} maxHeight={280} overflow="hidden">
          <Text flexWrap="wrap" numberOfLines={15}>
            {displayedText}
          </Text>
        </YStack>
      )}
      {content.images && <ImagesSmallView images={content.images} />}
      {content.file && <FileSmallView file={content.file} />}
      {showNavigateButton && !isUser && content.routeTo ? (
        <Button
          backgroundColor="#D7BB99"
          width="13%"
          marginTop="$1"
          height="auto"
          borderRadius="$3"
          padding={0}
          onPress={() => route.push(content.routeTo as any)}
        >
          <ArrowRight />
        </Button>
      ) : null}
    </YStack>
  );
}

export const InitChatElement = ({
  userId,
  conversation_id,
}: {
  userId: number;
  conversation_id: null | number;
}) => {
  const dispatch = useDispatch<AppDispatch>();

  const handleQuickQuestion = async (question: string) => {
    try {
      let currentConversationId = conversation_id;

      // 如果没有会话ID，先创建会话
      if (!currentConversationId) {
        const res = await dispatch(
          model.chatBot.actions.createChatRoom({
            user_id: Number(userId),
            title:
              question.length > 10
                ? question.substring(0, 10) + "..."
                : question,
          })
        ).unwrap();

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
          content: question,
          files: [],
        })
      );

      // 发送请求
      const params: chatParams = {
        user_id: Number(userId),
        conversation_id: currentConversationId as any,
        message: question,
        files: [],
      };

      dispatch(Send2Model(params));
    } catch (error) {
      console.error("发送消息失败:", error);
      toast({ title: "发送失败，请重试" });
    }
  };

  return (
    <XStack
      alignItems="flex-start"
      width="100%"
      paddingLeft="$1"
      paddingTop="$5"
    >
      <Circle
        backgroundColor="#AC702A"
        width={40}
        height={40}
        alignItems="center"
        justifyContent="center"
      >
        <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width={35} height={35} />
      </Circle>
      <YStack flex={1} paddingHorizontal="$2" alignSelf="flex-start">
        <Paragraph fontSize={16}>
          你好，这里是
          <Text fontWeight="bold">小粽子</Text>。 我将为你生成
          <Text fontWeight="bold">专属方案</Text>并
          <Text fontWeight="bold">匹配服务</Text>。 你可以通过
          <Text fontWeight="bold">右上方的按钮</Text>随时查看可购买服务。
          你想问点什么呢？
        </Paragraph>
        <YStack gap="$2" paddingTop="$2">
          <ChatBubble
            onPress={() => handleQuickQuestion("如何改造家里的一个角落？")}
          >
            如何改造家里的一个角落？
          </ChatBubble>
          <ChatBubble
            onPress={() => handleQuickQuestion("我想打官司，该做什么？")}
          >
            我想打官司，该做什么？
          </ChatBubble>
          <ChatBubble onPress={() => handleQuickQuestion("车钥匙丢了怎么办？")}>
            车钥匙丢了怎么办？
          </ChatBubble>
        </YStack>
      </YStack>
    </XStack>
  );
};

export const ChatElement = ({ item, index }) => {
  const isUser = item.role === "user";
  const PAGE_WIDTH = global.screenWidth;
  // 获取用户信息
  const userProfile = useSelector((state: RootState) => state.user.data);
  // 获取推理状态
  const isReasoning = useSelector((state: RootState) => state.chatBot.isReasoning);
  const reasoning = useSelector((state: RootState) => state.chatBot.reasoning);

  console.log(`渲染消息 ${index}:`, item);

  return (
    <XStack
      alignItems="flex-start"
      paddingHorizontal={16}
      width="100%"
      paddingVertical="$2"
      justifyContent={isUser ? "flex-end" : "flex-start"}
    >
      {/* 头像 - 仅在非用户消息时显示在左侧 */}
      {!isUser && (
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
      )}

      {/* 内容 */}
      <YStack
        flex={0}
        alignSelf={isUser ? "flex-end" : "flex-start"}
        gap="$2"
      >
        {/* 文本内容 */}
        {item.content && (
          <ChatContent content={item.content} isUser={isUser} />
        )}

        {/* 显示图片 */}
        {item.files && Array.isArray(item.files) && item.files.length > 0 && (
          <XStack gap="$1" flexWrap="wrap">
            {console.log("渲染图片:", item.files)}
            {item.files.map((imageUrl, imgIndex) => {
              console.log(`图片 ${imgIndex}:`, imageUrl);
              return (
                <XStack
                  key={`img-container-${imgIndex}`}
                  width={120}
                  height={120}
                  backgroundColor="#f0f0f0"
                  borderRadius={8}
                  marginBottom={8}
                  alignItems="center"
                  justifyContent="center"
                  overflow="hidden"
                >
                  <RNImage
                    key={`img-${imgIndex}`}
                    source={{ uri: imageUrl }}
                    style={{
                      width: 120,
                      height: 120,
                      borderRadius: 8,
                    }}
                    resizeMode="cover"
                    onError={(error) => console.log("图片加载失败:", imageUrl, error.nativeEvent.error)}
                    onLoad={() => console.log("图片加载成功:", imageUrl)}
                  />
                </XStack>
              );
            })}
          </XStack>
        )}

        {/* 显示推理状态 */}
        {!isUser && isReasoning && index === 0 && (
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

      {/* 头像 - 仅在用户消息时显示在右侧 */}
      {isUser && (
        <Avatar circular size={40} marginLeft="$2">
          {/* 使用用户真实头像 */}
          <Avatar.Image src={userProfile?.avatar} />
          {/* 添加头像加载失败时的默认显示 */}
          <Avatar.Fallback backgroundColor="$gray6" />
        </Avatar>
      )}
    </XStack>
  );
};
