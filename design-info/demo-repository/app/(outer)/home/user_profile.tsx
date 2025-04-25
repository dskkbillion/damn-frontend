import { FlashList } from "@shopify/flash-list";
import { LinearGradient } from "@tamagui/linear-gradient";
import { ChevronLeft, X } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams, useRouter } from "expo-router";
import { memo, useCallback, useEffect, useRef, useState } from "react";
import { TouchableWithoutFeedback, Text } from "react-native";
import FastImage from "react-native-fast-image";
import { SafeAreaView } from "react-native-safe-area-context";
import { SvgXml } from "react-native-svg";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import IoniconsIcon from "react-native-vector-icons/Ionicons";
import { useDispatch, useSelector } from "react-redux";
import {
  YStack,
  Image,
  Avatar,
  XStack,
  Label,
  Paragraph,
  Button,
  ButtonText,
  Circle,
  Separator,
  ScrollView,
  Card,
} from "tamagui";

import { goToChat } from "@/components/chat/goToChat";
import { StoryListComponent } from "@/components/homepage/story_list";
import {
  checkIsFollowing,
  followUser,
  unfollowUser,
} from "@/components/utils/follow_user";
import { AppDispatch, RootState, slices } from "@/src/store";
import React from "react";

/**
 * 用户主页
 * 局部变量：memberId
 * @returns
 */
export default function UserProfile() {
  const memberId = useLocalSearchParams().memberId;
  console.log("memberId", memberId);
  return (
    <YStack flex={1} height="100%">
      <UserTopIntro imageUri="https://gitee.com/Ryan_here/images/raw/master/IMG_6877.JPG" />
      <YStack
        flex={1}
        height={global.screenHeight}
        borderTopRightRadius={10}
        borderTopLeftRadius={10}
        backgroundColor="#ffffff"
      >
        <XStack padding="$2" />
        <ButtonSwitch seller_id={memberId} />
      </YStack>
    </YStack>
  );
}

/**
 * 用户顶部介绍
 * @param imageUri 用户背景图（暂不使用）
 * @returns
 */
