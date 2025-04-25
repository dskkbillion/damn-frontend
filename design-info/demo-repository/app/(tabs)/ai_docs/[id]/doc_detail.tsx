import { BlurView } from "expo-blur";
import { Link } from "expo-router";
import {
  YStack,
  H2,
  Separator,
  Theme,
  Button,
  ScrollView,
  Text,
} from "tamagui";

import { aiDocPage } from "@/constants/ai_doc_page";
export default function DocDetailScreen() {
  return (
    <Theme name="light">
      <BlurView intensity={70} style={{ flex: 1, paddingTop: 100 }}>
        <YStack
          flex={1}
          alignItems="center"
          justifyContent="center"
          backgroundColor="$yellow2"
          opacity={0.8}
          paddingHorizontal="$5"
          paddingTop="$2"
          // backgroundImage=""
        >
          <ScrollView>
            <Text fontSize="$6" fontWeight="600" textIndent="30%">
              {aiDocPage}
            </Text>
          </ScrollView>
        </YStack>
      </BlurView>
    </Theme>
  );
}
