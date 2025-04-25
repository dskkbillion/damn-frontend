import React, { useState, useEffect, useRef } from "react";
import { Dimensions, View } from "react-native";
import { SvgXml } from "react-native-svg";
import useTypewriter from "react-typewriter-hook";
import {
  Button,
  Card,
  CardProps,
  H2,
  Image,
  Paragraph,
  ScrollView,
  XStack,
  YStack,
  Text,
  Circle,
  useTheme,
} from "tamagui";

import { LOGO_BROWN_XML } from "@/constants/utils";

export function PrintText() {
  const PortraitName = ["主申(CS)", "副申(MFE)", "冲刺TOP30"];
  let index = 0;

  const [magicName, setMagicName] = useState("个性化分类");
  const intervalRef = useRef<number | null>(null);
  const name = useTypewriter(magicName);
  useEffect(() => {
    // 使用类型断言将 setInterval 的返回值声明为 number
    intervalRef.current = setInterval(() => {
      index = (index + 1) % PortraitName.length;
      setMagicName(PortraitName[index]);
    }, 5000) as unknown as number;

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);
  return (
    <XStack flex={1}>
      <Paragraph color="#000000">{name}</Paragraph>
    </XStack>
  );
}

export function AIGuidence() {
  const screenWidth = Dimensions.get("window").width;

  return (
    <ScrollView
      horizontal
      pagingEnabled
      showsHorizontalScrollIndicator={false}
      style={{ flexDirection: "row" }}
    >
      <XStack $sm={{ flexDirection: "row" }}>
        <DemoCardStep1
          animation="bouncy"
          size="$4"
          width={screenWidth * 0.9}
          height={280}
          scale={0.9}
          hoverStyle={{ scale: 0.925 }}
          pressStyle={{ scale: 0.875 }}
          marginHorizontal={Math.floor(screenWidth * 0.05)}
        />

        <DemoCardStep2
          animation="bouncy"
          size="$4"
          width={screenWidth * 0.9}
          height={280}
          scale={0.9}
          hoverStyle={{ scale: 0.925 }}
          pressStyle={{ scale: 0.875 }}
          marginHorizontal={Math.floor(screenWidth * 0.05)}
        />

        <DemoCardStep3
          animation="bouncy"
          size="$4"
          width={screenWidth * 0.9}
          height={280}
          scale={0.9}
          hoverStyle={{ scale: 0.925 }}
          pressStyle={{ scale: 0.875 }}
          marginHorizontal={Math.floor(screenWidth * 0.05)}
        />
      </XStack>
    </ScrollView>
  );
}

export function DemoCardStep1(props: CardProps) {
  const cardWidth = props.width;
  const cardHeight = props.height;
  const theme = useTheme();

  return (
    <YStack flexDirection="column" alignItems="center">
      <Card size="$4" {...props} backgroundColor="white" borderColor="white">
        <Card.Header padded>
          <H2 color="#000000">第一步</H2>

          <Paragraph theme="alt2">填写文书材料 </Paragraph>
          <Paragraph color="#000000">在"编辑模式"中填写你的相关信息</Paragraph>

          <XStack>
            {/* 主轴水平 */}
            <XStack
              flexDirection="row"
              marginLeft={(cardWidth as number) / 6.5}
              marginTop={(cardHeight as number) / 20}
            >
              <View
                style={{
                  width: 60,
                  height: 60,
                  borderRadius: 35,
                  overflow: "hidden",
                }}
              >
                <SvgXml
                  xml={LOGO_BROWN_XML} // 使用导入的SVG XML常量
                  width="100%"
                  height="100%"
                />
              </View>

              <YStack flexDirection="column" marginLeft="$3">
                <XStack>
                  <Paragraph color="#000000">标签：</Paragraph>
                  <View>
                    <PrintText />
                  </View>
                </XStack>
                <XStack>
                  <Paragraph color="#000000">描述：</Paragraph>
                  <View
                    style={{
                      width: 90,
                      height: 15,
                      backgroundColor: "gray",
                      marginVertical: 4.5,
                    }}
                  />
                </XStack>
              </YStack>
            </XStack>
          </XStack>
        </Card.Header>

        <YStack />

        <Card.Footer padded>
          <YStack flex={1} alignItems="center">
            {/* 在这里改第一步介绍内容 */}

            <Paragraph theme="alt2" fontSize={12}>
              填写您的相关信息作为文书材料，您可以尝试构建多个标签并切换它们来轻松地生成不同的文书
              <Text color="$gray11"> </Text>
              <Text margin="$2" textDecorationLine="underline" color="$gray11">
                了解更多
              </Text>
            </Paragraph>

            {/* <Button marginTop="$1" borderRadius="$10" width={110} height={30}>
      去创建画像
    </Button> */}
          </YStack>
        </Card.Footer>

        <Card.Background>
          {/* <Image
      resizeMode="contain"
      alignSelf="center"
      source={{
        width: 300,
        height: 300,
        uri: '',
      }}
    /> */}
        </Card.Background>
      </Card>
      <XStack space="$2" marginVertical="$2">
        <Circle width={10} height={10} backgroundColor={"#b66d0e"} />
        <Circle width={10} height={10} backgroundColor="gray" />
        <Circle width={10} height={10} backgroundColor="gray" />
      </XStack>
    </YStack>
  );
}

export function DemoCardStep2(props: CardProps) {
  const cardWidth = props.width;
  const cardHeight = props.height;
  const theme = useTheme();

  return (
    <YStack flexDirection="column" alignItems="center">
      <Card size="$4" {...props} backgroundColor="white" borderColor="white">
        <Card.Header padded>
          <H2 color="#000000">第二步</H2>

          <Paragraph theme="alt2">提供您的目标学校和专业</Paragraph>
          <Paragraph color="#000000">精准化的文书生成</Paragraph>

          <XStack flexDirection="row" alignSelf="center">
            {/* <Card 
                backgroundColor={'#EDEDED'}
                width={props.width as number / 1.8}
                height={props.height as number / 4}
                marginVertical='$5'
                >
                    <Card.Header>
                        <YStack flexDirection='column' >
                            <Paragraph color={'#000000'}>目标学校:</Paragraph>
                            <XStack padding='$2'/>
                            <Paragraph color={'#000000'}>目标专业:</Paragraph>
                        </YStack>
                    </Card.Header>
                </Card> */}

            <Image
              resizeMode="contain"
              // position='absolute'
              // right={8}
              source={{
                width: 130,
                height: 130,
                uri: "https://github.com/scallioncake/demo-imgae/blob/main/%E5%9B%BE%E5%83%8F%20(2)-1.jpg?raw=true",
              }}
            />
          </XStack>
        </Card.Header>

        <YStack />

        <Card.Footer padded>
          <Paragraph theme="alt2" fontSize={12}>
            模型将根据每个项目生成专属文书
          </Paragraph>
        </Card.Footer>

        <Card.Background />
      </Card>
      <XStack space="$2" marginVertical="$2">
        <Circle width={10} height={10} backgroundColor="gray" />
        <Circle width={10} height={10} backgroundColor={"#b66d0e"} />
        <Circle width={10} height={10} backgroundColor="gray" />
      </XStack>
    </YStack>
  );
}

export function DemoCardStep3(props: CardProps) {
  const cardWidth = props.width;
  const cardHeight = props.height;
  const theme = useTheme();

  return (
    <YStack flexDirection="column" alignItems="center">
      <Card size="$4" {...props} backgroundColor="white" borderColor="white">
        <Card.Header padded>
          <H2 color="#000000">第三步</H2>

          <Paragraph theme="alt2">生成文书</Paragraph>
          <Paragraph>一键生成文书</Paragraph>

          {/* <View> */}
          {/* <Image
                    source={{
                        width:300,
                        height:200,
                        uri:''}}
                ></Image> */}
          {/* </View> */}

          {/* 
            <Card.Footer>
                <Paragraph theme={'alt2'} fontSize={12}>这里是第三步的详细介绍（如有必要）
                </Paragraph>
            </Card.Footer> */}
        </Card.Header>

        <YStack />

        <Card.Footer padded />

        <Card.Background>
          <Image
            resizeMode="contain"
            alignSelf="center"
            source={{
              width: props.width as number,
              height: props.height as number,
              uri: "https://github.com/scallioncake/demo-imgae/blob/main/IMG_6754.JPG?raw=true",
            }}
          />
        </Card.Background>
      </Card>
      <XStack space="$2" marginVertical="$2">
        <Circle width={10} height={10} backgroundColor="gray" />
        <Circle width={10} height={10} backgroundColor="gray" />
        <Circle width={10} height={10} backgroundColor={"#b66d0e"} />
      </XStack>
    </YStack>
  );
}
