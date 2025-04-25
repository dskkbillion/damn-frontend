import { createAsyncThunk } from "@reduxjs/toolkit";

import { ErrorPayload } from "./authActions";
import type { SSEConnection } from "./modelTypes";
import { initSSEConnection, terminateCurrentConnection } from "./sseService";
import { getModelSlice } from "./storeInstance";
import { model, store } from "../store";

/**
 * 发送消息到模型
 * @param user_id 用户id
 * @param message 消息
 * @param conversation_id 会话id
 * @returns
 */
export const Send2Model =
  (params: chatParams) => async (dispatch, getState) => {
    try {
      const serverUrl = store.getState().chatBot.server_url;
      const modelStore = getModelSlice();
      if (!modelStore?.model?.chatBot?.actions) {
        console.error("Model actions not initialized");
        return;
      }

      // 确保files是有效的数组，并去重
      // 注意：我们现在允许本地文件路径，因为上传可能失败
      const files = params.files && Array.isArray(params.files)
        ? [...new Set(params.files.filter(url => typeof url === 'string' && url.trim() !== ''))]
        : [];

      console.log("处理后的图片数组(去重):", files);

      const data = {
        model: "dify",
        user_id: params.user_id,
        message: params.message,
        conversation_id: params.conversation_id,
        files: files,
        stream: true,
      };

      let sseConnection: SSEConnection | null = null;

      // 先终止可能存在的连接
      terminateCurrentConnection();
      console.log("已终止可能存在的旧连接，准备创建新连接");

      // 添加重试逻辑
      const maxRetries = 2;
      let retryCount = 0;

      const connectSSE = () => {
        return new Promise((resolve, reject) => {
          try {
            sseConnection = initSSEConnection({
              api: serverUrl + "/model/chat",
              data,
              onOpen: (event) => {
                dispatch(modelStore.model.chatBot.actions.setSSEConnection(true));
                resolve(true);
              },
              onMessage: (event) => {
                const data = JSON.parse(event.data);
                console.log("SSE消息类型:", event.type, "数据:", data);

                if (event.type === "conversation.message.delta") {
                  dispatch(model.chatBot.actions.updateAns(data.content));
                } else if (event.type === "conversation.message.completed") {
                  dispatch(
                    model.chatBot.actions.finalizeAns({
                      content: data.content,
                      content_type: data?.content_type || "text",
                      files: data.files || []
                    })
                  );
                  dispatch(model.chatBot.actions.setDone());
                } else if (event.type === "conversation.reasoning.delta") {
                  // 处理推理内容
                  console.log("收到推理内容:", data.reason_content);
                  dispatch(
                    model.chatBot.actions.updateReasoning({
                      content: data.reason_content || "",
                      isReasoning: true
                    })
                  );
                }
              },
              onError: (event) => {
                console.log("SSE error", event);
                dispatch(modelStore.model.chatBot.actions.setError());
                dispatch(modelStore.model.chatBot.actions.setSSEConnection(false));
                if (sseConnection) {
                  sseConnection.close();
                }

                // 如果还有重试次数，则重试
                if (retryCount < maxRetries) {
                  retryCount++;
                  console.log(`连接失败，正在进行第${retryCount}次重试...`);
                  setTimeout(() => {
                    connectSSE().catch(reject);
                  }, 1000); // 1秒后重试
                } else {
                  console.log("已达到最大重试次数，放弃连接");
                  reject(event);
                }
              },
              onEnd: (event) => {
                console.log("SSE end", event);
                dispatch(modelStore.model.chatBot.actions.setSSEConnection(false));
                dispatch(modelStore.model.chatBot.actions.setGenerating(false));
                // 确保推理状态也被重置
                dispatch(model.chatBot.actions.updateReasoning({
                  content: "",
                  isReasoning: false
                }));
                if (sseConnection) {
                  sseConnection.close();
                }
                resolve(true);
              },
            });
          } catch (err) {
            reject(err);
          }
        });
      };

      // 开始连接
      await connectSSE();
    } catch (err: any) {
      console.log("error", err);
      const modelStore = getModelSlice();
      if (modelStore?.model?.chatBot?.actions) {
        dispatch(modelStore.model.chatBot.actions.setError());
        dispatch(modelStore.model.chatBot.actions.setGenerating(false));
      }
    }
  };

