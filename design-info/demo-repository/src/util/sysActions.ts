import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";
import axios from "axios";

export const createFetchGlobalDictThunk = (axiosFn) =>
  createAsyncThunk<any, any, { rejectValue: ErrorPayload }>(
    "/xunapi/dictdata",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axios({
          method: "post",
          url: "https://app.duoshaokankan.com/prod-api/xunapi/dictdata",
          data: {},
          headers: {
            "Content-Type": "application/json",
            clienttype: "android",
            version: "100",
            decrypt: "",
            Authorization:
              "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjYxNzIwNjZmLTgzNjctNDIwYS1hNDc1LTk4Y2ZlNjhjNzgwOCJ9.pGkfwDl6bdjLgElBlkt666tNXUTtpa4Ls3ev2zgDYzoAeZOW80DWfRCbnXWRjt_Ohh_WTv0HzQgAsVDgSmev1A",
          },
        });
        console.log("输出结果", res);
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

export const createFetchSysConfigThunk = (axiosFn) =>
  createAsyncThunk<any, any, { rejectValue: ErrorPayload }>(
    "/api/common/config",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet("/api/common/config");
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

// 获取协议内容
export const createFetchContentThunk = (axiosFn) =>
  createAsyncThunk<
    any,
    {
      id: number;
    },
    { rejectValue: ErrorPayload }
  >("/api/content/page/get", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/content/page/get", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return { id: params.id, data: res.data };
    } catch (err: any) {
      if (err.response && err.response.data.message) {
        return rejectWithValue(err.response.data.message);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });
