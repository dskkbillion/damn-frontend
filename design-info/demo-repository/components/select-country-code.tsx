import { Check, ChevronDown, ChevronUp } from "@tamagui/lucide-icons";
import { useMemo, useState } from "react";
import {
  Adapt,
  Label,
  Select,
  SelectProps,
  Sheet,
  XStack,
  YStack,
  getFontSize,
} from "tamagui";
import { LinearGradient } from "tamagui/linear-gradient";

import { countryCodes } from "../constants/country-codes";

interface GeneralSelectProps extends SelectProps {
  label: string;
  first: string;
  options: Map<string, string | number>;
  snapPoints?: number[];
  val: string;
  setVal: (val: string) => void;
}

export function GeneralSelect({
  label,
  first,
  options,
  val,
  setVal,
  ...props
}: GeneralSelectProps) {
  return (
    <Select
      id="label"
      value={val}
      onValueChange={setVal}
      disablePreventBodyScroll
      {...props}
    >
      <Select.Trigger
        width={100}
        padding="$0"
        paddingHorizontal="$3"
        alignItems="center"
      >
        <Select.Value placeholder={label} fontSize="$2" fontWeight="normal" />
      </Select.Trigger>
      <Adapt when="sm" platform="touch">
        <Sheet
          native={!!props.native}
          modal
          dismissOnSnapToBottom
          animationConfig={{
            type: "spring",
            damping: 20,
            mass: 1.2,
            stiffness: 250,
          }}
          snapPoints={props.snapPoints && props.snapPoints}
        >
          <Sheet.Frame>
            <Sheet.ScrollView>
              <Adapt.Contents />
            </Sheet.ScrollView>
          </Sheet.Frame>

          <Sheet.Overlay
            animation="lazy"
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
          />
        </Sheet>
      </Adapt>
      <Select.Content zIndex={200000}>
        <Select.ScrollUpButton
          alignItems="center"
          justifyContent="center"
          position="relative"
          width="100%"
          height="$3"
        >
          <YStack zIndex={10}>
            <ChevronUp size={20} />
          </YStack>

          <LinearGradient
            start={[0, 0]}
            end={[0, 1]}
            fullscreen
            colors={["$background", "transparent"]}
            borderRadius="$4"
          />
        </Select.ScrollUpButton>
        <Select.Viewport
          // to do animations:
          // animation="quick"
          // animateOnly={['transform', 'opacity']}
          // enterStyle={{ o: 0, y: -10 }}
          // exitStyle={{ o: 0, y: 10 }}
          minWidth={200}
        >
          <Select.Group>
            <Select.Label>{label}</Select.Label>
            {/* for longer lists memoizing these is useful */}
            {Array.from(options).map(([key, value], index) => {
              return (
                <Select.Item
                  index={index}
                  key={key} // should be correct
                  value={value.toString()}
                >
                  <Select.ItemText>{key}</Select.ItemText>

                  <Select.ItemIndicator marginLeft="auto">
                    <Check size={16} />
                  </Select.ItemIndicator>
                </Select.Item>
              );
            })}
            {/* {useMemo(
              () =>
                Array.from(options).map(([key, value], index) => {
                  return (
                    <Select.Item
                      debug="verbose"
                      index={index}
                      key={key} // should be correct
                      value={value.toString()}
                    >
                      <Select.ItemText>{key}</Select.ItemText>

                      <Select.ItemIndicator marginLeft="auto">
                        <Check size={16} />
                      </Select.ItemIndicator>
                    </Select.Item>
                  );
                }),

              [options],
            )} */}
          </Select.Group>

          {/* Native gets an extra icon */}

          {props.native && (
            <YStack
              position="absolute"
              right={0}
              top={0}
              bottom={0}
              alignItems="center"
              justifyContent="center"
              width="$4"
              pointerEvents="none"
            >
              <ChevronDown size={getFontSize((props.size ?? "$true") as any)} />
            </YStack>
          )}
        </Select.Viewport>
        <Select.ScrollDownButton
          alignItems="center"
          justifyContent="center"
          position="relative"
          width="100%"
          height="$3"
        >
          <YStack zIndex={10}>
            <ChevronDown size={20} />
          </YStack>

          <LinearGradient
            start={[0, 0]}
            end={[0, 1]}
            fullscreen
            colors={["transparent", "$background"]}
            borderRadius="$4"
          />
        </Select.ScrollDownButton>
      </Select.Content>
    </Select>
  );
}

export function SelectPhoneRegion(props: SelectProps) {
  return (
    <GeneralSelect
      label="Country Code"
      first="86"
      options={countryCodes}
      val="86"
      setVal={() => {}}
      {...props}
    />
  );
}
