import { ChevronLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams, useRouter } from "expo-router";
import React, {
  memo,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import {
  Animated,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
  Alert,
  FlatList,
} from "react-native";
// import { getColors } from "react-native-image-colors";
import FastImage from "react-native-fast-image";
import Carousel from "react-native-reanimated-carousel";
import { SafeAreaView } from "react-native-safe-area-context";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import IoniconsIcon from "react-native-vector-icons/Ionicons";
import MaterialIcons from "react-native-vector-icons/MaterialIcons";
import { useDispatch, useSelector } from "react-redux";
import {
  YStack,
  H1,
  H2,
  Separator,
  Theme,
  Button,
  Avatar,
  XStack,
  ButtonText,
  Paragraph,
  ScrollView,
  Circle,
} from "tamagui";

import { renderAuthenticationItems } from "@/components/AuthenticationItems";
import ButtonWithText from "@/components/button_choose_service";
import { MoreDescription } from "@/components/homepage/bottom_sheet_service_intro";
import HorizontalItemList from "@/components/homepage/horizontal_item_list";
import { ItemFeaturesContent } from "@/components/homepage/itemFeaturesContent";
import { PaymentBottomSheet } from "@/components/homepage/payment_bottomsheet";
import FreqQuestion from "@/components/styled/accordion_template";
import { alert } from "@/components/styled/alert";
import { ImagePreviewComp } from "@/components/styled/preview_image";
import { isAxiosSuccess } from "@/components/utils";
import { getFilePath } from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";
import { useBottomSheet } from "@/components/ai_doc/bottom-sheet-context";
import { ThemeButton } from "@/components/styled/theme_button";
/**
 * 商品详情页
 * @param {string} id - 商品ID
 * @param {string} source - 来源: home, post
 * @returns
 */
export default function SeviceShowScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{ id: string; source: string; fromRecommend: string }>();
  const dispatch = useDispatch<AppDispatch>();

  const ItemDetail = useSelector((state: RootState) => state.item.ItemDetail);
  const tenant = useSelector((state: RootState) => state.item.tenant);
  const [activateIndex, setActiveIndex] = useState(0);
  const [purchaseServiceType, setPurchaseServiceType] = useState("bsc");
  const [arrowColor, setArrowColor] = useState("#ffffff"); // 默认为黑色
  const scrollY = useRef(new Animated.Value(0)).current; // Y轴高度
  // 控制支付底部是否弹出
  const [isPaymentSheetOpen, setPaymentSheetOpen] = useState(false);
  const [isLiked, setIsLiked] = useState(false);
  const cartList = useSelector((state: RootState) => state.cart.cartList);
  const [variant, setVariant] = useState(ItemDetail?.variants?.[0]);
  const [imagePreviewIndex, setImagePreviewIndex] = useState(0);
  const [imageModal, setImageModal] = useState(false);
  const [winImageModal, setWinImageModal] = useState(false);
  const [freqQuestions, setFreqQuestions] = useState<any[]>([]);
  const [materials, setMaterials] = useState<any[]>([]);
  const item_comments = useSelector(
    (state: RootState) => state.item.item_comments
  );
  const [authentication_array, setAuthentication_array] = useState(
    [] as string[]
  );
  const itemCode = useSelector((state: RootState) => state.item.code);
  const cartCode = useSelector((state: RootState) => state.cart.code);
  const source = useLocalSearchParams()?.source;

  const enterTimeRef = useRef<number>(0); // 使用 useRef 替代 useState

  const { presented, handlePresentModal } = useBottomSheet();

  const productMaterials = useMemo(() => {
    if (
      ItemDetail?.productMaterials &&
      ItemDetail?.productMaterials.length > 0
    ) {
      setFreqQuestions(
        ItemDetail?.productMaterials.filter((item) => item.type === "PROBLEM")
      );
      setMaterials(
        ItemDetail?.productMaterials.filter((item) => item.type !== "PROBLEM")
      );
    }
  }, [ItemDetail]);

  const path = useMemo(() => {
    if (source === "home") {
      return "/item_from_homepage";
    } else if (source === "search") {
      return "/item_from_search";
    } else if (source === "ai_home") {
      return "/item_from_ai_home";
    } else if (source === "bottom") {
      return "/item_from_bottom";
    }
  }, [source]);

  // 是否从模型进入
  const is_from_model = useLocalSearchParams()?.is_from_model;

  const handlePaymentShow = (status) => {
    if (status) {
      setPaymentSheetOpen(true);
    }
    if (!status) {
      setTimeout(() => {
        setPaymentSheetOpen(false);
      }, 300); // setPaymentSheetOpen(false);
    }
  };

  const onButtonValueChange = useCallback(
    (value) => {
      if (value === "bsc") {
        setVariant(ItemDetail?.variants?.[0]);
      } else if (value === "std") {
        setVariant(ItemDetail?.variants?.[1]);
      } else {
        setVariant(ItemDetail?.variants?.[2]);
      }
      setPurchaseServiceType(value);
    },
    [purchaseServiceType, variant]
  );

  const goToChat = useCallback(async () => {
    try {
      /** 无网络测试 */
      console.log("come in");
      router.push({
        pathname: "/(outer)/chatroom",
        params: { chatId: 1 },
      });
      // const res = await dispatch(
      //   slices.msg.actions.createRoom({ doctorId: tenant?.id, type: "MEMBER" })
      // );

      // if (isAxiosSuccess(res.type) && res.payload && "data" in res.payload) {
      //   router.push({
      //     pathname: "/(outer)/chatroom",
      //     params: { chatId: res.payload.data },
      //   });
      // }
    } catch (err) {
      console.error(err);
    }
  }, [tenant]);

  const clickLike = useCallback(async () => {
    try {
      if (!isLiked && variant) {
        // 添加收藏
        const res = await dispatch(
          slices.cart.actions.addCart({
            variantId: variant?.id,
            tenantId: ItemDetail?.tenantId,
            number: 1,
          })
        );
        if (isAxiosSuccess(res.type)) {
          setIsLiked(true);
          // 在成功添加收藏后发送埋点数据
          const loggingData = {
            path,
            businessType: "cart",
            businessId: ItemDetail?.id,
            interval: null,
          };
          dispatch(slices.logging.actions.sendLoggingData(loggingData));
          Alert.alert("提示", "收藏成功", [{ text: "确定" }]);
        } else {
          Alert.alert("提示", "收藏失败", [{ text: "确定" }]);
        }
      } else {
        // 取消收藏
        const cart_list = [
          ...(cartList?.normalList || []),
          ...(cartList?.invalidList || []),
        ];
        const cartItem = cart_list.find(
          (item) => item.productId === Number(ItemDetail?.id)
        );

        if (cartItem) {
          const res = await dispatch(
            slices.cart.actions.deleteCart({
              ids: [cartItem.id],
            })
          );
          if (isAxiosSuccess(res.type)) {
            setIsLiked(false);
            Alert.alert("提示", "取消收藏成功", [{ text: "确定" }]);
          } else {
            Alert.alert("提示", "取消收藏失败", [{ text: "确定" }]);
          }
        }
      }
    } catch (error) {
      console.log("fail to handle cart operation", error);
      Alert.alert("提示", "操作失败，请稍后重试", [{ text: "确定" }]);
    }
  }, [isLiked, variant, ItemDetail, path, dispatch]);

  const handleImageClick = useCallback((index: number, type: string) => {
    // 打开蒙版
    if (type === "win") {
      setWinImageModal(true);
    } else {
      setImageModal(true);
    }
    // 设置预览图片
    setImagePreviewIndex(index);
  }, []);

  const headerTranslate = scrollY.interpolate({
    inputRange: [0, 30], // 调整这个范围
    outputRange: [-global.screenHeight * 0.15, 0],
    extrapolate: "clamp",
  });

  const renderAuthenticationStyle = (auth: string) => {
    return (
      <XStack flexDirection="row" alignItems="center" marginRight="$1">
        <XStack flexDirection="row" alignItems="center" gap="$1">
          <XStack
            backgroundColor="$lightGray"
            paddingHorizontal="$3"
            borderRadius={10}
          >
            <Paragraph>{auth}</Paragraph>
          </XStack>

          <XStack paddingHorizontal="$2" />
        </XStack>
      </XStack>
    );
  };

  // useEffect(() => {
  //   const fetchColors = async () => {
  //     try {
  //       if (!ItemDetail?.images?.[0]) {
  //         setArrowColor("#000000");
  //         return;
  //       }
  //       const colors = await getColors(ItemDetail?.images?.[0], {
  //         fallback: "#000000",
  //         cache: true,
  //         key: ItemDetail?.images?.[0],
  //       });

  //       let dominantColor;
  //       switch (colors.platform) {
  //         case "android":
  //           dominantColor = colors.dominant;
  //           break;
  //         case "ios":
  //           dominantColor = colors.background;
  //           break;
  //         default:
  //           dominantColor = "#000000";
  //           break;
  //       }

  //       const { r, g, b } = hexToRgb(dominantColor);
  //       const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  //       const textColor = luminance < 0.8 ? "white" : "black";
  //       setArrowColor(textColor);
  //     } catch (error) {
  //       console.error("Error fetching image colors:", error);
  //     }
  //   };

  //   fetchColors();
  // }, [ItemDetail?.images?.[0]!]);

  useEffect(() => {
    if (itemCode && cartCode) {
      if (itemCode !== 200 || cartCode !== 200) {
        router.replace("/(outer)/login");
      }
    }
  }, [itemCode, cartCode]);

  useEffect(() => {
    const authentications = tenant?.attestationVo;
    if (!authentications) return;
    const authentication_array = [] as string[];
    for (let i = 0; i < authentications.length; i++) {
      if (authentications[i].status === "OPEN") {
        if (
          authentications[i]?.feature?.name &&
          authentications[i]?.feature?.name.trim()
        ) {
          authentication_array.push(authentications[i]?.feature?.name);
        }
      }
    }
    setAuthentication_array(authentication_array);
  }, [ItemDetail]);

  // 获取数据
  useEffect(() => {
    dispatch(slices.item.actions.fetchItemDetail({ id: Number(params.id) }));
  }, [params.id]);

  useEffect(() => {
    dispatch(slices.cart.actions.fetchCartList({}));
  }, [params.id, isLiked]);

  useEffect(() => {
    if (purchaseServiceType === "bsc") {
      setVariant(ItemDetail?.variants?.[0]);
    }
  }, [ItemDetail]);

  // 获取是否在购物车中
  useEffect(() => {
    if (!cartList || cartList === undefined) return;
    const cart_list = [
      ...(cartList?.normalList || []),
      ...(cartList?.invalidList || []),
    ];

    if (cart_list && cart_list !== undefined && cart_list.length > 0) {
      const res = cart_list.find(
        (item) => item.productId === Number(ItemDetail?.id)
      );
      if (res !== undefined) {
        setIsLiked(true);
      } else {
        setIsLiked(false);
      }
    } else {
      setIsLiked(false);
    }
  }, [cartList, ItemDetail?.id]);

  // 获取评论
  useEffect(() => {
    dispatch(
      slices.item.actions.fetchItemComments({ productId: ItemDetail?.id })
    );
  }, [ItemDetail?.id]);

  // 发送埋点（pv）
  useEffect(() => {
    enterTimeRef.current = Date.now();
    // 组件卸载时记录退出时间并发送埋点
    return () => {
      const exitTime = Date.now();
      const stayDuration = Math.floor((exitTime - enterTimeRef.current) / 1000); // 转换为秒

      if (enterTimeRef.current > 0) {
        const loggingData = {
          path,
          businessType: "pv",
          businessId: ItemDetail?.id,
          interval: stayDuration,
        };

        dispatch(slices.logging.actions.sendLoggingData(loggingData));
      }
    };
  }, []); // 依赖数组为空，确保只在组件挂载时执行一次

  useEffect(() => {
    // 组件卸载时清除状态
    return () => {
      // 清除商品详情
      dispatch(slices.item.actions.clearItemDetail());
      // 清除评论
      dispatch(slices.item.actions.clearItemComments());
      // 清除商家信息
      dispatch(slices.item.actions.clearTenant());

      // 清除图片
      dispatch(fileSlice.file.actions.clearAllImages());
    };
  }, []);

  useEffect(() => {
    console.log("source", source);
    if (source === "ai_home") {
      alert({
        title: "模型对话打包发送",
        message: "将模型对话打包发送给卖家,帮助卖家更好的了解你的需求！",
        buttons: [{ text: "去发送" }],
      });
    }
  }, [source]);

  const renderItem = () => (
    <Theme name="light">
      <ScrollView flex={0}>
        <TouchableWithoutFeedback
          onPress={() => {
            if (source === "ai_home" && !presented) {
              handlePresentModal(0);
            }
            router.back();
          }}
        >
          <View
            style={{
              position: "absolute",
              top: 80,
              left: 10,
              width: "20%",
              height: "3%",
              zIndex: 999,
            }}
          >
            <ChevronLeft size={30} color="#B66D0E" />
          </View>
        </TouchableWithoutFeedback>
        <XStack
          position="absolute"
          alignItems="center"
          top={83}
          right={10}
          space="$4"
          zIndex={3}
        >
          <TouchableWithoutFeedback onPress={clickLike}>
            {isLiked ? (
              <FontAwesomeIcon name="heart" size={35} color="#B66D0E" />
            ) : (
              <FontAwesomeIcon name="heart-o" size={35} color={arrowColor} />
            )}
          </TouchableWithoutFeedback>
          {/* 注释掉分享图标 */}
          {/* <IoniconsIcon name="share-outline" size={35} color="#B66D0E" /> */}
        </XStack>

        {/* <Image
      resizeMode="stretch"
      position="absolute"
      left={0}
      top={0}
      source={{
        width: global.screenWidth,
        height: global.screenHeight * 0.34,
        uri: ItemDetail?.images?.[0],
      }}
    /> */}

        <Carousel
          height={global.screenHeight * 0.34}
          width={global.screenWidth}
          data={ItemDetail?.images}
          onSnapToItem={(index) => setActiveIndex(index)}
          pagingEnabled
          renderItem={({ item, index }: { item: string; index: number }) => (
            <Button
              height="auto"
              onPress={() => handleImageClick(index, "item")}
              unstyled
            >
              <FastImage
                source={{
                  uri: getFilePath(item),
                  priority: FastImage.priority.high,
                }}
                resizeMode={FastImage.resizeMode.stretch}
                style={{
                  height: "100%",
                  width: "100%",
                }}
              />
            </Button>
          )}
        />
        <ImagePreviewComp
          images={ItemDetail?.images}
          previewIndex={imagePreviewIndex}
          modal={imageModal}
          setModal={setImageModal}
        />

        <XStack
          justifyContent="center"
          position="absolute"
          left={0}
          top={global.screenHeight * 0.32}
          width="100%"
        >
          {ItemDetail?.images &&
            ItemDetail?.images.length > 0 &&
            ItemDetail?.images.map((_, index) => (
              <Circle
                key={index}
                size={10}
                marginRight="$3"
                backgroundColor={index === activateIndex ? "#B66D0E" : "#EDEDED"}
              />
            ))}
        </XStack>

        <YStack flex={1} paddingTop={15} backgroundColor="#ffffff">
          {/* 用户头像和用户名 */}
          <XStack
            flexDirection="row"
            paddingHorizontal={15}
            alignItems="center"
            backgroundColor="#F2DFC1"
            paddingVertical={10}
            borderRadius={8}
            marginHorizontal={15}
          >
            <Avatar
              size="$5"
              circular
              onPress={() =>
                router.push({
                  pathname: "/(outer)/home/user_profile",
                  params: {
                    memberId: tenant?.id,
                  },
                })
              }
              backgroundColor="#EDEDED"
            >
              <Avatar.Image src={tenant?.avatar} />
            </Avatar>
            <YStack paddingHorizontal={10}>
              <Paragraph fontWeight="600">{tenant?.nickName}</Paragraph>
              {/* <Paragraph style={{ color: "gray" }}>
      {tenant?.university_authenticated}
    </Paragraph> */}
            </YStack>
            <Button
              width={params.fromRecommend === "true" ? "30%" : "20%"}
              height="60%"
              paddingHorizontal={params.fromRecommend === "true" ? "$2" : "$1"}
              backgroundColor="#B66D0E"
              marginLeft="auto"
              // 此处过度不顺滑，需后期更改
              onPress={goToChat}
            >
              <ButtonText
                color="#ffffff"
                fontSize={params.fromRecommend === "true" ? 13 : 14}
                letterSpacing={params.fromRecommend === "true" ? 1 : 0}
              >
                {params.fromRecommend === "true" ? "让ta看看" : "咨询"}
              </ButtonText>
            </Button>
          </XStack>

          <XStack
            flexDirection="row"
            paddingHorizontal={15}
            alignItems="center"
          >
            {/* 服务评分 */}
            <YStack
              flexDirection="column"
              alignItems="center"
              marginTop={10}
              paddingHorizontal={14}
            >
              <FontAwesomeIcon name="star" size={16} color="#EDB466" />
              <Paragraph>5.0</Paragraph>
            </YStack>

            <YStack paddingHorizontal={12}>
              {renderAuthenticationItems(
                2,
                3,
                authentication_array,
                renderAuthenticationStyle
              )}
            </YStack>
          </XStack>

          <Separator marginVertical="$3" />

          {/* 服务介绍 */}
          <YStack backgroundColor="#ffffff">
            <H1
              fontSize={20}
              fontWeight="700"
              color="#B66D0E"
              paddingHorizontal="4%"
            >
              {ItemDetail?.name}
            </H1>
            <XStack
              flexDirection="row"
              alignItems="center"
              paddingHorizontal="4%"
              marginTop="$2"
            >
              <Paragraph fontSize={18} color="#8A5208" fontWeight="600">
                ¥{variant?.sellingPrice}
              </Paragraph>
            </XStack>
            <Paragraph fontSize={15} marginHorizontal={20} numberOfLines={4}>
              {ItemDetail?.description}
              <MoreDescription service={ItemDetail} modifiable={false} />
            </Paragraph>
          </YStack>

          <Separator marginVertical="$3" />

          <ButtonWithText
            status="disableEdit"
            onValueChange={onButtonValueChange}
          >
            <ItemFeaturesContent variant={variant} />
          </ButtonWithText>

          {source !== "post" && (
            <XStack flexDirection="row" justifyContent="center">
              <ThemeButton
                width={global.screenWidth * 0.6}
                height={global.screenHeight * 0.05}
                title={`一键购买 (${variant?.sellingPrice})`}
                variant="primary"
                onPress={() => {
                  handlePaymentShow("open"); //弹出支付底部
                }}
              />
            </XStack>
          )}

          {isPaymentSheetOpen && (
            <PaymentBottomSheet
              isShow={handlePaymentShow}
              item={ItemDetail}
              tenantId={tenant?.id}
              purchaseServiceType={purchaseServiceType}
            />
          )}

          <Separator marginTop="$3" />

          {/* 常见问题 */}
          <FreqQuestion
            type="single"
            title="常见问题"
            height={70}
            defaultValue={ItemDetail?.productImages?.[0]}
            backgroundColor="#FFF9F4"
            borderColor="#D8A052"
            titleSize={18}
            titleColor="#B66D0E"
          >
            {freqQuestions && freqQuestions.length > 0 ? (
              freqQuestions.map((item, index) => (
                <YStack key={item.id}>
                  <Paragraph fontSize={15}>
                    {index + 1}. {item.question}
                  </Paragraph>
                  <Paragraph color="#636569">{item.answer}</Paragraph>
                </YStack>
              ))
            ) : (
              <YStack>
                <H2 fontSize={15}>暂无常见问题</H2>
              </YStack>
            )}
          </FreqQuestion>

          {materials && materials.length > 0 && (
            <YStack
              paddingHorizontal="4%"
              paddingVertical="$2"
              backgroundColor="#F2DFC1"
              marginHorizontal="4%"
              borderRadius={8}
              marginTop="$2"
              marginBottom="$2"
            >
              <H1 fontSize={16} color="#B66D0E">需要买家提供</H1>
              {materials.map((item) => (
                <XStack key={item.id} gap="$4" marginTop="$1">
                  <Paragraph fontSize={15} color="#8A5208">
                    {item.type === "TEXT" ? "-文本类型" : "-文件类型"}
                  </Paragraph>
                  <Paragraph fontSize={15}>{item.question}</Paragraph>
                </XStack>
              ))}
            </YStack>
          )}

          <Separator marginTop="$3" />

          {ItemDetail?.winImages && (
            <>
              <XStack
                flexDirection="row"
                alignItems="center"
                paddingHorizontal="4%"
                paddingVertical="$2"
                backgroundColor="#F2DFC1"
                marginHorizontal="4%"
                borderRadius={8}
                marginTop="$2"
                marginBottom="$2"
              >
                <H1 fontSize={16} color="#B66D0E">案例展示</H1>
              </XStack>

              {/* 图片预览 */}
              <ImagePreviewComp
                images={ItemDetail?.winImages}
                previewIndex={imagePreviewIndex}
                modal={winImageModal}
                setModal={setWinImageModal}
              />
              <XStack paddingHorizontal="4%">
                <FlatList
                  data={ItemDetail?.winImages}
                  renderItem={({ item, index }) => (
                    <Button
                      height="auto"
                      onPress={() => handleImageClick(index, "win")}
                      unstyled
                    >
                      <FastImage
                        source={{ uri: getFilePath(item) }}
                        style={{ width: 120, height: 150, marginRight: 10 }}
                      />
                    </Button>
                  )}
                  horizontal
                />
              </XStack>
            </>
          )}
          <Separator marginTop="$1" backgroundColor="$themeLight" />

          {/* ----- 买家评论 ------- */}
          <XStack
            flexDirection="row"
            justifyContent="space-between"
            alignItems="center"
            paddingHorizontal="4%"
            paddingVertical="$2"
            backgroundColor="#F2DFC1"
            marginHorizontal="4%"
            borderRadius={8}
            marginTop="$2"
          >
            <H1 fontSize={16} color="#B66D0E">评论 ({ItemDetail?.evaluateNum})</H1>

            <TouchableOpacity
              onPress={() =>
                router.push({
                  pathname: "/(outer)/home/review",
                  params: { productId: ItemDetail?.id },
                })
              }
            >
              <XStack flexDirection="row" alignItems="center">
                <Paragraph color="#8A5208">查看全部</Paragraph>
                <MaterialIcons name="keyboard-arrow-right" size={20} color="#8A5208" />
              </XStack>
            </TouchableOpacity>
          </XStack>

          <ReviewPreview
            productId={ItemDetail?.id}
            item_comments={item_comments}
          />

          <Separator marginTop="$3" backgroundColor="$themeLight" />

          {/* 推荐服务 */}
          {/* {params.source !== "post" && (
            <>
              <H1 marginLeft={20} fontSize={16} paddingTop={10}>
                你可能感兴趣
              </H1>
              <HorizontalItemList
                height={global.screenHeight * 0.1}
                source="bottom"
              />
            </>
          )} */}

          <XStack height={global.screenHeight * 0.1} width="100%" />
        </YStack>
      </ScrollView>
    </Theme>
  );

  return (
    <View style={{ flex: 1 }}>
      <Animated.View
        style={{
          position: "absolute",
          left: 0,
          top: 0,
          right: 0,
          zIndex: 999,
          transform: [{ translateY: headerTranslate }],
        }}
      >
        <SafeAreaView edges={["top"]} style={{ backgroundColor: "#ffffff" }}>
          <XStack
            flexDirection="row"
            alignItems="center"
            backgroundColor="$background"
            paddingBottom="$2"
          >
            <Button
              onPress={() => {
                if (source === "ai_home" && !presented) {
                  handlePresentModal(0);
                }
                router.back();
              }}
              size="$1"
              alignSelf="flex-start"
              backgroundColor="transparent"
              pressStyle={{
                backgroundColor: "transparent",
                borderColor: "transparent",
                opacity: 0.8,
              }}
            >
              <ChevronLeft size={30} color="#B66D0E" />
            </Button>
            <XStack flex={0} marginLeft="auto" marginRight="$2" space="$4">
              <TouchableWithoutFeedback onPress={clickLike}>
                {isLiked ? (
                  <FontAwesomeIcon name="heart" size={20} color="#B66D0E" />
                ) : (
                  <FontAwesomeIcon name="heart-o" size={20} color="#000" />
                )}
              </TouchableWithoutFeedback>
              {/* 注释掉分享图标 */}
              {/* <IoniconsIcon name="share-outline" size={20} color="#B66D0E" /> */}
            </XStack>
          </XStack>
        </SafeAreaView>
      </Animated.View>
      <Animated.FlatList
        data={[0]}
        renderItem={renderItem}
        // contentContainerStyle={{ paddingTop: headerHeight }}
        onScroll={Animated.event(
          [{ nativeEvent: { contentOffset: { y: scrollY } } }],
          { useNativeDriver: true }
        )}
      />
    </View>
  );
}

const ReviewPreview = memo(
  ({ item_comments, productId }: { item_comments: any; productId: number }) => {
    if (!item_comments || item_comments.length === 0) {
      return (
        <YStack paddingVertical="$4" paddingHorizontal="4%" alignItems="center">
          <Paragraph color="$gray8" fontSize={16}>
            暂无评论
          </Paragraph>
        </YStack>
      );
    }
    return item_comments.slice(0, 3).map((item, index) => (
      <YStack key={index} paddingVertical="$2" paddingHorizontal="4%">
        <Button
          onPress={() =>
            router.push({
              pathname: "/(outer)/home/review",
              params: { productId },
            })
          }
          unstyled
        >
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
        </Button>
      </YStack>
    ));
  }
);
