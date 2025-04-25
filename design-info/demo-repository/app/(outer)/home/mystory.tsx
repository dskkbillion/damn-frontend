// import { useLocalSearchParams } from "expo-router";

// import { StoryListComponent } from "@/components/homepage/story_list";

// export default function MyStory() {
//   const member_id = useLocalSearchParams()?.member_id;
//   return (
//     <StoryListComponent
//       pageSize="wh"
//       role="others"
//       member_id={Number(member_id)}
//     />
//   );
// }

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

import BlankBottomSheet from "@/components/styled/bottomsheet";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { StoryDetailComponent } from "@/components/homepage/story";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, slices } from "@/src/store";

const PostStoryPage = memo(() => {
  const [popup, setPopup] = useState(false);
  const story_id = useLocalSearchParams().id as string;
  const dispatch = useDispatch<AppDispatch>();

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
      <StoryDetailComponent story_id={story_id} type="others" />
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
          <H1 fontWeight="500" fontSize="$5">
            我的故事
          </H1>
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
          {}
        </Button>
      </XStack>
    );
  }
);
