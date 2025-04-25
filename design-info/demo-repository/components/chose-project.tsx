import {
  ArrowRight,
  CheckCircle,
  PlusCircle,
  ScrollText,
  X,
} from "@tamagui/lucide-icons";
import { themes } from "@tamagui/themes";
import { Link, useRouter } from "expo-router";
import { useState } from "react";
import {
  Button,
  Text,
  ButtonText,
  Input,
  Label,
  Spinner,
  XStack,
  Dialog,
  YStack,
  Adapt,
  Sheet,
  Fieldset,
  TooltipSimple,
  Paragraph,
  Unspaced,
  TextArea,
  useTheme,
} from "tamagui";

import { ApplicationState, DocState } from "@/constants/application";

function ApplicationItem({
  application,
  profileId,
  doc_idx,
}: {
  application: ApplicationState;
  profileId: string;
  doc_idx: number;
}) {
  // console.log(doc_idx)

  return (
    <XStack
      alignItems="center"
      justifyContent="space-between"
      paddingVertical="$3"
      paddingHorizontal="$2"
      width="80%"
      borderWidth={1}
      borderRadius={10}
      borderColor="gray"
    >
      <YStack space="$1">
        <Text>{application.name}</Text>
        <Text color="$gray10">{`已生成文书: ${application.version}`}</Text>
      </YStack>
      <Link
        href={{
          pathname: `/(tabs)/ai_docs/${profileId}/[doc_id]`,
          params: { doc_id: doc_idx },
        }}
        asChild
      >
        <Button
          size="$2"
          pressStyle={{ borderColor: "transparent" }}
          backgroundColor="#FFFFFF" //暂时这样写，后面调主题色
        >
          {application.finished ? (
            <CheckCircle fill="#B66E0D" />
          ) : (
            <ArrowRight />
          )}
        </Button>
      </Link>
    </XStack>
  );
}

function AddDialog() {
  const [open, setOpen] = useState(false);
  const background_color = useTheme().background.val;

  // console.log(`${background_color}`)

  return (
    <Dialog
      modal
      onOpenChange={(open) => {
        setOpen(open);
      }}
    >
      <Dialog.Trigger asChild>
        <Button
          width="100%"
          justifyContent="center"
          gap="$0"
          // backgroundColor= {`${background_color}`}
          backgroundColor="#FFFFFF" //暂时这样写，后面调主题色
        >
          <XStack space="$2">
            <PlusCircle />
            <ButtonText>添加项目</ButtonText>
          </XStack>
        </Button>
      </Dialog.Trigger>

      <Adapt when="sm" platform="touch">
        <Sheet animation="medium" zIndex={200000} modal dismissOnSnapToBottom>
          <Sheet.Frame padding="$4" gap="$4">
            <Adapt.Contents />
          </Sheet.Frame>
          <Sheet.Overlay
            animation="lazy"
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
          />
        </Sheet>
      </Adapt>

      <Dialog.Portal>
        <Dialog.Overlay
          key="overlay"
          animation="quick"
          opacity={0.5}
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
        />

        <Dialog.Content
          bordered
          elevate
          key="content"
          animateOnly={["transform", "opacity"]}
          animation={[
            "quick",
            {
              opacity: {
                overshootClamping: true,
              },
            },
          ]}
          enterStyle={{ x: 0, y: -20, opacity: 0, scale: 0.9 }}
          exitStyle={{ x: 0, y: 10, opacity: 0, scale: 0.95 }}
          gap="$4"
        >
          <Dialog.Title>添加项目</Dialog.Title>
          <Dialog.Description>
            请输入你想申请的学校名称，专业以及补充信息.
          </Dialog.Description>
          <Fieldset gap="$4" horizontal>
            <Label width={160} justifyContent="flex-end" htmlFor="name">
              目标学校
            </Label>
            <Input flex={1} id="schoolName" placeholder="请输入" />
          </Fieldset>
          <Fieldset gap="$4" horizontal>
            <Label width={160} justifyContent="flex-end" htmlFor="name">
              目标专业
            </Label>
            <Input flex={1} id="major" placeholder="请输入" />
            {/* <SelectDemoItem /> */}
          </Fieldset>
          <Fieldset gap="$4" horizontal>
            <TextArea
              flex={1}
              placeholder="输入你想补充的信息（如申请原因，我的优势，职业规划...)"
              height="$10"
            />
            {/* <SelectDemoItem /> */}
          </Fieldset>
          <XStack alignSelf="flex-end" gap="$4">
            <Dialog.Close displayWhenAdapted asChild>
              <Button theme="alt1" aria-label="Close">
                {/* Save changes */}
                保存
              </Button>
            </Dialog.Close>
          </XStack>

          <Unspaced>
            <Dialog.Close asChild>
              <Button
                position="absolute"
                top="$3"
                right="$3"
                size="$2"
                circular
                icon={X}
              />
            </Dialog.Close>
          </Unspaced>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog>
  );
}

export function ChooseApplication({
  applications,
  profileId,
}: {
  applications: ApplicationState[];
  profileId: string;
}) {
  applications.sort((a, b) => {
    return -Number(a.finished) + Number(b.finished);
  });

  // console.log(applications)

  return (
    <YStack alignItems="center" justifyContent="center" width="100%" space="$3">
      {/* {applications.map((application, idx) => { */}
      {applications.slice(0, 3).map((application, idx) => {
        //暂时只呈现前三个
        return (
          <ApplicationItem
            application={application}
            key={idx}
            profileId={profileId}
            doc_idx={application.version}
          />
        );
      })}
      <AddDialog />
    </YStack>
  );
}

export function DocItem({ doc_item }: { doc_item: DocState }) {
  return (
    <XStack
      // alignItems="center"
      // paddingVertical="$2"
      // paddingHorizontal="$2"
      width="100%"
      // borderWidth={1}
      // borderRadius={10}
      // borderColor="gray"
      marginTop="$1"
    >
      <YStack flex={1} paddingHorizontal="$10" marginHorizontal="$2" space="$2">
        <XStack alignItems="center">
          <Text>{doc_item.name}</Text>
          <Paragraph theme="alt2" fontSize={10} paddingHorizontal="$5">
            {doc_item.createAt}
          </Paragraph>
          <Text marginLeft="auto" color="#B66E0E">
            查看
          </Text>

          {/* <Text>-</Text>
          <Text>{doc_item.updateAt}</Text> */}
        </XStack>
      </YStack>

      {/* <Button size="$2" pressStyle={{ borderColor: "transparent" }}>
        <ScrollText />
      </Button> */}
    </XStack>
  );
}
