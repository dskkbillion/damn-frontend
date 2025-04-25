import { memo } from "react";
import FastImage from "react-native-fast-image";
import { XStack, Button } from "tamagui";

import { getFilePath } from "../utils/filesystem";

import { PickUpButton } from "@/components/styled/bottomsheet_picker";
/**
 * @description 用于显示上传的图片，可以显示多张图片，每行最多显示3张图片，超过3张图片时会自动换行，最多显示9张图片。
 * @param {array} assets - 一个包含图片信息的数组，每个元素都是一个对象(可以包含一个uri属性，表示图片的URL)
 * @param {function} setPopup - 一个函数，当点击添加新图片的按钮时被调用，用于显示一个弹出窗口或其他类型的界面来选择新的图片。
 * @param {function} handleImageClick - 一个函数，当点击已上传的图片时被调用，可以用于显示图片的大图或其他相关操作。
 * @returns {JSX.Element}
 */
export const ImagesUploaded = memo(
  ({ images, handleImageClick }: { images: string[]; handleImageClick }) => {
    console.log(images);
    return (
      <XStack flexWrap="wrap" gap={10} justifyContent="flex-start" width="100%">
        {images.map((image, index) => (
          <Button
            key={index}
            width="33%"
            onPress={() => handleImageClick(index)}
            unstyled
          >
            {/* <Paragraph>{image}</Paragraph> */}
            <FastImage
              source={{
                uri: getFilePath(image),
                priority: FastImage.priority.high,
              }}
              resizeMode={FastImage.resizeMode.stretch}
              style={{
                width: "100%",
                aspectRatio: 1,
              }}
            />
          </Button>
        ))}
      </XStack>
    );
  }
);
