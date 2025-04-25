import { createSlice } from "@reduxjs/toolkit";
import {
  addCommonQuestionThunk,
  createPostItemThunk,
  editCommonQuestionThunk,
  editPostItemStateThunk,
  fetchDraftItemThunk,
  fetchPostItemDetailThunk,
  fetchPostItemThunk,
  updatePostItemThunk,
} from "../util/postActions";

interface PostState {
  loading: boolean;
  success: boolean;
  error: boolean;
  post_data: object;
  postItemList: object[];
  draftList: object[];
  changed: boolean;
  userAction: boolean;
}

const initialState: PostState = {
  loading: false,
  success: false,
  error: false,
  post_data: {},
  postItemList: [],
  draftList: [],
  changed: false,
  userAction: false,
};

// 卖家发布的商品信息
export const createPostSlice = (axiosFn) => {
  const createPostItem = createPostItemThunk(axiosFn);
  const fetchPostItem = fetchPostItemThunk(axiosFn);
  const fetchItemDetail = fetchPostItemDetailThunk(axiosFn);
  const editItemState = editPostItemStateThunk(axiosFn);
  const fetchDraftItem = fetchDraftItemThunk(axiosFn);
  const addCommonQuestion = addCommonQuestionThunk(axiosFn);
  const updatePostItem = updatePostItemThunk(axiosFn);
  const postSlice = createSlice({
    name: "post",
    initialState,
    reducers: {
      onSave: (state, action) => {
        state.post_data = action.payload;
      },
      resetPostItemList: (state) => {
        state.postItemList = [];
      },
      resetDraftList: (state) => {
        state.draftList = [];
      },
      resetPostItem: (state) => {
        state.post_data = {};
      },
      setChanged: (state) => {
        state.changed = !state.changed;
      },
      clearItemDetail: (state) => {
        state.post_data = {};
      },
      setUserAction: (state) => {
        state.userAction = !state.userAction;
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(createPostItem.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(createPostItem.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.post_data = action.payload.data;
        })
        .addCase(createPostItem.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })

        // 更新商品
        .addCase(updatePostItem.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(updatePostItem.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
        })
        .addCase(updatePostItem.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })

        // 获取卖家发布的商品信息列表
        .addCase(fetchPostItem.pending, (state) => {
          state.loading = true;
        })
        .addCase(fetchPostItem.fulfilled, (state, action) => {
          state.loading = false;
          state.postItemList = action.payload.rows;
        })
        .addCase(fetchPostItem.rejected, (state) => {
          state.loading = false;
        })

        // 获取商品详情
        .addCase(fetchItemDetail.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchItemDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.post_data = action.payload.data;
        })
        .addCase(fetchItemDetail.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })

        // 上下架商品
        .addCase(editItemState.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(editItemState.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
        })
        .addCase(editItemState.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })

        .addCase(fetchDraftItem.pending, (state) => {
          state.loading = true;
        })
        .addCase(fetchDraftItem.fulfilled, (state, action) => {
          state.loading = false;
          state.draftList = action.payload.rows;
        })
        .addCase(fetchDraftItem.rejected, (state) => {
          state.loading = false;
        })
        .addCase(addCommonQuestion.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(addCommonQuestion.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
        })
        .addCase(addCommonQuestion.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        });
    },
  });
  return {
    ...postSlice,
    actions: {
      ...postSlice.actions,
      createPostItem,
      fetchPostItem,
      fetchItemDetail,
      editItemState,
      fetchDraftItem,
      addCommonQuestion,
      updatePostItem,
    },
  };
};
