import { router, useLocalSearchParams } from "expo-router";
import { memo, useCallback, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H1,
  Portal,
  ScrollView,
  XStack,
  YStack,
} from "tamagui";

import { goToChat } from "@/components/chat/goToChat";
import { DemandDetailComponent } from "@/components/orders/common_funcs";
import { DeliveryResComp } from "@/components/orders/delivery_comp";
import { DemandTimeLineComponent } from "@/components/orders/demandTimeline";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { PreviewComp } from "@/components/utils/filesystem";
import { AppDispatch, RootState, slices } from "@/src/store";

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
  const orderState = useSelector((state: RootState) => state.order.orderState);
  const [previewPopup, setPreviewPopup] = useState(false);
  const [previewUri, setPreviewUri] = useState("");
  const delivered =
    demandDetail?.status !== "WAIT" && orderState === "awaitingConfirmation"
      ? true
      : false;
  const { screenWidth, screenHeight } = useGlobalContext();
  const previewFile = (uri) => {
    setPreviewUri(uri);
    setPreviewPopup(true);
  };

  const confirmOrder = useCallback(async () => {
    try {
      const params = {
        orderId: Number(demandDetail?.orderId),
      };
      const res = await dispatch(slices.order.actions.completeOrder(params));
      if (isAxiosSuccess(res.type)) {
        alert("确认收货成功");
        router.back();
      } else {
        alert("确认收货失败");
      }
    } catch (e) {
      console.log("fail to confirm order");
    }
  }, [demandDetail?.orderId, dispatch]);

  // 获取demandDetail
  useEffect(() => {
    const fetchOrderDemanList = async () => {
      const params = {
        id: Number(demandId),
      };
      await dispatch(slices.order.actions.queryDemandDetail(params));
    };
    fetchOrderDemanList();
  }, [demandId]);

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
      <ScrollView contentContainerStyle={{ paddingBottom: screenHeight * 0.1 }}>
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
            role="buyer"
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

        {delivered && (
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
        width={screenWidth}
        backgroundColor="#fff"
        height={screenHeight * 0.1}
      >
        <XStack marginLeft="auto" marginTop="$3">
          <Button
            backgroundColor="#fff"
            borderWidth={1}
            borderColor="#B66D0E"
            marginRight="$3"
            paddingHorizontal="$3"
            height={screenHeight * 0.04}
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
                  role: "buyer",
                },
              })
            }
            // onPress={() => setIssuePopup(true)}
            unstyled
          >
            <ButtonText color="#B66D0E">平台介入</ButtonText>
          </Button>
          {demandDetail?.status === "WAIT" && (
            <>
              <Button
                backgroundColor="#B66D0E"
                borderWidth={1}
                borderColor="#B66D0E"
                marginRight="$3"
                paddingHorizontal="$3"
                height={screenHeight * 0.04}
                justifyContent="center"
                alignItems="center"
                borderRadius={20}
                onPress={() =>
                  goToChat({ dispatch, tenantId: order?.tenantId })
                }
                unstyled
              >
                <ButtonText color="#fff">联系卖家</ButtonText>
              </Button>
            </>
          )}

          {delivered && (
            <Button
              backgroundColor="#B66D0E"
              borderWidth={1}
              borderColor="#B66D0E"
              marginRight="$3"
              paddingHorizontal="$3"
              height={screenHeight * 0.04}
              justifyContent="center"
              alignItems="center"
              borderRadius={20}
              onPress={() => confirmOrder()}
              unstyled
            >
              <ButtonText color="#fff">确认收货</ButtonText>
            </Button>
          )}
          {/* {demandDetail?.status === "SUCCESS" && (
            <Button
              backgroundColor="#B66D0E"
              borderWidth={1}
              borderColor="#B66D0E"
              marginRight="$3"
              paddingHorizontal="$3"
              height={screenHeight * 0.04}
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
              <ButtonText color="#fff">撤销申请</ButtonText>
            </Button>
          )} */}
        </XStack>
      </XStack>
    </YStack>
  );
});

export default DemandDetailPage;
