import { createSlice } from "@reduxjs/toolkit";

import { createSendLoggingDataThunk } from "@/src/util/loggingActions";

interface loggingState {
  isLoading: boolean;
  error: boolean;
}

const initialState: loggingState = {
  isLoading: false,
  error: false,
};

export const createLoggingSlice = (axiosFn) => {
  const sendLoggingData = createSendLoggingDataThunk(axiosFn);

  const loggingSlice = createSlice({
    name: "logging",
    initialState,
    reducers: {},
    extraReducers: (builder) => {
      builder
        .addCase(sendLoggingData.fulfilled, (state, action) => {})
        .addCase(sendLoggingData.pending, (state) => {
          state.isLoading = true;
        })
        .addCase(sendLoggingData.rejected, (state, action) => {
          state.isLoading = false;
          state.error = true;
        });
    },
  });

  return {
    ...loggingSlice,
    actions: {
      ...loggingSlice.actions,
      sendLoggingData,
    },
  };
};
