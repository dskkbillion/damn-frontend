import { LinearGradient } from "@tamagui/linear-gradient";
import { ArrowLeft } from "@tamagui/lucide-icons";
import { radius } from "@tamagui/themes";
import { Link, Stack, useLocalSearchParams, useRouter } from "expo-router";
import { useState } from "react";
import { View, StyleSheet, Dimensions } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import {
  YStack,
  Separator,
  Theme,
  Button,
  XStack,
  Text,
  ZStack,
  Spinner,
  Avatar,
  H2,
  ButtonText,
  Card,
  Circle,
  Paragraph,
} from "tamagui";

import { MatchCircle } from "@/components/ai_doc/circle";
import { DocItem } from "@/components/chose-project";
import { applications, docs } from "@/constants/application";
import { portraits } from "@/constants/portrait";
import { sellerDataset } from "@/constants/sellers";

const screenWidth = Dimensions.get("window").width;
const screenHeight = Dimensions.get("window").height;

function randomRange(start: number, end: number) {
  const num = Math.random() * (end - start) + start;
  return num;
}

export default function ProfileScreen() {
  const params = useLocalSearchParams<{ id: string; doc_id: string }>();
  const router = useRouter();
  const user = portraits.find((p) => p.id === parseInt(params.id));

  const SPACETOP = screenHeight * 0.3;
  const SPACEBOTTOM = 120;
  const VERTICALSPACE = SPACETOP + SPACEBOTTOM;
  const row1Height = (screenHeight - VERTICALSPACE) * 0.2;
  const row2Height = (screenHeight - VERTICALSPACE) * 0.5;
  const row3Height = (screenHeight - VERTICALSPACE) * 0.3;
  const row1Split = [screenWidth * 0.6];
  const row3Split = [screenWidth * 0.4];
  const colorGroup: string[] = [
    "#b59d79",
    "#736357",
    "#512e12",
    "#e2c076",
    "#534741",
    "#b58f69",
    "#b26d2f",
    "#d8c987",
  ];

  const circles: MatchCircle[] = [];

  for (let row = 0; row < 3; row++) {
    //第一行
    if (row === 0) {
      const center_Xs: number[] = [];
      const radius_array = [80, 60];
      for (let col = 0; col <= row1Split.length; col++) {
        const radius = radius_array[col];

        const randomIndex = Math.floor(randomRange(0, colorGroup.length - 1));
        const color = colorGroup[randomIndex];
        colorGroup.splice(randomIndex, 1);

        // console.log('颜色是', color,randomIndex)

        const center_Y = randomRange(
          SPACETOP,
          row1Height + SPACETOP - 2 * radius,
        );

        if (col === 0) {
          const center_X_1 = randomRange(0, row1Split[0] - 2 * radius);
          center_Xs.push(center_X_1);
        } else if (col == row1Split.length) {
          const center_X_last = randomRange(
            row1Split[0],
            screenWidth - 2 * radius,
          );
          center_Xs.push(center_X_last);
        }

        const circle = new MatchCircle(
          radius,
          col === 0 ? center_Xs[col] + 5 : center_Xs[col],
          col === 0 ? center_Y : center_Y,
          color,
          sellerDataset[Math.floor(Math.random() * sellerDataset.length)],
        );
        circles.push(circle);
      }
      //第二行
    } else if (row === 1) {
      // 固定中心最大的圆

      let randomIndex = Math.floor(randomRange(0, colorGroup.length - 1));
      let color = colorGroup[randomIndex];
      colorGroup.splice(randomIndex, 1);

      const centerCircle_radius = 110;
      const centerCircle = new MatchCircle(
        centerCircle_radius,
        screenWidth * 0.5 - centerCircle_radius,
        screenHeight * 0.5 +
          0.5 * SPACETOP -
          0.5 * SPACEBOTTOM -
          centerCircle_radius,
        color,
        sellerDataset[Math.floor(Math.random() * sellerDataset.length)],
      );
      circles.push(centerCircle);

      // 固定左侧小圆
      randomIndex = Math.floor(randomRange(0, colorGroup.length - 1));
      color = colorGroup[randomIndex];
      colorGroup.splice(randomIndex, 1);

      const leftCircle_radius = 55;
      const leftcircle = new MatchCircle(
        leftCircle_radius,
        screenWidth * 0.5 - centerCircle_radius - screenWidth * 0.2,
        screenHeight * 0.5 +
          0.5 * SPACETOP -
          0.5 * SPACEBOTTOM -
          centerCircle_radius -
          randomRange(screenWidth * 0.01, screenWidth * 0.05),
        color,
        sellerDataset[Math.floor(Math.random() * sellerDataset.length)],
      );
      circles.push(leftcircle);

      // 固定右侧小圆
      randomIndex = Math.floor(randomRange(0, colorGroup.length - 1));
      color = colorGroup[randomIndex];
      colorGroup.splice(randomIndex, 1);

      const rightCirle_radius = 50;
      const rightCirle = new MatchCircle(
        rightCirle_radius,
        screenWidth * 0.5 -
          centerCircle_radius +
          randomRange(screenWidth * 0.5, screenWidth * 0.52),
        screenHeight * 0.5 +
          0.5 * SPACETOP -
          0.5 * SPACEBOTTOM -
          centerCircle_radius +
          randomRange(screenWidth * 0.15, screenWidth * 0.2),
        color,
        sellerDataset[Math.floor(Math.random() * sellerDataset.length)],
      );
      circles.push(rightCirle);

      //第三行
    } else if (row === 2) {
      const center_Xs: number[] = [];
      const radius_array = [60, 90];
      for (let col = 0; col <= row3Split.length; col++) {
        const randomIndex = Math.floor(randomRange(0, colorGroup.length - 1));
        const color = colorGroup[randomIndex];
        colorGroup.splice(randomIndex, 1);

        const radius = radius_array[col];
        const center_Y = randomRange(
          SPACETOP + row1Height + row2Height,
          SPACETOP + row1Height + row2Height + row3Height - 2 * radius,
        );
        if (col === 0) {
          const center_X_1 = randomRange(0, row3Split[0] - 2 * radius); // [radius,split1]
          center_Xs.push(center_X_1);
        } else if (col == row3Split.length) {
          const center_X_last = randomRange(
            row3Split[row3Split.length - 1],
            screenWidth - 2 * radius,
          );
          center_Xs.push(center_X_last);
        }
        const circle = new MatchCircle(
          radius_array[col],
          center_Xs[col],
          col === 0 ? center_Y - screenWidth * 0.05 : center_Y,
          color,
          sellerDataset[Math.floor(Math.random() * sellerDataset.length)],
        );
        circles.push(circle);
      }
    }
  }

  const [isLoading, setIsLoading] = useState(false);
  return (
    <Theme name="light">
      {/* <Stack.Screen options={{ headerTitle: "文书生成" }} /> */}
      <SafeAreaView>
        <YStack marginTop="$12" marginHorizontal="$3">
          <XStack>
            <ArrowLeft
              size="$3"
              onPress={() => {
                router.back();
              }}
            />
            <H2>与我相关的卖家</H2>
          </XStack>
        </YStack>

        {circles.map((circle, index) => circle.fotmatCircle())}
      </SafeAreaView>

      {/* {instance.fotmatCircle()} */}

      <ZStack
        width="20%"
        flex={1}
        onPress={() => {
          setIsLoading(!isLoading);
          setTimeout(() => setIsLoading(false), 2000);
          // router.push({
          //   pathname: `/(tabs)/ai_docs/${params.id}/1/`,
          //   params: { doc_id: params.id },
          // });
          router.push({
            pathname: `/(tabs)/ai_docs/${params.id}/doc_detail`,
          });
          // router.replace(`/(tabs)/ai_docs/${params.id}/1/`);
        }}
      >
        {/* <YStack
            width="$8"
            height="$8"
            borderRadius="$15"
            borderWidth={0}
            alignContent="center"
            justifyContent="center"
          >
            {isLoading ? (
              <Spinner size="small" color="white" />
            ) : (
              <Text
                textAlign="center"
                fontSize="$6"
                color="white"
                fontWeight="bold"
              >
                多看
              </Text>
            )}
          </YStack> */}
      </ZStack>
    </Theme>
  );
}
