import { createAsyncThunk } from "@reduxjs/toolkit";
import { ErrorPayload } from "./authActions";
import axios from "axios";

// 创建聊天室
export const createMsgRoomThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    { doctorId: number; type: string },
    { rejectValue: ErrorPayload }
  >("/api/chat/addChat", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/chat/addChat", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 发送消息
export const createSendMsgThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    { chatId: number; context: string; type: string },
    { rejectValue: ErrorPayload }
  >("/common/chat/message/add", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/common/chat/message/add", params);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 获取聊天室列表
export const getChatRoomListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: boolean | null;
      encryptField: string | null;
    },
    void,
    { rejectValue: ErrorPayload }
  >("/api/chat/list", async (_, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/api/chat/list", {});
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 获取消息列表
export const getMsgListThunk = (axiosFn) =>
  createAsyncThunk<
    {
      total: number;
      rows: any[];
      code: number;
      msg: string;
      encrypt: boolean | null;
      encryptField: string | null;
    },
    { chatId: number; pageNum?: number; pageSize?: number },
    { rejectValue: ErrorPayload }
  >("/api/chat/message/list", async (params, { rejectWithValue }) => {
    try {
      // 设置默认分页参数
      const requestParams = {
        chatId: params.chatId,
        pageNum: params.pageNum || 1,
        pageSize: params.pageSize || 50, // 默认每页50条消息
      };
      const res = await axiosFn.onPost("/api/chat/message/list", requestParams);
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 撤回消息
export const createRevokeThunk = (axiosFn) =>
  createAsyncThunk<any, { id: number }, { rejectValue: ErrorPayload }>(
    "/api/chat/message/withdraw",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/chat/message/withdraw", params);
        return { data: res.data, id: params.id };
      } catch (err: any) {
        if (err.response && err.response.data) {
          return rejectWithValue(err.response.data);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

// 删除消息
export const createDeleteThunk = (axiosFn) =>
  createAsyncThunk<any, any, { rejectValue: ErrorPayload }>(
    "/api/chat/message/delete",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/chat/message/delete", params);
        return res.data;
      } catch (err: any) {
        if (err.response && err.response.data) {
          return rejectWithValue(err.response.data);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );

// 查看聊天室详情
export const createFetchChatroomThunk = (axiosFn) =>
  createAsyncThunk<
    any,
    {
      id: number;
    },
    { rejectValue: ErrorPayload }
  >("/api/chat/get", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onGet("/api/chat/get", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });
