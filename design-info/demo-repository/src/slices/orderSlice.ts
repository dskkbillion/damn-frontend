import { createSlice, PayloadAction } from "@reduxjs/toolkit";

import { ErrorPayload } from "../util/authActions";
import {
  createApplyRefund,
  createApproveOrderDemand,
  createAsyncOrderCreateThunk,
  createAuditRefundThunk,
  createBuyerDeleteOrder,
  createCancelOrderThunk,
  createCancelRefundThunk,
  createDeleteRefundThunk,
  createEvaluateOrder,
  createFetchRefundDetailThunk,
  createMaterialSubmitThunk,
  createOrderCompletedThunk,
  createOrderDelivery,
  createOrderDemandAdd,
  createPayThunk,
  createQueryDemandDetail,
  createQueryDemandList,
  createQueryOrderDelivery,
  // createQueryOrderDemand,
  createQueryOrderDemandBuyer,
  createQueryOrderDetail,
  createQueryOrderEvaluate,
  createSellerDeleteOrder,
  createVerifyOrderThunk,
  orderInfo,
} from "../util/orderActions";

interface OrderState {
  loading: boolean;
  order: orderInfo;
  orderState: string;
  feature: [];
  files: [];
  application_type: string;
  reasonValue: string;
  reasonLabel: string;
  remarks: string;
  deliveryList: any[];
  evaluationList: any[];
  demandList: any[]; // 暂时保留
  materialDemand: any[];
  deliveryDemand: any[];
  refuseDemand: any[];
  platformDemand: any[];
  demandDetail: any;
  refundDetail: any; // 售后详情
  refundId: number | null;
  error: ErrorPayload | boolean;
  msg: string;
  success: boolean; // 用于判断订单状态更新动作是否成功，无关查询动作
  successToVerifyOrder: boolean;
  successToQueryOrderDetail: boolean;
  approved: boolean;
  rejected: boolean;
  code: number | null;
  autoMaterialTime: number | null;
  autoCancelTime: number | null;
  deliveryTime: number | null;
  deliveryTimestamp: number | null;
  autoOrderReceivinTime: number | null;
  refresh: boolean;
  successToCancelOrder: boolean;
  changed: boolean;
}

const initialState: OrderState = {
  loading: false,
  order: {} as orderInfo,
  orderState: "",
  feature: [],
  files: [],
  application_type: "",
  reasonValue: "",
  reasonLabel: "",
  remarks: "",
  deliveryList: [],
  evaluationList: [],
  demandList: [],
  materialDemand: [],
  deliveryDemand: [],
  refuseDemand: [],
  platformDemand: [],
  demandDetail: {},
  refundDetail: {},
  refundId: null,
  error: false,
  msg: "",
  success: false,
  successToVerifyOrder: false,
  successToQueryOrderDetail: false,
  approved: false,
  rejected: false,
  code: null,
  autoMaterialTime: null,
  autoCancelTime: null,
  deliveryTime: null,
  deliveryTimestamp: null,
  autoOrderReceivinTime: null,
  refresh: false,
  successToCancelOrder: false,
  changed: false,
};

