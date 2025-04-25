import { SafeAreaView } from "react-native";
import {
  Paragraph,
  YStack,
  Image,
  ScrollView,
  styled,
  Button,
  Text,
} from "tamagui";

import { useBottomSheet } from "@/components/ai_doc/bottom-sheet-context";

const Words = styled(Paragraph, {
  fontSize: 16,
  color: "black",
});

export default function FurnishView() {
  const { handlePresentModal } = useBottomSheet();
  return (
    <ScrollView>
      <SafeAreaView>
        <YStack
          paddingHorizontal="$3"
          width="100%"
          alignItems="center"
          gap="$3"
        >
          <Words paddingTop="$5">
            根据您110平的三室两厅来看，您的房间适合后现代风格，......
            {"\n"}下面是风格参考：
          </Words>
          <Image
            source={{
              uri: "https://assets.wfcdn.com/im/41682058/resize-h500-w750%5Ecompr-r85/2069/206926674/default_name.jpg",
              width: 300,
              height: 200,
            }}
            width="80%"
            height="40%"
          />

          <Image
            source={{
              uri: "https://assets.architecturaldigest.in/photos/62026064b5d9eefa7e4e2ddf/16:9/w_1920,c_limit/How%20to%20furnish%20your%20home%20on%20a%20budget.jpg",
              width: 300,
              height: 200,
            }}
            width="80%"
            height="40%"
          />
          <Words>
            如果您需要进一步的方案以及了解，多看可为您匹配专业人士细心指导喔 ～
          </Words>
          <Button
            backgroundColor="#D7BB99"
            width="20%"
            borderRadius="$3"
            bordered
            onPress={() => handlePresentModal(1)}
          >
            <Text color="white">匹配</Text>
          </Button>
        </YStack>
      </SafeAreaView>
    </ScrollView>
  );
}
