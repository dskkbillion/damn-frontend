// for system slice

import { createSlice } from "@reduxjs/toolkit";

import {
  createFetchContentThunk,
  createFetchGlobalDictThunk,
  createFetchSysConfigThunk,
} from "../util/sysActions";

interface SysState {
  loading: boolean;
  error: boolean;
  dictInitilized: boolean;
  sysConfigInitilized: boolean;
  contentInitilized: boolean;
  initilized: boolean;
  dict: object | null;
  sysConfig: object | null;
  deviceInfo: object | null;
  msg: string;
  code: number | null;
  success: boolean;
  server: string;
  content: {
    register: object | null;
    privacy: object | null;
    about: object | null;
    payment: object | null;
    delete: object | null;
  };
  mounted: boolean;
  reloadKey: number;
  // 极光配置
  ios_jverfication: object | null;
  android_jverfication: object | null;
}

const initialState: SysState = {
  loading: false,
  error: false,
  dictInitilized: false,
  sysConfigInitilized: false,
  contentInitilized: false,
  initilized: false,
  dict: null,
  sysConfig: null,
  deviceInfo: null,
  msg: "",
  code: null,
  success: false,
  server: "https://app.duoshaokankan.com/prod-api",
  content: {
    register: {},
    privacy: {},
    about: {},
    payment: {},
    delete: {},
  },
  mounted: false,
  reloadKey: 0,
  ios_jverfication: {
    time: 5000,
    appKey: "1234567890", // ios 极光 appKey
    channel: "default", // ios 极光 channel
    advertiserId: "1234567890", // ios 极光 advertiserId
    debug: true,
  },
  android_jverfication: {
    time: 5000,
    appKey: "1234567890", // android 极光 appKey
    channel: "default", // android 极光 channel
    advertiserId: "1234567890", // android 极光 advertiserId
    debug: true,
  },
};

export const createSysSlice = (axiosFn) => {
  const fetchSysConfig = createFetchSysConfigThunk(axiosFn);
  const fetchGlobalDict = createFetchGlobalDictThunk(axiosFn);
  const fetchContent = createFetchContentThunk(axiosFn);
  const sysSlice = createSlice({
    name: "sys",
    initialState,
    reducers: {
      setInitilized: (state) => {
        state.loading = false;
        state.initilized = true;
      },
      setError: (state) => {
        state.loading = false;
        state.error = true;
      },
      resetError: (state) => {
        state.error = false;
      },
      resetInitialized: (state) => {
        state.initilized = false;
        state.dictInitilized = false;
        state.sysConfigInitilized = false;
        state.contentInitilized = false;
        state.loading = false;
      },
      setMounted: (state) => {
        state.mounted = true;
      },
      resetMounted: (state) => {
        state.mounted = false;
      },
      incrementReloadKey: (state) => {
        state.reloadKey += 1;
      },
      setDeviceInfo: (state, action) => {
        state.deviceInfo = action.payload;
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(fetchGlobalDict.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchGlobalDict.fulfilled, (state, action) => {
          console.log("333333");
          state.error = false;
          state.dict = action.payload.data;
          state.code = action.payload.code;
          state.dictInitilized = true;
        })

        .addCase(fetchSysConfig.pending, (state, action) => {
          console.log("444444");
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchSysConfig.fulfilled, (state, action) => {
          state.error = false;
          state.sysConfig = action.payload.data;
          state.code = action.payload.code;
          state.sysConfigInitilized = true;
        })

        .addCase(fetchContent.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchContent.fulfilled, (state, action) => {
          state.error = false;
          state.code = action.payload.code;
          if (action.payload.id === 1) {
            state.content["register"] = action.payload.data.data;
          } else if (action.payload.id === 2) {
            state.content["privacy"] = action.payload.data.data;
          } else if (action.payload.id === 3) {
            state.content["payment"] = action.payload.data.data;
          } else if (action.payload.id === 4) {
            state.content["about"] = action.payload.data.data;
          } else if (action.payload.id === 6) {
            state.content["delete"] = action.payload.data.data;
          }
          state.contentInitilized = true;
        });
    },
  });

  return {
    ...sysSlice,
    actions: {
      ...sysSlice.actions,
      fetchGlobalDict,
      fetchSysConfig,
      fetchContent,
    },
  };
};
