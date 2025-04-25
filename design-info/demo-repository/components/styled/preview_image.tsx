import { X } from "@tamagui/lucide-icons";
import { memo } from "react";
import ImageView from "react-native-image-viewing";
import { ImageSource } from "react-native-image-viewing/dist/@types";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { useDispatch } from "react-redux";
import { Button, PortalProvider, XStack } from "tamagui";

import { AppDispatch, fileSlice } from "@/src/store";

interface ImagePreviewEditCompProps {
  images: any[];
  previewIndex: number;
  modal: boolean;
  setModal: (value: boolean) => void;
  deleteImage: (index: number) => void;
  type: "item" | "win" | "story" | "eval" | `auth_${string}`;
}

/**
 * @description 用于图片预览
 * @function: 图片滑动预览、删除、关闭
 * @param {array} images - 图片数组（不需要imgUrl格式）
 * @param {number} previewIndex - 预览图片索引
 * @param {boolean} modal - 是否显示预览
 * @param {function} setModal - 设置预览状态
 * @param {function} deleteImage - 删除图片
 * @returns {JSX.Element}
 */
export const ImagePreviewEditComp = memo(
  ({
    images,
    previewIndex,
    modal,
    setModal,
    deleteImage,
    type,
  }: ImagePreviewEditCompProps) => {
    const dispatch = useDispatch<AppDispatch>();

    const handleDelete = (imageIndex: number) => {
      dispatch(fileSlice.file.actions.setType(type));
      deleteImage(imageIndex);
      setModal(false);
      // if (images.length === 1) {
      //   setModal(false);
      // }
    };

    if (!images || !Array.isArray(images) || images.length === 0) {
      // 如果图片数组为空或无效，关闭预览并返回null
      if (modal) {
        setModal(false);
      }
      return null;
    }

    // 确保所有图片都有有效的URI
    const validImages = images.filter(image =>
      (typeof image === 'object' && image?.imgUrl) ||
      (typeof image === 'string' && image)
    );

    if (validImages.length === 0) {
      if (modal) {
        setModal(false);
      }
      return null;
    }

    let previewImages: ImageSource[] = [];

    if (typeof validImages[0] === "object") {
      previewImages = validImages.map((image) => ({
        uri: image?.imgUrl,
      }));
    } else {
      previewImages = validImages.map((image) => ({ uri: image }));
    }

    return (
      <PortalProvider>
        <ImageView
          images={previewImages}
          imageIndex={Math.min(previewIndex, validImages.length - 1)}
          visible={modal}
          onRequestClose={() => setModal(false)}
          keyExtractor={(item, index) => index.toString() + type}
          HeaderComponent={({ imageIndex }) => (
            <XStack
              height="auto"
              justifyContent="flex-end"
              marginTop={50}
              marginRight="$3"
              gap="$5"
            >
              <Button unstyled onPress={() => handleDelete(imageIndex)}>
                <AntDesignIcon name="delete" size={20} color="#fff" />
              </Button>
              <Button unstyled onPress={() => setModal(false)}>
                <X size="$1" color="#fff" />
              </Button>
            </XStack>
          )}
        />
      </PortalProvider>
    );
  }
);

/**
 * @description 纯图片预览组件
 * @function: 图片滑动预览、关闭
 * @param {array} images - 图片数组, 格式为 [{ imgUrl: string }] 或者 [string]
 * @param {number} previewIndex - 预览图片索引
 * @param {boolean} modal - 是否显示预览
 * @param {function} setModal - 设置预览状态
 * @returns {JSX.Element}
 */
export const ImagePreviewComp = memo(
  ({
    images,
    previewIndex,
    modal,
    setModal,
  }: {
    images: any;
    previewIndex: number;
    modal: boolean;
    setModal: (value: boolean) => void;
  }) => {
    if (!images || !Array.isArray(images) || images.length === 0) {
      // 如果图片数组为空或无效，关闭预览并返回null
      if (modal) {
        setModal(false);
      }
      return null;
    }

    // 确保所有图片都有有效的URI
    const validImages = images.filter(image => image?.imgUrl || (typeof image === 'string' && image));

    if (validImages.length === 0) {
      if (modal) {
        setModal(false);
      }
      return null;
    }

    console.log("预览图片", validImages);
    return (
      <ImageView
        images={validImages.map((image) => ({ uri: image?.imgUrl || image }))}
        keyExtractor={(item, index) => index.toString()}
        imageIndex={Math.min(previewIndex, validImages.length - 1)}
        visible={modal}
        onRequestClose={() => setModal(false)}
        HeaderComponent={() => (
          <XStack
            height="auto"
            justifyContent="flex-end"
            marginTop={50}
            marginRight="$3"
          >
            <Button unstyled onPress={() => setModal(false)}>
              <X size="$1" color="#fff" />
            </Button>
          </XStack>
        )}
      />
    );
  }
);
