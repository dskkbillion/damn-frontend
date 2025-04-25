import { X } from "@tamagui/lucide-icons";
import * as FileSystem from "expo-file-system";
import * as Sharing from "expo-sharing";
import { memo, useEffect, useState } from "react";
import {
  SafeAreaView,
  TouchableWithoutFeedback,
  Alert,
  FlatList,
  Platform,
} from "react-native";
import DocumentPicker from "react-native-document-picker";
import FastImage from "react-native-fast-image";
import * as ImagePicker from 'expo-image-picker';
import ImageView from "react-native-image-viewing";
import { SvgXml } from "react-native-svg";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { WebView } from "react-native-webview";
import { useDispatch } from "react-redux";
import {
  Button,
  ButtonText,
  Paragraph,
  Portal,
  PortalProvider,
  Sheet,
  styled,
  View,
  XStack,
  YStack,
} from "tamagui";

import { toast } from "../styled/toast";
import { isAxiosSuccess } from "../utils";

import { AppDispatch, fileSlice } from "../../src/store";
import { store } from "../../src/store";
import { launchCamera, launchImageLibrary } from 'react-native-image-picker';
import { CameraOptions } from 'react-native-image-picker';

// ----------------------------------------------------
// function: multiplePicker
// 选择文件、图片
// ----------------------------------------------------
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

/**
 * 上传图片
 * @param assets 图片信息
 * @param type 图片类型
 * @param dispatch
 */
export async function uploadImage({
  assets,
  type,
  dispatch,
}: {
  assets: any[];
  type: string;
  dispatch: AppDispatch;
}) {
  // 完全本地化处理，不依赖网络上传
  for (const asset of assets) {
    try {
      // 直接将图片添加到本地状态
      await dispatch(fileSlice.file.actions.setType(type));

      // 创建本地图片对象
      const localImage = {
        imgName: asset?.fileName || `image_${Date.now()}.jpg`,
        imgUrl: asset?.uri
      };

      // 直接添加到状态
      await dispatch(fileSlice.file.actions.addImage({
        type,
        images: [localImage]
      }));

      console.log('图片已添加到本地状态:', localImage.imgName);

      // 尝试在后台上传，但不阻塞用户操作
      setTimeout(() => {
        try {
          const formData = new FormData();
          formData.append("file", {
            uri: asset?.uri,
            name: asset?.fileName || `image_${Date.now()}.jpg`,
            type: asset?.type || 'image/jpeg',
            quality: 0.3, // 大幅降低质量以减少文件大小
          } as any);

          dispatch(fileSlice.file.actions.uploadFile(formData))
            .catch(error => {
              console.error('后台图片上传失败:', error);
              // 不显示错误提示，因为图片已经在本地显示
            });
        } catch (error) {
          console.error('准备后台上传时出错:', error);
        }
      }, 100);

    } catch (error) {
      console.error('处理图片时出错:', error);
      // 继续处理下一张图片
    }
  }
}

/**
 * 上传文件
 * @param dispatch
 * @param type
 */
export async function pickFile({
  dispatch,
  type,
}: {
  dispatch: any;
  type: string;
}) {
  try {
    const results = await DocumentPicker.pick({
      type: [DocumentPicker.types.allFiles],
      allowMultiSelection: true,
    });

    if (results && results.length === 0) {
      return;
    }

    // 将每个文件转换为 Blob 并添加到 FormData 中
    for (const result of results) {
      const fileExtension = result?.uri?.split(".")?.pop()?.toLowerCase();
      const is_support_file = ["doc", "docx", "pptx", "pdf"].includes(
        fileExtension || ""
      );
      if (!is_support_file) {
        toast({
          title: "不支持的文件类型",
          symbol: "xmark",
          haptic: "warning",
        });
        return;
      }

      const formData = new FormData();

      formData.append("file", {
        uri: result?.uri,
        name: result?.name,
        type: result?.type,
      } as any);

      await dispatch(fileSlice.file.actions.setType(type)); // 设置类型为文件
      const res = await dispatch(fileSlice.file.actions.uploadFile(formData));
      if (isAxiosSuccess(res.type)) {
        alert("上传成功");
      } else {
        alert("上传失败");
      }
    }
  } catch (err) {
    if (DocumentPicker.isCancel(err)) {
      alert();
    } else {
      alert("上传失败");
      throw err;
    }
  }
}

/**
 * 拍照
 */
