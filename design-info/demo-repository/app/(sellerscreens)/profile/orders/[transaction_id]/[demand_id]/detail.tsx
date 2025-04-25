import { Scroll } from "@tamagui/lucide-icons";
import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H1,
  Paragraph,
  Portal,
  ScrollView,
  XStack,
  YStack,
} from "tamagui";

import { DemandTimeLineComponent } from "@/components/orders/demandTimeline";
import { AppDispatch, RootState, slices } from "@/src/store";
import { DemandDetailComponent } from "@/components/orders/common_funcs";
import { DeliveryResComp } from "@/components/orders/delivery_comp";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { isAxiosSuccess } from "@/components/utils";
import { goToChat } from "@/components/chat/goToChat";
import { PreviewComp } from "@/components/utils/filesystem";
// import { FileDownloader } from "@/components/styled/file_downloader";

const DemandDetailPage = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const params = useLocalSearchParams();
  const demandId = params?.demand_id;
  const demandDetail = useSelector(
    (state: RootState) => state.order.demandDetail
  );
  const order = useSelector((state: RootState) => state.order.order);
  const deliveryList = useSelector(
    (state: RootState) => state.order.deliveryList
  );
  const lastDelivery = deliveryList?.[deliveryList.length - 1];
  const [status, setStatus] = useState(""); // 0: 未处理 1: 拒绝 2: 同意
  const orderState = useSelector((state: RootState) => state.order.orderState);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");

  const delivered =
    demandDetail?.status !== "WAIT" && orderState === "awaitingConfirmation"
      ? true
      : false;

  useEffect(() => {
    const params = {
      id: Number(demandId),
    };
    dispatch(slices.order.actions.queryDemandDetail(params));
  }, [demandId, orderState]);

  const handleConfirm = useCallback(async () => {
    let params;
    switch (status) {
      case "agree":
        params = {
          id: Number(demandId),
          status: "SUCCESS",
        };
        break;
      case "refuse":
        params = {
          id: Number(demandId),
          status: "FAIL",
        };
        break;
    }
    try {
      const res = await dispatch(slices.order.actions.auditOrderDemand(params));
      if (isAxiosSuccess(res.type)) {
        if (status === "agree") {
          alert("同意买家的交付申请");
          dispatch(
            slices.order.actions.queryDemandList({
              orderId: Number(demandDetail?.orderId),
              memberType: "buyer",
              type: "delivery",
            })
          );
          router.push(
            `/(sellerscreens)/profile/orders/${demandDetail?.orderId}/`
          );
          // router.back();
        } else {
          alert("已拒绝买家的交付申请");
          dispatch(
            slices.order.actions.queryDemandList({
              orderId: Number(demandDetail?.orderId),
              memberType: "buyer",
              type: "delivery",
            })
          );
          router.push(
            `/(sellerscreens)/profile/orders/${demandDetail?.orderId}/`
          );
          // router.back();
        }
      } else {
        alert("操作失败");
      }
    } catch (e) {
      console.log("fail to add auditOrderDemand");
    }
  }, [demandId, status]);

  const previewFile = (uri) => {
    setPreviewUri(uri);
    setPreviewPopup(true);
  };

  return (
    <YStack flex={1}>
      {previewPopup && (
        <Portal>
          <PreviewComp
            previewUri={previewUri}
            setPreviewPopup={setPreviewPopup}
          />
        </Portal>
      )}
      <ScrollView
        contentContainerStyle={{ paddingBottom: global.screenHeight * 0.1 }}
      >
        <YStack
          flex={1}
          backgroundColor="#fff"
          marginTop="$3"
          paddingVertical="$6"
          width="96%"
          borderRadius={20}
          alignSelf="center"
          paddingHorizontal="$2"
          height="30%"
        >
          <DemandTimeLineComponent
            role="seller"
            type={demandDetail?.type}
            currentStatus={delivered ? "DELIVERED" : demandDetail?.status}
          />
        </YStack>
        <YStack
          flexDirection="column"
          borderRadius={20}
          width="96%"
          paddingHorizontal={20}
          paddingBottom={20}
          backgroundColor="#fff"
          alignSelf="center"
          marginTop={20}
        >
          <H1 fontSize={16}>申请信息</H1>
          <DemandDetailComponent demandDetail={demandDetail} />
        </YStack>

        {deliveryList && deliveryList.length > 0 && (
          <YStack
            flexDirection="column"
            borderRadius={20}
            width="96%"
            paddingHorizontal={20}
            paddingBottom={20}
            backgroundColor="#fff"
            alignSelf="center"
            marginTop={20}
          >
            <H1 fontSize={16}>申请服务交付版本</H1>
            <DeliveryResComp item={lastDelivery} previewFile={previewFile} />
          </YStack>
        )}
      </ScrollView>
      <XStack
        position="fixed" // fixed：这样它就相对于整个页面定位
        display="flex"
        zIndex={999}
        left={0}
        bottom={0} // 确保它固定在页面的底部
        width={global.screenWidth}
        backgroundColor="#fff"
        height={global.screenHeight * 0.1}
      >
        <XStack marginLeft="auto" marginTop="$3">
          <Button
            backgroundColor="#fff"
            borderWidth={1}
            borderColor="#B66D0E"
            marginRight="$3"
            paddingHorizontal="$3"
            height={global.screenHeight * 0.04}
            justifyContent="center"
            alignItems="center"
            borderRadius={20}
            color="#B66D0E"
            onPress={() =>
              router.push({
                pathname: "/(outer)/order/application",
                params: {
                  orderId: demandDetail?.orderId,
                  application: "platform",
                  role: "seller",
                },
              })
            }
            unstyled
          >
            <ButtonText color="#B66D0E">平台介入</ButtonText>
          </Button>
          {demandDetail?.status === "WAIT" && (
            <>
              <AlertDialogComponent
                title="买家申请"
                description="是否拒绝买家的交付申请"
                handleConfirm={handleConfirm}
              >
                <Button
                  backgroundColor="#fff"
                  borderWidth={1}
                  borderColor="#B66D0E"
                  marginRight="$3"
                  paddingHorizontal="$3"
                  height={global.screenHeight * 0.04}
                  justifyContent="center"
                  alignItems="center"
                  borderRadius={20}
                  onPress={() => setStatus("refuse")}
                  color="#B66D0E"
                  unstyled
                >
                  <ButtonText color="#B66D0E">拒绝申请</ButtonText>
                </Button>
              </AlertDialogComponent>
              <AlertDialogComponent
                title="买家申请"
                description="是否同意买家的交付申请"
                handleConfirm={handleConfirm}
              >
                <Button
                  backgroundColor="#B66D0E"
                  borderWidth={1}
                  borderColor="#B66D0E"
                  marginRight="$3"
                  paddingHorizontal="$3"
                  height={global.screenHeight * 0.04}
                  justifyContent="center"
                  alignItems="center"
                  borderRadius={20}
                  onPress={() => setStatus("agree")}
                  unstyled
                >
                  <ButtonText color="#fff">同意</ButtonText>
                </Button>
              </AlertDialogComponent>
            </>
          )}
          {demandDetail?.status === "SUCCESS" && !delivered && (
            <Button
              backgroundColor="#B66D0E"
              borderWidth={1}
              borderColor="#B66D0E"
              marginRight="$3"
              paddingHorizontal="$3"
              height={global.screenHeight * 0.04}
              justifyContent="center"
              alignItems="center"
              borderRadius={20}
              onPress={() =>
                router.push(
                  `/(sellerscreens)/profile/orders/${demandDetail?.orderId}/reDelivery`
                )
              }
              unstyled
            >
              <ButtonText color="#fff">去重新交付</ButtonText>
            </Button>
          )}

          {delivered && (
            <Button
              backgroundColor="#B66D0E"
              borderWidth={1}
              borderColor="#B66D0E"
              marginRight="$3"
              paddingHorizontal="$3"
              height={global.screenHeight * 0.04}
              justifyContent="center"
              alignItems="center"
              borderRadius={20}
              onPress={() => goToChat({ dispatch, tenantId: order?.tenantId })}
              unstyled
            >
              <ButtonText color="#fff">联系卖家</ButtonText>
            </Button>
          )}
        </XStack>
      </XStack>
    </YStack>
  );
});

export default DemandDetailPage;
