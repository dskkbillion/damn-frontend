import { FlashList } from "@shopify/flash-list";
import { ChevronLeft } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo, useCallback, useEffect, useMemo, useState } from "react";
import { SafeAreaView, TouchableWithoutFeedback } from "react-native";
import FastImage from "react-native-fast-image";
import Carousel from "react-native-reanimated-carousel";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import {
  Avatar,
  Button,
  ButtonText,
  Circle,
  H1,
  Paragraph,
  Portal,
  View,
  XStack,
  YStack,
} from "tamagui";

import { ReviewBottomSheet, CommentItem } from "./story_list";

import { getFilePath } from "@/components/utils/filesystem";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";
import { ImagePreviewComp } from "@/components/styled/preview_image";

/**
/**
 * @description 用于展示故事详情
 * @param {string} story_id 故事id
 * @param {string} type
 */
export const StoryDetailComponent = memo(
  ({ story_id, type }: { story_id: string; type: string }) => {
    const dispatch = useDispatch<AppDispatch>();
    const story = useSelector((state: RootState) => state.item.storyDetail);
    const PAGE_HEIGHT = global.screenHeight;
    const PAGE_WIDTH = global.screenWidth;
    const [activeIndex, setActiveIndex] = useState(0);

    const [showComment, setShowComment] = useState(false);

    const comments = useSelector((state: RootState) => state.item.comments);
    const comment_added = useSelector(
      (state: RootState) => state.item.comment_added
    );
    const loading = useSelector((state: RootState) => state.item.loading);

    const [isExpanded, setIsExpanded] = useState(false);
    const [showExpandButton, setShowExpandButton] = useState(false);
    const [modal, setModal] = useState(false);

    const [like, setLike] = useState(false);
    const [likeNum, setLikeNum] = useState(0);

    const imageUrls = useMemo(() => {
      if (!story?.images) return [];
      return story?.images.map((image) => {
        return { imgUrl: getFilePath(image) };
      });
    }, [story?.images]);

    const fetchComments = useCallback(() => {
      dispatch(
        slices.item.actions.fetchComments({ invitationId: Number(story_id) })
      );
    }, [story_id]);

    const handleRefresh = useCallback(() => {
      fetchComments();
    }, [comment_added]);

    // 检查文本是否超过60%的宽度
    const handleTextLayout = (event) => {
      const textWidth = event.nativeEvent.layout.width;
      if (textWidth > PAGE_WIDTH * 0.6) {
        setShowExpandButton(true);
      } else {
        setShowExpandButton(false);
      }
    };

    const handleLoadComments = useCallback(() => {
      setShowComment(true);
      fetchComments();
    }, [fetchComments]);

    const handlePressLike = async () => {
      try {
        if (like) {
          const res = await dispatch(
            slices.item.actions.removeLike({ ids: [Number(story_id)] })
          );
          if (isAxiosSuccess(res.type)) {
            if (type === "user") {
              // 用户点赞/用户发布的故事
              await dispatch(slices.user.actions.setStoryChanged());
            } else {
              // 其他人的故事
              await dispatch(slices.item.actions.setStoryChanged());
            }
            setLikeNum((prev) => prev - 1);
          }
        } else {
          const res = await dispatch(
            slices.item.actions.likeStory({ id: Number(story_id) })
          );
          if (isAxiosSuccess(res.type)) {
            if (type === "user") {
              await dispatch(slices.user.actions.setStoryChanged());
            } else {
              await dispatch(slices.item.actions.setStoryChanged());
            }
            setLikeNum((prev) => prev + 1);
          }
        }
        setLike((prev) => !prev);
      } catch (error) {
        console.error("Like operation failed:", error);
      }
    };

    const sendComment = async ({ text, is_anonymity }) => {
      const params = {
        content: text,
        invitationId: story?.id,
        type: is_anonymity ? "publicity" : "anonymity",
      };
      try {
        await dispatch(slices.item.actions.addComment(params));
        handleRefresh();
      } catch (e) {
        console.log(e);
      }
    };

    const fetchStoryDetail = useCallback(async () => {
      await dispatch(
        slices.item.actions.fetchStoryDetail({ id: Number(story_id) })
      );
    }, []);

    useEffect(() => {
      fetchStoryDetail();
    }, [fetchStoryDetail]);

    useEffect(() => {
      if (story) {
        setLike(!!story.likeAttention);
        setLikeNum(story.like || 0);
      }
    }, [story]);

    return (
      <SafeAreaView style={{ flex: 1 }}>
        <YStack marginVertical="$3" flex={1}>
          {/* avatar && nickname  */}

          {modal && (
            <Portal>
              <ImagePreviewComp
                images={imageUrls}
                previewIndex={activeIndex}
                modal={modal}
                setModal={setModal}
              />
            </Portal>
          )}

          <Button
            flexDirection="row"
            paddingHorizontal="$3"
            paddingVertical="$1"
            alignItems="center"
            gap="$2"
            onPress={() =>
              router.push({
                pathname: "/(outer)/home/user_profile",
                params: { memberId: story?.memberId },
              })
            }
            unstyled
          >
            <Avatar size={50} backgroundColor="$lightGray" circular>
              <Avatar.Image src={story?.member?.avatar} />
            </Avatar>
            <Paragraph>{story?.member?.nickName}</Paragraph>
            <Paragraph color="$lightGray" marginLeft="auto">
              {story?.createTime}
            </Paragraph>
          </Button>
          <Carousel
            style={{
              width: "100%",
              // height: PAGE_HEIGHT * 0.55,
            }}
            width={PAGE_WIDTH}
            pagingEnabled
            onSnapToItem={(index) => setActiveIndex(index)}
            data={story?.images}
            renderItem={({ item, index }: { item: string; index }) => {
              return (
                <TouchableWithoutFeedback onPress={() => setModal(true)}>
                  <View>
                    <FastImage
                      key={index}
                      source={{
                        uri: getFilePath(item),
                      }}
                      style={{ width: "100%", height: "100%" }}
                      resizeMode="cover"
                    />
                  </View>
                </TouchableWithoutFeedback>
              );
            }}
          />

          <XStack
            paddingVertical="$3"
            paddingHorizontal="$3"
            alignItems="center"
            height="auto"
          >
            <XStack space="$2" width="20%" alignSelf="flex-start" height="auto">
              <TouchableWithoutFeedback onPress={handlePressLike}>
                <FontAwesomeIcon
                  name={like ? "heart" : "heart-o"}
                  size={25}
                  color={like ? "#FF2533" : "#000"}
                />
              </TouchableWithoutFeedback>
              <TouchableWithoutFeedback onPress={() => handleLoadComments()}>
                <FontAwesomeIcon name="comment-o" size={25} color="#000" />
              </TouchableWithoutFeedback>
            </XStack>
            <XStack width="60%" justifyContent="center">
              {story?.images &&
                story?.images.length > 0 &&
                story?.images.map((_, index) => (
                  <Circle
                    key={index}
                    size={10}
                    marginRight="$3"
                    backgroundColor={
                      index === activeIndex ? "$brown" : "$darkGray"
                    }
                  />
                ))}
            </XStack>
            <XStack width="20%" justifyContent="flex-end">
              <Paragraph fontSize={16}>{likeNum} 次赞</Paragraph>
            </XStack>
          </XStack>

          <XStack
            paddingHorizontal="$3"
            boxSizing="border-box"
            alignItems="flex-start"
            alignSelf="flex-start"
            onLayout={handleTextLayout}
            maxWidth={PAGE_WIDTH * 0.7}
            space="$3"
          >
            <Paragraph numberOfLines={isExpanded ? undefined : 1}>
              <Paragraph fontWeight="600">{story?.member?.nickName}</Paragraph>
              <Paragraph> {story?.content}</Paragraph>
            </Paragraph>

            {showExpandButton && (
              <Button onPress={() => setIsExpanded(!isExpanded)} unstyled>
                <ButtonText color="$lightGray">展开</ButtonText>
              </Button>
            )}
          </XStack>

          <XStack paddingHorizontal="$3">
            <Button onPress={() => handleLoadComments()} unstyled>
              <ButtonText color="$lightGray">
                共 {story?.commentCount} 条评论
              </ButtonText>
            </Button>
          </XStack>
          <ReviewBottomSheet
            isOpen={showComment}
            onClose={setShowComment}
            snapPoints={[40]}
            sendComment={sendComment}
          >
            <FlashList
              data={comments}
              keyExtractor={(item: any) => item.id.toString()}
              renderItem={({ item }) => (
                <YStack marginBottom="$3">
                  <CommentItem item={item} />
                </YStack>
              )}
              refreshing={!!loading}
              onRefresh={() => handleRefresh()}
              ListFooterComponent={() => (
                <Paragraph
                  alignSelf="center"
                  color="$lightGray"
                  marginTop="auto"
                >
                  没有更多了
                </Paragraph>
              )}
              contentContainerStyle={{ paddingBottom: 100 }}
              estimatedItemSize={100}
              showsVerticalScrollIndicator={false}
            />
          </ReviewBottomSheet>
        </YStack>
      </SafeAreaView>
    );
  }
);

export const StoryHeader = memo(
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
