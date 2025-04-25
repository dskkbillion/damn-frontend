import { FlashList } from "@shopify/flash-list";
import { LinearGradient } from "@tamagui/linear-gradient";
import { ChevronLeft } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo, useCallback, useEffect } from "react";
import { TouchableWithoutFeedback } from "react-native";
import FastImage from "react-native-fast-image";
import Carousel from "react-native-reanimated-carousel";
import { useDispatch, useSelector } from "react-redux";
import { Avatar, Label, Paragraph, XStack, YStack } from "tamagui";

import { AppDispatch, RootState, slices } from "@/src/store";

const StoryList = memo(() => {
  const dispatch = useDispatch<AppDispatch>();

  const userProfile = useSelector((state: RootState) => state.user.data);
  const storyList = useSelector(
    (state: RootState) => state.user.likedStoryList
  );
  const changed = useSelector((state: RootState) => state.user.storyChanged);
  const fetchLikedStores = useCallback(async () => {
    await dispatch(slices.user.actions.fetchLikedStoryList());
  }, [userProfile?.id]);

  const handleRefresh = useCallback(() => {
    dispatch(slices.user.actions.resetLikedStoryList());
    fetchLikedStores();
  }, [fetchLikedStores]);

  useEffect(() => {
    handleRefresh();
  }, [fetchLikedStores, changed]);

  return (
    <YStack flex={1}>
      <GradientImage userInfo={userProfile} />
      <XStack marginTop="$3" />
      <FlashList
        data={storyList}
        keyExtractor={(item: any) => item.id.toString()}
        renderItem={({ item }) => (
          <StoryItem item={item} pageSize="sm" role="user" />
        )}
        onEndReachedThreshold={0.1}
        estimatedItemSize={100}
        contentContainerStyle={{ paddingBottom: 200 }}
        ListFooterComponent={() => (
          <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
            没有更多了
          </Paragraph>
        )}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
});

export default StoryList;

const GradientImage = ({ userInfo }) => {
  return (
    <YStack>
      <LinearGradient
        colors={["#fff", "#000"]}
        zIndex={1}
        height={global.screenHeight * 0.25}
        width="100%"
        position="absolute"
        top={0}
        left={0}
      />

      <TouchableWithoutFeedback
        onPress={() => {
          router.back();
        }}
      >
        <XStack width="30%" height={30} zIndex={3} marginTop="14%">
          <ChevronLeft size={30} color="#ffffff" style={{ zIndex: 3 }} />
        </XStack>
      </TouchableWithoutFeedback>
      <Paragraph
        fontSize="$8"
        alignSelf="center"
        color="#fff"
        fontWeight="500"
        zIndex={999}
        paddingTop="20%"
      >
        我的点赞
      </Paragraph>
      <Label
        color="#ffffff"
        alignSelf="center"
        zIndex={3}
        alignItems="center"
        unstyled
      >
        @ {userInfo?.nickName}
      </Label>
    </YStack>
  );
};

const StoryItem = memo(
  ({ item }: { item: any; pageSize: string; role: string }) => {
    const PAGE_HEIGHT = global.screenHeight;
    const PAGE_WIDTH = global.screenWidth;
    const images = item?.invitation?.images;
    const story_id = item?.invitation?.id;

    const handleStoryPress = useCallback(() => {
      router.push({
        pathname: "/(tabs)/profile/likedStory/story",
        params: { id: story_id },
      });
    }, [story_id]);

    return (
      <TouchableWithoutFeedback onPress={handleStoryPress}>
        <YStack marginBottom="$3">
          {/* avatar && nickname */}
          <XStack
            paddingHorizontal="$3"
            paddingVertical="$1"
            alignItems="center"
          >
            <Avatar size={50} backgroundColor="$lightGray" circular>
              <Avatar.Image src={item?.avatar} />
            </Avatar>
            <Paragraph>{item?.memberName}</Paragraph>
            <Paragraph color="$lightGray" marginLeft="auto">
              {item?.createTime}
            </Paragraph>
          </XStack>

          <Carousel
            style={{
              width: "100%",
              height: PAGE_HEIGHT * 0.3,
            }}
            width={PAGE_WIDTH}
            pagingEnabled
            data={images}
            renderItem={({ item, index }: { item: string; index }) => (
              <FastImage
                key={index}
                source={{
                  uri: item,
                }}
                style={{ width: "100%", height: "100%" }}
                resizeMode="cover"
              />
            )}
          />
        </YStack>
      </TouchableWithoutFeedback>
    );
  }
);
