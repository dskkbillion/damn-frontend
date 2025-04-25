import { Image, View, Text } from "react-native";
import {
  Button,
  Card,
  CardProps,
  H2,
  Paragraph,
  XStack,
  YStack,
} from "tamagui";

import { OfferCards } from "./offercards";

export function TopLayout() {
  return (
    <XStack $sm={{ flexDirection: "column" }} paddingHorizontal="$3" space>
      <DemoCard size="$10" />
    </XStack>
  );
}

export function DemoCard(props: CardProps) {
  return (
    <Card paddingVertical="$2">
      <YStack flex={1}>
        <XStack flex={1}>
          <H2
            fontSize={20}
            marginLeft="$2"
            paddingHorizontal="$3"
            alignSelf="center"
          >
            多看Offer榜
          </H2>
          <Text
            style={{
              alignSelf: "center",
              marginLeft: "auto",
              color: "#b66d0e",
              paddingRight: 13,
            }}
          >
            全部
          </Text>
        </XStack>

        <XStack marginTop="$2" paddingHorizontal="$3">
          <OfferCards />
        </XStack>

        <XStack paddingHorizontal="$2" />
      </YStack>
    </Card>
  );
}
