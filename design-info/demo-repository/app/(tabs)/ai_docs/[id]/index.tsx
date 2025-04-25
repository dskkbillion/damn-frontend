import { LinearGradient } from "@tamagui/linear-gradient";
import {
  ArrowBigLeft,
  ArrowLeft,
  ArrowRight,
  ChevronLeft,
  MoreHorizontal,
  PlusCircle,
  X,
} from "@tamagui/lucide-icons";
import { Link, router, useLocalSearchParams, useRouter } from "expo-router";
import React, { useEffect, useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import Spinner from "react-native-spinkit";
import {
  YStack,
  H2,
  Separator,
  Theme,
  Button,
  Avatar,
  Text,
  XStack,
  ZStack,
  ButtonText,
  Card,
  Label,
  Switch,
  Paragraph,
  Dialog,
  Sheet,
  Adapt,
  useTheme,
  Fieldset,
  Unspaced,
  Input,
  TextArea,
  Circle,
  Image,
  View,
  ScrollView,
} from "tamagui";

import { formatName } from "@/components/ai_doc/accordion";
import { ApplicationState } from "@/constants/application";
import { portraits } from "@/constants/portrait";

const exampleImage = require("@/assets/PS_Example.png");

export default function DocProfileScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{ id: string }>();
  const user = portraits.find((p) => p.id === parseInt(params.id));
  const [isLoading, setIsLoading] = useState(false);
  const [isGeneratingMode, setIsGeneratingMode] = useState<boolean>(true); // 控制是否处于生成模式
  const page_margin = global.screenWidth * 0.075;
  const theme = useTheme();

  return (
    <Theme name="light">
      <SafeAreaView style={{ backgroundColor: "#ffffff" }}>
        <YStack
          flexDirection="column"
          height={global.screenHeight}
          backgroundColor="#ffffff"
        >
          {/* 切换开关：开为棕色，关为灰色 */}
          <XStack
            paddingHorizontal={page_margin}
            alignItems="center"
            paddingVertical="$8"
            justifyContent="space-between"
          >
            <Avatar circular size="$4">
              <Avatar.Fallback backgroundColor="#0B3954" />
              <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
                {user?.name !== undefined && formatName(user?.name)}
              </H2>
            </Avatar>

            <XStack space="$4">
              <Label>生成模式</Label>
              <Switch
                size="$3"
                checked={isGeneratingMode}
                onCheckedChange={(isGeneratingMode) => {
                  setIsGeneratingMode(isGeneratingMode);
                }}
                style={
                  isGeneratingMode
                    ? { backgroundColor: "#b66d0e" }
                    : { backgroundColor: "#A1A1A1" }
                }
              >
                <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
              </Switch>
            </XStack>
          </XStack>

          {/* 标题 */}
          <XStack
            paddingHorizontal={page_margin}
            flexDirection="row"
            alignItems="center"
          >
            <H2>{isGeneratingMode ? "我的画像" : "我的历史"}</H2>

            {/* <Paragraph  marginLeft='auto'>{isGeneratingMode ? '与我相关': ''}</Paragraph>
          {isGeneratingMode? <ArrowRight size={"$1"}/>:""} */}
          </XStack>

          {/* 如果是管理模式则要显示tags */}
          <XStack marginLeft="$8" paddingHorizontal={page_margin}>
            <Paragraph numberOfLines={1} space="$2" theme="alt2">
              <Paragraph>{"# " + user?.profile.university}</Paragraph>
              <Paragraph>{"# 绩点" + user?.profile.gpa}</Paragraph>
              {user?.profile.interships.map((item, index) => (
                <Paragraph key={index}>{"# " + item.company}</Paragraph>
              ))}
            </Paragraph>
          </XStack>

          <XStack marginTop="$5">
            {isGeneratingMode ? (
              <RenderGeneratingMode user={user} />
            ) : (
              <RenderManagementMode user={user} />
            )}
          </XStack>
        </YStack>
      </SafeAreaView>
    </Theme>
  );
}

