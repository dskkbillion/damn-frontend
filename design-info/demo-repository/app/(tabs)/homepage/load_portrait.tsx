import { Check, Check as CheckIcon } from "@tamagui/lucide-icons";
import { Link } from "expo-router";
import * as React from "react";
// import Svg, { SvgProps, G, Path, Circle } from "react-native-svg";
import { Dimensions } from "react-native";
import {
  YStack,
  Theme,
  Text,
  Avatar,
  XStack,
  H2,
  Paragraph,
  Button,
  ButtonText,
  Card,
  Image,
  Separator,
} from "tamagui";

import { SelectProfile } from "../../../components/select_profile";

export default function AiDocsScreen() {
  const screenWidth = Dimensions.get("window").width;
  const screenHeight = Dimensions.get("window").height;

  return (
    <Theme name="light">
      <YStack
        flex={1}
        alignItems="center"
        // justifyContent="center"
        padding="$2"
        paddingTop="$0"
        backgroundColor="#FFFFFF"
      >
        <Card
          width={screenWidth}
          height={screenHeight * 0.2}
          backgroundColor="#FFFFFF"
          padded
          // marginTop= {0}
        >
          <Card.Header
            width={screenWidth * 0.5}
            paddingTop="$5"
            marginLeft="$8"
          >
            <YStack alignItems="center">
              <Paragraph flexDirection="column" alignItems="center">
                <Text marginTop="$2" /* 其他样式属性 */>
                  该账号已生成5篇文书
                </Text>
              </Paragraph>

              <Button
                width={100}
                marginTop="$2"
                borderRadius="$10"
                backgroundColor="#000000"
                // onPress={() => {router.replace("/(tabs)/")}}
              >
                <ButtonText color="#EDEDED">去管理</ButtonText>
              </Button>
            </YStack>
          </Card.Header>
          <Separator marginHorizontal={15} />

          <Card.Background>
            <Image
              resizeMode="contain"
              position="absolute"
              right={screenWidth * 0.05}
              top={screenHeight * 0.048}
              source={{
                width: 150,
                height: 80,
                uri: "https://github.com/scallioncake/demo-imgae/blob/main/%E6%8B%8D%E6%89%8B.jpg?raw=true",
              }}
            />
          </Card.Background>
        </Card>

        <H2 fontSize={20} padding="$2">
          当前画像
        </H2>

        <Avatar circular size="$8">
          <Avatar.Image />
          <Avatar.Fallback delayMs={600} backgroundColor="$gray6" />
        </Avatar>

        <SelectProfile profiles={profiles} />

        <Paragraph alignSelf="center" padding="$2" theme="alt2">
          最近使用
        </Paragraph>

        <XStack marginLeft="$5" space="$2">
          <Avatar circular size="$5">
            <Avatar.Image />
            <Avatar.Fallback delayMs={600} backgroundColor="#0B3954" />
            <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
              主
            </H2>
          </Avatar>

          <Avatar circular size="$5">
            <Avatar.Image />
            <Avatar.Fallback delayMs={600} backgroundColor="#0C090D" />
            <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
              CS
            </H2>
          </Avatar>

          <Avatar circular size="$5">
            <Avatar.Image />
            <Avatar.Fallback delayMs={600} backgroundColor="#0088D1" />
            <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
              MFE
            </H2>
          </Avatar>
          <Paragraph alignSelf="center">. . .</Paragraph>
        </XStack>

        <XStack marginTop="$8" space="$0">
          <Text color="$gray11">还没有？</Text>
          <Link href="/(tabs)/ai_docs/create_profile-1">
            <Text textDecorationLine="underline" color="$gray11">
              去设置
            </Text>
          </Link>
        </XStack>
      </YStack>
    </Theme>
  );
}
