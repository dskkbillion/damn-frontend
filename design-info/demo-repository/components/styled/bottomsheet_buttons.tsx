import { Button } from "@tamagui/button";
import { PortalProvider } from "@tamagui/portal";
import { Sheet } from "@tamagui/sheet";
import React, { useState } from "react";
import { ButtonText, Paragraph, XStack } from "tamagui";

/**
 * @description :A bottom sheet component.
 * two buttons (comfirm bottom without dialog)
 * @param {any} value - The value associated with the button.
 * @example
 * <BottomSheetWithButtons
 *   isOpen={isOpen}
 *   onClose={setIsOpen}
 *   title="确认下架？"
 *   buttons={["取消", "确定"]}
 *   handleComfirm={handleComfirm}
 * />
 */

export const BottomSheetWithButtons = ({
  isOpen,
  onClose,
  title,
  buttons,
  handleCancel,
  handleComfirm,
  children = null,
  snapPoints = [40],
  zIndex = 100000,
  position = 0,
  ...props
}) => {
  const [currentPosition, setCurrentPosition] = useState(position);
  const [selectedValue, setSelectedValue] = useState(buttons[0]);

  const handleButtonClick = (value) => {
    setSelectedValue(value);
  };

  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => onClose(open)}
        snapPoints={snapPoints}
        dismissOnSnapToBottom
        dismissOnOverlayPress
        position={currentPosition}
        onPositionChange={setCurrentPosition}
        zIndex={zIndex}
        animation="medium"
      >
        <Sheet.Overlay
          animation="lazy"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <Sheet.Frame
          padding="$4"
          alignItems="center"
          space="$5"
          backgroundColor="#fff"
        >
          <Paragraph fontSize={16} fontWeight="500">
            {title}
          </Paragraph>

          <XStack
            flexDirection="row"
            marginTop={20}
            alignItems="center"
            justifyContent="center"
            paddingHorizontal={10}
            width="100%"
          >
            <Button
              marginHorizontal={10}
              width={
                global.screenWidth / buttons.length -
                20 -
                10 * (buttons.length - 1)
              }
              height={global.screenHeight * 0.04}
              justifyContent="center"
              alignItems="center"
              borderRadius={10}
              backgroundColor="$lightGray"
              onPress={() => {
                if (handleCancel) {
                  handleCancel();
                  onClose(false);
                } else {
                  onClose(false);
                }
              }}
              unstyled
            >
              <ButtonText color="$white">{buttons[0]}</ButtonText>
            </Button>

            <Button
              backgroundColor="#B66D0E"
              marginHorizontal={10}
              width={
                global.screenWidth / buttons.length -
                20 -
                10 * (buttons.length - 1)
              }
              height={global.screenHeight * 0.04}
              justifyContent="center"
              alignItems="center"
              borderRadius={10}
              onPress={() => handleComfirm()}
              unstyled
            >
              <ButtonText color="$white">{buttons[1]}</ButtonText>
            </Button>
          </XStack>
          <XStack
            flexDirection="row"
            width="100%"
            marginHorizontal={10}
            boxSizing="border-box"
          >
            {children}
          </XStack>
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};
