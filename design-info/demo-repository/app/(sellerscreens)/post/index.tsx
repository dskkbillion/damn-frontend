import { FlashList } from "@shopify/flash-list";
import { router } from "expo-router";
import React, { memo, useCallback, useEffect, useState } from "react";
import { Text, TouchableOpacity, TouchableWithoutFeedback } from "react-native";
import FastImage from "react-native-fast-image";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, Circle, Paragraph, XStack, YStack } from "tamagui";

import { ButtonSwitchComp } from "@/components/ButtonSwitchComp";
import { StoryListComponent } from "@/components/homepage/story_list";
import { QueryDict } from "@/components/queryDict";
import { BottomSheetWithButtons } from "@/components/styled/bottomsheet_buttons";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function SellerHomepage() {
  const [post, setPost] = useState("item");
  const dispatch = useDispatch<AppDispatch>();
  const userId = useSelector((state: RootState) => state?.user?.userId);

  const handlePost = useCallback(
    (post) => {
      if (post === "item") {
        router.push(`/(sellerscreens)/post/add/itemEdit`);
        dispatch(slices.post.actions.resetPostItem());
      } else {
        router.push({
          pathname: "/(sellerscreens)/post/story/storyEdit",
          params: { status: "add" },
        });
      }
    },
    [post]
  );

  const handlePostPress = useCallback(
    (post) => {
      if (post === "item") {
        setPost("item");
      } else {
        setPost("story");
      }
    },
    [post]
  );

  return (
    <YStack
      width="100%"
      height="100%"
      paddingTop="20%"
      backgroundColor="#EDEDED"
    >
      <XStack
        position="absolute"
        left={0}
        top={0}
        width="100%"
        height="18x%"
        backgroundColor="$brown"
      />
      <XStack marginBottom="$6">
        <XStack marginLeft="4%">
          <Paragraph
            color="#fff"
            fontSize={25}
            fontWeight="600"
            paddingTop="$3"
            marginRight="$2"
          >
            发布
          </Paragraph>
        </XStack>

        <XStack
          flexDirection="row"
          space="$5"
          width="50%%"
          marginLeft="$3"
          marginTop={10}
          // paddingTop={10}
        >
          <Button
            borderBottomWidth="$1"
            borderBottomColor={post === "item" ? "#fff" : "transparent"}
            unstyled
            onPress={() => handlePostPress("item")}
          >
            <ButtonText
              color={post === "item" ? "#fff" : "#ECB365"}
              fontSize={16}
            >
              商品
            </ButtonText>
          </Button>
          <Button
            borderBottomWidth="$1"
            borderBottomColor={post === "story" ? "#fff" : "transparent"}
            unstyled
            onPress={() => handlePostPress("story")}
          >
            <ButtonText
              color={post === "story" ? "#fff" : "#ECB365"}
              fontSize={16}
            >
              我的故事
            </ButtonText>
          </Button>
        </XStack>
      </XStack>

      {post === "item" && (
        <ButtonSwitchComp
          button_num={3}
          is_titled
          renderContent={renderContent}
          names={["在卖", "草稿", "已下架"]}
          fontSize={16}
        />
      )}

      {post === "story" && (
        <StoryListComponent pageSize="wh" member_id={userId} role="user" />
      )}
      <TouchableOpacity
        onPress={() => handlePost(post)}
        style={{
          position: "absolute",
          right: 20,
          bottom: 100,
        }}
      >
        <Circle size={55} backgroundColor="$brown">
          <AntDesignIcon name="plus" size={30} color="#ffffff" />
        </Circle>
      </TouchableOpacity>
    </YStack>
  );
}

const renderContent = ({ type }: { type: string }) => {
  return <RenderItemList type={type} />;
};

// 渲染在卖、草稿、已下架的商品列表
const RenderItemList = memo(({ type }: { type: string }) => {
  const dispatch = useDispatch<AppDispatch>();
  const [loading, setLoading] = useState(false);
  const postItemList = useSelector(
    (state: RootState) => state.post.postItemList
  );
  const draftList = useSelector((state: RootState) => state.post.draftList);
  const changed = useSelector((state: RootState) => state.post.changed);

  const fetchPostItemList = useCallback(async () => {
    setLoading(true);
    let params = {};
    if (type === "已下架") {
      params = { state: "disabled" };
    } else {
      params = { state: "normal" };
    }
    await dispatch(slices.post?.actions.fetchPostItem(params));
  }, [type, dispatch]);

  const fetchDraftItemList = useCallback(async () => {
    setLoading(true);
    if (type === "草稿") {
      const params = {
        pageNum: 1,
        pageSize: 9999,
      };
      await dispatch(slices.post?.actions.fetchDraftItem(params));
    }
  }, [type, dispatch]);

  const handleRefresh = useCallback(async () => {
    try {
      if (type === "草稿") {
        await dispatch(slices.post.actions.resetDraftList());
        await fetchDraftItemList();
      } else {
        await dispatch(slices.post.actions.resetPostItemList());
        await fetchPostItemList();
      }
    } catch (error) {
      console.error("Failed to refresh:", error);
    } finally {
      setLoading(false);
    }
  }, [fetchPostItemList, fetchDraftItemList, type, dispatch]);

  // 监听 type 变化时重新加载数据
  useEffect(() => {
    handleRefresh();
  }, [type, changed]);

  return (
    <FlashList
      data={type === "草稿" ? draftList : postItemList}
      keyExtractor={(item: any) => item.id}
      renderItem={({ item }) => <RenderPost item={item} type={type} />}
      refreshing={loading}
      onRefresh={handleRefresh}
      estimatedItemSize={1000}
      onEndReachedThreshold={0.1}
      contentContainerStyle={{ paddingBottom: 200, paddingTop: 15 }}
      ListFooterComponent={() => (
        <Paragraph alignSelf="center" color="$lightGray" marginTop="$8">
          {loading ? "加载中..." : "没有更多了"}
        </Paragraph>
      )}
      showsVerticalScrollIndicator={false}
    />
  );
});

