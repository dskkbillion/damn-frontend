import { useRef, useCallback, useEffect } from "react";
import { useDispatch } from "react-redux";

import { AppDispatch, slices } from "../store";

const HEARTBEAT_INTERVAL = 20000; // 心跳间隔20秒
const MAX_RECONNECT_ATTEMPTS = 2;

const useWebSocket = (url: string, token: string) => {
  const dispatch = useDispatch<AppDispatch>();
  const socketRef = useRef<WebSocket | null>(null);
  const heartbeatRef = useRef<NodeJS.Timeout | null>(null);
  const reconnectAttempts = useRef(0);

  const connectWebSocket = useCallback(() => {
    if (!url || !token) {
      return;
    }

    const wsUrl =
      url.startsWith("ws://") || url.startsWith("wss://") ? url : `ws://${url}`;

    const socket = new WebSocket(wsUrl);
    socketRef.current = socket;

    socket.onopen = () => {
      console.log("WebSocket 连接成功");
      reconnectAttempts.current = 0;
      socket.send(JSON.stringify({ type: "auth", token }));
      startHeartbeat();
    };

    // 接受消息
    socket.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message?.action === "CHAT") {
        if (!message?.data?.flag) {
          // 延迟100ms处理接收到的消息
          setTimeout(() => {
            dispatch(slices.msg.actions.receiveMessage(message?.data));
          }, 100);
        }
      }
      resetHeartbeat();
    };

    // 连接关闭
    socket.onclose = () => {
      stopHeartbeat();
      reconnectWebSocket();
    };

    // 连接错误
    socket.onerror = () => {
      stopHeartbeat();
      reconnectWebSocket();
    };
  }, [dispatch, token, url]);

  const reconnectWebSocket = useCallback(() => {
    if (reconnectAttempts.current >= MAX_RECONNECT_ATTEMPTS) {
      dispatch(slices.msg.actions.setWsError(true));
      return;
    }

    reconnectAttempts.current += 1;
    console.log(
      `重试WebSocket连接(${reconnectAttempts.current}/${MAX_RECONNECT_ATTEMPTS})`
    );

    // 使用指数退避策略
    const delay = Math.min(
      1000 * Math.pow(2, reconnectAttempts.current),
      10000
    );
    setTimeout(connectWebSocket, delay);
  }, [connectWebSocket]);

  const startHeartbeat = useCallback(() => {
    stopHeartbeat();
    heartbeatRef.current = setInterval(() => {
      if (socketRef.current?.readyState === WebSocket.OPEN) {
        socketRef.current.send(JSON.stringify({ type: "heartbeat" })); // 示例心跳包
        // console.log("发送心跳包");
      }
    }, HEARTBEAT_INTERVAL);
  }, []);

  const stopHeartbeat = useCallback(() => {
    if (heartbeatRef.current) {
      clearInterval(heartbeatRef.current);
      heartbeatRef.current = null;
    }
  }, []);

  const resetHeartbeat = useCallback(() => {
    stopHeartbeat();
    startHeartbeat();
  }, [startHeartbeat, stopHeartbeat]);

  const isConnected = useCallback(() => {
    return socketRef.current?.readyState === WebSocket.OPEN;
  }, []);

  const disconnect = useCallback(() => {
    socketRef.current?.close();
    stopHeartbeat();
  }, [stopHeartbeat]);

  useEffect(() => {
    if (url && token) {
      connectWebSocket();
    } else {
      if (socketRef.current) {
        socketRef.current.close();
        socketRef.current = null;
      }
      stopHeartbeat();
    }

    return () => {
      if (socketRef.current) {
        socketRef.current.close();
      }
      stopHeartbeat();
    };
  }, [connectWebSocket, stopHeartbeat, url, token]);

  return { isConnected, disconnect };
};

export default useWebSocket;
