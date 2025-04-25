import { useEffect, useState } from "react";
import { Keyboard } from "react-native";
import { SvgXml } from "react-native-svg";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { useDispatch } from "react-redux";
import {
  Button,
  ButtonText,
  Paragraph,
  PortalProvider,
  Sheet,
  styled,
  XStack,
} from "tamagui";

import { pickFile, pickImage, takePhoto } from "../utils/filesystem";

import { AppDispatch, fileSlice } from "@/src/store";

/**
 * @description: 底部弹窗选择图片（不包含文件）
 * @param isOpen 是否打开
 * @param onClose 关闭回调
 * @param zIndex 弹窗层级
 * @param position 弹窗位置
 * @param goToUpload 选择图片回调
 * @returns
 */

export const BottomImagePickerSheet = ({
  isOpen,
  onClose,
  zIndex = 100000,
  position = 0,
  goToUpload,
  ...props
}) => {
  const [currentPosition, setCurrentPosition] = useState(position);

  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => onClose(open)}
        snapPoints={[25]}
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
        <Sheet.Frame
          paddingHorizontal="$4"
          justifyContent="center"
          height="100%"
          alignItems="center"
          gap="$4"
          backgroundColor="#fff"
        >
          <Button
            width="100%"
            paddingVertical="$2"
            height="auto"
            onPress={() => goToUpload("cameral")}
          >
            <ButtonText fontSize={16} fontWeight="500">
              拍摄
            </ButtonText>
          </Button>
          <Button
            width="100%"
            height="auto"
            paddingVertical="$2"
            onPress={() => goToUpload("library")}
          >
            <ButtonText fontSize={16} fontWeight="500">
              从相册选择
            </ButtonText>
          </Button>
          <Button
            width="100%"
            height="auto"
            paddingVertical="$2"
            onPress={() => goToUpload("cancle")}
          >
            <ButtonText fontSize={16} fontWeight="500">
              取消
            </ButtonText>
          </Button>
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};

/**
 * @description: 触发底部弹窗按钮
 * @param width 宽度
 * @param height 高度
 * @param setPopup 设置弹窗状态
 * @param type 类型: 设置上传图片的类型
 * @param uploadIndex 上传图片的索引
 */

export const PickUpButton = ({
  width,
  height,
  setPopup,
  type,
  uploadIndex,
}: {
  width: number | string;
  height: number | string;
  setPopup: (popup: boolean) => void;
  type: string;
  uploadIndex?: number;
}) => {
  const dispatch = useDispatch<AppDispatch>();

  useEffect(() => {
    dispatch(fileSlice.file.actions.setType(type));
  }, [type]);

  return (
    <Button
      width={width}
      height={height}
      backgroundColor="#EDEDED"
      borderRadius={10}
      alignItems="center"
      justifyContent="center"
      onPress={() => {
        Keyboard.dismiss();
        setPopup(true);
        dispatch(fileSlice.file.actions.setUploadIndex(uploadIndex));
      }}
      unstyled
    >
      <SvgXml
        height="30%"
        width="30%"
        xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
      />
    </Button>
  );
};

/**
 * @description: 底部弹窗选择文件、图片
 * @param isOpen 是否打开
 * @param setIsOpen 设置弹窗状态
 * @param position 弹窗位置
 * @param zIndex 弹窗层级
 * @param limit 选择数量限制
 * @param type 选择类型
 * @returns
 */
export const BottomMultiplePicker = ({
  isOpen,
  setIsOpen,
  position = 0,
  zIndex = 100000,
  limit = 9,
  type,
}: {
  isOpen: boolean;
  setIsOpen: (open: boolean) => void;
  position: number;
  zIndex: number;
  limit: number;
  type: string;
}) => {
  const StyledButton = styled(Button, {
    alignItems: "center",
    justifyContent: "center",
    padding: 0,
    minWidth: 0, // reset any default Button padding & size
  });
  const [currentPosition, setCurrentPosition] = useState(position);
  const dispatch = useDispatch<AppDispatch>();
  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => setIsOpen(open)}
        snapPoints={[20]}
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
        <Sheet.Frame
          flexDirection="column"
          justifyContent="center"
          padding="$4"
          height="100%"
          alignItems="center"
          backgroundColor="#EDEDED"
        >
          <XStack justifyContent="space-evenly" width="90%" alignSelf="center">
            {/* 拍照 */}
            <StyledButton
              flexDirection="column"
              alignItems="center"
              height="auto"
              onPress={() => {
                setIsOpen(false);
                takePhoto({ dispatch, type });
              }}
              backgroundColor="#EDEDED"
            >
              <XStack backgroundColor="#fff" padding="$2" borderRadius={10}>
                <FontAwesomeIcon name="camera" size={25} color="#585D63" />
              </XStack>
              <Paragraph color="$darkGray">拍照</Paragraph>
            </StyledButton>
            {/* 从相册选择 */}
            <StyledButton
              flexDirection="column"
              alignItems="center"
              height="auto"
              backgroundColor="#EDEDED"
              onPress={() => {
                setIsOpen(false);
                pickImage({
                  selectionLimit: limit,
                  type,
                  dispatch,
                });
              }}
            >
              <XStack backgroundColor="#fff" padding="$2" borderRadius={10}>
                <FontAwesomeIcon name="photo" size={25} color="#585D63" />
              </XStack>
              <Paragraph color="$darkGray">相册</Paragraph>
            </StyledButton>
            {/* 文件上传 */}
            <StyledButton
              flexDirection="column"
              alignItems="center"
              height="auto"
              backgroundColor="#EDEDED"
              onPress={() => {
                setIsOpen(false);
                pickFile({ dispatch, type });
              }}
            >
              <XStack backgroundColor="#fff" padding="$2" borderRadius={10}>
                <FontAwesomeIcon name="file" size={25} color="#585D63" />
              </XStack>
              <Paragraph color="$darkGray">文件</Paragraph>
            </StyledButton>
          </XStack>
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};
