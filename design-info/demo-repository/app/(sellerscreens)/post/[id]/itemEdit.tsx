import { Check, ChevronLeft, X } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import {
  createContext,
  memo,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  Text,
  TouchableOpacity,
  TextInput,
  Platform,
  Keyboard,
  FlatList,
  TouchableWithoutFeedback,
} from "react-native";
import FastImage from "react-native-fast-image";

import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { SafeAreaView } from "react-native-safe-area-context";
import { SvgXml } from "react-native-svg";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H1,
  Input,
  Paragraph,
  Separator,
  XStack,
  YStack,
  Checkbox,
  Dialog,
  H2,
  View,
  Portal,
} from "tamagui";

import ButtonWithText from "@/components/button_choose_service";
import { alert } from "@/components/styled/alert";
import { BottomSheetWithButtons } from "@/components/styled/bottomsheet_buttons";
import { ImagePreviewEditComp } from "@/components/styled/preview_image";
import { isAxiosSuccess, isFloatNumber, isIntNumber } from "@/components/utils";
import { getFilePath, goToUpload } from "@/components/utils/filesystem";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";
import { BottomImagePickerSheet } from "@/components/styled/bottomsheet_picker";
/**
/**
 * @description 处理待发布的服务
 */
interface ServicePostContextType {
  name: string;
  setName: (name: string) => void;

  images: string[];
  setImages: (images: string[]) => void;
  description: string;
  setDescription: (description: string) => void;
  winImages: string[];
  setWinImages: (images: string[]) => void;
  prices: {
    std: string;
    bsc: string;
    prem: string;
  };
  setPrices: (prices: any) => void;
  features: featureType[];
  setFeatures: (
    features: featureType[] | ((prevFeatures: featureType[]) => featureType[])
  ) => void;
  productMaterials: productMaterialsType[];
  setProductMaterials: (
    productMaterials:
      | productMaterialsType[]
      | ((preMaterials: productMaterialsType[]) => productMaterialsType[])
  ) => void;
  freqQuestions: freqQuestionsType[];
  setFreqQuestions: (
    freqQuestions:
      | freqQuestionsType[]
      | ((preQuestions: freqQuestionsType[]) => freqQuestionsType[])
  ) => void;
}

interface productMaterialsType {
  id: string;
  question: string;
  type: string;
}

interface freqQuestionsType {
  id: string;
  question: string;
  answer: string;
  type: string;
}

export interface featureType {
  id: string;
  key: string;
  val: {
    std: string | boolean;
    bsc: string | boolean;
    prem: string | boolean;
  }; // std,bsc,pre
  type: string;
}

export const ItemPostContext = createContext<ServicePostContextType>({
  name: "",
  setName: () => {},
  images: [],
  setImages: () => {},
  description: "",
  setDescription: () => {},
  winImages: [],
  setWinImages: () => {},
  prices: {
    std: "",
    bsc: "",
    prem: "",
  },
  setPrices: () => {},
  features: [],
  setFeatures: () => {},
  productMaterials: [],
  setProductMaterials: () => {},
  freqQuestions: [],
  setFreqQuestions: () => {},
});

/**
 * @description 编辑服务（创建、编辑）
 * @param {string} id - 商品ID(创建时为add，编辑时为商品ID)
 */
