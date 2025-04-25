import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  EnhancedStore,
  ThunkDispatch,
  combineReducers,
  configureStore,
} from "@reduxjs/toolkit";
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import { Persistor, persistReducer, persistStore, PURGE } from "redux-persist";

import { createAuthSlice } from "../slices/authSlice";
import { createItemSlice } from "../slices/itemSlice";
import { createOrderListSlice } from "../slices/orderListSlice";
import { createOrderSlice } from "../slices/orderSlice";
import { createSysSlice } from "../slices/sysSlice";
import { createUserSlice } from "../slices/userSlice";
import { createAxiosFn, createAxiosInstance } from "../util/request";
import { authApi } from "../util/rtkquery";
import * as chatBotReducer from "../slices/chatBotSlice";
import { createPostSlice } from "../slices/postSlice";
import { createMsgSlice } from "../slices/msgSlice";
import { createFileSlice } from "../slices/fileSlice";
import { createCartSlice } from "../slices/cartSlice";
import { createChatBotSlice } from "../slices/chatBotSlice";
import { setFileSlice, setModelSlice, setStore } from "../util/storeInstance";
import { createLoggingSlice } from "../slices/loggingSlice";

// Define types for our axios function and actions
type AxiosFn = ReturnType<typeof createAxiosFn>;
type AuthSlice = ReturnType<typeof createAuthSlice>;
type UserSlice = ReturnType<typeof createUserSlice>;
type OrderSlice = ReturnType<typeof createOrderSlice>;
type SysSlice = ReturnType<typeof createSysSlice>;
type OrderListSlice = ReturnType<typeof createOrderListSlice>;
type ItemSlice = ReturnType<typeof createItemSlice>;
type ChatBotSlice = ReturnType<typeof createChatBotSlice>;
type PostSlice = ReturnType<typeof createPostSlice>;
type MsgState = ReturnType<typeof createMsgSlice>;
type FileSlice = ReturnType<typeof createFileSlice>;
type CartSlice = ReturnType<typeof createCartSlice>;
type loggingState = ReturnType<typeof createLoggingSlice>;
// Define the structure of slices
interface Slice {
  auth: AuthSlice;
  user: UserSlice;
  order: OrderSlice;
  orderList: OrderListSlice;
  sys: SysSlice;
  item: ItemSlice;
  post: PostSlice;
  msg: MsgState;
  cart: CartSlice;
  logging: loggingState;
}

interface Model {
  chatBot: ChatBotSlice;
}

interface File {
  file: FileSlice;
}

const LOGOUT = "user/logout";

// Create a function to generate all slices (except model)
const createSlice = (axiosFn: AxiosFn): Slice => ({
  auth: createAuthSlice(axiosFn),
  user: createUserSlice(axiosFn),
  order: createOrderSlice(axiosFn),
  orderList: createOrderListSlice(axiosFn),
  sys: createSysSlice(axiosFn),
  item: createItemSlice(axiosFn),
  post: createPostSlice(axiosFn),
  msg: createMsgSlice(axiosFn),
  cart: createCartSlice(axiosFn),
  logging: createLoggingSlice(axiosFn),
});

// Create a function to generate model slice
const createSliceForModel = (axiosFn: AxiosFn) => ({
  chatBot: createChatBotSlice(axiosFn),
});

const createSliceForFile = (axiosFn: AxiosFn) => ({
  file: createFileSlice(axiosFn),
});

// Define a type for the return value of createStore
interface StoreReturn {
  store: EnhancedStore;
  persistor: Persistor;
  slices: Slice;
  model: Model;
  fileSlice: File;
}

