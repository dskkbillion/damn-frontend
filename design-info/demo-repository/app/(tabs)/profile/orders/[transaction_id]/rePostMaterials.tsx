import { useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useRef, useState } from "react";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H5,
  Input,
  Paragraph,
  Portal,
  XStack,
  YStack,
} from "tamagui";

import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import {
  BottomMultiplePicker,
  PreviewComp,
} from "@/components/utils/filesystem";
import { renderTabFileContent } from "@/components/orders/common_funcs";
import ServiceComponent from "@/components/orders/service_comp";
import TabsComponent, {
  TabFileContent,
  TabTextContent,
} from "@/components/orders/tabs_comp";
import { AppDispatch, fileSlice, RootState, slices } from "@/src/store";

const rePostMaterialsPage = memo(() => {
  const id = useLocalSearchParams().transaction_id;
  const dispatch = useDispatch<AppDispatch>();
  const order = useSelector((state: RootState) => state.order.order);
  const materialFiles = useSelector(
    (state: RootState) => state.file.materialFiles
  );
  const orderMaterials = order?.orderMaterials;
  let memoMaterials = null as any;
  const features = useRef({}); // 用于存储输入框的引用
  const [submittedRes, setSubmittedRes] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const [previewPopup, setPreviewPopup] = useState(false);
  const [files, setFiles] = useState<any[]>([]);
  const [submittedFiles, setSubmittedFiles] = useState<any[]>([]);

  if (orderMaterials !== undefined && orderMaterials.length > 0) {
    const orderMaterialsSorted = orderMaterials.sort(
      (item: { id: any }) => item.id
    );
    memoMaterials = orderMaterialsSorted[orderMaterialsSorted.length - 1];
  }

  const productMaterialsVos = order?.items?.[0]?.productMaterialsVos;
  const [submitted, setSubmitted] = useState(false);
  let textMaterialsVos = [] as any;
  let fileMaterialsVos = [] as any;

  if (Array.isArray(productMaterialsVos) && productMaterialsVos.length > 0) {
    textMaterialsVos = productMaterialsVos.filter(
      (item) => item && item.type === "TEXT"
    );
    fileMaterialsVos = productMaterialsVos.filter(
      (item) => item && item.type === "ATTACHMENT"
    );
  }

  useEffect(() => {
    const files = materialFiles?.[order?.id];
    if (Array.isArray(files) && files.length > 0) {
      setFiles(
        files.map((file) => ({
          fileUrl: file.fileUrl,
          fileName: file.fileName,
        }))
      );
    } else {
      setFiles([]);
    }
  }, [materialFiles, order?.id]);

  const deleteFile = (index: number) => {
    dispatch(fileSlice.file.actions.deleteFile(index));
  };

  const handleComfirm = useCallback(async () => {
    if (
      features.current &&
      Object.keys(features.current).length < textMaterialsVos.length
    ) {
      alert("请填写完整的文本信息");
      return;
    }

    if (fileMaterialsVos.length > 0 && files.length === 0) {
      alert("请上传所需文件");
      return;
    }

    const data = {
      productId: order?.items[0].productId,
      orderId: order?.items[0].orderId,
      feature: textMaterialsVos.map((item, index) => ({
        question: item.question,
        answer: features.current[index] || "",
      })),
      files: files.map((file) => file.fileUrl),
    };

    try {
      const res = await dispatch(slices.order.actions.addOrderMaterials(data));
      if (res.payload?.code === 200) {
        alert("提交成功");
        setSubmitted(true);
        const textRes = textMaterialsVos.map((item, index) => ({
          question: item.question,
          answer: features.current[index] || "",
        }));
        setSubmittedRes(textRes);

        setSubmittedFiles(files);

        dispatch(fileSlice.file.actions.clearFiles({ type: "material" }));
        setFiles([]);
      }
    } catch (e) {
      console.log("failed to add order materials", e);
      alert("提交失败，请重试");
    }
  }, [files, order?.items, textMaterialsVos, dispatch]);

  const MemoTabTextContent = memo(
    ({ memoTextMaterial }: { memoTextMaterial }) => {
      const textMaterials = memoTextMaterial ? memoTextMaterial.feature : [];

      const matchMemoMatrials = (question) => {
        if (!textMaterials) return "";
        const res = textMaterials.find((item) => item.question === question);
        return res ? res.answer : "";
      };

      const handleInputChange = useCallback((index, value) => {
        features.current[index] = value;
      }, []);

      return (
        <YStack flex={1} backgroundColor="#fff">
          {textMaterialsVos.map((item, index) => (
            <YStack key={index}>
              <Paragraph marginBottom="$2">
                {index + 1}. {item?.question}
              </Paragraph>
              <Input
                width="100%"
                height={40}
                borderColor="$lightGray"
                placeholder={
                  matchMemoMatrials(item?.question)
                    ? matchMemoMatrials(item?.question)
                    : "请输入"
                }
                value={features.current[index]}
                onChangeText={(value) => handleInputChange(index, value)}
              />
            </YStack>
          ))}
        </YStack>
      );
    }
  );

  // 清除缓存材料文件
  useEffect(() => {
    dispatch(fileSlice.file.actions.clearFiles({ type: "material" }));
  }, []);

  useEffect(() => {
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(id) }));
  }, [id]);

  return (
    <>
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}

      <KeyboardAwareScrollView
        style={{ flex: 1, width: "100%" }}
        resetScrollToCoords={{ x: 0, y: 0 }}
        extraScrollHeight={50}
        scrollEnabled
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        <YStack
          marginTop={3}
          marginBottom={50}
          backgroundColor="#fff"
          padding="$3"
        >
          <ServiceComponent item={order.items[0]} />
        </YStack>
        <YStack flexDirection="column" backgroundColor="#fff" padding="$3">
          <H5 marginBottom="$3">要求提交</H5>
          <TabsComponent
            tab1Content={
              submitted ? (
                <TabTextContent textMaterial={submittedRes} />
              ) : (
                <MemoTabTextContent
                  memoTextMaterial={memoMaterials?.features}
                />
              )
            }
            tab2Content={
              submitted ? (
                <YStack flex={1} backgroundColor="#fff">
                  {submittedFiles.length > 0 ? (
                    submittedFiles.map((file, index) => (
                      <XStack
                        key={index}
                        padding="$2"
                        marginVertical="$1"
                        borderRadius={8}
                        backgroundColor="$gray5"
                        alignItems="center"
                        pressStyle={{ opacity: 0.8 }}
                        onPress={() => {
                          setPreviewUri(file.fileUrl);
                          setPreviewPopup(true);
                        }}
                        justifyContent="space-between"
                      >
                        <XStack
                          backgroundColor="#EDEDED"
                          width="90%"
                          paddingVertical="$2"
                          borderRadius={8}
                        >
                          <Paragraph ellipsizeMode="tail" numberOfLines={1}>
                            {file.fileName || `附件 ${index + 1}`}
                          </Paragraph>
                        </XStack>
                        <Paragraph color="$blue" marginLeft="$2">
                          预览
                        </Paragraph>
                      </XStack>
                    ))
                  ) : (
                    <Paragraph>暂无文件</Paragraph>
                  )}
                </YStack>
              ) : (
                renderTabFileContent({
                  orderId: order?.id,
                  uploadFiles: materialFiles,
                  deleteFile,
                  setIsOpen,
                  setPreviewUri,
                  setPreviewPopup,
                })
              )
            }
          />
        </YStack>
      </KeyboardAwareScrollView>
      {!submitted && (
        <XStack
          width="100%"
          height={global.screenHeight * 0.1}
          backgroundColor="#fff"
          position="absolute"
          bottom={0}
          justifyContent="center"
        >
          <AlertDialogComponent
            title="重传材料"
            description="确认重传材料吗？"
            handleConfirm={handleComfirm}
          >
            <Button
              width="50%"
              height={40}
              backgroundColor="$brown"
              marginTop="3%"
              borderRadius={20}
              textAlign="center"
              justifyContent="center"
              unstyled
            >
              <ButtonText color="#fff" alignSelf="center">
                确认提交
              </ButtonText>
            </Button>
          </AlertDialogComponent>
        </XStack>
      )}
      {/* 底部弹窗：选择上传类型 */}
      <BottomMultiplePicker
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        position={0}
        zIndex={100000}
        limit={9}
        type="material"
      />
    </>
  );
});

export default rePostMaterialsPage;
