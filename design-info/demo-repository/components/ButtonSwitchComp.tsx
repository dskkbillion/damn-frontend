import { AppDispatch, slices } from "@/src/store";
import React, { useState } from "react";
import { Text as TextNative } from "react-native";
import { useDispatch } from "react-redux";
import { Button, Separator, XStack } from "tamagui";

export type RenderContentType = ({
  type,
  ...props
}: {
  type: string;
  [key: string]: any;
}) => any;

export const ButtonSwitchComp = ({
  button_num,
  is_titled,
  renderContent,
  //   renderContent,
  ...props
}: {
  button_num: number;
  is_titled: boolean;
  renderContent: RenderContentType;
  //   renderContent: React.FC;
  [key: string]: any;
}) => {
  // console.log("props", props.initialIndex);
  const initialVal = props.initialIndex
    ? props.names[props.initialIndex]
    : props.names[0];

  const [selectedButton, setSelectedButton] = useState<string>(initialVal);
  const buttons = Array.from({ length: button_num }, (_, index) => index + 1);
  const names = props.names;
  const dispatch = useDispatch<AppDispatch>();
  return (
    <>
      <XStack flexDirection="row" width="100%" backgroundColor="transparent">
        {buttons.map((button, index) => (
          <Button
            key={index}
            backgroundColor={
              props.backgroundColor ? props.backgroundColor : "white"
            }
            borderBottomWidth="$1"
            width={is_titled ? global.screenWidth / button_num : null}
            height="auto"
            paddingVertical="$3"
            marginBottom="$3"
            borderRadius={0}
            onPress={() => {
              setSelectedButton(names[index]);
              dispatch(slices.order.actions.clearDemandList());
            }}
          >
            <TextNative
              style={{
                fontWeight: selectedButton === names[index] ? "800" : "400",
                fontSize: props.fontSize ? props.fontSize : 18,
                color:
                  names[index] === selectedButton
                    ? props.selectedColor
                      ? props.selectedColor
                      : "#B66D0E"
                    : "gray",
              }}
            >
              {names[index]}
            </TextNative>
          </Button>
        ))}
      </XStack>
      {renderContent({ type: selectedButton })}
    </>
  );
};
