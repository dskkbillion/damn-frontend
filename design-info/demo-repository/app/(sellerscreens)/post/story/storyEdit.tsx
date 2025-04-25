import { router, useLocalSearchParams } from "expo-router";
import { useCallback, useEffect, useState } from "react";
import {
  ActivityIndicator,
  Keyboard,
  TouchableWithoutFeedback,
} from "react-native";
import FastImage from "react-native-fast-image";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, TextArea, View, XStack, YStack } from "tamagui";

import { alert } from "@/components/styled/alert";
import { BottomImagePickerSheet } from "@/components/styled/bottomsheet_picker";
import { ImagePreviewEditComp } from "@/components/styled/preview_image";
import { isAxiosSuccess } from "@/components/utils";
import { getFilePath, goToUpload } from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";

export default function MyStoryEditPage() {
  const dispatch = useDispatch<AppDispatch>();
  const story = useSelector((state: RootState) => state.item.storyDetail);
  const status = useLocalSearchParams().status;
  const [text, setText] = useState("");
  const [popup, setPopup] = useState(false);
  const [firstUpload, setFirstUpload] = useState(true);
  const storyImages = useSelector((state: RootState) => state.file.storyImages);
  const [previewIndex, setPreviewIndex] = useState(0);
  const [showAddButton, setShowAddButton] = useState(false);
  const [modal, setModal] = useState(false);
  const loading = useSelector((state: RootState) => state.user.loading);
  const [showOptions, setShowOptions] = useState(false);
  const handleChange = (text) => {
    setText(text);
  };

  const addStory = async () => {
    if (text.length === 0) {
      alert({
        message: "请输入故事内容",
      });
      return;
    }
    if (storyImages.length === 0) {
      alert({
        message: "至少上传一张图片",
      });
      return;
    }
    const params = {
      content: text,
      images: storyImages.map((image) => image.imgUrl),
    };
    try {
      await dispatch(slices.user.actions.addMyStory(params));
      dispatch(slices.user.actions.setStoryChanged());
      router.back();
    } catch (e) {
      console.log(e);
    }
  };

  const updateStory = async () => {
    if (text.length === 0) {
      alert({
        message: "请输入故事内容",
      });
      return;
    }
    if (storyImages.length === 0) {
      alert({
        message: "至少上传一张图片",
      });
      return;
    }
    const params = {
      id: story?.id,
      content: text,
      images: storyImages.map((image) => image.imgUrl),
    };
    try {
      const res = await dispatch(slices.item.actions.updateStory(params));
      if (isAxiosSuccess(res.type)) {
        alert({
          message: "发布成功",
        });
        dispatch(slices.user.actions.setStoryChanged());
      }
      router.back();
    } catch (e) {
      console.log(e);
    }
  };

  const deleteImage = (index: number) => {
    dispatch(fileSlice.file?.actions.deleteImage(index));
  };

  const handleInputFocus = useCallback(() => {
    if (!showOptions) {
      setShowOptions(true);
    }
  }, []);

  useEffect(() => {
    if (storyImages.length === 0) {
      setFirstUpload(true);
      setModal(false);
    } else {
      setFirstUpload(false);
    }
    if (storyImages.length === 9) {
      setShowAddButton(false);
    } else {
      setShowAddButton(true);
    }
  }, [storyImages, firstUpload]);

  const handleImageClick = (index: number) => {
    // 打开蒙版
    setModal(true);
    // 设置预览图片
    setPreviewIndex(index);
  };

  useEffect(() => {
    dispatch(fileSlice.file.actions.setType("story"));
    dispatch(fileSlice.file.actions.clearImages({ type: "story" }));
  }, []);

  useEffect(() => {
    if (story && story !== undefined && status === "update") {
      setText(story?.content);
      const images = story?.images.map((image) => ({ imgUrl: image }));
      dispatch(fileSlice.file.actions.addImage({ type: "story", images }));
    }
  }, [story]);

  return (
    <YStack height="100%" alignItems="center">
      <ImagePreviewEditComp
        images={storyImages}
        previewIndex={previewIndex}
        modal={modal}
        setModal={setModal}
        deleteImage={deleteImage}
        type="story"
      />
      <ActivityIndicator
        style={{
          display: "flex",
          position: "absolute",
          justifyContent: "center",
          alignContent: "center",
          // top: 0,
        }}
        animating={loading}
        size="large"
        color="#0000ff"
      />

      {showOptions && (
        <TouchableWithoutFeedback
          onPress={() => {
            Keyboard.dismiss();
            setShowOptions(false);
          }}
        >
          <YStack
            width="100%"
            height={global.screenHeight}
            position="absolute"
            left={0}
            bottom={300}
            zIndex={888}
          />
        </TouchableWithoutFeedback>
      )}

      <YStack
        width={global.screenWidth * 0.95}
        alignSelf="center"
        height="30%"
        backgroundColor="#fff"
        marginTop="$6"
        borderTopRightRadius={20}
        borderTopLeftRadius={20}
      >
        <TextArea
          width="100%"
          height="100%"
          placeholder="分享你的故事"
          onFocus={handleInputFocus}
          fontSize={16}
          color="$darkGray"
          backgroundColor="#fff"
          value={text}
          borderWidth={0}
          onChangeText={handleChange}
        />
        <YStack
          backgroundColor="#fff"
          width={global.screenWidth * 0.95}
          height="auto"
          marginBottom="$3"
          borderBottomLeftRadius={20}
          borderBottomRightRadius={20}
        >
          {firstUpload ? (
            <Button
              width={(global.screenWidth * 0.92 - 20 - 26) / 3}
              height={(global.screenWidth * 0.92 - 20 - 26) / 3}
              backgroundColor="#EDEDED"
              marginLeft="$3"
              marginBottom="$3"
              onPress={() => setPopup(true)}
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
              paddingHorizontal="$3"
            >
              {storyImages.map((image, index) => (
                <TouchableWithoutFeedback
                  key={index}
                  onPress={() => handleImageClick(index)}
                >
                  <View>
                    <FastImage
                      source={{
                        uri: getFilePath(image.imgUrl),
                        priority: FastImage.priority.high,
                      }}
                      style={{
                        width: (global.screenWidth * 0.83) / 3,
                        height: (global.screenWidth * 0.83) / 3,
                      }}
                    />
                  </View>
                </TouchableWithoutFeedback>
              ))}
              {showAddButton && (
                <Button
                  key="button"
                  width={(global.screenWidth * 0.83) / 3}
                  height={(global.screenWidth * 0.83) / 3}
                  backgroundColor="#EDEDED"
                  alignItems="center"
                  justifyContent="center"
                  marginBottom="$3"
                  onPress={() => setPopup(true)}
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
      </YStack>
      <Button
        width="30%"
        padding="$2"
        marginLeft="auto"
        marginRight="$3"
        backgroundColor="$brown"
        marginTop="auto"
        marginBottom="$8"
        borderRadius={10}
        alignItems="center"
        unstyled
      >
        <ButtonText
          color="#fff"
          fontSize={16}
          onPress={status === "add" ? () => addStory() : () => updateStory()}
        >
          发布
        </ButtonText>
      </Button>
      <BottomImagePickerSheet
        isOpen={popup}
        onClose={setPopup}
        goToUpload={(action) =>
          goToUpload({
            action,
            setPopup,
            setFirstUpload,
            selectionLimit: 9,
            dispatch,
            type: "story",
          })
        }
      />
    </YStack>
  );
}