const UserTopIntro = ({ imageUri }) => {
  const [bottomColor, setBottomColor] = useState("#000000");
  const dispatch = useDispatch<AppDispatch>();
  const router = useRouter();
  const { previousPage } = useLocalSearchParams<{ previousPage: string }>();
  const isFollowing = useSelector((state: RootState) => state.cart.isFollowing);
  const memberId = useLocalSearchParams().memberId;
  const tenantProfile = useSelector(
    (state: RootState) => state.item.tenantProfile
  );

  console.log("memberId", memberId);
  console.log("tenantProfile", tenantProfile);

  // 获取卖家信息
  useEffect(() => {
    dispatch(
      slices.item.actions.fetchTenantProfile({ memberId: Number(memberId) })
    );

    const initIsFollowing = async () => {
      const isFollowing = await checkIsFollowing(dispatch, {
        type: "tenant",
        searchIds: [Number(memberId)],
        memberId: Number(memberId),
      });
      dispatch(slices.cart.actions.setIsFollowing(isFollowing));
    };

    initIsFollowing();

    return () => {
      dispatch(slices.item.actions.clearTenantProfile());
      dispatch(slices.cart.actions.setIsFollowing(false));
    };
  }, [dispatch]);

  const goBack = () => {
    if (previousPage) {
      if (typeof previousPage === "string") {
        router.push(previousPage as any); // 使用 as any 来绕过类型检查
      } else {
        console.warn("previousPage is not a string:", previousPage);
        router.back(); // Fallback 行为
      }
    } else {
      router.back(); // Fallback 行为
    }
  };

  // useEffect(() => {
  //   const fetchColors = async () => {
  //     const result = await getColors(imageUri, {
  //       fallback: "#000000",
  //       cache: true,
  //       key: imageUri,
  //     });

  //     switch (result.platform) {
  //       case "android":
  //         setBottomColor(result.dominant || "#000000");
  //         break;
  //       case "ios":
  //         setBottomColor(result.detail || "#000000");
  //         break;
  //       default:
  //         setBottomColor("#000000");
  //         break;
  //     }
  //   };

  //   fetchColors();
  // }, [imageUri]);

  return (
    <YStack>
      <LinearGradient
        colors={["transparent", bottomColor]}
        zIndex={1}
        height={global.screenHeight * 0.35}
        width="100%"
        position="absolute"
        top={0}
        left={0}
      />
      {/* <Image
        source={{
          uri: imageUri,
        }}
        position="absolute"
        top={0}
        left={0}
        style={{ width: "100%", height: global.screenHeight * 0.35 }}
        resizeMode="cover"
        zIndex={0}
      /> */}

      <TouchableWithoutFeedback onPress={goBack}>
        <XStack width="30%" height={30} zIndex={3} marginTop="14%">
          <ChevronLeft size={30} color="#ffffff" style={{ zIndex: 3 }} />
        </XStack>
      </TouchableWithoutFeedback>
      {/* 头像 && 用户名 && */}
      <XStack
        flex={0}
        alignItems="center"
        paddingHorizontal="6%"
        zIndex={3}
        space="$5"
      >
        <Avatar size={50} circular backgroundColor="#EDEDED">
          <Avatar.Image src={tenantProfile?.avatar} />
        </Avatar>
        <YStack paddingVertical="$2" zIndex={3}>
          <Paragraph fontSize={18} fontWeight="600" color="#ffffff">
            {tenantProfile?.nickName}
          </Paragraph>
          <Label color="#ffffff">{tenantProfile?.collectNum} 粉丝</Label>
        </YStack>
        {/* 注释掉分享图标 */}
        {/* <AntDesignIcon
          size={25}
          name="sharealt"
          color="#ffffff"
          style={{ marginLeft: "auto", paddingHorizontal: 30 }}
        /> */}
      </XStack>

      <XStack
        marginHorizontal="6%"
        space="$8"
        alignItems="center"
        zIndex={3}
        marginTop="$2"
        paddingBottom="$3"
      >
        <Button
          width="70%"
          height="70%"
          borderRadius={20}
          backgroundColor={isFollowing ? "$black" : "$white"}
          onPress={() => {
            if (!isFollowing) {
              followUser({
                dispatch,
                params: {
                  objectId: Number(memberId),
                  type: "tenant",
                  feature: {
                    nickName: tenantProfile?.nickName,
                    avatar: tenantProfile?.avatar,
                  },
                },
              });
            } else {
              unfollowUser({
                dispatch,
                params: { objectId: Number(memberId), type: "tenant" },
              });
            }
          }}
        >
          <ButtonText color={isFollowing ? "$white" : "$black"}>
            {isFollowing ? "取消关注" : "关注"}
          </ButtonText>
        </Button>

        <TouchableWithoutFeedback
          onPress={() => goToChat({ dispatch, tenantId: memberId })}
        >
          <Circle
            size={30}
            flex={0}
            alignItems="center"
            justifyContent="center"
            backgroundColor="#ffffff"
          >
            <AntDesignIcon size={15} name="message1" />
          </Circle>
        </TouchableWithoutFeedback>
      </XStack>
    </YStack>
  );
};

const ButtonSwitch = ({ seller_id, ...props }) => {
  const [selectedButton, setSelectedButton] = useState<string>("About");
  return (
    <>
      <XStack flexDirection="row" width="100%" backgroundColor="transparent">
        <Button
          backgroundColor="white"
          borderBottomWidth="$1"
          height={40}
          borderRadius={0}
          onPress={() => {
            setSelectedButton("About");
          }}
        >
          <ButtonText
            style={{
              fontWeight: selectedButton === "About" ? "800" : "400",
              fontSize: 15,
            }}
          >
            关于商家
          </ButtonText>
        </Button>

        <Button
          backgroundColor="white"
          borderBottomWidth="$1"
          borderRadius={0}
          height={40}
          onPress={() => {
            setSelectedButton("MyStory");
          }}
        >
          <ButtonText
            style={{
              fontWeight: selectedButton === "MyStory" ? "800" : "400",
              fontSize: 15,
            }}
          >
            我的故事
          </ButtonText>
        </Button>

        <Button
          borderBottomWidth="$1"
          borderRadius={0}
          height={40}
          onPress={() => {
            setSelectedButton("MyService");
          }}
        >
          <ButtonText
            style={{
              fontWeight: selectedButton === "MyService" ? "800" : "400",
              fontSize: 15,
            }}
          >
            我的服务
          </ButtonText>
        </Button>
      </XStack>
      <Separator marginTop="$2" backgroundColor="$drakGray" />
      {renderContent({ type: selectedButton, id: seller_id })}
    </>
  );
};

