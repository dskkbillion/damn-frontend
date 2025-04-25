import { createSlice, PayloadAction } from "@reduxjs/toolkit";

import {
  ErrorPayload,
  createCancleDeleteAccount,
  createDeleteAccountThunk,
  createFetchUserProfileThunk,
  createRegisterUserThunk,
  createUserLoginThunk,
  sendVerifyCodeThunk,
} from "@/src/util/authActions";

interface AuthState {
  loading: boolean;
  userInfo: object;
  userToken: string | null;
  error: ErrorPayload | boolean;
  deleteAccount: boolean;
  expired: boolean;
  initilized: boolean;
  reloadKey: number;
  source_page: string;
  auth_method: string;
}

const initialState: AuthState = {
  loading: false,
  userInfo: {}, // for user object
  userToken: null, // for storing user token
  error: false, // for storing error
  deleteAccount: false,
  expired: false, // for monitoring the token expiration
  initilized: false,
  source_page: "",
  reloadKey: 0,
  auth_method: "oneKey", // oneKey, mobile, wechat（默认为一键登录）
};

export const createAuthSlice = (axiosFn: any) => {
  const registerUser = createRegisterUserThunk(axiosFn);
  const userLogin = createUserLoginThunk(axiosFn);
  const deleteAccount = createDeleteAccountThunk(axiosFn);
  const cancleDeleteAccount = createCancleDeleteAccount(axiosFn);
  const fetchUserProfile = createFetchUserProfileThunk(axiosFn);
  const sendVerifyCode = sendVerifyCodeThunk(axiosFn);

  const authSlice = createSlice({
    name: "auth",
    initialState,
    reducers: {
      logout: (state) => {
        state = initialState;
      },
      setTokenExpired: (state, action) => {
        state.expired = action.payload.expired;
      },
      setError: (state) => {
        state.error = true;
      },
      setInitilized: (state) => {
        state.initilized = true;
      },
      resetError: (state) => {
        state.error = false;
      },
      resetInitialized: (state) => {
        state.initilized = false;
        state.loading = false;
      },
      incrementReloadKey: (state) => {
        state.reloadKey++;
      },
      setSourcePage: (state, action) => {
        state.source_page = action.payload;
      },
      setAuthMethod: (state, action: PayloadAction<string>) => {
        console.log("setAuthMethod111:", action.payload);
        state.auth_method = action.payload;
      },
      resetAuth: (state) => {
        state.auth_method = "oneKey";
      },
    },
    extraReducers: (builder) => {
      builder
        // user registration
        .addCase(registerUser.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(registerUser.fulfilled, (state, {}) => {
          state.loading = false;
        })
        .addCase(registerUser.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })
        // user login
        .addCase(userLogin.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(userLogin.fulfilled, (state, action) => {
          state.loading = false;
          state.userInfo = action.payload || {};
          state.userToken = action.payload?.token || null;
        })
        .addCase(userLogin.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })
        .addCase(deleteAccount.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(deleteAccount.fulfilled, (state) => {
          state.loading = false;
          state.deleteAccount = true;
        })
        .addCase(deleteAccount.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })
        .addCase(cancleDeleteAccount.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(cancleDeleteAccount.fulfilled, (state) => {
          state.loading = false;
          state.deleteAccount = false;
        })
        .addCase(cancleDeleteAccount.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        })

        .addCase(fetchUserProfile.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchUserProfile.fulfilled, (state, action) => {
          state.loading = false;
          state.error = false;
          state.userInfo = action?.payload.data;
        })
        .addCase(fetchUserProfile.rejected, (state, action) => {
          state.loading = false;
        })
        .addCase(sendVerifyCode.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(sendVerifyCode.fulfilled, (state) => {
          state.loading = false;
        })
        .addCase(sendVerifyCode.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
        });
    },
  });
  return {
    ...authSlice,
    actions: {
      ...authSlice.actions,
      registerUser,
      userLogin,
      deleteAccount,
      cancleDeleteAccount,
      fetchUserProfile,
      sendVerifyCode,
    },
  };
};

export const { setAuthMethod } = createAuthSlice(null).actions;
