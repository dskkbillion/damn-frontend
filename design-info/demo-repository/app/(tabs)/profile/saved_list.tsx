import { FlashList } from "@shopify/flash-list";
import { LinearGradient } from "@tamagui/linear-gradient";
import { ChevronLeft } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { TouchableWithoutFeedback, Text } from "react-native";
// import { getColors } from "react-native-image-colors";
import { SwipeListView } from "react-native-swipe-list-view";
import { useDispatch, useSelector } from "react-redux";
import {
  YStack,
  XStack,
  Button,
  Separator,
  Label,
  Paragraph,
  Avatar,
  H1,
  H2,
} from "tamagui";

import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { CartServiceComponent } from "@/components/profile/cartService";
import { userDataset } from "@/constants/users";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function SavedList() {
  const current_user = userDataset[0];

  return (
    <YStack flex={1} height="100%">
      <YStack
        flex={1}
        height={global.screenHeight}
        borderTopRightRadius={10}
        borderTopLeftRadius={10}
        backgroundColor="#ffffff"
        marginTop="$1"
      >
        <XStack padding="$2" />
        <ButtonSwitch seller_id={current_user.user_id} />
      </YStack>
    </YStack>
  );
}

const ButtonSwitch = ({ seller_id, ...props }) => {
  const [selectedButton, setSelectedButton] = useState<string>("Service");
  return (
    <>
      <XStack flexDirection="row" width="100%" backgroundColor="transparent">
        <Button
          width="50%"
          backgroundColor="white"
          borderBottomWidth="$1"
          borderBottomColor={
            selectedButton === "Service" ? "$brown" : "transparent"
          }
          size="$3"
          borderRadius={0}
          onPress={() => {
            setSelectedButton("Service");
          }}
        >
          <Text
            style={{
              fontWeight: "800",
              color: selectedButton === "Service" ? "#B66D0E" : "gray",
              fontSize: 15,
            }}
          >
            服务
          </Text>
        </Button>

        {/* button of standard  */}
        <Button
          width="50%"
          backgroundColor="white"
          color={selectedButton === "Service" ? "$brown" : "drakGray"}
          borderBottomWidth="$1"
          borderBottomColor={
            selectedButton === "Seller" ? "$brown" : "transparent"
          }
          size="$3"
          borderRadius={0}
          onPress={() => {
            setSelectedButton("Seller");
          }}
        >
          <Text
            style={{
              fontWeight: "800",
              color: selectedButton === "Seller" ? "#B66D0E" : "gray",
              fontSize: 15,
            }}
          >
            卖家
          </Text>
        </Button>
      </XStack>
      <Separator marginTop="$2" backgroundColor="$drakGray" />
      <RenderContent type={selectedButton} />
    </>
  );
};

const RenderContent = memo(({ type }: { type }) => {
  switch (type) {
    case "Service":
      return <ServiceContent />;
    case "Seller":
      return <SellerContent />;
    default:
      return <ServiceContent />;
  }
});

