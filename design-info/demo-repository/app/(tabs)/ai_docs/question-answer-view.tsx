import { useEffect } from "react";
import { SafeAreaView } from "react-native";
import { SvgXml } from "react-native-svg";
import {
  Paragraph,
  YStack,
  Image,
  ScrollView,
  styled,
  Button,
  Text,
  XStack,
  Circle,
} from "tamagui";

import { useBottomSheet } from "@/components/ai_doc/bottom-sheet-context";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";

const Words = styled(Paragraph, {
  fontSize: 16,
  color: "black",
});

export default function QuestionAnswerView() {
  const { handlePresentModal, handleSnapChange } = useBottomSheet();

  return (
    <YStack flex={1} position="relative">
      <ScrollView flex={1}>
        <YStack
          paddingHorizontal="$3"
          width="100%"
          alignItems="center"
          gap="$3"
        >
          <Words paddingTop="$5">
            A Taylor series is a mathematical representation of a function as an
            infinite sum of terms, each of which is a derivative of the function
            evaluated at a specific point. Specifically, the Taylor series of a
            function f(x) centered at a point x = a is given by:
          </Words>
          <Image
            source={{
              uri: "https://gitee.com/jiangdawang/pic/raw/master/src/20240210104559.png",
              width: 300,
              height: 200,
            }}
            // width="80%"
            // height="40%"
          />
          <Image
            source={{
              uri: "https://gitee.com/jiangdawang/pic/raw/master/src/20240210104633.png",
              width: 300,
              height: 200,
            }}
            // width="80%"
            // height="40%"
          />
          <Words>
            The applications of Taylor series are numerous and include fields
            such as physics, engineering, and economics. They are used in areas
            such as signal processing, numerical analysis, and optimization. For
            example, in physics, Taylor series are used to approximate the
            motion of objects under various conditions. In engineering, they are
            used to design circuits, control systems, and other applications. In
            economics, Taylor series are used to model the behavior of financial
            markets and to estimate the effects of policy changes.
          </Words>
          <Words>
            如果您仍需要更多的指导，多看可为您匹配专业讲师细心指导喔 ～
          </Words>
        </YStack>
      </ScrollView>
      <YStack
        position="absolute"
        width={55}
        height={55}
        alignItems="center"
        justifyContent="center"
        right={15}
        bottom={10}
        // shadowOpacity={0.8}
        shadowColor="#6C6C6C"
        shadowOffset={{
          width: 0,
          height: 1,
        }}
      >
        {/* Button with centered SVG */}
        <Button
          onPress={() => handlePresentModal()}
          backgroundColor="#AC702A"
          borderRadius={999}
          width="100%"
          height="100%"
          alignItems="center"
          justifyContent="center"
        >
          <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width={35} height={35} />
        </Button>

        {/* Notification Circle */}
        <YStack
          position="absolute"
          right={0}
          top={0}
          width={20}
          height={20}
          backgroundColor="red"
          borderRadius={999}
          alignItems="center"
          justifyContent="center"
        >
          <Text color="white">6</Text>
        </YStack>
      </YStack>
      {/* <Button
        width="100%"
        bottom={0}
        height="auto"
        position="absolute"
        gap="5"
        onPress={() => handlePresentModal()}
      >
        <YStack alignItems="center" justifyContent="center">
          <SvgXml
            xml={LOGO_BROWN_XML}
            width={35}
            height={35}
          />
          <Text color="gray" fontSize={15}>点击查看为您匹配到的相关服务</Text>
        </YStack>
      </Button> */}
    </YStack>
  );
}
