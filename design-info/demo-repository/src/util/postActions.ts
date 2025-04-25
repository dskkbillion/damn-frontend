import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";

export const createPostItemThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: object },
    {
      name: string;
      images: string[];
      description: string;
      winImages: string[];
      variants: any[];
      productMaterials: any[];
    },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/create", async (params, { rejectWithValue }) => {
    try {
      const response = await axiosFn.onPost("/api/shop/product/create", params);
      if (response.data.code !== 200) {
        return rejectWithValue(response.data);
      }
      return response.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 获取商品列表
export const fetchPostItemThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: object[];
      code: number;
      msg: string;
      encrpt: string | null;
      encriptField: string | null;
    },
    { state?: string },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/myList", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onPost("/api/shop/product/myList", params);

      if (result.data.code !== 200) {
        rejectWithValue(result.data);
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

export const fetchDraftItemThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: object[];
      code: number;
      msg: string;
      encrpt: string | null;
      encriptField: string | null;
    },
    { pageNum: number; pageSize: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/myDraft", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onPost("/api/shop/product/myDraft", params);
      if (result.data.code !== 200) {
        rejectWithValue(result.data);
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

export const fetchPostItemDetailThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
      data: object[];
    },
    { id: number },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/get", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onGet("/api/shop/product/get", params);
      if (result.data.code !== 200) {
        rejectWithValue(result.data);
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

// 上下架商品
export const editPostItemStateThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    { id: number; state: string },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/edit", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onPost("/api/shop/product/edit", params);
      if (result.data.code !== 200) {
        rejectWithValue(result.data);
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

// 常见问题添加
export const addCommonQuestionThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    any,
    { rejectValue: ErrorPayload }
  >(
    "/api/project/productMaterials/add",
    async (params, { rejectWithValue }) => {
      try {
        const result = await axiosFn.onPost(
          "/api/project/productMaterials/add",
          params
        );
        if (result.data.code !== 200) {
          rejectWithValue(result.data);
        }
        return result.data;
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        }
      }
    }
  );

// 常见问题修改
export const editCommonQuestionThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    any,
    { rejectValue: ErrorPayload }
  >(
    "/api/project/productMaterials/edit",
    async (params, { rejectWithValue }) => {
      try {
        const result = await axiosFn.onPost(
          "/api/project/productMaterials/edit",
          params
        );
        if (result.data.code !== 200) {
          rejectWithValue(result.data);
        }
        return result.data;
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        }
      }
    }
  );

// 更新商品
export const updatePostItemThunk = (axiosFn) =>
  createAsyncThunk<
    {
      msg: string;
      code: number;
    },
    {
      id: number;
      tenantId: number;
      productType?: string;
      selectionMode?: string;
      state: string;
      name: string;
      images: string[];
      description: string;
      winImages: string[];
      variants: any[];
      productMaterials: any[];
    },
    { rejectValue: ErrorPayload }
  >("/api/shop/product/update", async (params, { rejectWithValue }) => {
    try {
      const result = await axiosFn.onPost("/api/shop/product/update", params);
      if (result.data.code !== 200) {
        rejectWithValue(result.data);
      }
      return result.data;
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      }
    }
  });
