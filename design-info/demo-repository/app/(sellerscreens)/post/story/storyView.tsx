import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, Stack, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useState } from "react";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { useDispatch } from "react-redux";
import {
  Button,
  H1,
  Paragraph,
  Separator,
  styled,
  XStack,
  YStack,
} from "tamagui";

import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { StoryDetailComponent } from "@/components/homepage/story";
import BlankBottomSheet from "@/components/styled/bottomsheet";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, slices } from "@/src/store";
import React from "react";

const PostStoryPage = memo(() => {
  const [popup, setPopup] = useState(false);
  const story_id = useLocalSearchParams().id as string;
  const dispatch = useDispatch<AppDispatch>();

  const deleteStory = useCallback(async () => {
    setPopup(false);
    const res = await dispatch(
      slices.item.actions.deleteStory({ ids: [Number(story_id)] })
    );
    if (isAxiosSuccess(res.type)) {
      alert("删除故事成功");
      dispatch(slices.user.actions.setStoryChanged());
      router.back();
    } else {
      alert("删除故事失败");
    }
  }, [story_id]);
  const StyledButton = styled(Button, {
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: "0",
    height: 50,
    width: 50,
    padding: 10,
  });

  return (
    <>
      <Stack.Screen
        options={{
          header: () => <StoryHeader popup={popup} setPopup={setPopup} />,
        }}
      />
      {/* 用户发布的故事 */}
      <StoryDetailComponent story_id={story_id} type="user" />

      <BlankBottomSheet isOpen={popup} onClose={setPopup}>
        <YStack flex={1}>
          {/* 注释掉分享标题和微信分享按钮 */}
          {/* <Paragraph size="$3" alignSelf="center">
            分享
          </Paragraph>
          <XStack marginTop="10%" gap="$3">
            <StyledButton>
              <AntDesignIcon name="wechat" size={25} color="#00E16F" />
              <Paragraph color="$darkGray">微信</Paragraph>
            </StyledButton>
          </XStack> */}

          <Separator marginVertical="$3" />
          <XStack marginTop="$3" gap="$3">
            <AlertDialogComponent
              title="删除故事"
              description="是否确认删除？"
              handleConfirm={() => deleteStory()}
            >
              <StyledButton>
                <AntDesignIcon name="delete" size={25} />
                <Paragraph color="$darkGray">删除</Paragraph>
              </StyledButton>
            </AlertDialogComponent>

            <StyledButton
              onPress={() => {
                setPopup(false);
                router.push({
                  pathname: "/(sellerscreens)/post/story/storyEdit",
                  params: { status: "update" },
                });
              }}
            >
              <AntDesignIcon name="edit" size={25} />
              <Paragraph color="$darkGray">编辑</Paragraph>
            </StyledButton>
          </XStack>
        </YStack>
      </BlankBottomSheet>
    </>
  );
});

export default PostStoryPage;

const StoryHeader = memo(
  ({ popup, setPopup }: { popup: boolean; setPopup: any }) => {
    return (
      <XStack
        flexDirection="row"
        alignItems="center"
        justifyContent="space-evenly"
        paddingTop="10%"
        backgroundColor="$background"
      >
        <XStack width="30%" justifyContent="flex-start">
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
        </XStack>
        <XStack width="40%" justifyContent="center">
          <H1 fontSize="$5">故事详情</H1>
        </XStack>
        <Button
          width="30%"
          unstyled
          flexDirection="column"
          justifyContent="center"
          paddingRight="$6"
          alignItems="flex-end"
          paddingBottom="$2"
          onPress={() => setPopup(!popup)}
        >
          <XStack gap="$1" alignItems="center">
            {Array.from({ length: 3 }).map((_, index) => (
              <Paragraph size="$8" key={index} fontWeight="600">
                .
              </Paragraph>
            ))}
          </XStack>
        </Button>
      </XStack>
    );
  }
);
