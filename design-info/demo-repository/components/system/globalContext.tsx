import React, { createContext, useContext, useState, useEffect } from "react";
import { Dimensions } from "react-native";
import { useSelector } from "react-redux";

import { RootState } from "@/src/store";

// 扩展 Context 类型
interface GlobalContextType {
  screenHeight: number;
  screenWidth: number;
  dictData: any;
}

const GlobalContext = createContext<GlobalContextType>({
  screenHeight: Dimensions.get("window").height,
  screenWidth: Dimensions.get("window").width,
  dictData: null,
});

export const GlobalContextProvider = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  const dict = useSelector((state: RootState) => state.sys.dict);

  const [globalState, setGlobalState] = useState<GlobalContextType>({
    screenHeight: Dimensions.get("window").height,
    screenWidth: Dimensions.get("window").width,
    dictData: dict && Object.keys(dict).length > 0 ? dict : null,
  });

  // 处理屏幕尺寸
  useEffect(() => {
    const updateDimensions = () => {
      setGlobalState((prev) => ({
        ...prev,
        screenHeight: Dimensions.get("window").height,
        screenWidth: Dimensions.get("window").width,
      }));
    };

    updateDimensions();
    const subscription = Dimensions.addEventListener(
      "change",
      updateDimensions
    );

    return () => {
      subscription?.remove();
    };
  }, []);

  useEffect(() => {
    setGlobalState((prev) => ({
      ...prev,
      dictData: dict && Object.keys(dict).length > 0 ? dict : null,
    }));
  }, [dict]);

  return (
    <GlobalContext.Provider value={globalState}>
      {children}
    </GlobalContext.Provider>
  );
};

// 自定义 hook 来使用全局状态
export const useGlobalContext = () => useContext(GlobalContext);

// 为了向后兼容，保留原来的 hook 名称
export const useScreenDimensions = () => {
  const { screenHeight, screenWidth } = useContext(GlobalContext);
  return { screenHeight, screenWidth };
};

// 新增 hook 来获取字典数据
export const useDictData = () => {
  const { dictData } = useContext(GlobalContext);
  return dictData;
};
