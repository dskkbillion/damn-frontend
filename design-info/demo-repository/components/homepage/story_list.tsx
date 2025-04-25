import { FlashList } from "@shopify/flash-list";
import { X } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import {
  KeyboardAvoidingView,
  Platform,
  TouchableWithoutFeedback,
  View,
} from "react-native";
import FastImage from "react-native-fast-image";
import Carousel from "react-native-reanimated-carousel";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  Avatar,
  ButtonText,
  Circle,
  Label,
  Paragraph,
  PortalProvider,
  Sheet,
  Switch,
  TextArea,
  XStack,
  YStack,
} from "tamagui";

import { AppDispatch, RootState, slices } from "@/src/store";
import { useGlobalContext } from "../system/globalContext";

/**
 * @description 用于展示故事列表（我的故事、卖家故事）
 * @description 点赞的故事详情、发布的故事详情
 * @param pageSize 页面大小
 * @param role 角色
 * @param member_id 用户ID
 */

export const StoryListComponent = memo(
  ({
    pageSize = "sm",
    role = "user",
    member_id,
  }: {
    pageSize: "sm" | "wh";
    role: "user" | "others";
    member_id: number;
  }) => {
    const dispatch = useDispatch<AppDispatch>();
    const stories = useSelector((state: RootState) =>
      role === "user" ? state.user.stories : state.item.open_stories
    );
    const [loading, setLoading] = useState(false);

    const changed = useSelector((state: RootState) =>
      role === "user" ? state.user.storyChanged : state.item.storyChanged
    );

    // console.log("changed", changed);

    const fetchUserStores = useCallback(async () => {
      // 如果角色是user，则获取我的故事，存储到user的stories中
      setLoading(true);
      if (role === "user") {
        await dispatch(
          slices.user.actions.fetchUserStores({
            memberId: Number(member_id),
          })
        );
      } else if (role === "others") {
        // 如果角色是others，则获取卖家故事，存储到item的open_stories中
        await dispatch(
          slices.item.actions.fetchUserStores({
            memberId: Number(member_id),
          })
        );
      }
      setLoading(false);
    }, [member_id]);

    const handleRefresh = useCallback(() => {
      if (role === "user") {
        dispatch(slices.user.actions.resetUserStories());
      } else {
        dispatch(slices.item.actions.resetUserStories());
      }
      fetchUserStores();
    }, [fetchUserStores]);

    useEffect(() => {
      handleRefresh();
    }, [fetchUserStores, changed]);

    return (
      <FlashList
        data={stories}
        keyExtractor={(item: any) => item.id.toString()}
        renderItem={({ item }) => (
          <StoryItem item={item} pageSize={pageSize} role={role} />
        )}
        refreshing={loading}
        onRefresh={() => handleRefresh()}
        onEndReachedThreshold={0.1}
        estimatedItemSize={100}
        contentContainerStyle={{ paddingBottom: 200, paddingTop: 30 }}
        ListFooterComponent={() => (
          <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
            没有更多了
          </Paragraph>
        )}
      />
    );
  }
);

