import { router } from "expo-router";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, Dialog, XStack, YStack } from "tamagui";

import { AppDispatch, RootState, slices } from "@/src/store";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { isAxiosSuccess } from "../utils";

interface MaterialContextForBuyerType {
  textMaterialsVos: any[];
  fileMaterialsVos: any[];
  feature: object;
  files: string[];
  setFeature: (features: object) => void;
  setFiles: (files: string[]) => void;
  evaluation_score: number | null;
  setEvaluationScore: (score: number | null) => void;
  evaluation_comment: string;
  anonumityFlag: boolean;
  setAnonumityFlag: (flag: boolean) => void;
  setEvaluationComment: (comment: string) => void;
}

const MaterialContext = createContext<MaterialContextForBuyerType | undefined>(
  undefined
);

export const MaterialProvider = ({ children }) => {
  const [feature, setFeature] = useState({});
  const [files, setFiles] = useState<string[]>([]);
  const order = useSelector((state: RootState) => state.order.order);
  const productMaterialsVos = order?.items?.[0]?.productMaterialsVos;
  const [evaluation_score, setEvaluationScore] = useState<number | null>(null);
  const [evaluation_comment, setEvaluationComment] = useState("");
  const [anonumityFlag, setAnonumityFlag] = useState(false);

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

  return (
    <MaterialContext.Provider
      value={{
        textMaterialsVos,
        fileMaterialsVos,
        feature,
        files,
        evaluation_comment,
        evaluation_score,
        anonumityFlag,
        setEvaluationScore,
        setEvaluationComment,
        setFeature,
        setFiles,
        setAnonumityFlag,
      }}
    >
      {children}
    </MaterialContext.Provider>
  );
};

export const useMaterial = () => {
  const context = useContext(MaterialContext);
  if (context === undefined) {
    throw new Error("useMaterial must be used within a MaterialProvider");
  }
  return context;
};

export const ButtomButton = ({ state, isDialog, ...props }) => {
  const dispatch = useDispatch<AppDispatch>();
  const order = useSelector((state: RootState) => state.order.order);
  const [title, setTitle] = useState("");
  const [dialogDescription, setDialogDescription] = useState("");
  const [isCancelOrder, setIsCancelOrder] = useState(false);
  const { textMaterialsVos, feature, files } = useMaterial();
  const successToCancel = useSelector(
    (state: RootState) => state.order.successToCancelOrder
  );
  const [isRefund, setIsRefund] = useState(false);

  //  comfirm dialog (确认提交)
  const handleConfirm = async () => {
    let params;

    const pairedMaterials = textMaterialsVos.map((item, index) => ({
      question: item.question, // 从 textMaterialsVos 中获取 question
      answer: feature[index] || "", // 从 inputValues 中获取相应的 answer
    }));

    switch (state) {
      case "awaitingSubmission":
        params = {
          productId: order?.items[0].productId,
          orderId: order?.items[0].orderId,
          feature: pairedMaterials,
          files,
        };
        await dispatch(slices.order.actions.addOrderMaterials(params));
        break;
      case "awaitingStart":
        handleCancelConfirm();
        break;
      case "buyAwaitingSubmission":
        router.push(`/(tabs)/profile/orders/${order?.id}/rePostMaterials`);

        break;
      case "awaitingDelivery":
        console.log("awaitingDelivery");
        params = {
          orderId: Number(order?.id),
        };
        // dispatch(slices.order.actions.completeOrder(params));
        break;
      case "awaitingConfirmation":
      case "applyForRefuse":
        params = {
          orderId: Number(order?.id),
        };
        dispatch(slices.order.actions.completeOrder(params));
        break;
      case "sellerSupplementaryMaterials":
        router.push({
          pathname: "/(outer)/order/application",
          params: {
            orderId: order?.id,
            application: "platform",
            role: "buyer",
          },
        });
        break;
      default:
        break;
    }
  };

  const handleCancelConfirm = useCallback(async () => {
    const params = {
      orderId: String(order?.id),
    };
    try {
      const res = await dispatch(slices.order.actions.cancelOrder(params));
      if (isAxiosSuccess(res.type)) {
        alert("订单取消成功");
        dispatch(slices.order.actions.setChanged());
        router.back();
      } else {
        console.log("fail to cancel order", successToCancel);
        alert("订单取消失败");
      }
    } catch (e) {
      console.log("fail to cancel order", e);
    }
  }, []);

  const handleRefund = useCallback(async () => {
    router.push({
      pathname: "/(outer)/order/application",
      params: {
        orderId: order?.id,
        application: "refund",
        role: "buyer",
      },
    });
  }, []);

  useEffect(() => {
    if (order?.state === "awaitingSubmission") {
      setTitle("提交材料");
      setDialogDescription("确认提交材料吗？");
      setIsCancelOrder(true);
      setIsRefund(false);
    } else if (order?.state === "awaitingStart") {
      setTitle("取消订单");
      setDialogDescription("确认取消订单吗？");
      setIsCancelOrder(false);
      setIsRefund(false);
    } else if (order?.state === "buyAwaitingSubmission") {
      setTitle("重传材料");
      setIsCancelOrder(true);
      setIsRefund(false);
      setDialogDescription("是否去重传材料？");
    } else if (
      order?.state === "awaitingConfirmation" ||
      order?.state === "applyForRefuse"
    ) {
      setTitle("确认收货");
      setDialogDescription("是否确认收货？");
      setIsCancelOrder(false);
      setIsRefund(true);
    } else if (order?.state === "sellerSupplementaryMaterials") {
      setTitle("平台介入");
      setDialogDescription("是否申请平台介入？");
      setIsRefund(true);
      setIsCancelOrder(false);
    }
  }, [order]);

  return (
    <XStack
      display="flex"
      flexDirection="row"
      justifyContent="center"
      alignItems="center"
      width="100%"
    >
      {/* {isLoading && <Loader loading={isLoading} />} */}
      {isDialog && (
        <AlertDialogComponent
          title={title}
          description={dialogDescription}
          handleConfirm={handleConfirm}
        >
          <Button
            width="50%"
            height={40}
            marginBottom={10}
            marginRight={10}
            backgroundColor="$brown"
          >
            <ButtonText color="#fff">
              {title}
              {order?.id}
            </ButtonText>
          </Button>
        </AlertDialogComponent>
      )}

      {!isDialog && (
        <Button
          width="50%"
          marginBottom={10}
          marginRight={10}
          backgroundColor="$brown"
        >
          <ButtonText color="#fff">{props.title}</ButtonText>
        </Button>
      )}
      {isCancelOrder && (
        <AlertDialogComponent
          title="取消订单"
          description="确认取消订单吗？"
          handleConfirm={handleCancelConfirm}
        >
          <Button
            position="absolute"
            height="auto"
            right={30}
            bottom={35}
            borderBottomWidth="$1"
            borderBottomColor="$blue"
            unstyled
          >
            <ButtonText color="$blue" alignSelf="center">
              取消订单
            </ButtonText>
          </Button>
        </AlertDialogComponent>
      )}
      {isRefund && !order?.buyerRefundFlag && !order?.tenantRefundFlag && (
        <AlertDialogComponent
          title="申请退款"
          description="确认申请退款吗？"
          handleConfirm={handleRefund}
        >
          <Button
            position="absolute"
            right={30}
            bottom={35}
            borderBottomWidth="$1"
            borderBottomColor="$blue"
            unstyled
          >
            <ButtonText color="$blue" alignSelf="center">
              申请退款
            </ButtonText>
          </Button>
        </AlertDialogComponent>
      )}
    </XStack>
  );
};
