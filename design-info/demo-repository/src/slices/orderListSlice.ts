import { createSlice } from "@reduxjs/toolkit";

import { ErrorPayload } from "../util/authActions";
import {
  createFecthBuyerRefundItemList,
  createFecthTenantRefundItemList,
  createFetchOrderListThunk,
  orderInfo,
} from "../util/orderActions";

interface OrderState {
  loading: boolean;
  orderListForBuyer: orderInfo[][]; // order list for buyer displaying
  orderListForSeller: orderInfo[][]; // order list for seller displaying
  refundListForBuyer: any; // refund list for buyer displaying
  refundListForSeller: any; // refund list for seller displaying
  error: ErrorPayload | boolean;
  msg: string;
  success: boolean;
  code: number | null;
  hasMore: boolean;
  searchHistory: any[]; // search user list
  searchOrderList: any[]; // search order list
  searchHistoryForSeller: any[]; // search order list for seller
}

const initialState: OrderState = {
  loading: false,
  orderListForBuyer: [] as orderInfo[][],
  orderListForSeller: [] as orderInfo[][],
  refundListForBuyer: [] as any,
  refundListForSeller: [] as any,
  error: false,
  msg: "",
  success: false,
  code: null,
  hasMore: true,
  searchHistory: [],
  searchOrderList: [],
  searchHistoryForSeller: [],
};

export const createOrderListSlice = (axiosFn) => {
  const fetchOrderList = createFetchOrderListThunk(axiosFn);
  const fetchBuyerRefundList = createFecthBuyerRefundItemList(axiosFn);
  const fetchTenantRefundList = createFecthTenantRefundItemList(axiosFn);
  const orderSlice = createSlice({
    name: "orderList",
    initialState,
    reducers: {
      resetOrderList: (state, action) => {
        state.hasMore = true;
        state.loading = false;
        if (action.payload.type === "buyer") {
          state.orderListForBuyer[action.payload.state] = [];
        } else {
          state.orderListForSeller[action.payload.state] = [];
        }
      },
      resetRefundList: (state, action) => {
        if (action.payload.type === "buyer") {
          state.refundListForBuyer = [];
        } else {
          state.refundListForSeller = [];
        }
        console.log("重置退款列表（买家）", state.refundListForBuyer);
        console.log("重置退款列表（卖家）", state.refundListForSeller);
      },
      setLoading: (state, action) => {
        state.loading = action.payload;
      },
      addSearchList: (state, action) => {
        const searchItem = action.payload.searchItem;
        const role = action.payload.role;

        if (role === "buyer") {
          // 检查搜索项是否已经存在，若存在则将其移到最前面
          const existingIndex = state.searchHistory.findIndex(
            (item) => item === searchItem
          );
          if (existingIndex !== -1) {
            state.searchHistory.splice(existingIndex, 1);
          }

          // 将新搜索项添加到历史记录的最前面
          state.searchHistory.unshift(searchItem);

          // 保持最多十条记录
          if (state.searchHistory.length > 10) {
            state.searchHistory.pop();
          }
        } else {
          const existingIndex = state.searchHistoryForSeller.findIndex(
            (item) => item === searchItem
          );
          if (existingIndex !== -1) {
            state.searchHistoryForSeller.splice(existingIndex, 1);
          }

          // 将新搜索项添加到历史记录的最前面
          state.searchHistoryForSeller.unshift(searchItem);

          // 保持最多十条记录
          if (state.searchHistoryForSeller.length > 10) {
            state.searchHistoryForSeller.pop();
          }
        }
      },
      deleteSearchList: (state, action) => {
        if (action.payload.role === "buyer") {
          state.searchHistory = [];
        } else {
          state.searchHistoryForSeller = [];
        }
      },
    },
    extraReducers: (builder) => {
      builder

        .addCase(fetchOrderList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.hasMore = true;
        })
        .addCase(fetchOrderList.fulfilled, (state, action) => {
          const data = action.payload.data;
          const type = action.payload.type;
          const orderState = action.payload.state;

          if (type === "buyer") {
            state.orderListForBuyer[orderState] = [
              ...(state.orderListForBuyer[orderState] || []),
              ...(data.rows || []),
            ];
            // console.log("buyer ", state.orderListForBuyer[orderState]);
          } else {
            state.orderListForSeller[action.payload.state] = [
              ...(state.orderListForSeller[orderState] || []),
              ...(data.rows || []),
            ];
          }
          if (!data || data.total < 5) {
            console.log(data.total);
            state.hasMore = false;
          }
          state.loading = false;
          state.success = true;
          state.error = false;
          // console.log("数据获取完毕，加载状态为", state.loading);
          // console.log("数据获取完毕，数据", data);
          // console.log("数据获取完毕，是否还有更多数据", state.hasMore);
        })
        .addCase(fetchOrderList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 获取买家售后列表
        .addCase(fetchBuyerRefundList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.hasMore = true;
        })

        .addCase(fetchBuyerRefundList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.refundListForBuyer = [
            ...(state.refundListForBuyer || []),
            ...(action.payload.rows || []),
          ];
          if (state.refundListForBuyer.length >= action.payload.total) {
            state.hasMore = false;
          }

          state.error = false;
        })
        .addCase(fetchBuyerRefundList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 获取卖家售后列表
        .addCase(fetchTenantRefundList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.hasMore = true;
        })

        .addCase(fetchTenantRefundList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.refundListForSeller = [
            ...(state.refundListForSeller || []),
            ...(action.payload.rows || []),
          ];
          if (state.refundListForSeller.length >= action.payload.total) {
            state.hasMore = false;
          }
          state.error = false;
        })

        .addCase(fetchTenantRefundList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        });
    },
  });

  return {
    ...orderSlice,
    actions: {
      ...orderSlice.actions,
      fetchOrderList,
      fetchBuyerRefundList,
      fetchTenantRefundList,
    },
  };
};
