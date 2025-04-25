import { Store } from "@reduxjs/toolkit";

import { RootState } from "../store";

let storeInstance: Store | null = null;
let modelSlice: any = null;
let fileSlice: any = null;

// 设置 store 实例
export const setStore = (store: Store) => {
  if (!storeInstance) {
    storeInstance = store;
  }
};

// 获取 store 实例
export const getStore = (): Store | null => {
  if (!storeInstance) {
    console.warn("Store instance not initialized");
  }
  return storeInstance;
};

// 获取 store 的状态
export const getState = (): RootState | object => {
  if (!storeInstance) {
    console.warn("Store instance not initialized");
    return {};
  }
  return storeInstance.getState();
};

// 清除 store 实例
export const clearStore = () => {
  storeInstance = null;
};

export const setModelSlice = (slice: any) => {
  modelSlice = slice;
};

export const setFileSlice = (file: any) => {
  fileSlice = file;
};

// 获取 model 实例
export const getModelSlice = () => {
  if (!modelSlice) {
    console.warn("Model slice not initialized");
  }
  return modelSlice;
};

// 获取 fileSlice 实例
export const getFileSlice = () => {
  return fileSlice;
};
