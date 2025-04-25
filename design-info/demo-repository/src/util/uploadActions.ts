import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";

export const createFileUploadThunk = (axiosFn) =>
  createAsyncThunk<any, any, { rejectValue: ErrorPayload }>(
    "/api/common/public/upload",
    async (params, { rejectWithValue }) => {
      try {
        const res = await axiosFn.onPost("/api/common/public/upload", params);
        if (res.data.code === 200) {
          return res.data;
        } else {
          return rejectWithValue(res.data);
        }
      } catch (err: any) {
        if (err.response && err.response.data) {
          return rejectWithValue(err.response.data);
        } else {
          return rejectWithValue(err.message);
        }
      }
    }
  );
