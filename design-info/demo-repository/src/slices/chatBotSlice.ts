// for model slice

import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import {
  createChatRoomThunk,
  deleteChatRoomThunk,
  fectchChatRoomsThunk,
  loadHistoryChatThunk,
} from "../util/modelActions";

interface ChatBotState {
  answer: string;
  isDone: boolean;
  error: boolean;
  server_url: string;
  access_token: string;
  conversation_id: number | null;
  messages: Array<any>;
  model_loading: boolean; // 是否正在加载
  loading: boolean; // 是否正在加载
  generating: boolean; // 是否正在生成
  history: Array<any>;
  isSSEConnected: boolean;
  changed: boolean;
  reasoning: string; // 推理内容
  isReasoning: boolean; // 是否正在推理
}

const initialState: ChatBotState = {
  answer: "",
  isDone: false,
  error: false,
  server_url: "http://47.113.230.11:5102",
  access_token:
    "pat_nX78GOpdbUzUCzXcPRp0dPycaBJnP0DYl5QlVTTM5fc4LIHoanxKca7mHSkwgWN9",
  conversation_id: null,
  messages: [],
  model_loading: false, // 是否正在加载
  loading: false, // 是否正在加载
  generating: false, // 是否正在生成
  history: [],
  isSSEConnected: false,
  changed: false,
  reasoning: "", // 推理内容
  isReasoning: false, // 是否正在推理
};

// 在 slice 外部创建一个变量来存储 SSE 连接
let activeSSEConnection: any = null;

export const createChatBotSlice = (axiosFn) => {
  const fectchChatRooms = fectchChatRoomsThunk(axiosFn);
  const loadHistoryChat = loadHistoryChatThunk(axiosFn);
  const createChatRoom = createChatRoomThunk(axiosFn);
  const deleteChatRoom = deleteChatRoomThunk(axiosFn);
  const ChatBotSlice = createSlice({
    name: "model",
    initialState,
    reducers: {
      // 设置SSE连接
      setSSEConnection: (state, action) => {
        state.model_loading = true; // 开始加载
        state.isSSEConnected = action.payload;
      },

      // 对模型返回的流式回复进行处理
      updateAns: (state, action) => {
        if (state.answer === "") {
          state.model_loading = false; // 停止加载
          state.generating = true; // 开始生成
        }
        state.answer += action.payload;
      },

      // 处理推理内容
      updateReasoning: (state, action: PayloadAction<{content: string, isReasoning: boolean}>) => {
        state.reasoning = action.payload.content;
        state.isReasoning = action.payload.isReasoning;
      },

      // 缓存模型返回的消息
      finalizeAns: (state, action) => {
        state.generating = false;
        state.model_loading = false;
        state.isReasoning = false; // 确保推理状态被重置

        state.messages.push({
          message_id: `assistant-${Date.now()}`,
          role: "assistant",
          content: action.payload.content,
          files: action.payload.files || []
        });
        state.answer = "";
        state.reasoning = ""; // 清空推理内容
      },
      // 缓存用户发送消息
      addUserMessage: (state, action) => {
        state.model_loading = true;

        // 确保files是有效的数组，并去重
        const files = action.payload.files && Array.isArray(action.payload.files)
          ? [...new Set(action.payload.files.filter(url => typeof url === 'string' && url.trim() !== ''))]
          : [];

        state.messages.push({
          message_id: `user-${Date.now()}`,
          ...action.payload,
          files: files
        });
      },
      // 设置模型生成完成
      setDone: (state) => {
        state.generating = false;
        state.model_loading = false;
        state.isSSEConnected = false; // 确保SSE连接状态也被重置
        state.isReasoning = false; // 确保推理状态被重置
        console.log("模型生成已完成，状态已重置");
      },
      setError: (state) => {
        state.error = true;
        state.model_loading = false;
        state.isReasoning = false; // 确保推理状态被重置
      },
      // 强制更新UI状态
      forceUpdateUI: (state) => {
        // 这个reducer不修改任何状态，只是触发一个action让组件重新渲染
        console.log("强制更新UI状态");
      },
      initConversation: (state) => {
        state.answer = "";
        state.isDone = false;
        state.error = false;
        state.generating = false;
        state.model_loading = false;
        state.conversation_id = null;
        state.messages = [];
        state.reasoning = "";
        state.isReasoning = false;
      },
      // 不清除conversation_id
      clearHistory: (state) => {
        state.answer = "";
        state.isDone = false;
        state.error = false;
        state.generating = false;
        state.model_loading = false;
        state.messages = [];
        state.reasoning = "";
        state.isReasoning = false;
      },

      // 设置当前会话id
      setConversationId: (state, action) => {
        state.conversation_id = action.payload;
      },

      clearMessages: (state) => {
        state.messages = [];
        state.answer = "";
        state.reasoning = "";
        state.isReasoning = false;
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(fectchChatRooms.fulfilled, (state, action) => {
          state.history = action.payload.data?.conversations;
          state.loading = false;
        })
        .addCase(fectchChatRooms.rejected, (state, action) => {
          state.error = true;
        })
        .addCase(fectchChatRooms.pending, (state) => {
          state.loading = true;
        })
        .addCase(loadHistoryChat.fulfilled, (state, action) => {
          if (action.payload.data.length > 0) {
            state.messages = action.payload.data.map((message) => ({
              id: message.id,
              message_id: message.message_id,
              conversation_id: message.conversation_id,
              role: message.role,
              content: message.content,
              files: message.files,
            }));
          }

          state.loading = false;
        })
        .addCase(loadHistoryChat.rejected, (state, action) => {
          state.error = true;
        })
        .addCase(loadHistoryChat.pending, (state) => {
          state.loading = true;
        })
        .addCase(createChatRoom.pending, (state) => {
          state.loading = true;
        })
        .addCase(createChatRoom.fulfilled, (state, action) => {
          state.loading = false;
          state.changed = !state.changed;
          state.conversation_id = action.payload.data.conversation_id;
        })
        .addCase(createChatRoom.rejected, (state, action) => {
          state.error = true;
        })
        .addCase(deleteChatRoom.pending, (state) => {
          state.loading = true;
        })
        .addCase(deleteChatRoom.fulfilled, (state, action) => {
          state.loading = false;
          state.changed = !state.changed;
        })
        .addCase(deleteChatRoom.rejected, (state, action) => {
          state.error = true;
        });
    },
  });

  return {
    ...ChatBotSlice,
    actions: {
      ...ChatBotSlice.actions,
      fectchChatRooms,
      loadHistoryChat,
      createChatRoom,
      deleteChatRoom,
    },
  };
};