const AwaitPostServicePage = memo(() => {
  const id = useLocalSearchParams()?.id;
  const savedData = useSelector((state: RootState) => state.post.post_data);
  const tenantId = useSelector((state: RootState) => state.user.data?.id);
  const dispatch = useDispatch<AppDispatch>();

  // 初始化状态
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [images, setImages] = useState<string[]>([]);
  const [winImages, setWinImages] = useState<string[]>([]);
  const [prices, setPrices] = useState({
    std: "",
    bsc: "",
    prem: "",
  });
  const [features, setFeatures] = useState([
    {
      id: "0",
      key: "deliveryDay",
      val: { std: "", bsc: "", prem: "" },
      type: "input",
    },
    {
      id: "1",
      key: "editNum",
      val: { std: "", bsc: "", prem: "" },
      type: "input",
    },
  ] as featureType[]);
  const [productMaterials, setProductMaterials] = useState<
    productMaterialsType[]
  >([]);
  const [freqQuestions, setFreqQuestions] = useState<freqQuestionsType[]>([]);

  // 从 savedData 更新状态
  useEffect(() => {
    if (savedData && id !== "add" && savedData.variants) {
      // 找到对应的套餐索引
      const basicIndex = savedData.variants.findIndex((v) => v.name === "基础");
      const advancedIndex = savedData.variants.findIndex(
        (v) => v.name === "进阶"
      );
      const premiumIndex = savedData.variants.findIndex(
        (v) => v.name === "优质"
      );

      // 设置基本信息
      setName(savedData.name || "");
      setDescription(savedData.description || "");
      setImages(savedData.images || []);
      setWinImages(savedData.winImages || []);

      // 添加图片
      dispatch(
        fileSlice.file.actions.addImage({
          type: "item",
          images: savedData?.images || [],
        })
      );
      dispatch(
        fileSlice.file.actions.addImage({
          type: "win",
          images: savedData?.winImages || [],
        })
      );

      // 只有在找到对应套餐时才设置价格和特性
      if (basicIndex !== -1 && advancedIndex !== -1 && premiumIndex !== -1) {
        // 根据套餐名称设置价格
        setPrices({
          bsc: String(savedData.variants[basicIndex].sellingPrice || ""),
          std: String(savedData.variants[advancedIndex].sellingPrice || ""),
          prem: String(savedData.variants[premiumIndex].sellingPrice || ""),
        });

        // 处理基础特性
        const baseFeatures = [
          {
            id: "0",
            key: "deliveryDay",
            val: {
              bsc: String(savedData.variants[basicIndex].deliveryDay || ""),
              std: String(savedData.variants[advancedIndex].deliveryDay || ""),
              prem: String(savedData.variants[premiumIndex].deliveryDay || ""),
            },
            type: "input",
          },
          {
            id: "1",
            key: "editNum",
            val: {
              bsc: String(savedData.variants[basicIndex].editNum || ""),
              std: String(savedData.variants[advancedIndex].editNum || ""),
              prem: String(savedData.variants[premiumIndex].editNum || ""),
            },
            type: "input",
          },
        ];

        // 处理额外特性
        const extraFeatures =
          savedData.variants[basicIndex].feature?.map((feature, index) => ({
            id: String(index + 2),
            key: feature.key,
            val: {
              bsc: savedData.variants[basicIndex].feature?.[index]?.val || "",
              std:
                savedData.variants[advancedIndex].feature?.[index]?.val || "",
              prem:
                savedData.variants[premiumIndex].feature?.[index]?.val || "",
            },
            type: feature.type || "input",
          })) || [];

        // 合并基础特性和额外特性
        setFeatures([...baseFeatures, ...extraFeatures]);
      }

      // 处理材料和问题
      if (savedData.productMaterials) {
        setProductMaterials(
          savedData.productMaterials.filter(
            (item) => item.type === "TEXT" || item.type === "ATTACHMENT"
          )
        );
        setFreqQuestions(
          savedData.productMaterials.filter((item) => item.type === "PROBLEM")
        );
      }
    }
  }, [savedData, id]);

  // 优化 context value 的 memoization
  const contextValue = useMemo(
    () => ({
      name,
      setName,
      description,
      setDescription,
      images,
      setImages,
      winImages,
      setWinImages,
      prices,
      setPrices,
      features,
      setFeatures,
      productMaterials,
      setProductMaterials,
      freqQuestions,
      setFreqQuestions,
    }),
    [
      name,
      description,
      images,
      winImages,
      prices,
      features,
      productMaterials,
      freqQuestions,
    ]
  );

  const [selectedButton, setSelectedButton] = useState<string>("bsc");

  const onValueChange = useCallback((value: string) => {
    setSelectedButton(value);
  }, []);

  const [openDialog, setOpenDialog] = useState(false);
  const [reminder, setReminder] = useState("");
  const [isFilled, setIsFilled] = useState(false);
  const [isBottomPopup, setIsBottomPopup] = useState(false);

  const acquireParams = useCallback(() => {
    console.log("加载的常见问题", productMaterials);
    console.log("加载的常见问题", freqQuestions);
    const requiredMaterials = productMaterials.map((material) => ({
      question: material.question,
      answer: "",
      type: material.type,
    }));

    const commonQuetsions = freqQuestions.map((item) => ({
      question: item.question,
      answer: item.answer,
      type: "PROBLEM",
    }));

    const params = {
      name,
      images,
      description,
      winImages,
      variants: [
        {
          name: "基础",
          sellingPrice: prices.bsc,
          deliveryDay: features[0].val.bsc,
          editNum: features[1].val.bsc,
          feature: features.slice(2).map((f) => ({
            key: f.key,
            val: f.val.bsc,
            type: f.type,
          })),
        },
        {
          name: "进阶",
          sellingPrice: prices.std,
          deliveryDay: features[0].val.std,
          editNum: features[1].val.std,
          feature: features.slice(2).map((f) => ({
            key: f.key,
            val: f.val.std,
            type: f.type,
          })),
        },
        {
          name: "优质",
          sellingPrice: prices.prem,
          deliveryDay: features[0].val.prem,
          editNum: features[1].val.prem,
          feature: features.slice(2).map((f) => ({
            key: f.key,
            val: f.val.prem,
            type: f.type,
          })),
        },
      ],
      productMaterials: [...commonQuetsions, ...requiredMaterials],
    };

    return params;
  }, [
    id,
    tenantId,
    name,
    description,
    images,
    winImages,
    prices,
    features,
    productMaterials,
    freqQuestions,
  ]);

  const handlePostPress = useCallback(() => {
    const params = acquireParams();
    const [isFilled, message] = checkForm(params);
    setOpenDialog(true);
    setIsFilled(isFilled as boolean);
    setOpenDialog(true);
    setReminder(message as string);
  }, [contextValue]);

  // 函数：发布服务
  const postItem = async () => {
    try {
      if (isFilled) {
        if (id === "add") {
          console.log("创建服务");
          const params = acquireParams();
          const res = await dispatch(
            slices.post?.actions.createPostItem(params)
          );
          if (isAxiosSuccess(res.type)) {
            alert({ message: "发布成功" });
            router.replace("/(sellerscreens)/post");
          } else {
            alert({ message: `发布失败: ${res?.payload?.msg}` });
          }
        } else {
          //
          const params = acquireParams();
          let itemParams;

          if (savedData?.productType === "draft") {
            // 草稿商品发布
            itemParams = {
              ...params,
              id: Number(id),
              tenantId,
              state: "normal",
              productType: "product",
              selectionMode: "customize",
            };
          } else {
            // 在卖商品的更新
            itemParams = {
              ...params,
              id: Number(id),
              tenantId,
              state: "normal",
              selectionMode: "customize",
            };
            console.log("商品更新", itemParams);
          }
          const res = await dispatch(
            slices.post?.actions.updatePostItem(itemParams)
          );
          if (isAxiosSuccess(res.type)) {
            alert({ message: "发布成功" });
            router.replace("/(sellerscreens)/post");
          } else {
            alert({ message: `发布失败: ${res?.payload?.msg}` });
          }
        }
      }
    } catch (e) {
      console.log(e);
    }
  };

  // 函数：检查表达是否完整/合规
  function checkForm(params) {
    if (params.name === "") {
      return [false, "请填写服务名称"];
    } else if (params.description === "") {
      return [false, "请填写服务描述"];
    } else if (params.images.length === 0) {
      return [false, "请上传服务图片(至少一张)"];
    } else if (
      params.variants[0].sellingPrice === "" ||
      params.variants[1].sellingPrice === "" ||
      params.variants[2].sellingPrice === ""
    ) {
      return [false, "服务价格未完善"];
    } else if (
      isFloatNumber(params.variants[0].sellingPrice) === false ||
      isFloatNumber(params.variants[1].sellingPrice) === false ||
      isFloatNumber(params.variants[2].sellingPrice) === false
    ) {
      return [false, "服务价格不符合要求，要求为数字且最多两位小数"];
    } else if (
      params.variants[0].deliveryDay === "" ||
      params.variants[1].deliveryDay === "" ||
      params.variants[2].deliveryDay === ""
    ) {
      return [false, "请填写服务交付时间"];
    } else if (
      isIntNumber(params.variants[0].deliveryDay) === false ||
      isIntNumber(params.variants[1].deliveryDay) === false ||
      isIntNumber(params.variants[2].deliveryDay) === false
    ) {
      return [false, "服务交付时间不符合要求，要求为整数"];
    } else if (
      params.variants[0].editNum === "" ||
      params.variants[1].editNum === "" ||
      params.variants[2].editNum === ""
    ) {
      return [false, "请填写服务修改次数"];
    } else if (
      isIntNumber(params.variants[0].editNum) === false ||
      isIntNumber(params.variants[1].editNum) === false ||
      isIntNumber(params.variants[2].editNum) === false
    ) {
      return [false, "服务修改次数不符合要求，要求为整数"];
    } else if (params.productMaterials.length === 0) {
      return [true, "您未填写卖家所需提供的材料，请确认是否发布？"];
    } else {
      return [true, "您的服务信息已完善，请确认是否发布？"];
    }
  }

  // 函数：返回上一页
  const handleBackPress = useCallback(() => {
    if (!savedData) {
      router.back();
      return;
    }

    const currentParams = acquireParams();

    // 添加空值检查
    if (!currentParams || !savedData.variants) {
      router.back();
      return;
    }

    // 格式化当前参数
    const current = {
      name: currentParams.name || "",
      description: currentParams.description || "",
      images: [...(currentParams.images || [])].sort(),
      winImages: [...(currentParams.winImages || [])].sort(),
      variants: (currentParams.variants || [])
        .map((v) => ({
          name: v.name || "",
          sellingPrice: Number(v.sellingPrice || 0),
          deliveryDay: Number(v.deliveryDay || 0),
          editNum: Number(v.editNum || 0),
          feature: (v.feature || [])
            .map((f) => ({
              key: f.key || "",
              val: f.val || "",
              type: f.type || "",
            }))
            .sort((a, b) => (a.key || "").localeCompare(b.key || "")),
        }))
        .sort((a, b) => (a.name || "").localeCompare(b.name || "")),
      productMaterials: (currentParams.productMaterials || [])
        .map((m) => ({
          question: m.question || "",
          answer: m.answer || "",
          type: m.type || "",
        }))
        .sort((a, b) => (a.question || "").localeCompare(b.question || "")),
    };

    // 格式化初始参数
    const initial = {
      name: savedData.name || "",
      description: savedData.description || "",
      images: [...(savedData.images || [])].sort(),
      winImages: [...(savedData.winImages || [])].sort(),
      variants: (savedData.variants || [])
        .map((v) => ({
          name: v.name || "",
          sellingPrice: Number(v.sellingPrice || 0),
          deliveryDay: Number(v.deliveryDay || 0),
          editNum: Number(v.editNum || 0),
          feature: (v.feature || [])
            .map((f) => ({
              key: f.key || "",
              val: f.val || "",
              type: f.type || "",
            }))
            .sort((a, b) => (a.key || "").localeCompare(b.key || "")),
        }))
        .sort((a, b) => (a.name || "").localeCompare(b.name || "")),
      productMaterials: (savedData.productMaterials || [])
        .map((m) => ({
          question: m.question || "",
          answer: m.answer || "",
          type: m.type || "",
        }))
        .sort((a, b) => (a.question || "").localeCompare(b.question || "")),
    };

    // 检查每个字段的差异
    const differences = {
      name:
        current.name !== initial.name
          ? { current: current.name, initial: initial.name }
          : null,
      description:
        current.description !== initial.description
          ? { current: current.description, initial: initial.description }
          : null,
      images:
        JSON.stringify(current.images) !== JSON.stringify(initial.images)
          ? { current: current.images, initial: initial.images }
          : null,
      winImages:
        JSON.stringify(current.winImages) !== JSON.stringify(initial.winImages)
          ? { current: current.winImages, initial: initial.winImages }
          : null,
      variants:
        JSON.stringify(current.variants) !== JSON.stringify(initial.variants)
          ? { current: current.variants, initial: initial.variants }
          : null,
      productMaterials:
        JSON.stringify(current.productMaterials) !==
        JSON.stringify(initial.productMaterials)
          ? {
              current: current.productMaterials,
              initial: initial.productMaterials,
            }
          : null,
    };

    // 打印差异
    console.log("Differences found:");
    Object.entries(differences).forEach(([key, diff]) => {
      if (diff) {
        console.log(`\n${key}:`);
        console.log("Current:", JSON.stringify(diff.current, null, 2));
        console.log("Initial:", JSON.stringify(diff.initial, null, 2));
      }
    });

    const hasChanges = Object.values(differences).some((diff) => diff !== null);

    if (hasChanges) {
      setIsBottomPopup(true);
    } else {
      router.back();
    }
  }, [savedData, acquireParams]);

  /**
   * @description 保存服务
   */
  const saveItem = useCallback(async () => {
    let itemParams;
    try {
      if (savedData?.productType === "draft") {
        // 草稿商品的保存：更新草稿
        itemParams = acquireParams();
        itemParams["id"] = Number(id);
        itemParams["tenantId"] = tenantId;
        itemParams["state"] = "normal";
        itemParams["productType"] = "draft";
        itemParams["selectionMode"] = "customize";
        const res = await dispatch(
          slices.post?.actions.updatePostItem(itemParams)
        );
        if (isAxiosSuccess(res.type)) {
          alert({ message: "保存成功" });
          await dispatch(slices.post?.actions.setChanged());
        } else {
          alert({ message: `保存失败: ${res?.payload?.msg}` });
        }
      } else {
        // 在卖商品的保存：创建草稿
        itemParams = acquireParams();
        itemParams["productType"] = "draft";
        await dispatch(slices.post?.actions.createPostItem(itemParams));
      }

      setIsBottomPopup(false);
      router.back();
    } catch (e) {
      console.log(e);
    }
  }, [features, images, name, prices, productMaterials, winImages]);

  useEffect(() => {
    if (id !== "add") {
      // 清除图片
      dispatch(fileSlice.file.actions.clearAllImages());
      dispatch(slices.post?.actions.fetchItemDetail({ id: Number(id) }));
    }
  }, [id]);

  // 在组件卸载时清空数据
  useEffect(() => {
    return () => {
      // 清空 post_data
      dispatch(slices.post.actions.clearItemDetail());

      // 清空图片数据
      dispatch(fileSlice.file.actions.clearAllImages());

      // 重置 Context 数据
      setName("");
      setDescription("");
      setImages([]);
      setWinImages([]);
      setPrices({
        std: "",
        bsc: "",
        prem: "",
      });
      setFeatures([
        {
          id: "0",
          key: "deliveryDay",
          val: {
            std: "",
            bsc: "",
            prem: "",
          },
          type: "input",
        },
        {
          id: "1",
          key: "editNum",
          val: {
            std: "",
            bsc: "",
            prem: "",
          },
          type: "input",
        },
        // ... 其他默认 features
      ]);
      setProductMaterials([]);
      setFreqQuestions([]);
    };
  }, [dispatch]); // 只依赖 dispatch

  console.log("savedData:", savedData?.productMaterials);

  // useEffect(
  return (
    <ItemPostContext.Provider value={contextValue}>
      <SafeAreaView style={{ flex: 1 }}>
        <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
          <KeyboardAwareScrollView
            enableOnAndroid
            enableAutomaticScroll
            keyboardShouldPersistTaps="never"
            enableResetScrollToCoords={false}
            keyboardDismissMode="on-drag"
            extraScrollHeight={Platform.OS === "ios" ? 20 : 80}
            contentContainerStyle={{ flexGrow: 1 }}
          >
            <YStack width="100%" height="100%">
              {/* 发布提示 */}
              <Portal>
                <DiagalogToPost
                  open={openDialog}
                  setOpen={setOpenDialog}
                  reminder={reminder}
                  isFilled={isFilled}
                  handlePost={postItem}
                />
              </Portal>

              {/* 底部弹窗 */}
              <BottomSheetWithButtons
                isOpen={isBottomPopup}
                onClose={setIsBottomPopup}
                buttons={["不保存", "保存到草稿"]}
                title="您有未保存的内容，是否保存?"
                handleCancel={() => router.back()}
                handleComfirm={saveItem}
                snapPoints={[20]}
              />

              {/* top fixed */}
              <XStack
                width="100%"
                position="relative"
                top={0}
                flexDirection="row"
                alignItems="center"
                justifyContent="space-between"
              >
                <TouchableOpacity onPress={handleBackPress}>
                  <ChevronLeft size="$3" color="#B66D0E" />
                </TouchableOpacity>
                <Button
                  marginHorizontal={10}
                  width="18%"
                  height={30}
                  backgroundColor="$brown"
                  onPress={handlePostPress}
                >
                  <ButtonText color="$white" fontSize={15}>
                    发布
                  </ButtonText>
                </Button>
              </XStack>

              {/* 替换原来的 FlatList */}
              <YStack flex={1} paddingBottom={50}>
                <YStack
                  flexDirection="column"
                  marginHorizontal="$3"
                  marginVertical="4%"
                  flex={1}
                  borderRadius={20}
                  backgroundColor="#fff"
                >
                  {/* 商品名称 & 描述 */}
                  <ItemNameAndDescription />

                  {/* 商品图片 */}
                  <ItemImageUploader savedData={savedData} />
                </YStack>

                {/* 商品规格 */}
                <YStack width="100%" backgroundColor="$background">
                  <ButtonWithText
                    status={id === "add" ? "newEdit" : "enableEdit"}
                    onValueChange={onValueChange}
                  >
                    <ItemSpecContent type={selectedButton} />
                  </ButtonWithText>

                  <Separator paddingTop="4%" />
                </YStack>

                <Separator paddingTop="$2" />

                {/* 常见问题编辑 */}
                <FreqQuestionContent />

                <Separator paddingTop="$2" />

                {/* 需要卖家提供 */}
                <BuyerProvideComp />
                <YStack
                  flexDirection="column"
                  width="100%"
                  marginTop="$2"
                  alignSelf="center"
                  backgroundColor="$background"
                >
                  <XStack
                    flexDirection="row"
                    justifyContent="space-between"
                    alignItems="center"
                    marginHorizontal="6.5%"
                  >
                    <H1 fontSize={15}>成功案例</H1>
                  </XStack>
                  <CaseShowComp savedData={savedData} />
                </YStack>
              </YStack>
            </YStack>
          </KeyboardAwareScrollView>
        </TouchableWithoutFeedback>
      </SafeAreaView>
    </ItemPostContext.Provider>
  );
});

