import { ChevronDown } from "@tamagui/lucide-icons";
import { useSelector } from "react-redux";
import { Accordion, H1, Paragraph, XStack } from "tamagui";

import { QueryDict } from "../queryDict";

import { RootState } from "@/src/store";

export function RequiredMaterials() {
  const ItemDetail = useSelector((state: RootState) => state.item.ItemDetail);
  const requiredMaterials = ItemDetail?.productMaterials.filter(
    (item) => item.type === "TEXT" || item.type === "ATTCHMENT"
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
              <H1 fontSize={16}>需要卖家提供</H1>
              <XStack animation="quick" rotate={open ? "180deg" : "0deg"}>
                <ChevronDown size="$1" />
              </XStack>
            </>
          )}
        </Accordion.Trigger>
        <Accordion.Content>
          {requiredMaterials &&
            requiredMaterials.length > 0 &&
            requiredMaterials.map((item, index) => (
              <XStack key={index} paddingVertical="$2" alignItems="center">
                <Paragraph fontWeight="600">
                  {
                    QueryDict(
                      global.dictData?.["product_materials_type"],
                      item?.type
                    ).label
                  }
                  {"   "}-
                </Paragraph>
                <Paragraph color="#636569" marginLeft="$3">
                  {item?.question}
                </Paragraph>
              </XStack>
            ))}
        </Accordion.Content>
      </Accordion.Item>
    </Accordion>
  );
}
