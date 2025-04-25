import { ArrowLeft } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { useCallback, useEffect, useState } from "react";
import FastImage from "react-native-fast-image";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  H2,
  Input,
  Label,
  Paragraph,
  Portal,
  Switch,
  XStack,
  YStack,
} from "tamagui";

import ServiceComponent from "@/components/orders/service_comp";
import StarRating from "@/components/orders/star_rating";
import { BottomImagePickerSheet } from "@/components/styled/bottomsheet_picker";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { ImagePreviewEditComp } from "@/components/styled/preview_image";
import { toast } from "@/components/styled/toast";
import { goToUpload, getFilePath } from "@/components/utils/filesystem";
import { AppDispatch, RootState, fileSlice, slices } from "@/src/store";
import { SafeAreaView } from "react-native";

/**
 * @description: 独立的评价页面（用于追加评价）
 * @returns
 */
const EvaluationPage = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { orderId } = useLocalSearchParams();
  const order = useSelector((state: RootState) => state.order.order);
  const [score, setScore] = useState(5);
  const [remark, setRemark] = useState("");
  const [anonymityFlag, setAnonymityFlag] = useState(false);
  const [ratingLevel, setRatingLevel] = useState("非常满意");
  const [firstUpload, setFirstUpload] = useState(true);
  const [pickImagePopup, setPickImagePopup] = useState(false);
  const [modal, setModal] = useState(false);
  const evalImages = useSelector((state: RootState) => state.file.evalImages);
  const [previewIndex, setPreviewIndex] = useState(0);

  const maxLength = 200;

  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(orderId) }));
  }, [orderId]);

  const handleRatingChange = (newRating) => {
    setScore(newRating);
    setRatingLevel(renderRatingLevel(newRating));
  };

  const renderRatingLevel = (rating: number): string => {
    if (rating === 1) return "不满意";
    if (rating === 2) return "较不满意";
    if (rating === 3) return "一般";
    if (rating === 4) return "满意";
    if (rating === 5) return "非常满意";
    return "未评分";
  };

  const handleImageClick = (index: number) => {
    setModal(true);
    setPreviewIndex(index);
  };

  const deleteImage = (index: number) => {
    dispatch(fileSlice.file?.actions.deleteImage(index));
  };

  const handleSubmit = useCallback(async () => {
    if (!score) {
      toast({
        title: "请先评分",
        message: "请先评分",
        symbol: "xmark",
        haptic: "error",
      });
      return;
    }
    if (!remark.trim() && evalImages.length === 0) {
      toast({
        title: "请先评论或上传图片",
        message: "请先评论或上传图片",
        symbol: "xmark",
        haptic: "error",
      });
      return;
    }

    const images = evalImages.map((image) => image.imgUrl);
    const params = {
      orderId: Number(orderId),
      score,
      remark,
      images,
      anonumityFlag: anonymityFlag,
    };

    const res = await dispatch(slices.order.actions.evaluateOrder(params));
    if (res.type.includes("fulfilled")) {
      toast({
        title: "评价成功",
        message: "评价成功",
        symbol: "checkmark",
      });
      router.back();
    }
  }, [orderId, score, remark, evalImages, anonymityFlag]);

  useEffect(() => {
    dispatch(fileSlice.file?.actions.clearImages({ type: "eval" }));
  }, []);

  useEffect(() => {
    if (evalImages.length === 0) {
      setFirstUpload(true);
    }
  }, [evalImages]);

  return (
    <YStack flex={1} backgroundColor="$bottomColor">
      <SafeAreaView style={{ flex: 1 }}>
        <Button
          width="100%"
          height={50}
          position="relative"
          top={0}
          left={0}
          flexDirection="row"
          alignItems="center"
          justifyContent="flex-start"
          space={10}
          onPress={() => router.back()}
          unstyled
        >
          <ArrowLeft size="$1" />
          <H2 fontSize={18}>评价</H2>
        </Button>

        <KeyboardAwareScrollView
          style={{ flex: 1, width: "100%" }}
          resetScrollToCoords={{ x: 0, y: 0 }}
          extraScrollHeight={220}
          scrollEnabled
          contentContainerStyle={{ paddingBottom: 100 }}
        >
          {modal && (
            <Portal>
              <ImagePreviewEditComp
                images={evalImages}
                previewIndex={previewIndex}
                modal={modal}
                setModal={setModal}
                deleteImage={deleteImage}
                type="eval"
              />
            </Portal>
          )}

          <YStack backgroundColor="#fff" padding={20}>
            <ServiceComponent item={order?.items?.[0]} />
          </YStack>

          <YStack
            display="flex"
            flexDirection="column"
            justifyContent="flex-start"
            backgroundColor="#fff"
            padding={20}
          >
            <H2 fontSize={14} marginLeft={3}>
              您对本次服务的评价
            </H2>
            <XStack flex={0} alignItems="center" justifyContent="center">
              <StarRating
                maxStars={5}
                initialRating={score}
                onRatingChange={handleRatingChange}
              />
              <Paragraph textAlign="center" marginLeft="auto" color="$darkGray">
                {ratingLevel}
              </Paragraph>
            </XStack>
          </YStack>

          <YStack
            display="flex"
            flexDirection="column"
            backgroundColor="#fff"
            padding={20}
            marginTop={20}
          >
            <H2 fontSize={14}>评论</H2>

            <YStack space="$3" width="100%">
              <Input
                multiline
                numberOfLines={4}
                value={remark}
                onChangeText={setRemark}
                placeholder="请输入您的评论..."
                textAlignVertical="top"
                borderWidth={1}
                borderColor="$borderColor"
                borderRadius="$2"
                padding="$2"
                height={150}
                backgroundColor="#EDEDED"
              />
              <Paragraph fontSize="$2" color="$gray8" marginLeft="auto">
                {remark.length}/{maxLength} 字
              </Paragraph>

              <YStack space="$2">
                <Paragraph color="$lightGray" fontSize={12}>
                  上传图片(帮助他人更好的了解服务)
                </Paragraph>
                {firstUpload ? (
                  <Button
                    width="100%"
                    height={(global.screenWidth * 0.92 - 20 - 26) / 3}
                    backgroundColor="$bottomColor"
                    onPress={() => setPickImagePopup(true)}
                  >
                    <SvgXml
                      height="30%"
                      xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
                    />
                  </Button>
                ) : (
                  <XStack
                    flexWrap="wrap"
                    gap={10}
                    justifyContent="flex-start"
                    width="100%"
                  >
                    {evalImages.map((image, index) => (
                      <Button
                        key={index}
                        onPress={() => handleImageClick(index)}
                        unstyled
                      >
                        <FastImage
                          source={{ uri: getFilePath(image.imgUrl) }}
                          style={{
                            width: (global.screenWidth * 0.8) / 3,
                            aspectRatio: 1,
                          }}
                        />
                      </Button>
                    ))}
                    {evalImages.length < 9 && (
                      <Button
                        key="button"
                        width={(global.screenWidth * 0.8) / 3}
                        height={(global.screenWidth * 0.8) / 3}
                        backgroundColor="#EDEDED"
                        alignItems="center"
                        justifyContent="center"
                        onPress={() => setPickImagePopup(true)}
                        unstyled
                      >
                        <SvgXml
                          height="30%"
                          xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
                        />
                      </Button>
                    )}
                  </XStack>
                )}
              </YStack>

              <XStack space="$3" alignItems="center">
                <Label
                  htmlFor="anonymous-switch"
                  flex={1}
                  fontSize={14}
                  color="$darkGray"
                >
                  匿名评论
                </Label>
                <Switch
                  id="anonymous-switch"
                  size="$2"
                  checked={anonymityFlag}
                  onCheckedChange={setAnonymityFlag}
                  backgroundColor={anonymityFlag ? "$brown" : "gray"}
                >
                  <Switch.Thumb animation="quick" backgroundColor="#fff" />
                </Switch>
              </XStack>

              <AlertDialogComponent
                title="提交评论"
                description="确定提交评论吗？"
                handleConfirm={handleSubmit}
              >
                <Button
                  height={40}
                  alignSelf="center"
                  marginTop="$3"
                  backgroundColor="$brown"
                  width="50%"
                  color="#fff"
                >
                  提交评论
                </Button>
              </AlertDialogComponent>
            </YStack>
          </YStack>
        </KeyboardAwareScrollView>

        <BottomImagePickerSheet
          isOpen={pickImagePopup}
          onClose={setPickImagePopup}
          goToUpload={(action) =>
            goToUpload({
              action,
              setPopup: setPickImagePopup,
              setFirstUpload,
              selectionLimit: 9,
              dispatch,
              type: "eval",
            })
          }
        />
      </SafeAreaView>
    </YStack>
  );
};

export default EvaluationPage;
