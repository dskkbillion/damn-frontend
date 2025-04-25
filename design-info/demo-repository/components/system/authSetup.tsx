import { memo, useCallback, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";

import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export const AuthSetup = memo(() => {
  const dispatch = useDispatch<AppDispatch>();
  const userToken = useSelector((state: RootState) => state.auth?.userToken);
  const initialized = useSelector((state: RootState) => state.auth?.initilized);
  // 初始化用户数据
  const initializeUserData = useCallback(async () => {
    if (!userToken) return true; // 未登录也算初始化成功

    try {
      // 获取用户信息
      const userRes = await dispatch(slices.auth.actions.fetchUserProfile({}));
      if (!isAxiosSuccess(userRes.type)) {
        throw new Error("Failed to fetch user profile");
      }

      dispatch(slices.auth.actions.setInitilized());
      dispatch(slices.auth.actions.setTokenExpired(false));
      return true;
    } catch (error) {
      //   console.error("User initialization failed:", error);
      // Token 失效，清除登录状态
      dispatch(slices.auth.actions.setTokenExpired(true));
      return false;
    }
  }, [dispatch, userToken]);

  useEffect(() => {
    let mounted = true;
    let retryCount = 0;
    const maxRetries = 2;

    const tryInitialize = async () => {
      try {
        const success = await initializeUserData();
        if (!success && mounted && retryCount < maxRetries) {
          console.log(`重试用户初始化 (${retryCount + 1}/${maxRetries})`);
          retryCount++;
          setTimeout(tryInitialize, 2000 * retryCount);
        } else if (!success) {
          // 达到最大重试次数，设置错误状态
          //   console.error("用户初始化失败: 达到最大重试次数");
          dispatch(slices.auth.actions.setError());
        }
      } catch (error) {
        // console.error("用户初始化错误:", error);
        if (mounted && retryCount < maxRetries) {
          retryCount++;
          setTimeout(tryInitialize, 2000 * retryCount);
        } else {
          // 达到最大重试次数，设置错误状态
          dispatch(slices.auth.actions.setError());
        }
      }
    };

    if (!initialized) {
      tryInitialize();
    }

    return () => {
      mounted = false;
    };
  }, [initializeUserData]);

  // 初始化完成，返回 null 让子组件渲染
  return null;
});

export default AuthSetup;