/**
 * @description 商品图片上传
 */
const ItemImageUploader = memo(({ savedData }: { savedData: any }) => {
  const [firstUpload, setFirstUpload] = useState(true);
  const [pickImagePopup, setPickImagePopup] = useState(false);
  const [modal, setModal] = useState(false);
  const itemImages = useSelector((state: RootState) => state.file.itemImages);
  const [previewIndex, setPreviewIndex] = useState(0);
  const [showAddButton, setShowAddButton] = useState(true);
  const params = useLocalSearchParams();
  const { images, setImages } = useContext(ItemPostContext);

  const dispatch = useDispatch<AppDispatch>();
  const handleImageClick = (index: number) => {
    // 打开蒙版
    setModal(true);
    // 设置预览图片
    setPreviewIndex(index);
  };

  const deleteImage = (index: number) => {
    dispatch(fileSlice.file.actions.deleteImage(index));
  };

  const setImageMode = useCallback(async () => {
    if (params?.id === "add" && firstUpload) {
      await dispatch(fileSlice.file.actions.setType("item"));
      await dispatch(fileSlice.file.actions.clearImages({ type: "item" }));
    } else {
      await dispatch(fileSlice.file.actions.setType("item"));
    }
    setPickImagePopup(true);
  }, [firstUpload, params?.id, dispatch]);

  useEffect(() => {
    if (itemImages.length === 0) {
      setFirstUpload(true);
      setModal(false);
    } else {
      setFirstUpload(false);
      setModal(false);
    }
    if (itemImages.length === 9) {
      setShowAddButton(false);
    } else {
      setShowAddButton(true);
    }
    setImages(itemImages.map((image) => image.imgUrl));
  }, [itemImages, firstUpload, setImages]);

  return (
    <>
      <ImagePreviewEditComp
        images={itemImages}
        previewIndex={previewIndex}
        modal={modal}
        setModal={setModal}
        deleteImage={deleteImage}
        type="item"
      />

      <YStack marginTop="auto" marginHorizontal="$3" marginBottom="$3">
        {firstUpload ? (
          <Button
            width={(global.screenWidth * 0.92 - 20 - 26) / 3}
            height={(global.screenWidth * 0.92 - 20 - 26) / 3}
            backgroundColor="$bottomColor"
            onPress={() => setImageMode()}
          >
            <SvgXml
              height="30%"
              xml={`<svg t="1706105333890" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="3843" width="200" height="200"><path d="M864 800a32 32 0 0 0 32-32V256a32 32 0 0 0-32-32H160a32 32 0 0 0-32 32v512a32 32 0 0 0 32 32z m0 64H160a96 96 0 0 1-96-96V256a96 96 0 0 1 96-96h704a96 96 0 0 1 96 96v512a96 96 0 0 1-96 96z" p-id="3844"></path><path d="M384 432a48 48 0 1 0-48 48 48 48 0 0 0 48-48z m64 0a112 112 0 1 1-112-112 112 112 0 0 1 112 112z m55.68 325.44a32 32 0 1 1-47.36-42.88l175.04-192a32 32 0 0 1 47.36 0l112.96 124.16a32 32 0 1 1-47.36 42.88l-89.28-98.24z m-225.92 1.92a32 32 0 0 1-43.52-46.72l138.56-128a32 32 0 0 1 43.2 0l53.76 49.28a32 32 0 1 1-43.52 47.04l-32-29.12z" p-id="3845"></path></svg>`}
            />
          </Button>
        ) : (
          <XStack flexWrap="wrap" gap={10} justifyContent="flex-start">
            {itemImages.map((image, index) => (
              <TouchableWithoutFeedback
                key={index}
                onPress={() => handleImageClick(index)}
              >
                <View>
                  <FastImage
                    source={{
                      uri: getFilePath(image.imgUrl),
                      priority: FastImage.priority.low,
                    }}
                    resizeMode={FastImage.resizeMode.stretch}
                    style={{
                      width: (global.screenWidth * 0.8) / 3, // 减去 gap 的宽度
                      aspectRatio: 1,
                    }}
                  />
                </View>
              </TouchableWithoutFeedback>
            ))}
            {showAddButton && (
              <Button
                key="button"
                width={(global.screenWidth * 0.8) / 3}
                height={(global.screenWidth * 0.8) / 3}
                backgroundColor="#EDEDED"
                alignItems="center"
                justifyContent="center"
                onPress={() => setImageMode()}
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
            type: "item",
          })
        }
      />
    </>
  );
});

/**
 * @description: 商品名称 & 描述
 * @return {*}
 */
const ItemNameAndDescription = memo(() => {
  const { name, setName, description, setDescription } =
    useContext(ItemPostContext);

  return (
    <YStack>
      <Input
        width="100%"
        value={name}
        onChangeText={setName}
        height={70}
        placeholder="服务名称"
        placeholderTextColor="$darkGray"
        padding="$3"
        borderBottomLeftRadius={0}
        borderBottomRightRadius={0}
        borderWidth={0}
        fontWeight="600"
        fontSize={20}
      />
      <XStack paddingTop="$1" backgroundColor="$bottom" />
      <Input
        multiline
        placeholder="描述一下您的服务的具体信息，如..."
        backgroundColor="#fff"
        value={description}
        onChangeText={setDescription}
        placeholderTextColor="$darkGray"
        width="100%"
        color="#000"
        fontSize={14}
        padding="$3"
        height={100}
        unstyled
      />
    </YStack>
  );
});

/**
 * @description: 规格内容
 * @param {type}
 * @return {*}
 */
const ItemSpecContent = ({ type }) => {
  const { features, setFeatures } = useContext(ItemPostContext);
  const [delNum, setDelNum] = useState(0);

  // 添加新条目
  function addNewItem(type: string) {
    if (type === "input") {
      const newItem = {
        id: String(features.length) + String(delNum),
        val: {
          std: "",
          bsc: "",
          prem: "",
        },
        key: "",
        type,
      };
      setFeatures([...features, newItem]);
    } else {
      const newItem = {
        id: String(features.length) + String(delNum),
        val: {
          std: false,
          bsc: false,
          prem: false,
        },
        key: "",
        type,
      };
      setFeatures([...features, newItem]);
    }
  }

  const handleDeleteItem = (index) => {
    setFeatures((prevItem) => prevItem.filter((item) => item.id !== index));
    setDelNum((prev) => prev + 1);
  };

  return (
    <YStack>
      <YStack>
        {features.map((item, index) => (
          <SpecItem
            key={index}
            item={item}
            type={type}
            handleDeleteItem={handleDeleteItem}
          />
        ))}
      </YStack>

      <Paragraph color="$lightGray" marginTop="$3" alignSelf="center">
        选择你想添加规格的类型
      </Paragraph>

      <XStack flexDirection="row" paddingVertical={10} justifyContent="center">
        {/* add Item */}
        <Button
          flexDirection="row"
          onPress={() => addNewItem("input")}
          paddingVertical={5}
          width="40%"
          borderTopLeftRadius={10}
          borderBottomLeftRadius={10}
          justifyContent="center"
          color="$text"
          backgroundColor="$darkGray"
          unstyled
        >
          输入
        </Button>
        <Button
          flexDirection="row"
          onPress={() => addNewItem("select")}
          paddingVertical={5}
          justifyContent="center"
          borderTopRightRadius={10}
          borderBottomRightRadius={10}
          width="40%"
          color="$white"
          backgroundColor="$brown"
          unstyled
        >
          单选
        </Button>
      </XStack>
    </YStack>
  );
};

/**
 * @description: 规格item
 * @param {item,type,handleDeleteItem}
 * @return {*}
 */
const SpecItem = memo(
  ({
    item,
    type,
    handleDeleteItem,
  }: {
    item: featureType;
    type: string;
    handleDeleteItem: (id: string) => void;
  }) => {
    const { setFeatures } = useContext(ItemPostContext);

    const handleFeatureNameChange = useCallback(
      (text) => {
        setFeatures((prev) =>
          prev.map((i) => (i === item ? { ...i, key: text } : i))
        );
      },
      [item, setFeatures]
    );

    const handleCheckboxChange = useCallback(() => {
      setFeatures((prev) =>
        prev.map((i) =>
          i === item ? { ...i, val: { ...i.val, [type]: !i.val[type] } } : i
        )
      );
    }, [item, type, setFeatures]);

    const handleInputChange = useCallback(
      (text) => {
        setFeatures((prev) =>
          prev.map((i) =>
            i === item ? { ...i, val: { ...i.val, [type]: text } } : i
          )
        );
      },
      [item, type, setFeatures]
    );

    return (
      <XStack
        flex={1}
        flexDirection="row"
        alignItems="center"
        width="100%"
        justifyContent="space-between"
        minHeight={50}
        paddingHorizontal="$3"
        marginBottom="$2"
        backgroundColor="$white"
      >
        <XStack width="25%" alignItems="center">
          {item.key === "deliveryDay" || item.key === "editNum" ? (
            <Paragraph fontSize={14} fontWeight="500">
              {item.key === "deliveryDay" ? "交付周期" : "交付次数"}
            </Paragraph>
          ) : (
            <TextInput
              style={{
                width: "100%",
                alignItems: "center",
                justifyContent: "center",
                height: "auto",
                backgroundColor: "#EDEDED",
                borderRadius: 10,
                paddingHorizontal: 10,
                paddingTop: 12,
                paddingBottom: 10,
                textAlign: "center",
                // scrollEnabled: false,
                // blurOnSubmit: false,
              }}
              multiline
              placeholder="服务规格"
              value={item.key}
              onChangeText={handleFeatureNameChange}
            />
          )}
        </XStack>
        {/* 输入  */}
        <XStack
          alignItems="center"
          space="$1"
          height="100%"
          width="70%"
          justifyContent="flex-end"
        >
          {item.type === "select" && (
            <Checkbox
              marginHorizontal={global.screenWidth * 0.15 - 20 / 2}
              size="$4"
              checked={item.val[type]}
              onCheckedChange={handleCheckboxChange}
              backgroundColor={item.val[type] ? "$brown" : "#EDEDED"}
            >
              <Checkbox.Indicator>
                <Check />
              </Checkbox.Indicator>
            </Checkbox>
          )}

          {item.type === "input" && (
            <TextInput
              placeholder={
                item.key === "deliveryDay"
                  ? "请输入（天）,如：3"
                  : item.key === "editNum"
                    ? "请输入（次）,如：2"
                    : "请输入"
              }
              style={{
                height: "auto",
                width: "80%",
                paddingHorizontal: 10,
                borderRadius: 10,
                marginHorizontal: "5%",
                backgroundColor: "#EDEDED",
                textAlign: "center",
                paddingTop: 12,
                paddingBottom: 10,
              }}
              multiline
              maxLength={50}
              value={item.val[type]}
              onChangeText={handleInputChange}
            />
          )}
          {item.key === "deliveryDay" || item.key === "editNum" ? null : (
            <TouchableOpacity onPress={() => handleDeleteItem(item.id)}>
              <AntDesignIcon name="minuscircle" size={20} color="#B66D0E" />
            </TouchableOpacity>
          )}
        </XStack>
      </XStack>
    );
  }
);

/**
 * @description: 需要卖家提供
 * @return {*}
 */
const BuyerProvideComp = () => {
  const { productMaterials, setProductMaterials } = useContext(ItemPostContext);
  const [delNum, setDelNum] = useState(0);

  const handleAddBuyerProvideComp = (type: "TEXT" | "ATTACHMENT") => {
    setProductMaterials((preMaterials) => {
      const newId = String(preMaterials.length) + String(delNum);
      const newItem = {
        id: newId,
        question: "",
        type: type,
      };
      return [...preMaterials, newItem];
    });
  };

  return (
    <YStack backgroundColor="#fff">
      <H2 fontSize={15} marginLeft="4%">
        需要卖家提供
      </H2>

      <YStack width="100%" flexDirection="column" marginLeft="4%">
        <Paragraph fontSize={14} color="$lightGray">
          选择你需要卖家提供的信息类型（该信息将展示在订单详情页）
        </Paragraph>
        <XStack flexDirection="row" space="$2" padding="$3">
          <Button
            width={80}
            height={40}
            backgroundColor="$brown"
            onPress={() => handleAddBuyerProvideComp("TEXT")}
          >
            <ButtonText color="$white">文本</ButtonText>
          </Button>
          <Button
            width={80}
            height={40}
            backgroundColor="$brown"
            onPress={() => handleAddBuyerProvideComp("ATTACHMENT")}
          >
            <ButtonText color="$white">附件</ButtonText>
          </Button>
        </XStack>
      </YStack>

      <YStack>
        {productMaterials.map((item) => (
          <ItemContent key={item.id} item={item} countDelNum={setDelNum} />
        ))}
      </YStack>
    </YStack>
  );
};

/**
 * @description: 需要卖家提供
 * @param {item,countDelNum}
 * @return {*}
 */
const ItemContent = memo(({ item, countDelNum }: { item; countDelNum }) => {
  const { productMaterials, setProductMaterials } = useContext(ItemPostContext);

  const handleMinusBuyerProvideComp = (id: string) => {
    setProductMaterials((preMaterials) =>
      preMaterials.filter((item) => item.id !== id)
    );
    countDelNum((preNum) => preNum + 1);
  };

  const handleInputChange = (text) => {
    setProductMaterials((preMaterials) =>
      preMaterials.map((i) => (i.id === item.id ? { ...i, question: text } : i))
    );
  };

  return (
    <XStack
      flex={1}
      paddingHorizontal="4%"
      width="100%"
      height={60}
      flexDirection="row"
      alignItems="center"
      justifyContent="space-between"
    >
      <XStack height="100%" alignItems="center">
        <Paragraph color="$brown">
          {item.type === "TEXT" ? "文本" : "附件"}
        </Paragraph>
        <Input
          width="90%"
          height="100%"
          placeholder={item.type === "TEXT" ? "需要的文本信息" : "需要的附件"}
          borderWidth={0}
          value={item.question}
          onChangeText={handleInputChange}
        />
      </XStack>
      <TouchableOpacity
        onPress={() => handleMinusBuyerProvideComp(item.id)}
        style={{ marginLeft: "auto" }}
      >
        <AntDesignIcon name="minuscircle" size={20} color="#B66D0E" />
      </TouchableOpacity>
    </XStack>
  );
});

/**
 * @description: 常见问题编辑renderContent
 * @return {*}
 */
const FreqQuestionContent = () => {
  const { freqQuestions, setFreqQuestions } = useContext(ItemPostContext);
  const [delNum, setDelNum] = useState(0);

  //  加入编辑：加入component时传入id和content（以生成数量作为newId）
  const handleAddFreqQuestions = () => {
    setFreqQuestions((preFreqQuestions) => {
      const newId = String(preFreqQuestions.length) + String(delNum);
      const newItem = {
        id: newId,
        question: "",
        answer: "",
        type: "PROBLEM",
      };
      return [...preFreqQuestions, newItem];
    });
  };

  return (
    <YStack backgroundColor="#fff">
      <XStack
        flex={1}
        alignItems="center"
        justifyContent="space-between"
        paddingRight="4%"
      >
        <H1 fontSize={15} marginLeft="4%">
          常见问题编辑
        </H1>
        {/* 点击按钮后数量+1 */}
        <TouchableOpacity onPress={handleAddFreqQuestions}>
          <AntDesignIcon name="pluscircle" size={20} color="gray" />
        </TouchableOpacity>
      </XStack>

      <YStack>
        {freqQuestions.map((item) => (
          <FreqQuestionItem key={item.id} item={item} countDelNum={setDelNum} />
        ))}
      </YStack>
    </YStack>
  );
};

/**
 * @description: 常见问题编辑
 * @param {item,countDelNum}
 * @return {*}
 */
const FreqQuestionItem = memo(
  ({ item, countDelNum }: { item: any; countDelNum: any }) => {
    const { freqQuestions, setFreqQuestions } = useContext(ItemPostContext);

    const handleMinusFreqQuestions = (id: string) => {
      setFreqQuestions((preFreqQuestions) =>
        preFreqQuestions.filter((item) => item.id !== id)
      );
      countDelNum((preNum) => preNum + 1);
    };

    const handleQuestionChange = (text) => {
      setFreqQuestions((preFreqQuestions) =>
        preFreqQuestions.map((i) =>
          i.id === item.id ? { ...i, question: text } : i
        )
      );
    };

    const handleAnsChange = (text) => {
      setFreqQuestions((preFreqQuestions) =>
        preFreqQuestions.map((i) =>
          i.id === item.id ? { ...i, answer: text } : i
        )
      );
    };

    return (
      <>
        <XStack
          flex={1}
          height={50}
          flexDirection="row"
          alignItems="center"
          paddingRight="4%"
          width="100%"
        >
          <Text
            style={{
              color: "#B66D0E",
              fontSize: 20,
              marginHorizontal: "4%",
            }}
          >
            问
          </Text>
          <TextInput
            style={{
              width: "80%",
              height: "auto",
              paddingTop: 12,
              paddingBottom: 10,
            }}
            placeholder={
              item?.question
                ? item.question
                : "可编辑一些客户可能会问的常见问题"
            }
            multiline
            maxLength={20}
            value={item?.question}
            onChangeText={handleQuestionChange}
            scrollEnabled={false}
            blurOnSubmit={false}
          />
          <TouchableOpacity
            onPress={() => handleMinusFreqQuestions(item?.id)}
            style={{ marginLeft: "auto" }}
          >
            <AntDesignIcon name="minuscircle" size={20} color="#B66D0E" />
          </TouchableOpacity>
        </XStack>
        <Separator />
        <XStack
          width="100%"
          minHeight={50}
          height="auto"
          flexDirection="row"
          alignItems="center"
        >
          <Text
            style={{
              color: "#B66D0E",
              fontSize: 20,
              marginHorizontal: "4%",
            }}
          >
            答
          </Text>
          <TextInput
            style={{
              width: "80%",
              height: "auto",
              paddingTop: 12,
              paddingBottom: 10,
            }}
            multiline
            placeholder={item?.answer ? item.answer : "回答尽量简明了"}
            maxLength={50}
            value={item?.answer}
            onChangeText={handleAnsChange}
          />
        </XStack>
      </>
    );
  }
);

/**
 * @description: 确认发布
 * @param {open,setOpen,isFilled,handlePost,reminder}
 * @return {*}
 */
const DiagalogToPost = memo(
  ({
    open,
    setOpen,
    isFilled,
    handlePost,
    reminder,
  }: {
    open: boolean;
    setOpen: (open: boolean) => void;
    isFilled: boolean;
    handlePost: any;
    reminder: string;
  }) => {
    return (
      <Dialog open={open} onOpenChange={setOpen}>
        <Dialog.Portal>
          <Dialog.Overlay
            key="overlay"
            animation="quick"
            opacity={0.5}
            enterStyle={{ opacity: 0 }}
            exitStyle={{ opacity: 0 }}
            backgroundColor="rgba(0, 0, 0, 0.5)"
          />
          <Dialog.Content
            elevate
            key="content"
            width={global.screenWidth * 0.7}
            animation={[
              "quick",
              {
                opacity: {
                  overshootClamping: true,
                },
              },
            ]}
            enterStyle={{ x: 0, y: -20, opacity: 0, scale: 0.9 }}
            exitStyle={{ x: 0, y: 10, opacity: 0, scale: 0.95 }}
            x={0}
            scale={1}
            opacity={1}
            y={0}
          >
            <YStack space>
              <Dialog.Title fontSize={20} alignSelf="center">
                确认发布
              </Dialog.Title>
              <Dialog.Description>{reminder}</Dialog.Description>
              <XStack gap="$3" justifyContent="flex-end">
                <Dialog.Close asChild>
                  <Button height={30}>取消</Button>
                </Dialog.Close>
                <Button
                  color="#fff"
                  backgroundColor="$brown"
                  height={30}
                  onPress={isFilled ? () => handlePost() : () => setOpen(false)}
                >
                  {isFilled ? "确认" : "去填写"}
                </Button>
              </XStack>
            </YStack>
          </Dialog.Content>
        </Dialog.Portal>
      </Dialog>
    );
  }
);

/**
 * @description: 案例展示
 * @param {savedData}
 * @return {*}
 */
const CaseShowComp = memo(({ savedData }: { savedData: any }) => {
  const [firstUpload, setFirstUpload] = useState(true);
  const [pickImagePopup, setPickImagePopup] = useState(false);
  const [modal, setModal] = useState(false);
  const uploadedImages = useSelector(
    (state: RootState) => state.file.winImages
  );
  const [previewIndex, setPreviewIndex] = useState(0);
  const params = useLocalSearchParams();
  const { winImages, setWinImages } = useContext(ItemPostContext);
  const dispatch = useDispatch<AppDispatch>();

  // 添加 setImageMode 函数
  const setImageMode = useCallback(async () => {
    if (firstUpload && params?.id === "add") {
      await dispatch(fileSlice.file.actions.setType("win"));
      await dispatch(fileSlice.file.actions.clearImages({ type: "win" }));
    } else {
      await dispatch(fileSlice.file.actions.setType("win"));
    }
    setPickImagePopup(true);
  }, [firstUpload, params?.id, dispatch]);

  const handleImageClick = (index: number) => {
    setModal(true);
    setPreviewIndex(index);
  };

  const deleteImage = useCallback(
    (index: number) => {
      dispatch(fileSlice.file.actions.deleteImage(index));
    },
    [dispatch]
  );

  useEffect(() => {
    if (uploadedImages.length === 0) {
      setFirstUpload(true);
      setModal(false);
    }
    if (uploadedImages.length === 9) {
      setPickImagePopup(false);
    }
    setWinImages(uploadedImages.map((image) => image.imgUrl));
  }, [uploadedImages, firstUpload, setWinImages, dispatch]);

  useEffect(() => {
    if (winImages.length > 0) {
      setFirstUpload(false);
    }
  }, [winImages, params?.id, dispatch]);

  const StyledUploaderButton = memo(() => {
    return (
      <Button
        width={150}
        height={180}
        backgroundColor="$bottomColor"
        marginTop="auto"
        marginHorizontal="6.5%"
        marginBottom="$3"
        onPress={() => setImageMode()}
      >
        <AntDesignIcon name="pluscircle" size={18} color="#808080" />
      </Button>
    );
  });

  return (
    <>
      <ImagePreviewEditComp
        images={uploadedImages}
        previewIndex={previewIndex}
        modal={modal}
        setModal={setModal}
        deleteImage={deleteImage}
        type="win"
      />

      <YStack marginTop="auto" marginHorizontal="$3" marginBottom="$3">
        {firstUpload ? (
          <Button
            width={150}
            height={180}
            backgroundColor="$bottomColor"
            marginTop="auto"
            marginHorizontal="6.5%"
            marginBottom="$3"
            onPress={() => setImageMode()}
          >
            <AntDesignIcon name="pluscircle" size={18} color="#808080" />
          </Button>
        ) : (
          <YStack space="$2">
            <FlatList
              data={uploadedImages.map((image) => image.imgUrl)}
              keyExtractor={(item, index) => index.toString()}
              renderItem={({ item, index }) => (
                <TouchableWithoutFeedback
                  onPress={() => handleImageClick(index)}
                >
                  <View>
                    <FastImage
                      source={{
                        uri: item,
                        priority: FastImage.priority.low,
                      }}
                      style={{
                        width: 150,
                        height: 180,
                        marginRight: 10,
                      }}
                    />
                  </View>
                </TouchableWithoutFeedback>
              )}
              horizontal
              ListFooterComponent={StyledUploaderButton}
              contentContainerStyle={{ paddingRight: 200 }}
            />
          </YStack>
        )}
      </YStack>
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
            type: "win",
          })
        }
      />
    </>
  );
});

export default AwaitPostServicePage;