export const createOrderSlice = (axiosFn) => {
  const OrderCreate = createAsyncOrderCreateThunk(axiosFn);
  const payOrder = createPayThunk(axiosFn);
  const queryOrderDetail = createQueryOrderDetail(axiosFn);
  const verifyOrder = createVerifyOrderThunk(axiosFn);
  const addOrderMaterials = createMaterialSubmitThunk(axiosFn);
  // 添加申请
  const addOrderDemand = createOrderDemandAdd(axiosFn);
  const completeOrder = createOrderCompletedThunk(axiosFn);
  const cancelOrder = createCancelOrderThunk(axiosFn);
  const deliveryOrder = createOrderDelivery(axiosFn);
  // 查询交付列表
  const queryDeliveryList = createQueryOrderDelivery(axiosFn);
  const evaluateOrder = createEvaluateOrder(axiosFn);
  const queryOrderEvaluation = createQueryOrderEvaluate(axiosFn);
  // const queryOrderDemandList = createQueryOrderDemand(axiosFn);
  const auditOrderDemand = createApproveOrderDemand(axiosFn);
  const queryBuyerOrderDemandList = createQueryOrderDemandBuyer(axiosFn);
  // 查询需求详情
  const queryDemandDetail = createQueryDemandDetail(axiosFn);
  const deleteBuyerOrder = createBuyerDeleteOrder(axiosFn);
  const deleteSellerOrder = createSellerDeleteOrder(axiosFn);
  // 查询需求列表
  const queryDemandList = createQueryDemandList(axiosFn);
  // 查询售后详情
  const fetchRefundDetail = createFetchRefundDetailThunk(axiosFn);
  // 卖家售后审核
  const refundAudit = createAuditRefundThunk(axiosFn);
  // 申请售后
  const applyRefund = createApplyRefund(axiosFn);
  // 撤销售后
  const cancelRefund = createCancelRefundThunk(axiosFn);
  // 删除售后记录
  const deleteRefund = createDeleteRefundThunk(axiosFn);

  const orderSlice = createSlice({
    name: "order",
    initialState,
    reducers: {
      setSubmitMaterials: (state, action) => {
        state.feature = action.payload.feature;
        state.files = action.payload.files;
        console.log("submit materials", state.feature, state.files);
      },
      setAddOrderDemand: (state, action) => {
        state.application_type = action.payload.type;
        state.reasonValue = action.payload.reasonValue;
        state.reasonLabel = action.payload.reasonLabel;
        state.remarks = action.payload.remarks;
      },
      resetSuccessToVerifyOrder: (state) => {
        state.successToVerifyOrder = false;
      },

      resetSuccess: (state) => {
        state.success = false;
        state.successToQueryOrderDetail = false;
        state.successToVerifyOrder = false;
      },

      setRefresh(state) {
        state.refresh = !state.refresh;
      },
      setChanged(state) {
        console.log("订单状态更新", state.changed);
        state.changed = !state.changed;
      },
      setRefundId(state, action) {
        state.refundId = action.payload;
      },
      resetRefundDetail(state) {
        state.refundDetail = {};
      },
      resetDemandDetail(state) {
        state.demandDetail = {};
      },
      clearOrderDetail: (state) => {
        state.order = {} as orderInfo;
        state.demandList = [];
        state.deliveryList = [];
        state.evaluationList = [];
        // 不清空 orderState,避免触发重新请求
      },

      clearDemandList: (state) => {
        state.demandList = [];
        state.materialDemand = [];
        state.deliveryDemand = [];
        state.refuseDemand = [];
        state.platformDemand = [];
      },

      setOrderState: (state, action: PayloadAction<string>) => {
        state.orderState = action.payload;
      },
    },
    extraReducers: (builder) => {
      builder

        .addCase(OrderCreate.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.orderState = "orderCreating";
          state.msg = "loading";
        })
        .addCase(OrderCreate.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "orderCreated";
          state.changed = !state.changed;
          state.order = action.payload.data;
          state.msg = action.payload.msg;
        })
        .addCase(OrderCreate.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.orderState = "orderCreateFailed";
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(payOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.orderState = "paying";
          state.msg = "loading";
        })

        .addCase(payOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "awaitingSubmission";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
        })

        .addCase(payOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.orderState = "payFailed";
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(queryOrderDetail.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.msg = "loading";
          state.success = false;
        })
        .addCase(queryOrderDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.order = action.payload.data;
          state.orderState = state.order?.state;
          state.feature = state.order?.orderMaterials?.feature;
          state.files = state.order?.orderMaterials?.files;
          state.successToQueryOrderDetail = true;

          if (action.payload.data?.state === "awaitingPayment") {
            state.autoCancelTime = action.payload.data?.autoCancelTime;
          } else if (
            action.payload.data?.state === "awaitingSubmission" ||
            action.payload.data?.state === "awaitingStart"
          ) {
            state.autoMaterialTime = action.payload.data?.autoMaterialTime;
          } else if (action.payload.data?.state === "awaitingDelivery") {
            state.deliveryTime = action.payload.data?.deliveryTime;
            state.deliveryTimestamp = action.payload.data?.deliveryTimestamp;
          } else if (action.payload.data?.state === "awaitingConfirmation") {
            state.autoOrderReceivinTime =
              action.payload.data?.autoOrderReceivinTime;
          }
        })
        .addCase(queryOrderDetail.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(addOrderMaterials.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(addOrderMaterials.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "awaitingStart";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(addOrderMaterials.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        // .addCase(addOrderDemand.pending, (state, action) => {
        //   state.loading = true;
        //   state.error = false;
        //   state.success = false;
        //   state.msg = "loading";
        // })
        // .addCase(addOrderDemand.fulfilled, (state, action) => {
        //   state.loading = false;
        //   state.success = true;
        //   state.orderState = action.payload.type;
        //   state.changed = !state.changed;
        //   state.msg = action.payload.data.msg;
        //   state.code = action.payload.data.code;
        // })
        // .addCase(addOrderDemand.rejected, (state, action) => {
        //   state.loading = false;
        //   state.error = true;
        //   state.success = false;
        //   state.msg = action.payload?.msg as string;
        //   state.code = action.payload?.code as number;
        // })

        .addCase(verifyOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.successToVerifyOrder = false;
          state.msg = "loading";
        })
        .addCase(verifyOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "awaitingDelivery";
          state.changed = !state.changed;
          state.successToVerifyOrder = true;
          state.msg = action.payload.msg;
        })
        .addCase(verifyOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.successToVerifyOrder = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(completeOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(completeOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "orderCompleted";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
          console.log("complete order", action.payload);
        })
        .addCase(completeOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(cancelOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(cancelOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.successToCancelOrder = true;
          state.msg = action.payload.msg;
        })
        .addCase(cancelOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(deliveryOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(deliveryOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "awaitingConfirmation";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
        })
        .addCase(deliveryOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        // 查询交付列表
        .addCase(queryDeliveryList.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.msg = "loading";
        })
        .addCase(queryDeliveryList.fulfilled, (state, action) => {
          state.loading = false;
          state.deliveryList = action.payload.rows;
          state.msg = action.payload.msg;
        })
        .addCase(queryDeliveryList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(evaluateOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(evaluateOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "orderCompleted";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
        })
        .addCase(evaluateOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(queryOrderEvaluation.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.msg = "loading";
        })
        .addCase(queryOrderEvaluation.fulfilled, (state, action) => {
          state.loading = false;
          state.evaluationList = action.payload.rows;
          state.msg = action.payload.msg;
        })
        .addCase(queryOrderEvaluation.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 审核需求
        .addCase(auditOrderDemand.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(auditOrderDemand.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          if (action.payload.status === "SUCCESS") {
            state.approved = true;
            state.orderState = "awaitingConfirmation";
          } else {
            // state.orderState = "awaitingConfirmation";
            state.rejected = true;
          }
          state.msg = action.payload.msg;
          state.changed = !state.changed;
        })
        .addCase(auditOrderDemand.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 查询需求列表
        .addCase(queryDemandList.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(queryDemandList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.data.msg;

          // 确保 rows 存在且是数组
          const rows = Array.isArray(action.payload.data.rows)
            ? action.payload.data.rows
            : [];

          //
          // 根据不同类型更新对应的 demand 列表
          switch (action.payload.type) {
            case "material":
              state.materialDemand = rows.filter(
                (item) => item?.type === "replenish_materials"
              );
              break;
            case "delivery":
              state.deliveryDemand = rows.filter(
                (item) => item?.type === "reform"
              );
              state.platformDemand = rows.filter(
                (item) => item?.type === "platform"
              );
              break;
            case "refuse":
              state.refuseDemand = rows.filter(
                (item) => item?.type === "refuse"
              );
              break;
            case "platform":
              state.platformDemand = rows.filter(
                (item) => item?.type === "platform"
              );
              break;
            default:
              state.demandList = rows;
          }
        })
        .addCase(queryDemandList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 查询需求详情
        .addCase(queryDemandDetail.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.msg = "loading";
        })
        .addCase(queryDemandDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.demandDetail = action.payload.data;
          state.msg = action.payload.msg;
        })
        .addCase(queryDemandDetail.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 申请退款
        .addCase(applyRefund.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(applyRefund.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.msg;
        })
        .addCase(applyRefund.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        // 删除订单(买家)
        .addCase(deleteBuyerOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(deleteBuyerOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "orderDeleted";
          state.changed = !state.changed;

          state.msg = action.payload.msg;
        })
        .addCase(deleteBuyerOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        // 删除订单(卖家)
        .addCase(deleteSellerOrder.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(deleteSellerOrder.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.orderState = "orderDeleted";
          state.changed = !state.changed;
          state.msg = action.payload.msg;
        })
        .addCase(deleteSellerOrder.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchRefundDetail.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(fetchRefundDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.msg;
          state.refundDetail = action.payload.data;
        })
        .addCase(fetchRefundDetail.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(refundAudit.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(refundAudit.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.msg;
        })
        .addCase(refundAudit.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(cancelRefund.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(cancelRefund.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.msg;
        })
        .addCase(cancelRefund.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(deleteRefund.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
          state.msg = "loading";
        })
        .addCase(deleteRefund.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.msg;
        })
        .addCase(deleteRefund.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.success = false;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        });
    },
  });

  return {
    ...orderSlice,
    actions: {
      ...orderSlice.actions,
      OrderCreate,
      payOrder,
      queryOrderDetail,
      addOrderMaterials,
      addOrderDemand,
      verifyOrder,
      completeOrder,
      cancelOrder,
      deliveryOrder,
      queryDeliveryList,
      evaluateOrder,
      queryOrderEvaluation,
      // queryOrderDemandList,
      auditOrderDemand,
      queryBuyerOrderDemandList,
      queryDemandDetail,
      applyRefund,
      deleteBuyerOrder,
      queryDemandList,
      deleteSellerOrder,
      fetchRefundDetail,
      refundAudit,
      cancelRefund,
      deleteRefund,
    },
  };
};
