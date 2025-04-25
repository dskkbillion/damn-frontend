import { createContext, useContext, useEffect, useState } from "react";
import { Alert } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, XStack } from "tamagui";

import Loader from "../styled/loader";
import { isAxiosSuccess } from "../utils";

import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { AppDispatch, RootState, slices } from "@/src/store";

interface DeliveryContextType {
  content: string;
  setContent: (content: string) => void;
  files: string[];
  setFiles: (files: string[]) => void;
}

const DeliveryContext = createContext<DeliveryContextType>({
  content: "",
  setContent: () => {},
  files: [],
  setFiles: () => {},
});

export const DeliveryProvider = ({ children }) => {
  const [content, setContent] = useState("");
  const [files, setFiles] = useState<string[]>([]);

  return (
    <DeliveryContext.Provider value={{ content, setContent, files, setFiles }}>
      {children}
    </DeliveryContext.Provider>
  );
};

export const useDelivery = () => {
  const context = useContext(DeliveryContext);
  if (context === undefined) {
    throw new Error("useMaterial must be used within a MaterialProvider");
  }
  return context;
};

export const ButtomButton = ({ state, isDialog, ...props }) => {
  const dispatch = useDispatch<AppDispatch>();
  const isLoading = useSelector((state: RootState) => state.order.loading);
  const order = useSelector((state: RootState) => state.order.order);
  const [title, setTitle] = useState("");
  const [dialogDescription, setDialogDescription] = useState("");
  const [isCancelOrder, setIsCancelOrder] = useState(false);
  const [openForCancle, setOpenForCancle] = useState(false);
  const { content, files } = useDelivery();
  const loading = useSelector((state: RootState) => state.order.loading);

  /**
   * Handles the confirmation logic based on the current state.
   */
  const handleConfirm = async () => {
    let params;

    switch (state) {
      case "awaitingSubmission":
        break;
      case "awaitingStart":
        break;
      case "awaitingDelivery":
      case "sellerSupplementaryMaterials":
        if (!content && !files.length) {
          Alert.alert("请填写内容");
          return;
        }
        params = {
          orderId: Number(order?.id),
          content,
          files,
        };
        try {
          await dispatch(slices.order.actions.deliveryOrder(params));
        } catch (e) {
          console.log(e);
        }

        break;
      case "awaitingConfirmation":
      case "applyForRefuse":
        params = {
          orderId: Number(order?.id),
        };
        dispatch(slices.order.actions.completeOrder(params));
        break;
      case "awaitingEvaluation":
        params = {
          orderId: Number(order?.id),
        };
        try {
          const res = await dispatch(slices.item.actions.inviteComment(params));
          if (isAxiosSuccess(res.type)) {
            alert("邀请成功");
          } else {
            alert("每日只能邀请一次");
          }
        } catch (e) {
          console.log(e);
        }

        break;
      case "orderCompleted":
        params = {
          orderId: Number(order?.id),
        };
        dispatch(slices.order.actions.deleteSellerOrder(params));
        break;
      default:
        break;
    }
  };

  const handleCancelConfirm = () => {
    const params = {
      orderId: String(order?.id),
    };
    dispatch(slices.order.actions.cancelOrder(params));
    setOpenForCancle(false);
  };

  useEffect(() => {
    if (order?.state === "awaitingSubmission") {
      setTitle("提交材料");
      setDialogDescription("确认提交材料吗？");
    } else if (order?.state === "awaitingStart") {
      setTitle("确认接单");
      setDialogDescription("确认开始订单吗？");
    } else if (
      order?.state === "awaitingDelivery" ||
      order?.state === "sellerSupplementaryMaterials" ||
      order?.state === "applyForRefuse"
    ) {
      setTitle("确认交付");
      setDialogDescription("确认交付订单吗？");
    } else if (order?.state === "orderCompleted") {
      setTitle("删除记录");
      setDialogDescription("确认删除订单吗？");
      setIsCancelOrder(false);
    } else if (order?.state === "awaitingEvaluation") {
      setTitle("邀请评价");
      setDialogDescription("是否邀请用户评价？每日可邀请一次");
    }

    if (isLoading) {
      setTitle("提交中");
      setDialogDescription("请稍等片刻");
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
      {loading && <Loader loading={loading} />}
      {isDialog && (
        <AlertDialogComponent
          // setOpen={setOpen}
          title={title}
          description={dialogDescription}
          handleConfirm={handleConfirm}
        >
          <Button
            height={40}
            width="50%"
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
            right={30}
            bottom={40}
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
    </XStack>
  );
};
