import EventSource from "react-native-sse";

let activeConnection = null;

export const initSSEConnection = ({
  api,
  data,
  onOpen,
  onMessage,
  onError,
  onEnd,
}) => {
  const bodyData = JSON.stringify(data);
  console.log("bodyData:", bodyData);

  const es = new EventSource(api, {
    headers: {
      "Content-Type": "application/json",
    },
    method: "POST",
    pollingInterval: 0,
    body: bodyData,
  });

  es.addEventListener("open", onOpen);
  es.addEventListener("error", onError);
  es.addEventListener("conversation.message.delta", onMessage);
  es.addEventListener("conversation.message.completed", onMessage);
  es.addEventListener("conversation.reasoning.delta", onMessage);
  es.addEventListener("event:done", onEnd);

  // 保存当前连接
  activeConnection = es;

  return {
    close: () => {
      es.removeAllEventListeners();
      es.close();
      activeConnection = null;
    },
  };
};

// 新增一个终止当前活动连接的函数
export const terminateCurrentConnection = () => {
  console.log("terminateCurrentConnection 被调用");

  if (activeConnection) {
    console.log("找到活动的SSE连接，准备关闭");
    try {
      // 先移除所有事件监听器
      activeConnection.removeAllEventListeners();
      console.log("已移除所有事件监听器");

      // 关闭连接
      activeConnection.close();
      console.log("已关闭SSE连接");

      // 重置连接变量
      activeConnection = null;
      console.log("已重置连接变量");

      // 强制清理
      setTimeout(() => {
        if (activeConnection) {
          console.log("连接未正确关闭，强制清理");
          activeConnection = null;
        }
      }, 500);

      return true;
    } catch (error) {
      console.error("关闭SSE连接时出错:", error);
      // 即使出错，也尝试重置连接变量
      activeConnection = null;
      return false;
    }
  } else {
    console.log("没有找到活动的SSE连接");
    return false;
  }
};
