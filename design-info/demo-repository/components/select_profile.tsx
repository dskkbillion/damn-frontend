import { MoreHorizontal, PlusCircle } from "@tamagui/lucide-icons";
import { Link, useRouter } from "expo-router";
import { useState } from "react";
import { SvgXml } from "react-native-svg";
import {
  Adapt,
  Avatar,
  Button,
  ButtonText,
  H2,
  Input,
  Label,
  Paragraph,
  Popover,
  PopoverProps,
  Separator,
  XStack,
  YStack,
} from "tamagui";

import { formatName } from "./ai_doc/accordion";

import { portraits, PortraitInfo } from "@/constants/portrait";
import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";
export function SelectProfile({
  portrait,
  ...props
}: PopoverProps & { portrait: PortraitInfo[] }) {
  const [open, setOpen] = useState<boolean>(false);
  return (
    <Popover
      size="$5"
      allowFlip
      {...props}
      open={open}
      onOpenChange={() => setOpen(!open)}
    >
      <Popover.Trigger asChild>
        <Avatar circular size="$4">
          <Avatar.Fallback backgroundColor="#0B3954" />

          <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width={35} height={35} />
        </Avatar>
      </Popover.Trigger>
      <Adapt platform="touch">
        <Popover.Sheet modal dismissOnSnapToBottom snapPoints={[32]}>
          <Popover.Sheet.Frame padding="$4">
            <Popover.Sheet.ScrollView>
              <Adapt.Contents />
            </Popover.Sheet.ScrollView>
          </Popover.Sheet.Frame>

          <Popover.Sheet.Overlay
            animation="lazy"
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
          />
        </Popover.Sheet>
      </Adapt>
      <Popover.Content
        borderWidth={1}
        borderColor="$borderColor"
        enterStyle={{ y: -10, opacity: 0 }}
        exitStyle={{ y: -10, opacity: 0 }}
        elevate
        animation={[
          "quick",
          {
            opacity: {
              overshootClamping: true,
            },
          },
        ]}
      >
        <Popover.Arrow borderWidth={1} borderColor="$borderColor" />
        <YStack space="$2" paddingBottom="$3" paddingRight="$2">
          {portrait.map((portrait) => (
            <ProfileElement
              key={portrait.id}
              portrait={portrait}
              setModal={() => {
                setOpen(false);
              }}
            />
          ))}
          {/* <Link
            href="/(tabs)/ai_docs/create_profile-1"
            onPress={() => {
              setOpen(false);
            }}
          >
            <XStack
              alignItems="center"
              justifyContent="flex-start"
              space="$5"
              padding="$5"
              paddingLeft="$3"
            >
              <PlusCircle size={24} color="gray" />
              <YStack alignItems="center" justifyContent="center">
                <ButtonText fontSize="$3">添加画像</ButtonText>
              </YStack>
            </XStack>
          </Link> */}
        </YStack>
      </Popover.Content>
    </Popover>
  );
}

function ProfileElement({
  portrait,
  setModal,
}: {
  portrait: PortraitInfo;
  setModal: () => void;
}) {
  const router = useRouter();
  return (
    <YStack space="$2">
      <XStack alignItems="center" justifyContent="space-between" padding="1">
        <XStack space="$3">
          <Avatar circular size="$5">
            <Avatar.Fallback backgroundColor="#0B3954" />
            <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
              {formatName(portrait.name)}
            </H2>
          </Avatar>
          <YStack justifyContent="flex-start" space="2">
            <Label>{portrait.name}</Label>
            <Label theme="alt2">{portrait.description}</Label>
          </YStack>
        </XStack>
        {/* <Link
          href={{
            pathname: "/(tabs)/ai_docs/[id]/",
            params: { id: portrait.id },
          }}
          asChild
        > */}
        <Button
          borderRadius="$10"
          paddingHorizontal="$3"
          paddingVertical="$0"
          onPress={() => {
            setModal();
          }}
        >
          <Paragraph>选择</Paragraph>
        </Button>
        {/* </Link> */}
      </XStack>
      <Separator />
    </YStack>
  );
}
