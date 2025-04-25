import { createAsyncThunk } from "@reduxjs/toolkit";

import { RootState } from "../store";

// 发送日志数据
export const createSendLoggingDataThunk = (axiosFn) =>
  createAsyncThunk(
    "/api/project/dau/add",
    async (data: any, { getState, rejectWithValue }) => {
      try {
        const state: RootState = getState();
        const deviceInfo = state.sys.deviceInfo;
        const userId = state.user.data?.id;

        // 确保 data.feature 存在
        const feature = {
          ...(data.feature || {}),
          is_visitor: !userId,
        };

        // 构建基础日志数据
        const loggingData = {
          ...data,
          feature,
          deviceInfo,
          // 根据用户登录状态设置 userSign
          userSign: userId || deviceInfo?.deviceId, // 如果有 userId 使用 userId，否则使用 deviceId
        };

        console.log("Sending logging data:", loggingData);

        return loggingData;
        // const res = await axios.post("/api/project/dau/add", loggingData);
        // return res.data;
      } catch (error) {
        if (error instanceof Error) {
          return rejectWithValue({
            message: error.message,
            name: error.name,
          });
        }
        return rejectWithValue(error);
      }
    }
  );
