import { createAsyncThunk } from "@reduxjs/toolkit";

import { User } from "./userActions";

export type ErrorPayload = {
  code: number;
  msg: string;
};

interface RegisterUserParams {
  mobile: string;
  code: string;
  scene: string;
  inviterId?: string; // 如果这是可选的
}

export const createRegisterUserThunk = (axisoFn) =>
  createAsyncThunk<void, RegisterUserParams, { rejectValue: ErrorPayload }>(
    "/api/auth/register",
    async ({ mobile, code, scene }, { rejectWithValue }) => {
      try {
        await axisoFn.onPost("/api/auth/register", {
          mobile,
          code,
          scene,
        });
      } catch (err: any) {
        if (err.response && err.response.data.message) {
          return rejectWithValue(err.response.data.message);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

export interface LoginUserResponse {
  code: number;
  token: string;
}

export const createUserLoginThunk = (axisoFn) =>
  createAsyncThunk<LoginUserResponse, any, { rejectValue: ErrorPayload }>(
    "/api/auth/login",
    async (params, { rejectWithValue }) => {
      try {
        if (params.scene === "jiguang_login") {
          const res = await axisoFn.onPost("/api/auth/login/", params);
          return res.data;
        } else {
          const res = await axisoFn.onPost("/api/auth/login", params);
          return res.data;
        }
      } catch (err: any) {
        if (err.response && err.response.data) {
          return rejectWithValue(err.response.data);
        } else {
          return rejectWithValue(err);
        }
      }
    }
  );

// 验证码校验
// export const createVerifyCodeThunk = (axisoFn) =>
//   createAsyncThunk<any, void, { rejectValue: ErrorPayload }>(
//     "/api/auth/verifyCode",
//     async (_, { rejectWithValue }) => {
//       try {
//         const res = await axisoFn.onPost("/api/auth/verifyCode");
//       }
//     }
//   );

// 注销操作
export const createDeleteAccountThunk = (axisoFn) =>
  createAsyncThunk<any, void, { rejectValue: ErrorPayload }>(
    "/api/member/writeOff",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axisoFn.onGet("/api/member/writeOff");
        if (res?.data?.code !== 200) {
          return rejectWithValue(res);
        }
      } catch (err: any) {
        return rejectWithValue(err);
      }
    }
  );

// 撤销注销操作
export const createCancleDeleteAccount = (axiosFn) =>
  createAsyncThunk<any, void, { rejectValue: ErrorPayload }>(
    "/api/project/logout/cancel",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/project/logout/cancel");
        if (res?.data?.code !== 200) {
          return rejectWithValue(res);
        }
      } catch (err: any) {
        return rejectWithValue(err);
      }
    }
  );

export const createFetchUserProfileThunk = (axiosFn) =>
  createAsyncThunk<User, object, { rejectValue: ErrorPayload }>(
    "/api/member/info",
    async (_, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onGet("/api/member/info");
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

export const sendVerifyCodeThunk = (axiosFn) =>
  createAsyncThunk<
    any,
    {
      mobile: string;
    },
    { rejectValue: ErrorPayload }
  >("/api/common/send-code/register", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost(
        "/api/common/send-code/register",
        params
      );
      if (res?.data?.code !== 200) {
        return rejectWithValue(res);
      }
    } catch (err: any) {
      return rejectWithValue(err);
    }
  });
