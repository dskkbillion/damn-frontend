import axios from "axios";
import { router } from "expo-router";

import { getStore, getState } from "./storeInstance";
import { slices } from "../store/index";

// 定义白名单路径
const whiteList = [
  "/api/content/banner/list", // 首页展示
  "/api/shop/product/recommend/detail", // 首页推荐
  "/xunapi/dictdata", // 字典数据

  // ... 其他不需要授权的路径
];

// 添加一个标志来防止重复跳转
let isRedirecting = false;

// 处理未授权的函数
const handleUnauthorized = (api) => {
  let source_page = "/";

  // 根据 API 路径判断来源页面
  if (api.includes("/api/chat/list")) {
    source_page = "/(tabs)/chat";
  } else if (api.includes("/api/project/authentication/list")) {
    source_page = "/(tabs)/profile";
  } else if (api.includes("/api/member/info")) {
    source_page = "/(tabs)/profile";
  }

  if (!isRedirecting) {
    isRedirecting = true;
    const store = getStore();
    if (store) {
      store.dispatch({ type: "auth/logout" });
      store.dispatch(slices.auth.actions.setSourcePage(source_page));
    }

    router.replace({
      pathname: "/(outer)/login",
    });

    setTimeout(() => {
      isRedirecting = false;
    }, 2000);
  }
};

export const createAxiosInstance = ({ baseURL, content_type, type }) => {
  const axiosInstance = axios.create({
    baseURL,
    timeout: 60 * 1000,
    headers: {
      "Content-Type": content_type,
      clienttype: "1",
      client: "android",
      version: "100",
    },
  });

  /* 请求拦截器 */
  axiosInstance.interceptors.request.use(
    (config) => {
      const state = getState();

      if (type === "model") {
        const access_token = state?.chatBot?.access_token;
        // console.log("access_token:", access_token);
        config.headers["Authorization"] = `Bearer ${access_token}`;
      } else if (type === "user") {
        const member_token = state?.auth?.userToken;
        if (member_token) {
          config.headers["Authorization"] = member_token;
        }
      }
      // console.log("发送请求:", config);

      // console.log("request:", config.url);
      // console.log("params:", config.params);
      return config;
    },
    (error) => {
      console.log("interceptors.request error");
      return Promise.reject(error);
    }
  );

  /* 响应拦截器 */
  axiosInstance.interceptors.response.use(
    (response) => {
      // 先检查是否在白名单中
      const isWhitelisted = whiteList.some((path) =>
        response.config.url?.includes(path)
      );
      // console.log("response:", response.data);
      // console.log("response.config.url:", response.config.url);
      // console.log("isWhitelisted:", isWhitelisted);
      // console.log("response.data.code:", response?.data?.code);

      if (response?.data?.code === 200) {
        return response;
      } else if (response?.data?.code === 401 && !isWhitelisted) {
        handleUnauthorized(response.config.url);
        // 直接抛出错误并中断
        throw new Error("Unauthorized");
      }
      return response;
    },
    (error) => {
      // 检查是否在白名单中
      const isWhitelisted = whiteList.some((path) =>
        error.config?.url?.includes(path)
      );

      if (error.response?.status === 401 && !isWhitelisted) {
        handleUnauthorized(error.config.url);
        return new Promise(() => {});
      }

      // 网络错误处理
      if (!error.response) {
        console.error("网络错误:", error.message);
        if (!isWhitelisted) {
          router.replace({
            pathname: "/(outer)/reminder/error",
            params: { type: "system" },
          });
        }
      }

      return Promise.reject(error);
    }
  );

  return axiosInstance;
};

export const createAxiosFn = (instance) => {
  const axiosFn = {
    onGet: async (url, params = {}) => {
      // console.log("onGet:", url, params);
      const res = await instance.get(url, { params });

      return res;
    },
    onPost: async (url, data = {}) => {
      const res = await instance.post(url, data);
      return res;
    },
  };
  return axiosFn;
};
