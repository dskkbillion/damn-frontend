import { ChevronDown } from "@tamagui/lucide-icons";
import React from "react";
import { Accordion, H1, XStack } from "tamagui";

interface AccordionTemplateProps {
  title: string;
  width?: number;
  height?: number;
  type: "single" | "multiple";
  defaultValue?: string | string[];
  titleSize?: number;
  backgroundColor?: string;
  borderColor?: string;
  borderBottomWidth?: number;
  triggerPadding?: number | string;
  contentPadding?: number | string;
  titleColor?: string;
  children: React.ReactNode;
}

function AccordionTemplate({
  title,
  width = global.screenWidth,
  height = 50,
  type,
  defaultValue,
  titleSize = 16,
  backgroundColor = "#ffffff",
  borderColor = "#F2F2F2",
  borderBottomWidth = 1,
  triggerPadding = "4%",
  contentPadding = "$3",
  titleColor = "#000000",
  children,
}: AccordionTemplateProps) {
  const AccordionContent = (
    <Accordion.Item value="accordion-1">
      <Accordion.Trigger
        flexDirection="row"
        justifyContent="space-between"
        alignItems="center"
        paddingHorizontal={triggerPadding}
        height={height}
        borderBottomColor={borderColor}
        borderBottomWidth={borderBottomWidth}
        style={{ backgroundColor }}
        unstyled
      >
        {({ open }) => (
          <>
            <H1 fontSize={titleSize} color={titleColor}>{title}</H1>
            <XStack animation="quick" rotate={open ? "180deg" : "0deg"}>
              <ChevronDown size="$1" />
            </XStack>
          </>
        )}
      </Accordion.Trigger>
      <Accordion.Content padding={contentPadding}>{children}</Accordion.Content>
    </Accordion.Item>
  );

  if (type === "multiple") {
    return (
      <Accordion
        type="multiple"
        overflow="hidden"
        width={width}
        defaultValue={defaultValue as string[]}
      >
        {AccordionContent}
      </Accordion>
    );
  }

  return (
    <Accordion
      type="single"
      collapsible
      overflow="hidden"
      width={width}
      defaultValue={defaultValue as string}
    >
      {AccordionContent}
    </Accordion>
  );
}

export default AccordionTemplate;
