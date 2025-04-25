import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, H1, H5, TextArea, XStack, YStack } from "tamagui";

import {
  renderTabFileContent,
  DemandDetailComponent,
} from "@/components/orders/common_funcs";
import ServiceComponent from "@/components/orders/service_comp";
import TabsComponent from "@/components/orders/tabs_comp";
import { BottomMultiplePicker } from "@/components/styled/bottomsheet_picker";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { PreviewBasedOnUrl } from "@/components/utils/filesystem";
import { AppDispatch, RootState, fileSlice, slices } from "@/src/store";
import { isAxiosSuccess } from "@/components/utils";

const ReDeliveryPage = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const order = useSelector((state: RootState) => state.order.order);
  const demandList = useSelector((state: RootState) => state.order.demandList);
  const uploadFiles = useSelector(
    (state: RootState) => state.file.deliveryFiles
  );

  const [content, setContent] = useState("");
  const [files, setFiles] = useState<string[]>([]);
  const [currentDemand, setCurrentDemand] = useState({});
  const orderId = useLocalSearchParams().transaction_id;

  // 新增状态管理
  const [isOpen, setIsOpen] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const [previewPopup, setPreviewPopup] = useState(false);

  // 文件管理函数
  const deleteFile = (index: number) => {
    dispatch(fileSlice.file.actions.deleteFile(index));
  };

  const handleConfirm = useCallback(async () => {
    const params = {
      orderId: Number(orderId),
      content,
      files,
    };
    try {
      const res = await dispatch(slices.order.actions.deliveryOrder(params));

      if (isAxiosSuccess(res.type)) {
        // 先更新数据再返回
        await dispatch(
          slices.order.actions.queryOrderDetail({ id: Number(orderId) })
        );
        await dispatch(
          slices.order.actions.queryDemandList({
            orderId: Number(orderId),
            memberType: "buyer",
            type: "delivery",
          })
        );
        alert("交付成功");
        // 返回前不清理状态
        dispatch(fileSlice.file.actions.clearAllFiles());
        router.back();
      } else {
        alert("交付失败");
      }
    } catch (e) {
      console.log("fail to deliveryOrder", e);
    }
  }, [demandList, content, files, orderId]);

  useEffect(() => {
    const files = uploadFiles?.[order?.id];
    if (Array.isArray(files) && files.length > 0) {
      setFiles(files.map((file) => file.fileUrl));
    }
  }, [uploadFiles]);

  useEffect(() => {
    // 设置订单ID用于文件上传
    dispatch(fileSlice.file.actions.setOrderId(Number(orderId)));
    // 获取订单详情
    dispatch(slices.order.actions.queryOrderDetail({ id: Number(orderId) }));
    // 获取需求列表
    dispatch(
      slices.order.actions.queryDemandList({
        orderId: Number(orderId),
        memberType: "seller",
        type: "delivery",
      })
    );

    return () => {
      // 只清理文件状态
      dispatch(fileSlice.file.actions.clearAllFiles());
    };
  }, [orderId]);
  useEffect(() => {
    if (demandList?.length > 0) {
      setCurrentDemand(demandList[demandList.length - 1]);
    }
  }, [demandList]);

  const renderTabTextContent = () => {
    return (
      <YStack height={200}>
        <TextArea
          width="100%"
          height="100%"
          alignSelf="center"
          boxSizing="border-box"
          backgroundColor="#EDEDED"
          placeholder="在此输入您需要交付的文本信息"
          alignContent="center"
          value={content}
          onChangeText={setContent}
        />
      </YStack>
    );
  };

  return (
    <YStack flex={1}>
      <KeyboardAwareScrollView
        style={{ flex: 1, width: "100%" }}
        resetScrollToCoords={{ x: 0, y: 0 }}
        extraScrollHeight={60}
        scrollEnabled={true}
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        <YStack
          flex={1}
          backgroundColor="#fff"
          marginVertical="$3"
          paddingBottom="$6"
          width="96%"
          borderRadius={20}
          alignSelf="center"
          paddingHorizontal="$2"
          height="30%"
          justifyContent="center"
        >
          <H1 fontSize={16}>申请信息</H1>
          <DemandDetailComponent demandDetail={currentDemand} />
        </YStack>

        <YStack marginBottom={25} backgroundColor="#fff" padding="$3">
          <ServiceComponent item={order?.items?.[0]} />
        </YStack>
        <YStack
          flexDirection="column"
          backgroundColor="#fff"
          paddingHorizontal="$3"
          paddingBottom={100}
        >
          <XStack justifyContent="space-between">
            <H5 marginBottom="$3" fontSize={16}>
              您的交付
            </H5>
          </XStack>
          <TabsComponent
            tab1Content={renderTabTextContent()}
            tab2Content={renderTabFileContent({
              orderId: order?.id,
              uploadFiles,
              deleteFile,
              setIsOpen,
              setPreviewUri,
              setPreviewPopup,
            })}
          />
        </YStack>

        {previewPopup && (
          <PreviewBasedOnUrl
            previewPopup={previewPopup}
            setPreviewPopup={setPreviewPopup}
            previewUri={previewUri}
          />
        )}
      </KeyboardAwareScrollView>

      <BottomMultiplePicker
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        position={0}
        zIndex={100000}
        limit={9}
        type="delivery"
      />

      <XStack
        position="fixed" // fixed：这样它就相对于整个页面定位
        display="flex"
        justifyContent="center"
        alignItems="center"
        zIndex={999}
        left={0}
        bottom={0} // 确保它固定在页面的底部
        width={global.screenWidth}
        backgroundColor="#fff"
        height={global.screenHeight * 0.1}
      >
        <AlertDialogComponent
          title="重新交付"
          description="确认交付？"
          handleConfirm={handleConfirm}
        >
          <Button
            backgroundColor="#B66D0E"
            width="80%"
            borderWidth={1}
            borderColor="#B66D0E"
            paddingHorizontal="$3"
            height={global.screenHeight * 0.04}
            justifyContent="center"
            alignItems="center"
            borderRadius={20}
            unstyled
          >
            <ButtonText color="#fff">确认交付</ButtonText>
          </Button>
        </AlertDialogComponent>
      </XStack>
    </YStack>
  );
});

export default ReDeliveryPage;
