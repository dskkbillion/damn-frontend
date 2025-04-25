/* eslint-disable no-empty-pattern */
import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";

interface AuthData {
  id: number;
  name: string;
  icon: string;
  remarks: string;
  status: string;
  type: string;
  authenticationAuditVo: authenticationAuditVoData[] | null;
}

interface authenticationAuditVoData {
  id: number;
  authenticaltionId: number;
  authenticationType: string;
  name: string;
  remarks: string | null;
  images: string[];
  audiStatus: string;
  auditRemark: string | null;
  feature: object;
}

interface UserAuthData {
  total: number | null;
  rows: AuthData[] | null;
  code: number | null;
  msg: string | null;
  encripty: number | null;
  encriptField: string[] | null;
}

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
  >("/api/common/invitation-list/user", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/common/invitation-list", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 添加我的故事
export const createAddMyStoryThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { content: string; images: string[] },
    { rejectValue: ErrorPayload }
  >("/api/invitation/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/invitation/add", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// add application of authentication
export const createAddAuthThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    {
      authenticationId: number;
      name?: string;
      images: string[];
      remarks?: string;
      feature?: object;
    },
    { rejectValue: ErrorPayload }
  >(
    "/api/project/authenticationAudit/add",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost(
          "/api/project/authenticationAudit/add",
          params
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
    }
  );

// 昵称/头像修改
export const createEditUserProfile = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number },
    { nickName?: string; avatar?: string },
    { rejectValue: ErrorPayload }
  >("/api/member/edit", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/member/edit", params);
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

export interface User {
  msg: string;
  code: number;
  data: {
    createTime: string; // 创建时间
    updateTime: string | null; // 更新时间
    sort: number; // 排序
    id: number; // 用户ID
    signature: string | null; // 个性签名
    birthday: string | null; // 生日
    vipTime: string | null; // VIP时间
    mobile: string; // 手机号码
    nickName: string; // 昵称
    trueName: string | null; // 真实姓名
    avatar: string | null; // 头像
    gender: "MALE" | "FEMALE" | "NONE"; // 性别
    status: "ENABLE" | "DISABLE"; // 状态
    type: "DEFAULT" | "VIP" | "ADMIN"; // 用户类型
    province: string | null; // 省份
    remarks: string | null; // 备注
    weminiOpenid: string | null; // 微信小程序OpenID
    weappOpenid: string | null; // 微信App OpenID
    weUnionid: string | null; // 微信UnionID
    lastLoginTime: string | null; // 最后登录时间
    payPriceTotal: number | null; // 总支付金额
    inviter: string | null; // 邀请人
    isApplyDel: number; // 是否申请删除
    xingzuo: string | null; // 星座
    age: number | null; // 年龄
  };
}

// 用户购物车列表
export const createFetchCartListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    any,
    { rejectValue: ErrorPayload }
  >("/api/shop/cart/list", async ({}, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/shop/cart/list", {});
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

// 添加收藏
export const createAddCartThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { variantId: number; tenantId: number; number: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/cart/modify-number", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/cart/modify-number", params);
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
};

// 删除购物车
export const createDeleteCartThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { ids: number[] },
    { rejectValue: ErrorPayload }
  >("/api/shop/cart/delete", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/shop/cart/delete", params.ids);
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
};

// 添加关注
export const createFollowThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    {
      objectId: number;
      type: string;
      feature?: object;
    },
    { rejectValue: ErrorPayload }
  >("/api/collect/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/collect/add", params);
      console.log("res", res.data);
      console.log("params", params);
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
};

// 获取收藏
export const createFetchCollectThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encripty: number;
      encriptField: string[];
    },
    { type: string },
    { rejectValue: ErrorPayload }
  >("/api/collect/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/collect/list", params);
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
};

// 取消关注
export const createUnFollowThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    {
      ids: number[];
    },
    { rejectValue: ErrorPayload }
  >("/api/collect/delete", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/collect/delete", params.ids);
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
};

// 获取卖家指标
export const createFetchStatDataThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    any,
    { rejectValue: ErrorPayload }
  >("/api/project/statistics/index", async ({}, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/project/statistics/index");
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
};

// 获取卖家指标（百分比数据）
export const createFetchPercentageStatDataThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    any,
    { rejectValue: ErrorPayload }
  >("/api/project/statistics/percent", async ({}, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/project/statistics/percent");
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
};

// 卖家升级
export const createFetchUpgradeLevelStatDataThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      msg: string;
      code: number;
      data: any;
    },
    any,
    { rejectValue: ErrorPayload }
  >("/api/project/statistics/upgradeLevel", async ({}, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/project/statistics/upgradeLevel");
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
};

export const createMemberUpdateThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      recoverFlag?: boolean;
      recoverContent?: string;
      onlineFlag?: boolean;
    },
    any,
    { rejectValue: ErrorPayload }
  >("/api/member/update", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/member/update", params);
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
};

// 点赞的故事记录
export const createFetchLikedStoryListThunk = (axiosFn) => {
  return createAsyncThunk<any, void, { rejectValue: ErrorPayload }>(
    "/api/collect/listLike",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/collect/listLike", {
          type: "like",
        });
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
};

// fetch user auth data
export const createFetchUserAuthThunk = (axiosFn: any) => {
  return createAsyncThunk<UserAuthData, object, { rejectValue: ErrorPayload }>(
    "/api/project/authentication/list",
    async (_, { rejectWithValue }) => {
      try {
        const result = await axiosFn.onPost("/api/project/authentication/list");
        return result.data;
      } catch (err: any) {
        return rejectWithValue(err.response.data);
      }
    }
  );
};

// 查询是否关注
export const createFetchIsFollowThunk = (axiosFn) => {
  return createAsyncThunk<
    {
      code: number;
      msg: string;
      data: any;
    },
    {
      type: string;
      searchIds: number[];
    },
    { rejectValue: ErrorPayload }
  >("/api/collect/isCollect", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/collect/isCollect", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return {
        code: res.data.code,
        msg: res.data.msg,
        data: res.data.data || {},
      };
    } catch (err: any) {
      return rejectWithValue(
        err.response?.data || { code: 500, msg: "请求失败" }
      );
    }
  });
};
