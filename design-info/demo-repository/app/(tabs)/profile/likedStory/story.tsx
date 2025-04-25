import { Stack, useLocalSearchParams } from "expo-router";
import React, { memo, useState } from "react";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { Button, Paragraph, styled, XStack, YStack } from "tamagui";

import BlankBottomSheet from "@/components/styled/bottomsheet";
import { StoryDetailComponent, StoryHeader } from "@/components/homepage/story";

const StyledButton = styled(Button, {
  flexDirection: "column",
  alignItems: "center",
  justifyContent: "center",
  borderWidth: "0",
  height: 50,
  width: 50,
  padding: 10,
});

const LikedStory = memo(() => {
  const story_id = useLocalSearchParams().id as string;
  const [popup, setPopup] = useState(false);
  return (
    <YStack flex={1}>
      <Stack.Screen
        options={{
          header: () => <StoryHeader popup={popup} setPopup={setPopup} />,
        }}
      />
      {/* 用户点赞的故事 */}
      <StoryDetailComponent story_id={story_id} type="user" />

      {/* 注释掉分享底部弹窗 */}
      {/* <BlankBottomSheet isOpen={popup} onClose={setPopup}>
        <YStack flex={1}>
          <Paragraph size="$3" alignSelf="center">
            分享
          </Paragraph>
          <XStack marginTop="10%" gap="$3">
            <StyledButton>
              <AntDesignIcon name="wechat" size={25} color="#00E16F" />
              <Paragraph color="$darkGray">微信</Paragraph>
            </StyledButton>
          </XStack>
        </YStack>
      </BlankBottomSheet> */}
    </YStack>
  );
});

export default LikedStory;