export async function takePhoto({
  dispatch,
  type,
}: {
  dispatch: any;
  type: string;
}) {
  try {
    // 请求相机权限
    const { status } = await ImagePicker.requestCameraPermissionsAsync();
    if (status !== 'granted') {
      toast({
        title: "需要相机权限",
        symbol: "xmark",
        haptic: "warning",
      });
      return [];
    }

    // 修改配置，使用系统相机
    const result = await ImagePicker.launchCameraAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images, // 只允许图片
      allowsEditing: true, // 允许编辑，可以裁剪图片
      quality: 0.3, // 大幅降低质量以减少文件大小
      presentationStyle: ImagePicker.UIImagePickerPresentationStyle.FULL_SCREEN,
      exif: false,
      // 限制图片尺寸
      aspect: [4, 3],
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      // 返回本地资源，不尝试上传
      return result.assets.map(asset => ({
        uri: asset.uri,
        type: 'image/jpeg',
        fileName: `photo_${Date.now()}.jpg`,
      }));
    } else {
      toast({
        title: "已取消拍照",
        symbol: "xmark",
        haptic: "warning",
      });
      return [];
    }
  } catch (e) {
    console.error("相机错误:", e);
    toast({
      title: "相机启动失败",
      symbol: "xmark",
      haptic: "error",
    });
    return [];
  }
}

/**
 * 从相册选择图片
 */
export async function pickImage({
  selectionLimit,
  type,
  dispatch,
}: {
  selectionLimit: number;
  type: string;
  dispatch: AppDispatch;
}) {
  try {
    // 请求相册权限
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      toast({
        title: "需要相册权限",
        symbol: "xmark",
        haptic: "warning",
      });
      return [];
    }

    // 使用 ImagePicker 代替 launchImageLibrary
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images, // 只允许图片
      allowsMultipleSelection: true,
      selectionLimit,
      quality: 0.3, // 大幅降低质量以减少文件大小
      allowsEditing: true, // 允许编辑，可以裁剪图片
      aspect: [4, 3],
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      // 返回本地资源，不尝试上传
      return result.assets.map(asset => ({
        uri: asset.uri,
        type: 'image/jpeg',
        fileName: `photo_${Date.now()}_${Math.random().toString(36).substring(7)}.jpg`,
      }));
    } else {
      toast({
        title: "已取消选择",
        symbol: "xmark",
        haptic: "warning",
      });
      return [];
    }
  } catch (e) {
    console.error("选择图片错误:", e);
    toast({
      title: "选择图片失败",
      symbol: "xmark",
      haptic: "error",
    });
    return [];
  }
}

interface UploadParams {
  action: string;
  setPopup: any;
  setFirstUpload?: any;
  type: string;
  selectionLimit: number;
  dispatch: AppDispatch;
}

export const goToUpload = async ({
  action,
  type,
  setPopup,
  setFirstUpload,
  selectionLimit,
  dispatch,
}: UploadParams) => {
  if (action === "cameral") {
    setPopup(false);
    const res = await takePhoto({ dispatch, type });
    if (res !== undefined) {
      if (setFirstUpload) {
        setFirstUpload(false);
      }
    }
  } else if (action === "library") {
    setPopup(false);
    const res = await pickImage({ selectionLimit, dispatch, type });
    if (res !== undefined) {
      if (setFirstUpload) {
        setFirstUpload(false);
      }
    }
  } else if (action === "cancle") {
    setPopup(false);
  }
};
// export async function pickDocument() {
//   try {
//     const result = await DocumentPicker.pick({
//       type: [DocumentPicker.types.allFiles],
//     });
//   } catch (err) {
//     if (DocumentPicker.isCancel(err)) {
//       // 用户取消了文档选择
//     } else {
//       throw err;
//     }
//   }
// }

// export function ImageCameralComponent(children: any) {}

// export function ImagePickerComponent(children: any) {
//   const [image, setImage] = useState<string | null>(null);

//   const pickImage = async () => {
//     try {
//       const result = await launchImageLibrary({
//         mediaType: "photo",
//         includeBase64: false,
//         maxHeight: 200,
//         maxWidth: 200,
//         selectionLimit: 9,
//       });

//       if (!result.didCancel && result.assets?.[0]?.uri) {
//         console.log("result", result);
//         setImage(result.assets[0].uri);
//         // console.log("User cancelled image picker");
//       }
//       // console.log("result", result);
//       // if (!result.canceled) {
//       //   setImage(result.assets[0].uri);
//       // }
//     } catch (e) {
//       console.log(e);
//     }
//   };

