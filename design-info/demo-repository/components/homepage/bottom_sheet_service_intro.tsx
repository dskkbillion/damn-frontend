import { ChevronDown, ChevronUp } from "@tamagui/lucide-icons";
import { Sheet, SheetProps, useSheet } from "@tamagui/sheet";
import { useState } from "react";
import { TextInput } from "react-native";
import {
  Button,
  ButtonText,
  H1,
  H2,
  Input,
  Paragraph,
  PortalProvider,
  XStack,
  YStack,
} from "tamagui";

const spModes = ["percent", "constant", "fit", "mixed"] as const;

export const MoreDescription = (props: {
  service: any;
  modifiable: boolean;
}) => {
  const [position, setPosition] = useState(0);
  const [open, setOpen] = useState(false);

  const snapPoints = [50, 75, 25]; // 底单可停在25%，50%，75%高度

  return (
    <PortalProvider>
      <Paragraph fontSize={15} onPress={() => setOpen(true)} color="#4095E5">
        {props.modifiable ? "修改" : "更多"}{" "}
      </Paragraph>

      <Sheet
        forceRemoveScrollEnabled={open}
        modal
        open={open}
        onOpenChange={setOpen}
        position={position} // 初始化是snapPoints[0]
        onPositionChange={setPosition}
        snapPoints={snapPoints} // 设置底部表单的高度为 200
        zIndex={100_000}
        animation="medium"
      >
        <Sheet.Overlay
          animation="lazy"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <Sheet.Handle />
        <Sheet.Frame padding="$4" alignItems="center" space="$5">
          {props.modifiable ? (
            <TextInput
              multiline
              placeholder={props.service.description}
              placeholderTextColor="#777777" // 设置占位符文字颜色
              style={{
                fontSize: 15,
              }}
            />
          ) : (
            <YStack>
              <H1 alignSelf="center" fontSize={18}>
                {props.service?.name}
              </H1>
              <Paragraph fontSize={15} marginHorizontal={20}>
                {props.service?.description}
              </Paragraph>
            </YStack>
          )}
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};