export const createStore = (): StoreReturn => {
  let store: EnhancedStore;

  // 平台端请求实例
  const axiosPlat = createAxiosInstance({
    baseURL: "https://app.duoshaokankan.com/prod-api",
    content_type: "application/json",
    type: "user",
  });

  // 文件上传请求实例
  const axiosFile = createAxiosInstance({
    baseURL: "https://app.duoshaokankan.com/prod-api",
    content_type: "multipart/form-data",
    type: "user",
  });

  // 模型端请求实例
  const axiosModel = createAxiosInstance({
    baseURL: "http://47.113.230.11:5102/",
    content_type: "application/json",
    type: "model",
  });

  // 建立异步请求
  const axiosFn = createAxiosFn(axiosPlat);
  const axiosFnModel = createAxiosFn(axiosModel);
  const axiosFnFile = createAxiosFn(axiosFile);

  const slices = createSlice(axiosFn);
  const model = createSliceForModel(axiosFnModel);
  const fileSlice = createSliceForFile(axiosFnFile);

  const AuthPersistConfig = {
    key: "auth",
    storage: AsyncStorage,
    whitelist: [
      "userToken",
      "userInfo",
      "initilized",
      "expired",
      "deleteAccount",
    ],
  };

  const userPersistConfig = {
    key: "user",
    storage: AsyncStorage,
    whitelist: ["data", "initilized", "userId", "statData", "autoReply"],
  };

  const orderPersistConfig = {
    key: "order",
    storage: AsyncStorage,
    whitelist: ["orderList"],
  };

  const sysPersistConfig = {
    key: "sys",
    storage: AsyncStorage,
    whitelist: ["sysData", "dict", "initilized"],
  };

  const postPersistConfig = {
    key: "post",
    storage: AsyncStorage,
    whitelist: ["post_data"],
  };

  const msgPersistConfig = {
    key: "msg",
    storage: AsyncStorage,
    whitelist: ["msg"],
  };

  const cartPersistConfig = {
    key: "cart",
    storage: AsyncStorage,
    whitelist: ["cartList"],
  };

  const itemPersistConfig = {
    key: "item",
    storage: AsyncStorage,
    whitelist: ["searchItemList"],
  };

  const filePersistConfig = {
    key: "file",
    storage: AsyncStorage,
    whitelist: ["uploadFiles", "acceptFiles", "files", "images"],
  };
  // const modelPersistConfig = {
  //   key: "model",
  //   storage: AsyncStorage,
  //   whitelist: ["access_token", "conversation_id", "history"],
  // };

  // const itemPersistConfig = {
  //   key: "item",
  //   store: AsyncStorage,
  //   whitelist: ["data"]
  // }

  const authPersistedReducer = persistReducer(
    AuthPersistConfig,
    slices.auth.reducer
  );
  const userPersistedReducer = persistReducer(
    userPersistConfig,
    slices.user.reducer
  );
  const orderPersistedReducer = persistReducer(
    orderPersistConfig,
    slices.order.reducer
  );
  const sysPersistedReducer = persistReducer(
    sysPersistConfig,
    slices.sys.reducer
  );

  const postPersistedReducer = persistReducer(
    postPersistConfig,
    slices.post.reducer
  );

  const msgPersistedReducer = persistReducer(
    msgPersistConfig,
    slices.msg.reducer
  );

  const cartPersistedReducer = persistReducer(
    cartPersistConfig,
    slices.cart.reducer
  );

  const itemPersistedReducer = persistReducer(
    itemPersistConfig,
    slices.item.reducer
  );

  const filePersistedReducer = persistReducer(
    filePersistConfig,
    fileSlice.file.reducer
  );

  const rootReducer = combineReducers({
    auth: authPersistedReducer,
    user: userPersistedReducer,
    order: orderPersistedReducer,
    orderList: slices.orderList.reducer,
    sys: sysPersistedReducer,
    item: itemPersistedReducer,
    post: postPersistedReducer,
    msg: msgPersistedReducer,
    chatBot: model.chatBot.reducer,
    file: filePersistedReducer,
    cart: cartPersistedReducer,
    logging: slices.logging.reducer,
    [authApi.reducerPath]: authApi.reducer,
  });

  store = configureStore({
    reducer: (state, action) => {
      if (action.type === LOGOUT) {
        // 只在 logout 触发时清除指定的状态
        state = {
          ...state,
          auth: undefined,
          user: undefined,
          order: undefined,
        };
      }
      return rootReducer(state, action);
    },
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware({
        serializableCheck: {
          ignoredActions: [
            "persist/PERSIST",
            "persist/REHYDRATE",
            "persist/FLUSH",
            "persist/PAUSE",
            "persist/REHYDRATE",
            "persist/REGISTER",
            PURGE,
          ],
        },
      }).concat(authApi.middleware),
    enhancers: (getDefaultEnhancers) =>
      getDefaultEnhancers({
        autoBatch: false,
      }),
  });

  // 设置 store 和 model slice
  setStore(store);
  setModelSlice({ model }); // 设置 model slice

  const persistor = persistStore(store);
  return { store, persistor, slices, model, fileSlice };
};

// Export types
export const { store, persistor, slices, model, fileSlice } = createStore();
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = ThunkDispatch<RootState, unknown, any>;

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

// Logout function
export const logout = async () => {
  store.dispatch({ type: LOGOUT });

  // Dispatch PURGE for each persisted reducer except sys
  store.dispatch({ type: PURGE, key: "auth", result: () => null });
  store.dispatch({ type: PURGE, key: "user", result: () => null });
  store.dispatch({ type: PURGE, key: "order", result: () => null });

  await persistor.flush(); // 确保所有挂起的操作完成

  // 手动清除 AsyncStorage 中的持久化数据
  await AsyncStorage.removeItem("persist:auth");
  await AsyncStorage.removeItem("persist:user");
  await AsyncStorage.removeItem("persist:order");

  await persistor.purge(); // 再次清除，以防万一
};