//   return (
//     <YStack width="100%" height="100%">
//       <Button
//         width="100%"
//         height="100%"
//         onPress={pickImage}
//         backgroundColor="#EDEDED"
//         unstyled
//       >
//         {image && (
//           <Image
//             source={{ uri: image }}
//             style={{ width: "100%", height: "100%" }}
//           />
//         )}
//       </Button>
//     </YStack>
//   );
// }

/*
ImagesUploaded组件用于显示上传的图片，可以显示多张图片，每行最多显示3张图片，超过3张图片时会自动换行，最多显示9张图片。
ImagesUploaded组件接受三个参数：
assets：一个包含图片信息的数组，每个元素都是一个对象，至少包含一个uri属性，表示图片的URL。
setPopup：一个函数，当点击添加新图片的按钮时被调用，用于显示一个弹出窗口或其他类型的界面来选择新的图片。
handleImageClick：一个函数，当点击已上传的图片时被调用，可以用于显示图片的大图或其他相关操作。
*/
export const ImagesUploaded = memo(
  ({
    assets,
    setPopup,
    handleImageClick,
    width,
    height,
  }: {
    assets: any[];
    setPopup;
    handleImageClick;
    width;
    height;
  }) => {
    const rows = [] as string[][];
    const rows_assets = [] as any[][];
    const [newLine, setNewLine] = useState(false);

    // console.log("images", images);
    const images = assets.map((asset) => (asset?.uri ? asset?.uri : asset));

    console.log(newLine);
    for (let i = 0; i < 9; i += 3) {
      rows.push(images.slice(i, i + 3));
      rows_assets.push(assets.slice(i, i + 3));
    }

    useEffect(() => {
      if (images.length % 3 === 0 && images.length !== 0) {
        setNewLine(true);
      } else {
        setNewLine(false);
      }

      if (images.length === 9) {
        setNewLine(false);
      }
    }, [images]);

    return (
      <YStack space="$2">
        {rows.map((row, rowIndex) => (
          <XStack key={rowIndex}>
            {row.map((image, index) => (
              <XStack key={index}>
                <TouchableWithoutFeedback
                  onPress={() => handleImageClick(rows_assets[rowIndex][index])}
                >
                  <View>
                    <FastImage
                      key={index}
                      source={{ uri: image }}
                      style={{
                        width,
                        height,
                        marginRight: index === 2 ? 0 : 10,
                      }}
                    />
                  </View>
                </TouchableWithoutFeedback>
                {rowIndex * 3 + index === images.length - 1 &&
                  (rowIndex * 3 + index + 1) % 3 !== 0 && (
                    <Button
                      key={index + "button"}
                      width={width}
                      height={height}
                      backgroundColor="#EDEDED"
                      alignItems="center"
                      justifyContent="center"
                      unstyled
                      onPress={() => setPopup(true)}
                    >
                      <SvgXml
                        height="30%"
                        xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
                      />
                    </Button>
                  )}
              </XStack>
            ))}
          </XStack>
        ))}
        {newLine && (
          <Button
            key="button"
            width={width}
            height={height}
            backgroundColor="#EDEDED"
            alignItems="center"
            justifyContent="center"
            unstyled
            onPress={() => setPopup(true)}
          >
            <SvgXml
              height="30%"
              xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
            />
          </Button>
        )}
      </YStack>
    );
  }
);

export const PickUpButton = ({ width, height, setPopup }) => {
  return (
    <Button
      width={width}
      height={height}
      backgroundColor="#EDEDED"
      borderRadius={10}
      alignItems="center"
      justifyContent="center"
      onPress={() => setPopup(true)}
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

// ---------------路径处理器---------------
export const getFilePath = (path: any) => {
  if (path === undefined || path === null) {
    return "";
  }
  // 判断是绝对路径还是相对路径
  if (typeof path === 'string') {
    if (path.startsWith("http") || path.startsWith("https")) {
      return path;
    } else if (path.startsWith("file://")) {
      // 如果是本地路径，直接返回
      return path;
    }
  } else {
    // 如果不是字符串，返回空字符串
    return "";
  }

  // 否则拼接服务器地址
  try {
    const server = store?.getState()?.sys?.server;
    if (server) {
      const url = `${server.replace(/\/+$/, "")}/${path.replace(/^\/+/, "")}`;
      return url;
    }
    return path;
  } catch (error) {
    console.error("获取服务器地址失败:", error);
    return path;
  }
};
