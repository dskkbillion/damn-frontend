import { ChevronDown } from "@tamagui/lucide-icons";
import { useSelector } from "react-redux";
import { Accordion, H1, Paragraph, XStack, YStack } from "tamagui";

import { RootState } from "@/src/store";

export function FreqQuestion() {
  const ItemDetail = useSelector((state: RootState) => state.item.ItemDetail);
  const freqQuestions = ItemDetail?.productMaterials.filter(
    (item) => item.type === "PROBLEM"
  );

  return (
    <Accordion overflow="hidden" width={global.screenWidth} type="multiple">
      <Accordion.Item value="a1">
        <Accordion.Trigger
          flexDirection="row"
          justifyContent="space-between"
          paddingHorizontal="4%"
          borderBottomColor="#F2F2F2"
          borderBottomWidth={1}
          style={{ backgroundColor: "#ffffff" }}
          alignItems="center"
          unstyled
        >
          {({ open }) => (
            <>
              <H1 fontSize={16}>常见问题</H1>
              <XStack animation="quick" rotate={open ? "180deg" : "0deg"}>
                <ChevronDown size="$1" />
              </XStack>
            </>
          )}
        </Accordion.Trigger>
        <Accordion.Content>
          {freqQuestions &&
            freqQuestions.length > 0 &&
            freqQuestions.map((item, index) => (
              <YStack key={index} paddingVertical="$2">
                <Paragraph fontWeight="600">{item?.question}</Paragraph>
                <Paragraph color="#636569">{item?.answer}</Paragraph>
              </YStack>
            ))}
        </Accordion.Content>
      </Accordion.Item>
    </Accordion>
  );
}
