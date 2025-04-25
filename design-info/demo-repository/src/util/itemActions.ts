import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";

export const createFetchMyStoriesThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encripty: number;
      encriptField: string[];
    },
    { memberId: number },
    { rejectValue: ErrorPayload }
  >(
    "/api/common/invitation-list/seller",
    async ({ memberId }, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/common/invitation-list", {
          memberId,
        });
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

export const createLikeStoryThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { id: number },
    { rejectValue: ErrorPayload }
  >("/api/invitation/like", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/invitation/like", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 获取故事详情
export const createFetchStoryDetailThunk = (axiosFn) =>
  createAsyncThunk<any, { id: number }, { rejectValue: ErrorPayload }>(
    "/api/invitation/detail",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet("/api/invitation/detail", params);
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
    }
  );

export const createRemoveLikeThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { ids: number[] },
    { rejectValue: ErrorPayload }
  >("/api/invitation/remove-like", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/invitation/remove-like",
        params.ids
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

// 删除故事
export const createDeleteStoryThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { ids: number[] },
    { rejectValue: ErrorPayload }
  >("/api/invitation/remove", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/invitation/remove", params.ids);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 修改故事
export const createUpdateStoryThunk = (axiosFn) =>
  createAsyncThunk<
    any,
    { id: number; content: string; images: any },
    { rejectValue: ErrorPayload }
  >("/api/invitation/update", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/invitation/update", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

export const createCollectionMemberThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { referId: number },
    { rejectValue: ErrorPayload }
  >("/api/invitation/collectionMember", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/invitation/collectionMember",
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

export const createRemoveCollectionMemberThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { referId: number },
    { rejectValue: ErrorPayload }
  >(
    "/api/invitation/cancelCollectionMember",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost(
          "/api/invitation/cancelCollectionMember",
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

// 获取故事评论列表
export const createFetchCommentsThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encryty: number;
      encryotField: string[];
    },
    { invitationId: number },
    { rejectValue: ErrorPayload }
  >("/api/comment/invitation/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/comment/invitation/list", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });
};

// 新增评论
export const createAddCommentThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    { invitationId: number; content: string; type: string },
    { rejectValue: ErrorPayload }
  >("/api/comment/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/comment/add", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

export const createFetchItemCommentsThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encryty: number;
      encryotField: string[];
    },
    { productId: number },
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

// 获取首页商品数据
export const createFetchHomeItemListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    object,
    { rejectValue: ErrorPayload }
  >("/api/shop/product/recommend/detail", async (_, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/shop/product/recommend/detail", {
        code: "home",
      });
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

export const createFetchBannerListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encripty: number;
      encriptField: string[];
    },
    {
      categoryId?: number;
      pageSize: number;
      pageNum: number;
    },
    { rejectValue: ErrorPayload }
  >("/api/content/banner/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/content/banner/list", params);
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

export const createFetchItemDetailThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    { id: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/get", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onGet("/api/shop/product/get", params);
      if (result.data.code !== 200) {
        return rejectWithValue(result.data);
      }
      return result.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 关于此商家
export const createFetchTenantProfileThunk = (axiosFn) =>
  createAsyncThunk<any, { memberId: number }, { rejectValue: ErrorPayload }>(
    "/api/project/details",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet("/api/project/details", params);
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
    }
  );

// 搜索关键词获取产品列表
export const createFetchSearchItemListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: number;
      encryptField: string[];
    },
    { keyword?: string; tenantId?: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/product/list", params);
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

// 邀请评价
export const createFetchInviteCommentThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    { orderId: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/order/invite", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/shop/order/invite", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 获取余额
export const createFetchBalanceThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    object,
    { rejectValue: ErrorPayload }
  >("/api/member/balance/info", async (_, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/member/balance/info");
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

// 余额提现

export const createWithdrawThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    {
      accountType: string;
      accountInfo: object;
      amount: number;
    },
    { rejectValue: ErrorPayload }
  >("/api/member/balance/cash", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/member/balance/cash", params);
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

// 获取交易记录
export const createFetchRecordsThunk = (axiosFn) =>
  createAsyncThunk<
    any,
    {
      pageNum: number;
      pageSize: number;
    },
    { rejectValue: ErrorPayload }
  >("/api/member/balance/cash/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/member/balance/cash/list", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      }
    }
  });
