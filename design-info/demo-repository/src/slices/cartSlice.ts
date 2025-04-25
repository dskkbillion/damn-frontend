import { createSlice, PayloadAction } from "@reduxjs/toolkit";

import {
  createAddCartThunk,
  createDeleteCartThunk,
  createFetchCartListThunk,
  createFetchCollectThunk,
  createFetchIsFollowThunk,
  createFollowThunk,
  createUnFollowThunk,
} from "../util/userActions";

interface CartState {
  loading: boolean;
  msg: string;
  code: number | null;
  cartList: any[];
  followList: any[];
  clickedList: any[];
  success: boolean;
  changed: boolean;
  error: boolean;
  isFollowing: boolean;
}

const initialState: CartState = {
  loading: false,
  msg: "",
  code: null,
  cartList: [],
  followList: [],
  clickedList: [],
  success: false,
  changed: false,
  error: false,
  isFollowing: false,
};

export const createCartSlice = (axiosFn) => {
  const fetchCartList = createFetchCartListThunk(axiosFn);
  const addCart = createAddCartThunk(axiosFn);
  const deleteCart = createDeleteCartThunk(axiosFn);
  const followUser = createFollowThunk(axiosFn);
  const unFollowUser = createUnFollowThunk(axiosFn);
  const fetchCollecList = createFetchCollectThunk(axiosFn);
  const fetchIsFollow = createFetchIsFollowThunk(axiosFn);
  const CartSlice = createSlice({
    name: "cart",
    initialState,
    reducers: {
      resetCartList: (state) => {
        state.cartList = [];
      },
      resetFollowList: (state) => {
        state.followList = [];
      },
      addCheckedList: (state, action) => {
        if (state.clickedList.includes(action.payload)) {
          return;
        }
        state.clickedList.push(action.payload);
      },
      removeCheckedList: (state, action) => {
        state.clickedList = state.clickedList.filter(
          (item) => item !== action.payload
        );
      },
      setChanged: (state) => {
        state.changed = !state.changed;
      },
      setIsFollowing: (state, action: PayloadAction<boolean>) => {
        console.log("action.payload", action.payload);
        state.isFollowing = action.payload;
      },
      clearFollow: (state) => {
        state.isFollowing = false;
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(fetchCartList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchCartList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.cartList = action.payload.data;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchCartList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(addCart.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(addCart.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(addCart.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(deleteCart.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(deleteCart.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(deleteCart.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(followUser.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(followUser.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(followUser.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(unFollowUser.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(unFollowUser.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(unFollowUser.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchCollecList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchCollecList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.followList = action.payload.rows;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchCollecList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchIsFollow.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchIsFollow.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(fetchIsFollow.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        });
    },
  });
  return {
    ...CartSlice,
    actions: {
      ...CartSlice.actions,
      fetchCartList,
      addCart,
      deleteCart,
      followUser,
      unFollowUser,
      fetchCollecList,
      fetchIsFollow,
    },
  };
};