const renderContent = ({ type, id }: { type: string; id: number }) => {
  switch (type) {
    case "MyService":
      return <RenderSellerPostContent tenantId={id} />;

    case "MyStory":
      return <StoryListComponent pageSize="sm" role="others" member_id={id} />;
    case "About":
      return <RenderForAboutContent />;
  }
};
const renderAuthenticationStyle = (auth: string) => {
  return (
    <XStack flexDirection="row" alignItems="center">
      <IoniconsIcon name="shield-checkmark" size={16} color="green" />
      <Paragraph>{auth}</Paragraph>
      <XStack paddingHorizontal="$2" />
    </XStack>
  );
};

// render the content of "About"
export const RenderForAboutContent = memo(() => {
  const tenantProfile = useSelector(
    (state: RootState) => state.item.tenantProfile
  );

  console.log("tenantProfile", tenantProfile);

  const RenderInfoList: React.FC<{
    icon_xml: string;
    title: string;
    text: string;
    width: number;
    height;
  }> = ({ icon_xml, title, text, width, height }) => {
    return (
      <>
        <XStack flex={0} alignItems="center" space="$3">
          <SvgXml width={width} height={height} xml={icon_xml} />
          <YStack flex={1} space="$2">
            <Text style={{ fontSize: 16, color: "gray" }}>{title}</Text>
            <Text style={{ fontSize: 16, fontWeight: "500" }}>{text}</Text>
          </YStack>
        </XStack>
        <Separator marginVertical="$2" />
      </>
    );
  };

  return (
    <SafeAreaView edges={["bottom"]} style={{ flex: 1 }}>
      <ScrollView flex={1} marginHorizontal="4%" marginVertical="$5">
        <RenderInfoList
          title="卖家等级"
          text={tenantProfile?.levelName}
          width={35}
          height={28}
          icon_xml={`<svg t="1716871203787" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3750" id="mx_n_1716871203787" width="200" height="200"><path d="M512 941.860571C274.958629 941.860571 82.1248 749.026743 82.1248 512 82.1248 274.958629 274.958629 82.1248 512 82.1248c237.026743 0 429.8752 192.848457 429.8752 429.8752S749.026743 941.860571 512 941.860571z m0-807.087542C303.996343 134.773029 134.787657 303.996343 134.787657 512S303.996343 889.212343 512 889.212343 889.212343 720.003657 889.212343 512C889.212343 303.996343 720.003657 134.773029 512 134.773029z" p-id="3751" fill="#bfbfbf"></path><path d="M360.769829 773.778286a42.773943 42.773943 0 0 1-25.263543-8.148115 43.476114 43.476114 0 0 1-16.4864-46.314057l42.861714-157.257143-128.6144-100.132571a42.949486 42.949486 0 0 1-14.189714-48.303543 43.008 43.008 0 0 1 40.725943-28.906057h155.735771l56.378514-141.019429c6.319543-15.857371 22.030629-26.126629 40.023772-26.126628 17.934629 0 33.645714 10.196114 40.053028 25.994971l56.407772 141.136457h155.735771c18.519771 0 34.947657 11.776 40.872229 29.301029a42.934857 42.934857 0 0 1-14.277486 47.864686l-128.658286 100.074057 42.832457 157.227886a43.154286 43.154286 0 0 1-16.764342 46.548114 43.9296 43.9296 0 0 1-48.683886 0.804571L512 681.5744l-127.341714 84.948114a42.744686 42.744686 0 0 1-23.888457 7.255772z m-73.303772-336.398629l134.436572 104.682057-45.392458 166.6048 135.460572-90.375314 135.489828 90.287543-45.392457-166.634057 134.421943-104.565029H572.752457L512 285.330286l-60.767086 152.049371H287.466057z" p-id="3752" fill="#bfbfbf"></path></svg>`}
        />
        <RenderInfoList
          title="卖家评分"
          text={tenantProfile?.score}
          width={35}
          height={35}
          icon_xml={`<svg t="1716871104160" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3239" width="200" height="200"><path d="M313.0368 429.40416h399.36v40.96h-399.36zM313.0368 618.86464h399.36v40.96h-399.36z" fill="#bfbfbf" p-id="3240"></path><path d="M816.20992 823.86944H209.26464V200.13056h478.35136l128.57344 134.22592v489.51296z m-565.98528-40.96h525.02528V350.8224l-105.10336-109.73184H250.22464v541.81888z" fill="#bfbfbf" p-id="3241"></path></svg>`}
        />
        <RenderInfoList
          title="评价消息响应时间"
          text="3 小时"
          width={35}
          height={28}
          icon_xml={`<svg t="1716871040262" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3113" id="mx_n_1716871040263" width="200" height="200"><path d="M512 108.251429C289.016686 108.251429 108.251429 289.016686 108.251429 512c0 67.3792 16.544914 132.432457 47.733028 190.551771 3.3792 6.3488 10.210743 18.197943 20.626286 35.883886l-26.916572 98.684343c-6.158629 22.601143 14.570057 43.344457 37.185829 37.1712l98.772114-26.945829c10.181486 5.9392 16.544914 9.654857 18.987886 11.146972A402.212571 402.212571 0 0 0 512 915.748571c222.968686 0 403.748571-180.765257 403.748571-403.748571S734.968686 108.251429 512 108.251429z m0 754.234514a348.628114 348.628114 0 0 1-179.960686-49.664 5212.013714 5212.013714 0 0 0-31.275885-18.314972 30.997943 30.997943 0 0 0-23.698286-3.115885l-61.191314 16.6912 16.705828-61.176686a30.983314 30.983314 0 0 0-3.247543-23.888457c-13.955657-23.566629-22.864457-38.970514-26.448457-45.655772a348.437943 348.437943 0 0 1-41.398857-165.376c0-193.579886 156.935314-350.500571 350.500571-350.500571S862.485943 318.420114 862.485943 512 705.565257 862.485943 512 862.485943z" p-id="3114" fill="#bfbfbf"></path><path d="M333.7216 526.628571m-42.057143 0a42.057143 42.057143 0 1 0 84.114286 0 42.057143 42.057143 0 1 0-84.114286 0Z" p-id="3115" fill="#bfbfbf"></path><path d="M512 526.628571m-42.057143 0a42.057143 42.057143 0 1 0 84.114286 0 42.057143 42.057143 0 1 0-84.114286 0Z" p-id="3116" fill="#bfbfbf"></path><path d="M690.293029 526.628571m-42.057143 0a42.057143 42.057143 0 1 0 84.114285 0 42.057143 42.057143 0 1 0-84.114285 0Z" p-id="3117" fill="#bfbfbf"></path></svg>`}
        />
        {/* Authentication */}
        <Paragraph
          style={{ fontSize: 16, fontWeight: "500" }}
          marginVertical="$2"
        >
          卖家认证
        </Paragraph>

        {tenantProfile?.authenticationVos &&
          tenantProfile?.authenticationVos.map((item, index) => {
            // 尝试解析认证名称
            let displayName = "认证项";
            try {
              if (typeof item?.name === 'string') {
                // 检查是否是JSON字符串
                if (item.name.includes('{') && item.name.includes('}')) {
                  // 尝试解析JSON字符串
                  const parsedName = JSON.parse(item.name);
                  displayName = parsedName.name || "认证项";
                } else {
                  displayName = item.name;
                }
              } else if (typeof item?.name === 'object' && item?.name !== null) {
                // 如果是对象，尝试获取name属性
                displayName = item.name.name || "认证项";
              }
            } catch (e) {
              // 如果解析失败，使用默认值
              displayName = "认证项";
            }

            return (
              <XStack
                justifyContent="space-between"
                key={index}
                alignItems="center"
                height={30}
              >
                <Paragraph fontSize={15}>{displayName}</Paragraph>
                {item?.authenticationAuditVo ? (
                  <XStack
                    backgroundColor="$successBox"
                    paddingHorizontal="$3"
                    borderRadius={20}
                  >
                    <Paragraph color="$successText">已认证</Paragraph>
                  </XStack>
                ) : (
                  <XStack
                    backgroundColor="$lightGray"
                    paddingHorizontal="$3"
                    borderRadius={20}
                  >
                    <Paragraph color="#fff">未认证</Paragraph>
                  </XStack>
                )}
              </XStack>
            );
          })}

        {/* Reviews */}
        {/* <XStack alignItems="center">
          <Text style={{ fontSize: 16, fontWeight: "500" }}>评论</Text>
          <Button
            backgroundColor="transparent"
            borderRadius={20}
            paddingVertical={3}
            paddingHorizontal="$1"
            height={35}
            marginLeft="auto"
            unstyled
          >
            <ButtonText color="$blue">查看更多</ButtonText>
          </Button>
        </XStack>
        <YStack
          flex={1}
          paddingVertical="$3"
          marginVertical="$3"
          paddingHorizontal="$1"
        >
          <FlashList
            data={tenant?.memberEvaluateNewVos.slice(0, 3)}
            renderItem={({ item, index }: { item: any; index: number }) => (
              <YStack paddingVertical="$2">
                <XStack
                  flexDirection="row"
                  alignItems="center"
                  justifyContent="center"
                >
                  <Avatar size="$3" circular backgroundColor="#EDEDED">
                    <Avatar.Image src={item?.buyer?.avatar} />
                    <Avatar.Fallback backgroundColor="$gray6" />
                  </Avatar>
                  <Paragraph fontSize={16} paddingHorizontal="$2">
                    {item?.buyer?.nickName}
                  </Paragraph>
                  <Paragraph marginLeft="auto" color="$darkGray">
                    {item.createTime}
                  </Paragraph>
                </XStack>
                <Paragraph marginLeft="$7" numberOfLines={2} width="60%">
                  {item?.remark}
                </Paragraph>
                {index !== 2 ? <Separator marginTop="$2" /> : ""}
              </YStack>
            )}
          />
        </YStack>
        <XStack paddingVertical="$3" /> */}
      </ScrollView>
    </SafeAreaView>
  );
});

