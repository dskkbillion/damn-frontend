import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";

/**
 * Creates an asynchronous thunk for order creation without coupon.
 *
 * @param axiosFn - The axios function to use for making HTTP requests.
 * @returns An asynchronous thunk that creates an order.
 */
export const createAsyncOrderCreateThunk = (axiosFn) =>
  createAsyncThunk<
    OrderCreateResponse,
    OrderCreateWithoutCouponParams,
    { rejectValue: ErrorPayload }
  >("/api/shop/order/create", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order/create", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

/**
 * Creates a fetch order list thunk.
 * @param axiosFn - The axios function used for making HTTP requests.
 * @returns A thunk function that fetches the order list.
 */
export const createFetchOrderListThunk = (axiosFn) =>
  createAsyncThunk<
    FetchOrderListResponse,
    FetchOrderListParams,
    { rejectValue: ErrorPayload }
  >(
    "/api/shop/order/list",
    async (
      { type, state, keyword, pageSize, pageNum },
      { rejectWithValue }
    ) => {
      try {
        const param = {
          pageSize,
          pageNum,
        };

        switch (state) {
          case 0:
            if (keyword) {
              param["keyword"] = keyword;
            }
            break;
          case 1:
            if (type === "buyer") {
              param["state"] = "awaitingPayment";
            } else {
              param["states"] = ["awaitingStart", "buyAwaitingSubmission"];
            }
            break;
          case 2:
            param["states"] =
              type === "buyer"
                ? [
                    "awaitingSubmission",
                    "buyAwaitingSubmission",
                    "awaitingStart",
                    "awaitingDelivery",
                    "awaitingConfirmation",
                    "sellerSupplementaryMaterials",
                    "applyForRefuse",
                    "canceled",
                  ]
                : [
                    "awaitingDelivery",
                    "awaitingConfirmation",
                    "sellerSupplementaryMaterials",
                    "applyForRefuse",
                    "canceled",
                  ];
            break;
          case 3:
            if (type === "buyer") {
              param["states"] = ["awaitingEvaluation", "orderCompleted"];
            } else {
              param["states"] = ["awaitingEvaluation", "orderCompleted"];
            }

            break;
          case 4:
            param["states"] =
              type === "buyer"
                ? ["afterSale", "AfterSaleRejection", "applyingForMediation"]
                : ["afterSale", "AfterSaleRejection", "applyingForMediation"];
            break;
        }

        if (type === "buyer") {
          param["type"] = "buyer";
        } else {
          param["type"] = "seller";
        }

        const res = await axiosFn.onPost("/api/shop/order/list", param);
        // console.log("res", res.data);
        return { type, state, data: res.data };
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

// 查询买家售后列表
export const createFecthBuyerRefundItemList = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number | null;
      encryptField: string[] | null;
    },
    { pageNum: number; pageSize: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order-refund/list", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询卖家售后审核列表
export const createFecthTenantRefundItemList = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number | null;
      encryptField: string[] | null;
    },
    { pageNum: number; pageSize: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/tenantAudit", async (_, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order-refund/tenantAudit");
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询售后详情
export const createFetchRefundDetailThunk = (axiosFn) =>
  createAsyncThunk<any, { id: number }, { rejectValue: ErrorPayload }>(
    "/api/shop/order-refund/detail",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet(
          "/api/shop/order-refund/detail",
          params
        );
        return res.data;
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

export const createPayThunk = (axiosFn) =>
  createAsyncThunk<
    PaymentResponse,
    PaymentParams,
    { rejectValue: ErrorPayload }
  >("/api/payment", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/payment", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

export const createQueryOrderDetail = (axiosFn) =>
  createAsyncThunk<orderInfo, { id: number }, { rejectValue: ErrorPayload }>(
    "/api/shop/order/detail",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet("/api/shop/order/detail", params);
        return res.data;
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

export const createMaterialSubmitThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    MaterialSubmitParams,
    { rejectValue: ErrorPayload }
  >("/api/project/orderMaterials/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/project/orderMaterials/add",
        params
      );
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

export const createOrderDemandAdd = (axiosFn) =>
  createAsyncThunk<
    { type: string; data: { msg: string; code: number } },
    orderDemandAddParams,
    { rejectValue: ErrorPayload }
  >("/api/project/orderDemand/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/project/orderDemand/add", params);
      return { type: params.type, data: res.data };
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 确认接单
export const createVerifyOrderThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    // { orderId: number },
    any,
    { rejectValue: ErrorPayload }
  >("/api/shop/order/verify", async (params, { rejectWithValue }) => {
    try {
      const url = "/api/shop/order/verify?" + "orderId=" + params.orderId;
      const res = await axiosFn.onPost(url, {});
      console.log("确认下单", res.data);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 完成订单
export const createOrderCompletedThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order/complete", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/shop/order/complete", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 取消订单
export const createCancelOrderThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { orderId: string },
    { rejectValue: ErrorPayload }
  >("/api/shop/order/cancel", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/shop/order/cancel", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 交付订单（卖家）
export const createOrderDelivery = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { orderId: number; content: string; files: string[] },
    { rejectValue: ErrorPayload }
  >("/api/project/orderDelivery/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/project/orderDelivery/add",
        params
      );
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询订单交付列表
export const createQueryOrderDelivery = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number | null;
      encryptField: string[] | null;
    },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/project/orderDelivery/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/project/orderDelivery/list",
        params
      );
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 评价订单
export const createEvaluateOrder = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    {
      orderId: number;
      score: number;
      remark: string;
      images: string[];
      anonumityFlag: boolean;
    },
    { rejectValue: ErrorPayload }
  >("/api/shop/evaluate/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/evaluate/add", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询订单评价列表
export const createQueryOrderEvaluate = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number | null;
      encryptField: string[] | null;
    },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/evaluate/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/evaluate/list", params);
      if (res.data.code !== 200) {
        rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询卖家申请列表
// export const createQueryOrderDemand = (axiosFn) =>
//   createAsyncThunk<
//     {
//       total: number;
//       rows: any[];
//       code: number;
//       msg: string;
//       encrypt: number | null;
//       encryptField: string[] | null;
//     },
//     { orderId: number },
//     { rejectValue: ErrorPayload }
//   >(
//     "/api/project/orderDemand/buyerList",
//     async (params, { rejectWithValue }) => {
//       try {
//         const res = await axiosFn.onPost(
//           "/api/project/orderDemand/buyerList",
//           params
//         );
//         return res.data;
//       } catch (err: any) {
//         if (err.response && err.response.data.message) {
//           return rejectWithValue(err.response.data.message);
//         } else {
//           return rejectWithValue(err.message);
//         }
//       }
//     }
//   );

// 订单申请补充并完成（同意）
export const createApproveOrderDemand = (axiosFn) =>
  createAsyncThunk<
    {
      status: string;
      msg: string;
      code: number;
    },
    { id: number; status: string },
    { rejectValue: ErrorPayload }
  >("/api/project/orderDemand/audit", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/project/orderDemand/audit",
        params
      );
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return { status: params.status, ...res.data };
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 查询买家申请列表
export const createQueryOrderDemandBuyer = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number | null;
      encryptField: string[] | null;
    },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >(
    "/api/project/orderDemand/buyerList",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost(
          "/api/project/orderDemand/buyerList",
          params
        );
        return res.data;
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

// 查询需求列表
export const createQueryDemandList = (axiosFn) => {
  return createAsyncThunk<
    {
      data: any;
      type: string | undefined;
    },
    {
      orderId: number;
      memberType: string;
      type?: "material" | "delivery" | "refuse" | "platform";
    },
    { rejectValue: ErrorPayload }
  >("order/queryDemandList", async (params, { rejectWithValue }) => {
    try {
      const response = await axiosFn.onPost("/api/project/orderDemand/list", {
        orderId: params.orderId,
        memberType: params.memberType,
      });

      if (response.data.code !== 200) {
        return rejectWithValue(response.data);
      }

      return {
        data: response.data,
        type: params.type || "default",
      };
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });
};

// 查询需求详情
export const createQueryDemandDetail = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    { id: number },
    { rejectValue: ErrorPayload }
  >("/api/project/orderDemand/get", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/project/orderDemand/get", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 退款申请

export const createApplyRefund = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    {
      orderItemId: number;
      memberType: string;
      refundReason: string;
      refundExplain: string;
      auditType: string;
    },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/apply", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order-refund/apply", params);
      if (
        (res.data.code === 500 && res.data.msg === "您已经申请过售后！") ||
        res.data.code === 200
      ) {
        return res.data;
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 卖家删除订单记录
export const createSellerDeleteOrder = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order/sellerDelete", async (params, { rejectWithValue }) => {
    try {
      const postUrl =
        "/api/shop/order/sellerDelete?" + "orderId=" + params.orderId;
      const res = await axiosFn.onPost(postUrl, {});
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 买家删除订单记录
export const createBuyerDeleteOrder = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order/delete", async (params, { rejectWithValue }) => {
    try {
      const postUrl = "/api/shop/order/delete?" + "orderId=" + params.orderId;
      const res = await axiosFn.onPost(postUrl, {});
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 卖家售后审核
export const createAuditRefundThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    {
      id: number;
      refundState: string;
      auditRemark: string;
    },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/audit", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order-refund/audit", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 撤销退款
export const createCancelRefundThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { refundId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/cancel", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/order-refund/cancel", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 删除售后记录
export const createDeleteRefundThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { ids: number[] },
    { rejectValue: ErrorPayload }
  >("/api/shop/order-refund/delete", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/shop/order-refund/delete",
        params?.ids
      );
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

interface buyerInfo {
  id: number;
  nickName: string;
  trueName: string;
  avatar: string | null;
  mobile: string;
  gender: string;
}

interface tenantInfo {
  id: number;
  nickName: string;
  trueName: string;
  avatar: string;
  mobile: string;
  gender: string;
}

// orderInfo data dictionary
export interface orderInfo {
  id: number;
  buyerId: number;
  buyer: buyerInfo;
  tenantId: number;
  tenant: tenantInfo;
  orderSn: string;
  totalPrice: number;
  payPrice: number;
  couponPrice: number;
  couponId: number | null;
  payType: number | null;
  payTradeNo: number | null;
  [key: string]: any;
}

interface OrderCreateResponse {
  msg: string;
  code: number;
  data: orderInfo;
}

interface OrderCreateWithoutCouponParams {
  remark: string;
  tenantId: number;
  items: {
    productId: number;
    variantId: number;
    quantity: number;
  }[];
}

// interface OrderCreateParams {
//   coupondId: number;
//   tenantId: number;
//   remark: string;
//   items: {
//     productId: number;
//     variantId: number;
//     quantity: number;
//   }[];
// }

interface FetchOrderListParams {
  type: string;
  state: number;
  keyword?: string;
  pageSize: number;
  pageNum: number;
}

interface FetchOrderListResponse {
  type: string;
  state: number;
  data: {
    total: number;
    rows: orderDetail[];
    code: number;
    msg: string;
    encripty: number | null;
    encriptField: string[] | null;
  };
}

interface orderDetail {
  id: number;
  buyerId: number;
  buyer: buyerInfo;
  tenantId: number;
  tenant: tenantInfo;
  orderSn: string;
  totalPrice: number;
  payPrice: number;
  couponPrice: number;
  couponId: number | null;
  payType: number | null;
  payTradeNo: number | null;
  remark: string;
  state: string;
  feature: object | null;
  payTime: string | null;
  completeTime: string | null;
  cancelTime: string | null;
  items: {
    id: number;
    buyerId: number;
    tenantId: number;
    orderId: number;
    productId: number;
    variantId: number;
    variantName: string;
    productName: string;
    productInfo: string | null;
    quantity: number;
    unitPrice: number;
    totalPrice: number;
    payPrice: number;
    feature: object | null;
    deliveryDay: number;
    editNum: number;
    productMaterialsVos: any[];
  }[];
  evaluate: boolean;
  autoCancelTime: number;
  autoMaterialTime: string | null;
  orderMaterials: any[];
  autoOrderReceivinTime: string | null;
  orderDel;
}

interface PaymentParams {
  scene: string;
  payway: string;
  businessId: number;
}

interface PaymentResponse {
  msg: string;
  code: number;
  data: any;
}

interface MaterialSubmitParams {
  productId: number;
  orderId: number;
  feature: object;
  files: string[];
}

interface orderDemandAddParams {
  orderId: number;
  type: string;
  reasonValue: string;
  reasonLabel: string;
  remarks: string;
}
