import { Check, Check as CheckIcon, PlusCircle } from "@tamagui/lucide-icons";
import { Link, router } from "expo-router";
import * as React from "react";
// import Svg, { SvgProps, G, Path, Circle } from "react-native-svg";
import { YStack, Theme, H2, Paragraph, Button, ButtonText } from "tamagui";

import { SelectProfile } from "../../../components/select_profile";

import AccordionView from "@/components/ai_doc/accordion";
import { userDataset } from "@/constants/users";

export default function AiDocsScreen() {
  const current_user = userDataset[0];
  const portraits = current_user.portraits;
  return (
    <Theme name="light">
      <YStack
        flex={1}
        alignItems="center"
        padding="$2"
        paddingTop="$12"
        backgroundColor="#FFFFFF"
      >
        {/* 展示用户名 */}
        <H2 fontSize={25}>{current_user.username}</H2>
        <Paragraph fontSize={15} theme="alt2">
          {Object.keys(current_user.portraits).length}个画像
        </Paragraph>

        {/* 展示画像和折叠信息(组件跳转) */}
        <YStack marginTop="$12">
          <AccordionView sections={portraits} />
        </YStack>

        {/* 添加画像 */}
        <Button
          position="absolute"
          bottom={global.screenHeight * 0.07}
          width={global.screenWidth * 0.5}
          backgroundColor="#b66d0e"
          borderRadius={20}
          marginTop={30}
          onPress={() => router.push("/(tabs)/ai_docs/create_profile-1")}
        >
          <PlusCircle color="#ffffff" size="$1" />
          <ButtonText color="#ffffff">添加画像</ButtonText>
        </Button>

        <SelectProfile portrait={portraits} />
      </YStack>
    </Theme>
  );
}