// 渲染在卖、草稿、已下架的商品
const RenderPost = memo(({ item, type }: { item: any; type: string }) => {
  const { dictData, screenWidth } = useGlobalContext();
  const dict = dictData["product_status_audit"];
  const [bottomPopup, setBottomPopup] = useState(false);
  const dispatch = useDispatch<AppDispatch>();

  const changeItemState = useCallback(async () => {
    let params;
    if (type === "在卖") {
      // 下架商品
      params = {
        id: item?.id,
        state: "disabled",
      };
    } else if (type === "已下架") {
      // 上架商品
      params = {
        id: item?.id,
        state: "normal",
      };
    }
    try {
      const res = await dispatch(slices.post.actions.editItemState(params));
      if (isAxiosSuccess(res.type)) {
        setBottomPopup(false);
        dispatch(slices.post.actions.setChanged());
      }
    } catch (error) {
      console.log("fail to change the state of order", error);
    }
  }, [item, type]);

  // 去编辑发布的商品
  const editItem = useCallback(async (id) => {
    try {
      router.push(`/(sellerscreens)/post/${id}/itemEdit`);
    } catch (err) {
      console.log("fail to fetch item detail", err);
    }
  }, []);

  return (
    <YStack
      width="100%"
      backgroundColor="#fff"
      paddingVertical="$1"
      paddingBottom="$3"
      marginBottom={1}
    >
      <TouchableWithoutFeedback
        style={{ width: "100%" }}
        onPress={() => {
          if (type !== "草稿") {
            router.push({
              pathname: "/(outer)/home/itemHomepage",
              params: { id: item?.id, source: "post" },
            });
          } else {
            editItem(item?.id);
            // router.push(`/(sellerscreens)/post/${item?.id}/itemEdit`);
          }
        }}
      >
        <XStack
          flexDirection="row"
          paddingVertical="$3"
          width="100%"
          paddingHorizontal="$3"
          backgroundColor="$background"
          alignItems="flex-start"
        >
          <FastImage
            source={{
              uri: item?.images?.[0],
              priority: FastImage.priority.high,
            }}
            style={{
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              borderRadius: 10,
            }}
          />
          <YStack marginHorizontal="$3" flex={1} space={4}>
            <XStack>
              <Paragraph fontSize={16} numberOfLines={1}>
                {item?.name} {item?.id}
              </Paragraph>

              {item?.productType !== "draft" && (
                <XStack
                  backgroundColor={
                    item.statusAudit === "SUCCESS" ? "#DAF5E1" : "#FEE2E2"
                  }
                  borderRadius={20}
                  marginLeft="auto"
                  paddingHorizontal={10}
                >
                  <Paragraph
                    color={
                      item.statusAudit === "SUCCESS" ? "#4E7462" : "#FF453B"
                    }
                  >
                    {QueryDict(dict, item?.statusAudit).label}
                  </Paragraph>
                </XStack>
              )}
            </XStack>

            <Text
              style={{
                fontSize: 20,
                color: "#B66D0E",
              }}
            >
              ¥{item?.sellingPrice}
            </Text>
            {item?.productType !== "draft" && (
              <XStack space="$2">
                <Paragraph color="$lightGray">
                  曝光 {item?.viewNumber}
                </Paragraph>
                <Paragraph color="$lightGray">
                  收藏 {item?.collectNum}
                </Paragraph>
                <Paragraph color="$lightGray">
                  卖出 {item?.buyedNumber}
                </Paragraph>
              </XStack>
            )}
          </YStack>
        </XStack>
      </TouchableWithoutFeedback>

      <XStack
        flexDirection="row"
        alignItems="center"
        marginLeft="auto"
        marginRight="4%"
        space="$2"
      >
        {type !== "已下架" && (
          <Button
            textAlign="center"
            backgroundColor="$lightGray"
            paddingVertical={3}
            color="$text"
            borderRadius={10}
            width="25%"
            unstyled
            zIndex={999}
            onPress={() => editItem(item?.id)}
          >
            <ButtonText color="black">编辑</ButtonText>
          </Button>
        )}
        {type !== "草稿" && (
          <Button
            textAlign="center"
            backgroundColor="$lightGray"
            paddingVertical={3}
            color="$text"
            borderRadius={10}
            width="25%"
            zIndex={999}
            onPress={() => setBottomPopup(true)}
            unstyled
          >
            <ButtonText color="black">
              {type === "在卖" ? "下架" : "上架"}
            </ButtonText>
          </Button>
        )}
      </XStack>

      <BottomSheetWithButtons
        isOpen={bottomPopup}
        onClose={setBottomPopup}
        handleCancel={null}
        snapPoints={[20]}
        title={type === "在卖" ? "确认下架？" : "确认上架？"}
        buttons={["取消", "确定"]}
        handleComfirm={changeItemState}
      />
    </YStack>
  );
});
