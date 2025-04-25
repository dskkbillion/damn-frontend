import { createSlice, PayloadAction } from "@reduxjs/toolkit";

import {
  createDeleteThunk,
  createFetchChatroomThunk,
  createMsgRoomThunk,
  createRevokeThunk,
  createSendMsgThunk,
  getChatRoomListThunk,
  getMsgListThunk,
} from "../util/msgActions";

type MsgState = {
  chatId: string;
  msg: string;
  msgList: any[];
  chatRoomList: any[];
  chatRoom: any[];
  error: boolean;
  wsError: boolean;
  success: boolean;
  code: number | null;
  loading: boolean;
  isConnected: boolean;
  baseUrl: string;
  changed: boolean;
  shouldConnect: boolean;
  changedId: string;
  currentPage: number;
  hasMoreMessages: boolean;
  totalMessages: number;
};

const initialState: MsgState = {
  chatId: "",
  msg: "",
  msgList: [],
  chatRoomList: [],
  chatRoom: [],
  error: false,
  wsError: false,
  success: false,
  code: null,
  loading: false,
  isConnected: false,
  // baseUrl: "ws://17-8187.proxy.product-demo.cn:8000/websocket/message",
  baseUrl: "ws://app.duoshaokankan.com/prod-api/websocket/message",
  changed: false,
  shouldConnect: false,
  changedId: "",
  currentPage: 1,
  hasMoreMessages: true,
  totalMessages: 0,
};

export const createMsgSlice = (axiosFn) => {
  const createRoom = createMsgRoomThunk(axiosFn);
  const sendMsg = createSendMsgThunk(axiosFn);
  const getMsgList = getMsgListThunk(axiosFn);
  const getChatRoomList = getChatRoomListThunk(axiosFn);
  const revokeMessage = createRevokeThunk(axiosFn);
  const deleteMessage = createDeleteThunk(axiosFn);
  const fetchChatroomDetail = createFetchChatroomThunk(axiosFn);

  const msgSlice = createSlice({
    name: "msg",
    initialState,
    reducers: {
      setConnectionStatus: (state, action: PayloadAction<boolean>) => {
        state.isConnected = action.payload;
      },
      setWsError: (state, action: PayloadAction<boolean>) => {
        state.wsError = action.payload;
      },
      receiveMessage: (state, action) => {
        state.msgList.push({
          ...action.payload,
          flag: "receive",
        });
      },
      resetChatRoomList: (state) => {
        state.chatRoomList = [];
      },
      resetMsgList: (state) => {
        state.msgList = [];
        state.loading = false;
        state.currentPage = 1;
        state.hasMoreMessages = true;
        state.totalMessages = 0;
      },
      setChanged: (state) => {
        state.changed = !state.changed;
        state.loading = false;
      },
      setShouldConnect: (state, action: PayloadAction<boolean>) => {
        state.shouldConnect = action.payload;
      },
      resetConnection: (state) => {
        state.isConnected = false;
        state.shouldConnect = false;
      },
      setChangedId: (state, action: PayloadAction<string>) => {
        state.changedId = action.payload;
      },
      clearChangedId: (state) => {
        state.changedId = "";
      },
      loadMoreMessages: (state) => {
        if (state.hasMoreMessages && !state.loading) {
          state.currentPage += 1;
        }
      },
    },
    extraReducers: (builder) => {
      builder
        // create room
        .addCase(createRoom.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(createRoom.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.chatId = action.payload.data;
        })
        .addCase(createRoom.rejected, (state) => {
          state.loading = false;
          state.error = true;
        })

        // send message
        .addCase(sendMsg.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(sendMsg.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.msg = action.payload.data;
          state.msgList.push({
            ...action.payload.data,
            flag: "send",
          });
        })
        .addCase(sendMsg.rejected, (state) => {
          state.loading = false;
          state.error = true;
        })

        // get message list
        .addCase(getMsgList.pending, (state) => {
          state.loading = true;
        })
        .addCase(getMsgList.fulfilled, (state, action) => {
          const { rows, total } = action.payload;
          state.totalMessages = total;

          if (state.currentPage === 1) {
            state.msgList = rows;
          } else {
            const existingIds = new Set(state.msgList.map(msg => msg.id));
            const newMessages = rows.filter(msg => !existingIds.has(msg.id));
            state.msgList = [...state.msgList, ...newMessages];
          }

          state.hasMoreMessages = state.msgList.length < total;
          state.loading = false;
        })
        .addCase(getMsgList.rejected, (state) => {
          state.loading = false;
          state.error = true;
        })

        // get chat room list
        .addCase(getChatRoomList.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(getChatRoomList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.chatRoomList = action.payload.rows;
          state.code = action.payload.code;
        })
        .addCase(getChatRoomList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.code = action.payload?.code as number;
        })

        // revoke message
        .addCase(revokeMessage.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(revokeMessage.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          const messageId = action.payload.id;
          const data = action.payload.data;
          if (data.code === 200) {
            state.msgList = state.msgList.filter((msg) => msg.id !== messageId);
            state.changed = !state.changed;
          }
        })
        .addCase(revokeMessage.rejected, (state) => {
          state.loading = false;
          state.error = true;
        })

        // delete message
        .addCase(deleteMessage.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(deleteMessage.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
        })
        .addCase(deleteMessage.rejected, (state) => {
          state.loading = false;
          state.error = true;
        })

        // detail of chat room
        .addCase(fetchChatroomDetail.pending, (state) => {
          state.loading = true;
          state.error = false;
          state.success = false;
        })
        .addCase(fetchChatroomDetail.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.chatRoom = action.payload.data;
        })
        .addCase(fetchChatroomDetail.rejected, (state) => {
          state.loading = false;
          state.error = true;
        });
    },
  });

  return {
    ...msgSlice,
    actions: {
      ...msgSlice.actions,
      createRoom,
      sendMsg,
      getMsgList,
      getChatRoomList,
      revokeMessage,
      deleteMessage,
      fetchChatroomDetail,
    },
  };
};