// ---------------------------生成模式渲染的卡片内内容------------------------
const RenderGeneratingMode = ({ user }) => {
  // 添加空值检查
  if (!user) {
    return null; // 或者返回一个加载状态
  }

  const applications = user.applications || []; // 提供默认空数组
  const [isaddProgram, setIsAddProgram] = useState(false);
  const [targetApplication, setTargetApplication] =
    useState<ApplicationState>();
  const [isLoading, setIsLoading] = useState(false);
  const [isGenerateComplete, setIsGenerateComplete] = useState(false);
  const name: string = user?.name;
  const page_margin = global.screenWidth * 0.075;
  const theme = useTheme();

  const addApplication = (newApplication: ApplicationState) => {
    setTargetApplication(newApplication);
    setIsAddProgram(true);
  };

  useEffect(() => {
    // 在3秒后暂停加载，生成内容
    if (isLoading) {
      const timeoutId = setTimeout(() => {
        setIsLoading(false);
        setIsGenerateComplete(true);
      }, 3000);
      // 清除定时器
      return () => clearTimeout(timeoutId);
    }
  }, [isLoading]); // isLoading变化时执行

  return (
    <Theme name="light">
      <YStack paddingHorizontal={page_margin}>
        <Card
          width={global.screenWidth * 0.85}
          height={global.screenHeight * 0.45}
          unstyled
        >
          <Card.Header>
            {/* -----------未添加项目----------- */}
            {!isaddProgram && renderApplicationItem(applications)}
            {!isaddProgram && (
              <Paragraph
                paddingVertical="$10"
                alignSelf="center"
                onPress={() =>
                  router.push(`/(tabs)/ai_docs/${user.id}/[match_id]`)
                }
              >
                跳转
              </Paragraph>
            )}
            {/*----------- 已添加项目------------ */}
            {isaddProgram && (
              <YStack flexDirection="column" alignItems="center">
                <XStack
                  flexDirection="row"
                  alignItems="center"
                  justifyContent="center"
                  space="$2"
                >
                  <H2 alignSelf="center" color="#ffffff">
                    {targetApplication?.application_university}
                  </H2>
                  <H2 color="#ffffff">
                    {targetApplication?.application_majority}
                  </H2>
                </XStack>
                <Paragraph color="#ffffff" numberOfLines={2}>
                  {targetApplication?.supplementary_info}
                </Paragraph>
              </YStack>
            )}
          </Card.Header>

          {/* 生成加载条 */}
          <XStack
            position="absolute"
            bottom={global.screenHeight * 0.15}
            left={global.screenWidth * 0.3}
            zIndex={999}
          >
            {/* type: Bouce/Wave/ */}
            {isLoading && (
              <Spinner isVisible size={100} type="Wave" color="#ffffff" />
            )}
          </XStack>

          {isGenerateComplete && (
            <YStack flex={1} alignItems="center">
              <XStack padding="$2" />

              <Image
                source={exampleImage}
                style={{
                  height: "70%",
                  width: "90%",
                  borderRadius: 10,
                }}
              />

              <XStack space>
                {/* <Button height={30} backgroundColor={"#b66d0e"}>
              <ButtonText fontSize="$3">发送至邮箱</ButtonText>
            </Button> */}
              </XStack>
            </YStack>
          )}

          <Card.Background zIndex={-1}>
            <LinearGradient
              width={global.screenWidth * 0.85}
              height={global.screenHeight * 0.45}
              borderRadius="$4"
              colors={["$background", "$black"]}
              start={[1, 1]}
              end={[0, 0]}
            />
          </Card.Background>
        </Card>

        {!isaddProgram && <AddDialog addApplication={addApplication} />}

        {/* 生成文书按钮 */}
        {isaddProgram && (
          <Button
            width={global.screenWidth * 0.6}
            backgroundColor={"#b66d0e"}
            marginTop="$4"
            alignSelf="center"
            onPress={() => {
              setIsLoading(true);
              setIsGenerateComplete(false);
            }}
          >
            <ButtonText color="#ffffff">
              {isGenerateComplete ? "发送至邮箱" : "生成文书"}
            </ButtonText>
          </Button>
        )}
      </YStack>
    </Theme>
  );
};
// ---------------------------管理模式渲染-----------------------------

const RenderManagementMode = ({ user }) => {
  const applications = user?.applications;
  const page_margin = global.screenWidth * 0.075;
  const theme = useTheme();
  // console.log(global.screenWidth)

  return (
    <YStack>
      <ScrollView
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
      >
        <XStack flexDirection="row">
          {applications.map((item, index) => (
            <Card
              key={index}
              marginHorizontal={page_margin}
              width={global.screenWidth * 0.85}
              height={global.screenHeight * 0.45}
            >
              <Card.Header>
                <YStack>
                  {/* 申请学校 & 专业 */}
                  <YStack paddingVertical="$2" marginBottom="$2">
                    <Paragraph color="#ffffff" fontSize={15}>
                      {item.application_university}
                    </Paragraph>
                    <Paragraph color="#ffffff" fontSize={15}>
                      {item.application_majority}专业
                    </Paragraph>
                  </YStack>

                  {/* 历史生成文书 */}
                  <Image
                    source={exampleImage}
                    style={{
                      height: "70%",
                      width: "90%",
                      borderRadius: 10,
                      flexDirection: "row",
                      alignSelf: "center",
                    }}
                  />

                  {/* 补充的信息 */}
                  <Paragraph
                    marginHorizontal={global.screenWidth * 0.05}
                    color="#ffffff"
                    numberOfLines={1}
                  >
                    {item.supplementary_info}
                  </Paragraph>

                  <Card.Footer>{/* 生成时间 */}</Card.Footer>
                </YStack>
              </Card.Header>

              <Card.Background key={index}>
                <LinearGradient
                  width={global.screenWidth * 0.85}
                  height={global.screenHeight * 0.45}
                  borderRadius="$4"
                  colors={["$background", "$black"]}
                  start={[1, 1]}
                  end={[0, 0]}
                />
              </Card.Background>
            </Card>
          ))}
        </XStack>
      </ScrollView>

      <XStack
        flexDirection="row"
        alignItems="center"
        marginHorizontal={page_margin}
        marginTop="$3"
        space="$2"
      >
        <Button backgroundColor={"#F2F2F2"}>
          <ButtonText>文书</ButtonText>
        </Button>
        <Button backgroundColor={"#F2F2F2"}>
          <ButtonText>推荐信</ButtonText>
        </Button>
        <Input
          size="$3"
          style={{ width: "50%", height: "100%", textAlign: "center" }}
          placeholder="搜索..."
          backgroundColor={"#F2F2F2"}
          // borderColor={"#F2F2F2"}
        />
      </XStack>
    </YStack>
  );
};

