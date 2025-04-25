import { Check, ChevronDown, ChevronUp } from "@tamagui/lucide-icons";
import { useEffect, useMemo, useState } from "react";
import { Adapt, Paragraph, Select, Sheet, YStack } from "tamagui";
import { LinearGradient } from "tamagui/linear-gradient";

export function SelectItem({ label, items, onValueChange, ...props }) {
  const [val, setVal] = useState("");
  console.log("val", val);
  useEffect(() => {
    setVal(val);
    onValueChange(val);
  }, [val]);
  return (
    <Select
      value={val}
      onValueChange={setVal}
      disablePreventBodyScroll
      {...props}
    >
      {/* select trigger box */}
      <Select.Trigger width={220} iconAfter={ChevronDown}>
        {val ? (
          <Paragraph>{val}</Paragraph>
        ) : (
          <Paragraph color="$lightGray">请选择具体原因</Paragraph>
        )}{" "}
      </Select.Trigger>

      <Adapt platform="touch">
        <Sheet
          modal
          dismissOnSnapToBottom
          animationConfig={{
            type: "spring",
            damping: 20,
            mass: 1.2,
            stiffness: 250,
          }}
        >
          <Sheet.Frame paddingVertical="$3">
            <Sheet.ScrollView>
              <Adapt.Contents />
            </Sheet.ScrollView>
          </Sheet.Frame>
          <Sheet.Overlay
            animation="lazy"
            backgroundColor="rgba(0, 0, 0, 0.5)"
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
          />
        </Sheet>
      </Adapt>

      <Select.Content zIndex={200000}>
        <Select.Viewport
          //   to do animations:
          animation="quick"
          animateOnly={["transform", "opacity"]}
          enterStyle={{ x: 0, y: -10 }}
          exitStyle={{ x: 0, y: 10 }}
          minWidth={200}
        >
          <Select.Group>
            <Select.Label color="$blue">{label}</Select.Label>
            {/* for longer lists memoizing these is useful */}
            {useMemo(
              () =>
                items.map((item, i) => {
                  return (
                    <Select.Item
                      index={i}
                      key={item}
                      value={item.toLowerCase()}
                    >
                      <Select.ItemText>{item}</Select.ItemText>
                      <Select.ItemIndicator marginLeft="auto">
                        <Check size={16} />
                      </Select.ItemIndicator>
                    </Select.Item>
                  );
                }),
              [items],
            )}
          </Select.Group>
        </Select.Viewport>
      </Select.Content>
    </Select>
  );
}
