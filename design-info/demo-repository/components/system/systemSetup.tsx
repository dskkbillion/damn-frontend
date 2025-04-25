import { memo, useCallback, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";

import { isAxiosSuccess } from "@/components/utils";
import { Device } from "@/sdk/device";
import { AppDispatch, RootState, slices } from "@/src/store";

export const SystemSetup = memo(() => {
  console.log("SystemSetup");
  const dispatch = useDispatch<AppDispatch>();
  const { dictInitilized, sysConfigInitilized, contentInitilized, initilized } =
    useSelector((state: RootState) => state.sys);

  // 统一初始化系统配置
  const initializeSystem = useCallback(async () => {
    try {
      // 1. 获取字典数据
      if (!dictInitilized) {
        const dictRes = await dispatch(slices.sys.actions.fetchGlobalDict({}));
        console.log("dictRes", dictRes);
        if (!isAxiosSuccess(dictRes.type)) {
          throw new Error("Failed to fetch dictionary");
        }
      }

      // 2. 获取系统配置
      if (!sysConfigInitilized) {
        const configRes = await dispatch(slices.sys.actions.fetchSysConfig({}));
        if (!isAxiosSuccess(configRes.type)) {
          throw new Error("Failed to fetch system config");
        }
      }

      // 3. 获取内容配置
      if (!contentInitilized) {
        // 注册协议
        await dispatch(slices.sys.actions.fetchContent({ id: 1 }));
        // 隐私政策
        await dispatch(slices.sys.actions.fetchContent({ id: 2 }));
        // 支付协议
        await dispatch(slices.sys.actions.fetchContent({ id: 3 }));
        // 关于我们
        await dispatch(slices.sys.actions.fetchContent({ id: 4 }));
        // 注销协议
        await dispatch(slices.sys.actions.fetchContent({ id: 6 }));
      }

      // 所有数据加载完成
      dispatch(slices.sys.actions.setInitilized());
      return true;
    } catch (error) {
      //   console.error("System initialization failed:", error);
      return false;
    }
  }, [dispatch, dictInitilized, sysConfigInitilized, contentInitilized]);

  // 初始化设备信息（每次启动APP时）
  const initilizedDevice = useCallback(async () => {
    let retryCount = 0;
    const maxDeviceRetries = 3;

    const tryGetDeviceInfo = async () => {
      try {
        const device = new Device();
        const deviceInfo = await device.getDeviceInfo();
        console.log("Device info initialized:", deviceInfo);
        dispatch(slices.sys.actions.setDeviceInfo(deviceInfo));
        return;
      } catch (error) {
        console.error("Device initialization failed:", error);
        if (retryCount < maxDeviceRetries) {
          retryCount++;
          setTimeout(tryGetDeviceInfo, 1000 * retryCount);
        } else {
          console.warn("设备信息获取失败，但不影响系统运行");
        }
      }
    };

    tryGetDeviceInfo();
  }, [dispatch]);

  useEffect(() => {
    let mounted = true;
    let retryCount = 0;
    const maxRetries = 2;

    const tryInitialize = async () => {
      try {
        const success = await initializeSystem();
        if (!success && mounted && retryCount < maxRetries) {
          console.log(`重试系统初始化 (${retryCount + 1}/${maxRetries})`);
          retryCount++;
          setTimeout(tryInitialize, 2000 * retryCount);
        } else if (!success) {
          dispatch(slices.sys.actions.setError());
        }
      } catch (error) {
        if (mounted && retryCount < maxRetries) {
          retryCount++;
          setTimeout(tryInitialize, 2000 * retryCount);
        } else {
          dispatch(slices.sys.actions.setError());
        }
      }
    };

    if (!initilized) {
      console.log("tryInitialize");
      tryInitialize();
    } else {
      console.log("initilized", initilized);
    }

    initilizedDevice();

    return () => {
      mounted = false;
    };
  }, [initializeSystem, initilizedDevice]);

  // 系统初始化完成,渲染子组件
  return null;
});

export default SystemSetup;