// 认证： 一行最多渲染三个，最多渲染两行
function renderApplicationItem(applications) {
  // console.log(applications.length)

  const items: JSX.Element[] = [];
  const maxRows = 2;
  const maxItemsPerRow = 3;

  for (let rowIndex = 0; rowIndex < maxRows; rowIndex++) {
    const startIdx = rowIndex * maxItemsPerRow;
    const endIdx = startIdx + maxItemsPerRow;
    const chunk = applications.slice(startIdx, endIdx);
    const chunkElements = chunk.map((application, index) => (
      <XStack key={index} flexDirection="row" alignItems="center">
        <Button
          marginRight="$2"
          marginVertical="$2"
          backgroundColor="rgba(255, 255, 255, 0.05)" /* 白色背景，透明度为0.5 */
        >
          <ButtonText color="#ffffff">
            {application.application_university}{" "}
            {application.application_majority}{" "}
          </ButtonText>
        </Button>
      </XStack>
    ));
    items.push(
      <XStack
        key={rowIndex}
        style={{ flexDirection: "column", alignItems: "center" }}
      >
        {chunkElements}
      </XStack>,
    );
    // 如果是最后一行，且有查看更多的元素，将其放在第二列末尾
    if (
      rowIndex === maxRows - 1 &&
      applications.length > maxRows * maxItemsPerRow
    ) {
      items.push(
        <YStack flexDirection="column" alignItems="center">
          <MoreHorizontal size="$1" color="#ffffff" />
        </YStack>,
      );
    }
    if (endIdx >= applications.length) {
      break; // Stop if we have reached the end of the array
    }
  }
  return items;
}

// 添加项目组件
export function AddDialog({
  addApplication,
}: {
  addApplication: (newApplication: ApplicationState) => void;
}) {
  const [open, setOpen] = useState(false);
  const [targetUniversity, setTargetUniversity] = useState<string>("");
  const [targetMajority, setTargetMajority] = useState<string>("");
  const [supplement, setSupplement] = useState<string>("");

  return (
    <Dialog
      modal
      onOpenChange={(open) => {
        setOpen(open);
      }}
    >
      <Dialog.Trigger asChild>
        <Button
          width={global.screenWidth * 0.6}
          backgroundColor="#F2F2F2"
          marginTop="$4"
          alignSelf="center"
          justifyContent="center"
          gap="$0"
          // backgroundColor= {`${background_color}`}
          color="#ffffff"
          pressStyle={{
            backgroundColor: "transparent",
            borderColor: "transparent",
          }}
        >
          <XStack space="$2">
            {/* <PlusCircle color={'#ffffff'} /> */}
            <ButtonText color="black">添加项目</ButtonText>
          </XStack>
        </Button>
      </Dialog.Trigger>

      <Adapt platform="touch">
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
            <Input
              flex={1}
              id="schoolName"
              placeholder="请输入"
              value={targetUniversity}
              onChangeText={(t) => {
                setTargetUniversity(t);
              }}
            />
          </Fieldset>
          <Fieldset gap="$4" horizontal>
            <Label width={160} justifyContent="flex-end" htmlFor="name">
              目标专业
            </Label>
            <Input
              flex={1}
              id="major"
              placeholder="请输入"
              value={targetMajority}
              onChangeText={(t) => {
                setTargetMajority(t);
              }}
            />
            {/* <SelectDemoItem /> */}
          </Fieldset>
          <Fieldset gap="$4" horizontal>
            <Input
              flex={1}
              placeholder="输入你想补充的信息（如申请原因，我的优势，职业规划...)"
              height="$10"
              value={supplement}
              onChangeText={(t) => {
                setSupplement(t);
              }}
            />
            {/* <SelectDemoItem /> */}
          </Fieldset>
          <XStack alignSelf="flex-end" gap="$4">
            <Dialog.Close displayWhenAdapted asChild>
              <Button
                theme="alt1"
                aria-label="Close"
                onPress={() => {
                  addApplication({
                    application_university: targetUniversity,
                    application_majority: targetMajority,
                    officialProgramName: "",
                    generating_num: 0,
                    supplementary_info: supplement,
                    finished: false,
                  });
                }}
              >
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