export const ServiceContent = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const cartList = useSelector((state: RootState) => state.cart.cartList);
  const loading = useSelector((state: RootState) => state.cart.loading);
  const changed = useSelector((state: RootState) => state.cart.changed);

  const fetchCartList = useCallback(() => {
    dispatch(slices.cart.actions.fetchCartList({}));
  }, [dispatch]);

  const handleRefresh = useCallback(async () => {
    dispatch(slices.cart.actions.resetCartList());
    fetchCartList();
  }, []);

  // 删除条目
  const renderHiddenItem = (index) => {
    const handleDeleteItem = async (index) => {
      await dispatch(slices.cart.actions.deleteCart({ ids: [index] }));
      dispatch(slices.cart.actions.setChanged());
    };

    return (
      <Button
        flexDirection="row"
        alignItems="center"
        height="97%"
        paddingRight={50}
        justifyContent="flex-end"
        backgroundColor="$brown"
        borderRadius={10}
        onPress={() => handleDeleteItem(index)}
      >
        <Paragraph color="#fff" alignSelf="center" fontSize={18}>
          删除
        </Paragraph>
      </Button>
    );
  };

  useEffect(() => {
    handleRefresh();
  }, [fetchCartList]);

  useEffect(() => {
    handleRefresh();
  }, [changed]);

  return (
    <YStack flex={1} padding="2%" backgroundColor="#EDEDED">
      <SwipeListView
        data={[
          ...(cartList?.normalList || []),
          ...(cartList?.invalidList || []),
        ]}
        keyExtractor={(item, index) => index.toString()}
        renderItem={({ item, index }) => {
          return (
            <YStack>
              <CartServiceComponent item={item} />
              <XStack height={5} backgroundColor="#EDEDED" />
            </YStack>
          );
        }}
        renderHiddenItem={({ item }: { item: any }) =>
          renderHiddenItem(item.id) || <></>
        } // cannot return null
        refreshing={loading}
        onRefresh={handleRefresh}
        leftOpenValue={0}
        rightOpenValue={-150}
        disableRightSwipe // 禁用右滑
      />
    </YStack>

    // <ServiceComponent item={sellerDataset[0]} />
  );
});

export const SellerContent = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const followList = useSelector((state: RootState) => state.cart.followList);
  const changed = useSelector((state: RootState) => state.cart.changed);
  const loading = useSelector((state: RootState) => state.cart.loading);
  const fetchCollecList = useCallback(() => {
    dispatch(slices.cart.actions.fetchCollecList({ type: "tenant" }));
  }, [dispatch]);

  const handleRefresh = useCallback(async () => {
    dispatch(slices.cart.actions.resetFollowList());
    fetchCollecList();
  }, []);

  useEffect(() => {
    handleRefresh();
  }, []);

  useEffect(() => {
    handleRefresh();
  }, [changed]);

  const cancelFollow = useCallback(async (id) => {
    await dispatch(slices.cart.actions.unFollowUser({ ids: [id] }));
    dispatch(slices.cart.actions.setChanged());
  }, []);

  if (followList.length === 0) {
    return (
      <YStack
        backgroundColor="#EDEDED"
        flex={1}
        justifyContent="center"
        alignItems="center"
      >
        <H1 fontSize={30} color="$lightGray">
          暂无关注
        </H1>
      </YStack>
    );
  }

  return (
    <YStack backgroundColor="#EDEDED" flex={1} padding="$2">
      <FlashList
        data={followList}
        refreshing={loading}
        onRefresh={handleRefresh}
        renderItem={({ item }) => {
          return (
            <XStack
              width="100%"
              alignItems="center"
              backgroundColor="#fff"
              paddingVertical="$2"
              marginBottom="$2"
              paddingHorizontal="$2"
            >
              <Button
                width="80%"
                height="auto"
                onPress={() =>
                  router.push({
                    pathname: "/(outer)/home/user_profile",
                    params: {
                      memberId: item?.memberId,
                    },
                  })
                }
                unstyled
              >
                <XStack>
                  <Avatar circular size={50} backgroundColor="#EDEDED">
                    <Avatar.Image source={{ uri: item?.avatar }} />
                  </Avatar>
                  <YStack marginLeft="$3">
                    <Paragraph fontWeight="500">
                      {item?.feature?.nickName}
                    </Paragraph>
                    <Paragraph numberOfLines={1}>
                      {item?.feature?.description}
                    </Paragraph>
                  </YStack>
                </XStack>
              </Button>

              <AlertDialogComponent
                title="取消关注"
                description="确认取消关注？"
                handleConfirm={() => cancelFollow(item?.id)}
              >
                <Button
                  marginLeft="auto"
                  backgroundColor="#EDEDED"
                  borderRadius={20}
                  size="$2"
                >
                  <Button.Text color="$darkGray">已关注</Button.Text>
                </Button>
              </AlertDialogComponent>
            </XStack>
          );
        }}
        keyExtractor={(item: any) => item}
        estimatedItemSize={50}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
});
