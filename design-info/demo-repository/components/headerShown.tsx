import { ChevronLeft } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { Button, H1, Paragraph, XStack, YStack } from "tamagui";

export default function headerComponent({ title, ...props }) {
  // console.log("props", props.canBack);
  return (
    // headerleft(30%): if the page can go back to the last one
    // header center(40%)
    // headerright(30%)
    <XStack
      flexDirection="row"
      alignItems="center"
      justifyContent="space-evenly"
      paddingTop="10%"
      backgroundColor="$background"
    >
      <XStack width="30%" justifyContent="flex-start">
        {props.canBack ? (
          <Button
            onPress={() => {
              router.back();
            }}
            size="$1"
            backgroundColor="transparent"
            pressStyle={{
              backgroundColor: "transparent",
              borderColor: "transparent",
              opacity: 0.8,
            }}
          >
            <ChevronLeft color="#4285F6" />
          </Button>
        ) : (
          ""
        )}
      </XStack>
      <XStack width="40%" justifyContent="center">
        <H1 fontSize={16}>{title}</H1>
      </XStack>
      <XStack width="30%">{props.headerRightComponent}</XStack>
    </XStack>
  );
}