// 加载聊天室
export const fectchChatRoomsThunk = (axiosFn) =>
  createAsyncThunk<
    { message: string; code: number; data: any },
    { user_id: number },
    { rejectValue: ErrorPayload }
  >("/model/chat/list", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/model/chat/list", params);
      console.log("fectchChatRoomsThunk", res.data);
      if (res.data.code === 200) {
        return res.data;
      } else {
        return rejectWithValue(res.data.message);
      }
    } catch (err: any) {
      if (err.response && err.response.data) {
        return rejectWithValue(err.response.data);
      } else {
        return rejectWithValue(err.message);
      }
    }
  });

// 删除聊天室
export const deleteChatRoomThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    { user_id: number; conversation_id: string },
    { rejectValue: ErrorPayload }
  >("/model/chat/delete", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/model/chat/delete", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  });

// 创建聊天室
export const createChatRoomThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    { user_id: number; title?: string },
    { rejectValue: ErrorPayload }
  >("/model/chat/create", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/model/chat/create", params);
      if (res.data.code !== 200) {
        return rejectWithValue(res.data);
      }
      return res.data;
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  });

export const loadHistoryChatThunk = (axiosFn) =>
  createAsyncThunk<
    { msg: string; code: number; data: any },
    {
      conversation_id: string;
      user_id: number;
    },
    { rejectValue: ErrorPayload }
  >("/model/chat/messages", async (params, { rejectWithValue }) => {
    try {
      const res = await axiosFn.onPost("/model/chat/messages", params);
      if (res.data.code === 200) {
        return res.data;
      } else {
        return rejectWithValue(res.data.message);
      }
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  });

type createConversationParams = {
  meta_data?: Map<string, string>;
  messages?: EnterMessageObject | ObjectString[];
};

// 消息结构
type EnterMessageObject = {
  role: string;
  type: string; // question, answer ,function_call, tool_output, tool_response, follow_up, verbose
  content: string;
  content_type: string; // text, object_string , card
  meta_data: Map<string, string>;
};

// 多模态结构
type ObjectString = {
  type: string;
  text: string;
  file_id: string;
  file_url: string;
};

type createConversationResponse = {
  code: number;
  msg: ConversationObject;
  data: any;
};

type ConversationObject = {
  id: string;
  create_at: string;
  meta_data: Map<string, string>;
};

export type chatParams = {
  user_id: number;
  conversation_id: string | number;
  message: string;
  files?: string[];
};

// export const chatGPT = (params: chatParams) => async (dispatch, getState) => {
//   const data = {
//     model: "moonshot-v1-8k",
//     messages: [
//       {
//         role: "system",
//         content: "You are a helpful assistant.",
//       },
//       {
//         role: "user",
//         content: "What is the meaning of life?",
//       },
//     ],
//     max_tokens: 600,
//     n: 1,
//     temperature: 0.7,
//     stream: true,
//   };
//   const sseConnection = initSSEConnection({
//     // api: "https://api.openai.com/v1/chat/completions",
//     api: "https://api.moonshot.cn/v1/chat/completions",
//     api_key: "sk-bRHXLmXQicArHo812bUPAJ7QGxxJxAovAtPKBp1EZKawvVsw",
//     data: data,
//     onOpen: (event) => {
//       console.log("SSE connection opened", event);
//     },
//     onMessage: (event) => {
//       console.log("SSE message", event);
//       if (event.event === "conversation.message.delta") {
//         dispatch(model?.chatBot?.actions?.updateAns(event.data.content));
//       } else if (event.event === "conversation.message.completed") {
//         //   dispatch(model?.chatBot?.actions?.finalizeAns());
//       } else if (event.event === "done") {
//         dispatch(model?.chatBot?.actions?.setDone());
//       }
//     },
//     onError: (event) => {
//       console.log("SSE error", event);
//       dispatch(model?.chatBot?.actions?.setError());
//     },
//     onEnd: (event) => {
//       console.log("SSE end", event);
//     },
//   });
// };
