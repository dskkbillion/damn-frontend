/**
 * @description: WebSocket初始化连接组件
 */

import { useEffect, useState } from "react";
import { useSelector } from "react-redux";

import { RootState } from "@/src/store";
import useWebSocket from "@/src/util/websocketService";

export const WebSocketProvider = ({ children }) => {
  const baseUrl = useSelector((state: RootState) => state?.msg?.baseUrl);
  const userProfile = useSelector((state: RootState) => state?.user?.data);
  const userToken = useSelector((state: RootState) => state?.auth?.userToken);
  const [socketUrl, setSocketUrl] = useState("");

  useEffect(() => {
    if (baseUrl && userProfile?.commonUserId && userToken) {
      const wsUrl = `${baseUrl}/${userProfile.commonUserId}/member`;
      setSocketUrl(wsUrl);
    } else {
      setSocketUrl("");
    }
  }, [baseUrl, userProfile, userToken]);

  const { disconnect } = useWebSocket(
    socketUrl && userToken ? socketUrl : "",
    userToken || ""
  );

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return <>{children}</>;
};

export default WebSocketProvider;