export const StoryItem = memo(
  ({
    item,
    pageSize,
    role = "user",
  }: {
    item: any;
    pageSize: string;
    role: "user" | "others";
  }) => {
    const dispatch = useDispatch<AppDispatch>();
    const PAGE_HEIGHT = global.screenHeight;
    const PAGE_WIDTH = global.screenWidth;
    const images = item?.images;
    const [activeIndex, setActiveIndex] = useState(0);
    const [like, setLike] = useState(item?.likeAttention);
    const [likeNum, setLikeNum] = useState(item?.like);
    const [showComment, setShowComment] = useState(false);

    const comments = useSelector((state: RootState) => state.item.comments);
    const comment_added = useSelector(
      (state: RootState) => state.item.comment_added
    );
    const loading = useSelector((state: RootState) => state.item.loading);

    const [isExpanded, setIsExpanded] = useState(false);
    const [showExpandButton, setShowExpandButton] = useState(false);

    // console.log("comment_added", comment_added);
    const fetchComments = useCallback(() => {
      dispatch(slices.item.actions.fetchComments({ invitationId: item.id }));
    }, [item]);

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

    const handlePressLike = () => {
      if (like) {
        dispatch(slices.item.actions.removeLike({ ids: [item.memberId] }));
        setLikeNum(likeNum - 1);
      } else {
        dispatch(slices.item.actions.likeStory({ id: item.memberId }));
        setLikeNum(likeNum + 1);
      }
      setLike(!like);
    };

    const sendComment = async ({ text, is_anonymity }) => {
      const params = {
        content: text,
        invitationId: item?.id,
        type: is_anonymity ? "anonymity" : "publicity",
      };
      try {
        await dispatch(slices.item.actions.addComment(params));
        handleRefresh();
      } catch (e) {
        console.log(e);
      }
    };

    const goToDetailPage = () => {
      if (role === "others") {
        router.push({
          pathname: "/(outer)/home/mystory",
          params: { id: item?.id },
        });
      } else {
        router.push({
          pathname: "/(sellerscreens)/post/story/storyView",
          params: { id: item?.id },
        });
      }
    };

    return (
      <YStack marginBottom="$3">
        {/* avatar && nickname  */}
        <TouchableWithoutFeedback onPress={() => goToDetailPage()}>
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
        </TouchableWithoutFeedback>
        <Carousel
          style={{
            width: "100%",
            height: pageSize === "sm" ? PAGE_HEIGHT * 0.3 : PAGE_HEIGHT * 0.55,
          }}
          width={PAGE_WIDTH}
          pagingEnabled
          onSnapToItem={(index) => setActiveIndex(index)}
          data={images}
          renderItem={({ item, index }: { item: string; index }) => {
            return (
              <TouchableWithoutFeedback onPress={() => goToDetailPage()}>
                <View>
                  <FastImage
                    key={index}
                    source={{
                      uri: item,
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
          flex={1}
          paddingVertical="$3"
          paddingHorizontal="$3"
          alignItems="center"
        >
          <XStack space="$2" width="20%" alignSelf="flex-start">
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
            {/* 注释掉分享图标 */}
            {/* <FontAwesomeIcon name="share" size={25} color="#000" /> */}
          </XStack>
          <XStack width="60%" justifyContent="center">
            {images &&
              images !== undefined &&
              images.length > 0 &&
              images.map((_, index) => (
                <Circle
                  key={index}
                  size={10}
                  marginRight="$3"
                  backgroundColor={index === activeIndex ? "$brown" : "#EDEDED"}
                />
              ))}
          </XStack>
          <XStack width="20%" justifyContent="flex-end">
            <Paragraph fontSize={16}>{likeNum} 次赞</Paragraph>
          </XStack>
        </XStack>

        <XStack
          flex={1}
          paddingHorizontal="$3"
          boxSizing="border-box"
          alignItems="flex-start"
          alignSelf="flex-start"
          onLayout={handleTextLayout}
          maxWidth={PAGE_WIDTH * 0.7}
          space="$3"
        >
          <Paragraph numberOfLines={isExpanded ? undefined : 1}>
            <Paragraph fontWeight="600">{item?.member?.nickName}</Paragraph>
            <Paragraph> {item?.content}</Paragraph>
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
              共 {item?.commentCount} 条评论{" "}
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
            renderItem={({ item }) => <CommentItem item={item} />}
            refreshing={!!loading}
            onRefresh={() => handleRefresh()}
            ListFooterComponent={() => (
              <Paragraph alignSelf="center" color="$lightGray" marginTop="auto">
                没有更多了
              </Paragraph>
            )}
            contentContainerStyle={{ paddingBottom: 50 }}
            estimatedItemSize={100}
            showsVerticalScrollIndicator={false}
          />
        </ReviewBottomSheet>
      </YStack>
    );
  }
);

export const CommentItem = memo(({ item }: { item: any }) => {
  const is_anonymity = item?.type === "anonymity";

  return (
    <XStack marginVertical="$2" space="$3" alignItems="flex-start">
      <Avatar size={50} circular backgroundColor="$lightGray">
        <Avatar.Image src={item?.avatar} />
      </Avatar>
      <YStack alignItems="flex-start">
        <XStack alignItems="center" space="$2">
          <Paragraph>{is_anonymity ? "匿名评论" : item?.memberName}</Paragraph>
          <Paragraph color="$lightGray">{item?.createTime}</Paragraph>
        </XStack>
        <XStack justifyContent="space-between" alignItems="center">
          <Paragraph width="80%">{item?.content}</Paragraph>
        </XStack>
        {/* <Button onPress={() => {}} unstyled>
          <ButtonText color="$lightGray">回复</ButtonText>
        </Button> */}
      </YStack>
    </XStack>
  );
});

export const ReviewBottomSheet = ({
  isOpen,
  onClose,
  children,
  zIndex = 100000,
  position = 0,
  sendComment,
  ...props
}) => {
  const [currentPosition, setCurrentPosition] = useState(position);
  const [text, setText] = useState("");
  const [anonymity, setAnonymity] = useState(false);
  const { screenWidth, screenHeight } = useGlobalContext();

  const handleSendComment = () => {
    sendComment({ text, is_anonymity: anonymity });
    setText("");
  };

  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => onClose(open)}
        snapPoints={[70]}
        dismissOnSnapToBottom
        position={currentPosition}
        onPositionChange={setCurrentPosition}
        zIndex={zIndex}
        disableDrag
        animation="medium"
      >
        <Sheet.Overlay
          animation="lazy"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <KeyboardAvoidingView
          behavior={Platform.OS === "ios" ? "padding" : "height"}
          style={{ flex: 1 }}
          keyboardVerticalOffset={Platform.OS === "ios" ? 250 : 0}
        >
          <Sheet.Frame
            paddingHorizontal="$4"
            paddingTop="$3"
            height="100%"
            alignItems="center"
            space="$5"
            backgroundColor="#fff"
            unstyled
          >
            {/* 顶部标题栏 */}
            <XStack
              position="fixed"
              left={0}
              top={0}
              justifyContent="space-between"
              width="100%"
              height={30}
            >
              <Paragraph>评论</Paragraph>
              <TouchableWithoutFeedback onPress={() => onClose(false)}>
                <XStack>
                  <X size={20} color="#000" />
                </XStack>
              </TouchableWithoutFeedback>
            </XStack>

            {/* 评论列表区域 */}
            <XStack
              flexDirection="row"
              width="100%"
              height="80%"
              // marginTop="$3"
            >
              {children}
            </XStack>

            {/* 输入区域 */}
            <YStack
              width={screenWidth}
              backgroundColor="#EDEDED"
              padding="$3"
              paddingBottom="$5"
              space="$3"
              position="absolute"
              bottom={0}
              left={0}
              right={0}
            >
              <TextArea
                placeholder="评论"
                width="100%"
                height={60}
                borderRadius={20}
                value={text}
                onChangeText={setText}
                autoCapitalize="none"
              />
              <XStack space="$2" width="100%" alignItems="center">
                <Switch
                  size="$3"
                  checked={anonymity}
                  onCheckedChange={setAnonymity}
                  backgroundColor={anonymity ? "$brown" : "#A1A1A1"}
                >
                  <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
                </Switch>
                <Label color="$lightGray">匿名评论</Label>
                <Button
                  paddingVertical="$2"
                  width={60}
                  paddingHorizontal="$3"
                  borderRadius={10}
                  backgroundColor="$brown"
                  color="#fff"
                  marginLeft="auto"
                  alignItems="center"
                  justifyContent="center"
                  unstyled
                  onPress={handleSendComment}
                >
                  发送
                </Button>
              </XStack>
            </YStack>
          </Sheet.Frame>
        </KeyboardAvoidingView>
      </Sheet>
    </PortalProvider>
  );
};
