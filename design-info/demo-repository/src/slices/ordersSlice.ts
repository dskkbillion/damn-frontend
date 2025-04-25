import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// 定义订单状态接口
interface OrdersState {
  data: any[];
  loading: boolean;
  error: string | null;
}

// 初始状态
const initialState: OrdersState = {
  data: [],
  loading: false,
  error: null
};

// 创建异步 thunk
export const fetchOrdersThunk = createAsyncThunk(
  'orders/fetchOrders',
  async () => {
    // 调用 API 获取订单数据
    const response = await fetch('/api/orders');
    return response.json();
  }
);

const ordersSlice = createSlice({
  name: 'orders',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchOrdersThunk.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchOrdersThunk.fulfilled, (state, action) => {
        state.loading = false;
        state.data = action.payload;
      })
      .addCase(fetchOrdersThunk.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || null;
      });
  },
});

export default ordersSlice.reducer; 