// render the content of "MyService"
export const RenderSellerPostContent = memo(
  ({ tenantId }: { tenantId: number }) => {
    const dispatch = useDispatch<AppDispatch>();
    const items = useSelector((state: RootState) => state.item.searchItemList);
    const fetchPostList = useCallback(async () => {
      try {
        await dispatch(
          slices.item.actions.fetchSearchItemList({
            tenantId: Number(tenantId),
          })
        );
      } catch (e) {
        console.log("fail to fetch post list", e);
      }
    }, [dispatch]);

    useEffect(() => {
      fetchPostList();
    }, [fetchPostList]);

    return (
      <YStack flex={1} backgroundColor="$bottomColor">
        <FlashList
          data={items}
          renderItem={({ item, index }: { item: any; index: number }) => (
            <RenderPostItem item={item} index={index} />
          )}
          numColumns={2}
          estimatedItemSize={100}
          contentContainerStyle={{
            paddingBottom: 100,
            paddingTop: 10,
            paddingHorizontal: 5,
          }}
          showsVerticalScrollIndicator={false}
        />
      </YStack>
    );
  }
);

const RenderPostItem = memo(({ item, index }: { item: any; index: number }) => {
  return (
    <XStack
      key={item.id}
      width="100%"
      alignItems="center"
      marginTop={8}
      justifyContent="center"
    >
      {/* <TouchableOpacity onPress={() => handlePress(item.id)}> */}
      <TouchableWithoutFeedback
        onPress={() =>
          router.push({
            pathname: "/(outer)/home/itemHomepage",
            params: { id: item?.id },
          })
        }
      >
        <Card
          style={{
            width: global.screenWidth * 0.45,
          }}
        >
          <FastImage
            source={{
              uri: item?.images?.[0],
              priority: FastImage.priority.normal,
            }}
            style={{
              borderTopLeftRadius: 8,
              borderTopRightRadius: 8,
              width: "100%",
              height: 200,
            }}
            resizeMode={FastImage.resizeMode.stretch}
          />
          {/* <Paragraph>{item?.images?.[0]}</Paragraph> */}
          <YStack padding="$2">
            <XStack marginRight="auto">
              <FontAwesomeIcon name="star" size={16} color="#EDB466" />
              <Text style={{ color: "#EDB466", fontWeight: "800" }}>
                {item?.score ? item?.score : "5.0"}
              </Text>
              <Text style={{ color: "#797B83" }}> ({item?.evaluateNum})</Text>
            </XStack>
            <YStack flex={1} padding="$1" />
            <YStack style={{ flexDirection: "column" }}>
              <XStack marginRight="auto"></XStack>
              <YStack flex={1} padding="$1" />
              <XStack>
                <Text
                  numberOfLines={2}
                  ellipsizeMode="tail"
                  style={{
                    // color: theme.color.get(),
                    maxWidth: "100%",
                    overflow: "hidden",
                    minHeight: 35, // 设置最小高度，根据实际需求调整
                    fontSize: 16,
                  }}
                >
                  {item?.name}
                </Text>
              </XStack>
            </YStack>
          </YStack>
          <Card.Footer paddingRight="$2">
            <XStack flexDirection="row" marginLeft="auto" alignItems="flex-end">
              <Text
                style={{
                  paddingVertical: 1,
                  fontSize: 15,
                }}
              >
                ¥
              </Text>
              <Text
                style={{
                  fontSize: 18,
                  fontWeight: "500",
                }}
              >
                {item?.sellingPrice}
              </Text>
            </XStack>
          </Card.Footer>
          <YStack flex={1} padding="$1" />
        </Card>
      </TouchableWithoutFeedback>
    </XStack>
  );
});
