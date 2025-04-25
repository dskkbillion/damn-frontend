import { createSlice, PayloadAction } from "@reduxjs/toolkit";

import {
  createAddCommentThunk,
  createCollectionMemberThunk,
  createDeleteStoryThunk,
  createFetchBannerListThunk,
  createFetchCommentsThunk,
  createFetchHomeItemListThunk,
  createFetchInviteCommentThunk,
  createFetchItemCommentsThunk,
  createFetchItemDetailThunk,
  createFetchMyStoriesThunk,
  createFetchSearchItemListThunk,
  createFetchStoryDetailThunk,
  createFetchTenantProfileThunk,
  createLikeStoryThunk,
  createRemoveCollectionMemberThunk,
  createRemoveLikeThunk,
  createUpdateStoryThunk,
} from "../util/itemActions";

interface ItemState {
  loading: boolean;
  msg: string;
  code: number | null;
  data: object | null;
  homeItemList: any[];
  searchItemList: any[];
  bannerList: any[];
  ItemDetail: any;
  tenant: any[];
  tenantProfile: any;
  stories: any[];
  storyDetail: object;
  storyChanged: boolean;
  open_stories: object;
  comments: any[]; // comments for seller story
  comment_added: any;
  item_comments: any[]; // item comments
  comments_num: number;
  success: boolean;
  error: boolean;
}

const initialState: ItemState = {
  loading: false,
  msg: "",
  code: null,
  data: null,
  homeItemList: [],
  searchItemList: [],
  bannerList: [],
  stories: [],
  storyDetail: {},
  storyChanged: false,
  ItemDetail: {},
  tenant: [],
  tenantProfile: {},
  open_stories: [],
  comments: [],
  comment_added: null,
  item_comments: [],
  comments_num: 0,
  success: false,
  error: false,
};

// item slice (买家浏览的商品信息)
export const createItemSlice = (axiosFn) => {
  const fetchUserStores = createFetchMyStoriesThunk(axiosFn);
  const likeStory = createLikeStoryThunk(axiosFn);
  const removeLike = createRemoveLikeThunk(axiosFn);
  const collectionMember = createCollectionMemberThunk(axiosFn);
  const removeCollectionMember = createRemoveCollectionMemberThunk(axiosFn);
  const fetchComments = createFetchCommentsThunk(axiosFn);
  const addComment = createAddCommentThunk(axiosFn);
  const fetchItemComments = createFetchItemCommentsThunk(axiosFn);
  // 获取首页推荐商品数据
  const fetchHomeItemList = createFetchHomeItemListThunk(axiosFn);
  // 获取首页轮播图
  const fetchBannerList = createFetchBannerListThunk(axiosFn);
  // 获取商品数据
  const fetchItemDetail = createFetchItemDetailThunk(axiosFn);

  // 获取卖家数据
  const fetchTenantProfile = createFetchTenantProfileThunk(axiosFn);

  // 获取搜索商品
  const fetchSearchItemList = createFetchSearchItemListThunk(axiosFn);

  // 邀请评价
  const inviteComment = createFetchInviteCommentThunk(axiosFn);

  // 获取故事详情
  const fetchStoryDetail = createFetchStoryDetailThunk(axiosFn);
  // 更新故事
  const updateStory = createUpdateStoryThunk(axiosFn);
  // 删除故事
  const deleteStory = createDeleteStoryThunk(axiosFn);

  const itemSlice = createSlice({
    name: "item",
    initialState,
    reducers: {
      resetUserStories: (state) => {
        state.stories = [];
        state.open_stories = [];
      },
      resetSuccess: (state) => {
        state.success = false;
      },
      resetHomeItemList: (state) => {
        state.homeItemList = [];
      },
      setStoryChanged: (state) => {
        state.storyChanged = !state.storyChanged;
      },
      clearItemComments: (state) => {
        state.item_comments = [];
      },
      clearItemDetail: (state) => {
        state.ItemDetail = null;
        state.tenant = [];
        state.tenantProfile = {};
      },
      clearTenant: (state) => {
        state.tenant = [];
        state.tenantProfile = {};
      },
      clearTenantProfile: (state) => {
        state.tenantProfile = {};
      },
      updateFansNum: (state, action: PayloadAction<{ increment: boolean }>) => {
        if (state.tenantProfile) {
          state.tenantProfile.collectNum += action.payload.increment ? 1 : -1;
          console.log(
            "state.tenantProfile.collectNum",
            state.tenantProfile.collectNum
          );
        }
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(fetchUserStores.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchUserStores.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.stories = action.payload?.rows;

          if (state.stories.length > 0) {
            state.open_stories = state.stories.filter(
              (item) => item.status === "open" && item.auditStatus === "PASS"
            );
          }
        })
        .addCase(fetchUserStores.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(likeStory.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(likeStory.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(likeStory.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(removeLike.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(removeLike.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(removeLike.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(collectionMember.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(collectionMember.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(collectionMember.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(removeCollectionMember.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(removeCollectionMember.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(removeCollectionMember.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchComments.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchComments.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.comments = action.payload?.rows;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchComments.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(addComment.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(addComment.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.comment_added = action.payload.data;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })
        .addCase(addComment.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchItemComments.pending, (state, action) => {
          state.loading = true;
          state.error = false;
          state.comments_num = 0;
          state.item_comments = [];
        })
        .addCase(fetchItemComments.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.item_comments = action.payload.rows;
          state.comments_num = action.payload.total;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchItemComments.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchHomeItemList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchHomeItemList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.homeItemList = action.payload?.data;
        })

        .addCase(fetchHomeItemList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 获取首页轮播图
        .addCase(fetchBannerList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchBannerList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.bannerList = action.payload?.rows;
        })

        .addCase(fetchBannerList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchItemDetail.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchItemDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.ItemDetail = action.payload?.data;
          state.tenant = action.payload?.data?.tenant;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchItemDetail.rejected, (state, action) => {
          console.log("fetchItemDetail.rejected", action.payload);
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 获取卖家数据
        .addCase(fetchTenantProfile.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchTenantProfile.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.tenantProfile = action.payload.data;
        })

        .addCase(fetchTenantProfile.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchSearchItemList.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchSearchItemList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.searchItemList = action.payload?.rows;
        })

        .addCase(fetchSearchItemList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 邀请评价
        .addCase(inviteComment.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(inviteComment.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })

        .addCase(inviteComment.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 获取故事详情
        .addCase(fetchStoryDetail.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchStoryDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
          state.storyDetail = action.payload.data;
        })

        .addCase(fetchStoryDetail.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 删除故事
        .addCase(deleteStory.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(deleteStory.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })

        .addCase(deleteStory.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 更新故事
        .addCase(updateStory.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(updateStory.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.msg = action.payload.msg;
          state.code = action.payload.code;
        })

        .addCase(updateStory.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        });
    },
  });
  return {
    ...itemSlice,
    actions: {
      ...itemSlice.actions,
      fetchUserStores,
      likeStory,
      removeLike,
      collectionMember,
      removeCollectionMember,
      fetchComments,
      addComment,
      fetchItemComments,
      fetchHomeItemList,
      fetchBannerList,
      fetchItemDetail,
      fetchTenantProfile,
      fetchSearchItemList,
      inviteComment,
      fetchStoryDetail,
      deleteStory,
      updateStory,
      clearItemDetail: itemSlice.actions.clearItemDetail,
      clearItemComments: itemSlice.actions.clearItemComments,
      clearTenant: itemSlice.actions.clearTenant,
    },
  };
};
