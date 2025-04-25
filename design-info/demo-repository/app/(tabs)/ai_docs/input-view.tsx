import { Search, Image, FileText } from "@tamagui/lucide-icons";
import * as Burnt from "burnt";
import { Audio } from "expo-av";
import { Recording } from "expo-av/build/Audio";
import * as DocumentPicker from "expo-document-picker";
import * as ImagePicker from "expo-image-picker";
import { useRouter } from "expo-router";
import { title } from "process";
import { useEffect, useState } from "react";
import { Pressable } from "react-native";
import Animated, {
  interpolate,
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
} from "react-native-reanimated";
import { SvgXml } from "react-native-svg";
import useTyperwriter from "react-typewriter-hook";
import {
  Button,
  Circle,
  Input,
  XStack,
  YStack,
  useTheme,
  H2,
  styled,
  H3,
  H4,
} from "tamagui";

import { PhotoGallery } from "@/components/ai_doc/photo_gallery";
import { VoiceDialog } from "@/components/ai_doc/voiceDialog";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";

const StyledButton = styled(Button, {
  alignItems: "center",
  justifyContent: "center",
  padding: 0,
  minWidth: 0, // reset any default Button padding & size
});

const InputContainer = styled(XStack, {
  backgroundColor: "white",
  borderColor: "#e1e1e1", // Change to your preferred border color
  borderRadius: 0,
  alignItems: "center",
  flex: 1,
});

export function InputViewTitle() {
  const titleName = "请告诉我你的需求语音，文字，图片的形式都可以";
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
  });

  return (
    <YStack alignItems="center" paddingTop="$5" height="$9">
      <H4 color="#000000">
        {showFullText ? titleName.substring(0, middleIndex) : firstPart}
      </H4>
      <XStack padding="$2" />
      <H4 color="#000000" paddingLeft="$10">
        {showFullText ? titleName.substring(middleIndex) : secondPart}
      </H4>
    </YStack>
  );
}

export default function AIInputView() {
  const theme = useTheme();
  const router = useRouter();
  const [input, setInput] = useState("");
  const [images, setImages] = useState<any | undefined>();
  const [doc, setDoc] = useState<any | undefined>();

  const toast = (title: string, symbol: string) => {
    Burnt.toast({
      title, // required
      message: "", // optional
      haptic: "success", // or "success", "warning", "error"
      duration: 2, // duration in seconds
      shouldDismissByDrag: true,
      from: "top", // "top" or "bottom"
      // optionally customize layout
      layout: {
        iconSize: {
          height: 24,
          width: 24,
        },
      },
      icon: {
        ios: {
          // SF Symbol. For a full list, see https://developer.apple.com/sf-symbols/.
          name: symbol,
          color: "#87D96C",
        },
      },
    });
  };

  const pickImage = async () => {
    // No permissions request is necessary for launching the image library
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.All,
      aspect: [4, 3],
      quality: 1,
      allowsMultipleSelection: true,
    });

    console.log(result);

    if (!result.canceled) {
      setImages(result.assets.map((asset) => asset.uri));
      toast("图片已上传", "checkmark.seal");
    }
  };

  const pickDocument = async () => {
    const result = await DocumentPicker.getDocumentAsync({
      type: "*/*",
    });

    if (!result.canceled) {
      setDoc(result.assets.map((asset) => asset.uri));
      toast("文件已上传", "checkmark.seal");
    }
  };

  const InputWithButton = () => {
    return (
      <InputContainer>
        <Input
          placeholder="Type something..."
          borderRadius={0}
          flex={1}
          value={input}
          onChangeText={setInput}
        />
        <XStack position="absolute" right={0}>
          <StyledButton circular size="$4" borderWidth="0" onPress={pickImage}>
            <Image />
          </StyledButton>
          <StyledButton
            circular
            size="$4"
            borderWidth="0"
            onPress={pickDocument}
          >
            <FileText />
          </StyledButton>
        </XStack>
      </InputContainer>
    );
  };

  return (
    <YStack paddingTop="$10" gap="$10" alignContent="center" height="100%">
      <XStack justifyContent="center" alignItems="center" gap="$3">
        <Circle
          size="$5"
          backgroundColor={"#b66d0e"}
          justifyContent="center"
        >
          <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width="100%" height={55} />
        </Circle>
        <H2>生成你的专属方案</H2>
      </XStack>
      <YStack flex={1} />

      {/* <InputViewTitle />
      <XStack
        justifyContent="flex-start"
        gap="$1"
        width="100%"
        paddingHorizontal="$1"
      >
        <VoiceDialog />
        <InputWithButton />
        <StyledButton
          borderTopLeftRadius={0}
          borderBottomLeftRadius={0}
          width="$4"
          onPress={() => {
            if (input.includes("装修")) {
              router.push("/(tabs)/ai_docs/furnish-view");
            } else if (input.includes("文书")) {
              router.push("/(tabs)/ai_docs/docs");
            } else {
              // make another router
              router.push("/(tabs)/ai_docs/question-answer-view");
            }
          }}
        >
          <Search />
        </StyledButton>
      </XStack> */}
      {/* {images ? <PhotoGallery images={images} /> : null} */}
    </YStack>
  );
}
