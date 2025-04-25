import { createSlice } from "@reduxjs/toolkit";

import { createFileUploadThunk } from "../util/uploadActions";

import { ErrorPayload } from "@/src/util/authActions";

interface Files {
  fileName?: string;
  fileUrl: string;
}

interface Images {
  imgName?: string;
  imgUrl: string;
  width?: number;
  height?: number;
}

interface OrderFiles {
  [key: number]: Files[];
}

type FileState = {
  loading: boolean;
  deliveryFiles: OrderFiles; // delivery (image && file)
  materialFiles: OrderFiles; // material (image && file)
  itemImages: Images[]; // item post images
  winImages: Images[]; // item post winimages
  storyImages: Images[]; // story post images
  authImages: {
    [key: string]: any;
  }; // authentication images
  modelImages: Images[]; // model post images
  uploadIndex: number; // 上传图片的索引
  evalImages: Images[]; // evaluation images
  chatImages: Images[]; //聊天图片
  chatAudios: Files[]; // 聊天语音
  avatar: string;
  type:
    | "delivery"
    | "material"
    | "item"
    | "win"
    | "story"
    | "eval"
    | "chat"
    | "avatar"
    | "chatAudio"
    | "auth_background" // 认证学校背景
    | "auth_corporation" // 认证公司背景
    | "auth_real_name" // 实名认证
    | "auth_other" // 其他认证
    | "model" // 模型图片
    | null;
  orderId: number | null;
  error: ErrorPayload | boolean;
  success: boolean;
};

const initialState: FileState = {
  loading: false,
  deliveryFiles: {},
  materialFiles: {},
  itemImages: [], // 商品图片
  winImages: [], // 案例图片
  storyImages: [], // 故事图片
  evalImages: [], // 评论图片
  chatImages: [], //聊天图片
  chatAudios: [], // 聊天语音
  authImages: {
    background: [],
    corporation: [],
    real_name: {
      front: [],
      back: [],
    },
    other: [],
  }, // authentication images
  modelImages: [], // model post images
  avatar: "", // 头像
  uploadIndex: 0, // 上传图片的索引
  orderId: null,
  type: null,
  error: false, // for storing error
  success: false, // for monitoring the registration process
};

export const createFileSlice = (axiosFn: any) => {
  const uploadFile = createFileUploadThunk(axiosFn);
  const fileSlice = createSlice({
    name: "file",
    initialState,
    reducers: {
      setOrderId: (state, action) => {
        state.orderId = action.payload;
      },
      setType: (state, action) => {
        state.type = action.payload;
      },
      setUploadIndex: (state, action) => {
        state.uploadIndex = action.payload;
      },

      // 删除file
      deleteFile: (state, action) => {
        if (state.type === "material") {
          if (state.orderId && state.materialFiles[state.orderId]) {
            state.materialFiles[state.orderId].splice(action.payload, 1);
          }
        } else if (state.type === "delivery") {
          if (state.orderId && state.deliveryFiles[state.orderId]) {
            state.deliveryFiles[state.orderId].splice(action.payload, 1);
          }
        }
      },
      clearImages: (state, action) => {
        if (action.payload.type === "item") {
          state.itemImages = [];
        } else if (action.payload.type === "win") {
          state.winImages = [];
        } else if (action.payload.type === "story") {
          state.storyImages = [];
        } else if (action.payload.type === "chat") {
          state.chatImages = [];
        } else if (action.payload.type === "eval") {
          state.evalImages = [];
        } else if (action.payload.type === "model") {
          state.modelImages = [];
        } else if (action.payload.type === "auth_background") {
          state.authImages["background"] = [];
        } else if (action.payload.type === "auth_corporation") {
          state.authImages["corporation"] = [];
        } else if (action.payload.type === "auth_personal") {
          state.authImages["personal"] = [];
        }
      },
      clearAllImages: (state) => {
        state.itemImages = [];
        state.winImages = [];
        state.storyImages = [];
        state.evalImages = [];
        state.chatImages = [];
        state.modelImages = [];
      },
      clearFiles: (state, action) => {
        if (action.payload.type === "material") {
          state.materialFiles = {};
        } else if (action.payload.type === "delivery") {
          state.deliveryFiles = {};
        }
      },
      clearAllFiles: (state) => {
        state.materialFiles = {};
        state.deliveryFiles = {};
      },
      clearAudio: (state) => {
        state.chatAudios = [];
      },
      deleteImage: (state, action) => {
        if (state.type === "item") {
          state.itemImages.splice(action.payload, 1);
        } else if (state.type === "win") {
          state.winImages.splice(action.payload, 1);
        } else if (state.type === "story") {
          state.storyImages.splice(action.payload, 1);
        } else if (state.type === "eval") {
          state.evalImages.splice(action.payload, 1);
        } else if (state.type === "chat") {
          state.chatImages.splice(action.payload, 1);
        } else if (state.type === "auth_background") {
          state.authImages["background"].splice(0, 1);
        } else if (state.type === "auth_corporation") {
          state.authImages["corporation"].splice(0, 1);
        } else if (state.type === "auth_real_name") {
          // action.payload.index 0 正面 1 反面
          if (state.uploadIndex === 0) {
            state.authImages["real_name"]["front"].splice(0, 1);
          } else {
            state.authImages["real_name"]["back"].splice(0, 1);
          }
        } else if (state.type === "auth_other") {
          state.authImages["other"].splice(action.payload, 1);
        }
      },
      addImage: (state, action) => {
        const type = action.payload.type;
        let images = action.payload.images; // Image[]
        if (!images || images.length === 0) {
          return;
        } else {
          if (typeof images[0] === "string") {
            // 只有图片的url
            images = images.map((item) => ({
              imgUrl: item,
            }));
          }
        }

        if (type === "item") {
          // 如果添加后总数超过9张,移除前面多余的图片
          if (state.itemImages.length + images.length > 9) {
            const removeCount = state.itemImages.length + images.length - 9;
            state.itemImages.splice(0, removeCount);
          }
          state.itemImages.push(...images);
        } else if (type === "win") {
          if (state.winImages.length + images.length > 9) {
            const removeCount = state.winImages.length + images.length - 9;
            state.winImages.splice(0, removeCount);
          }
          state.winImages.push(...images);
        } else if (type === "story") {
          if (state.storyImages.length + images.length > 9) {
            const removeCount = state.storyImages.length + images.length - 9;
            state.storyImages.splice(0, removeCount);
          }
          state.storyImages.push(...images);
        } else if (type === "eval") {
          if (state.evalImages.length + images.length > 9) {
            const removeCount = state.evalImages.length + images.length - 9;
            state.evalImages.splice(0, removeCount);
          }
          state.evalImages.push(...images);
        } else if (type === "chat") {
          // 聊天图片处理
          console.log("添加聊天图片:", images);
          if (state.chatImages.length + images.length > 9) {
            const removeCount = state.chatImages.length + images.length - 9;
            state.chatImages.splice(0, removeCount);
          }
          state.chatImages.push(...images);
          console.log("添加后的聊天图片:", state.chatImages);
        } else if (type === "auth_university") {
          state.authImages["university"].push(...images);
        } else if (type === "auth_corporation") {
          state.authImages["corporation"].push(...images);
        } else if (type === "auth_real_name") {
          state.authImages["real_name"].push(...images);
        } else if (type === "auth_other") {
          if (state.authImages["other"].length + images.length > 9) {
            const removeCount =
              state.authImages["other"].length + images.length - 9;
            state.authImages["other"].splice(0, removeCount);
          }
          state.authImages["other"].push(...images);
        }
      },
      updateImageUrl: (state, action) => {
        const { type, index, url } = action.payload;

        if (type === "chat" && state.chatImages[index]) {
          state.chatImages[index].imgUrl = url;
        } else if (type === "item" && state.itemImages[index]) {
          state.itemImages[index].imgUrl = url;
        } else if (type === "win" && state.winImages[index]) {
          state.winImages[index].imgUrl = url;
        } else if (type === "story" && state.storyImages[index]) {
          state.storyImages[index].imgUrl = url;
        } else if (type === "eval" && state.evalImages[index]) {
          state.evalImages[index].imgUrl = url;
        }
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(uploadFile.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(uploadFile.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;

          switch (state.type) {
            case "delivery":
              if (state.orderId) {
                if (!Array.isArray(state.deliveryFiles[state.orderId])) {
                  state.deliveryFiles[state.orderId] = []; // 初始化为空数组
                }

                state.deliveryFiles[state.orderId].push({
                  fileName: action.payload.data.fileName,
                  fileUrl: action.payload.data.url,
                });
              }
              break;
            case "material":
              if (state.orderId) {
                if (!Array.isArray(state.materialFiles[state.orderId])) {
                  state.materialFiles[state.orderId] = []; // 初始化为空数组
                }

                state.materialFiles[state.orderId].push({
                  fileName: action.payload.data.fileName,
                  fileUrl: action.payload.data.url,
                });
              }
              break;
            case "item":
              if (state.itemImages.length >= 9) {
                state.itemImages.shift(); // 移除第一张图片
              }
              state.itemImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "win":
              if (state.winImages.length >= 9) {
                state.winImages.shift(); // 移除第一张图片
              }
              state.winImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "story":
              if (state.storyImages.length >= 9) {
                state.storyImages.shift(); // 移除第一张图片
              }
              state.storyImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "eval":
              if (state.evalImages.length >= 9) {
                state.evalImages.shift(); // 移除第一张图片
              }
              state.evalImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "chat":
              if (state.chatImages.length >= 9) {
                state.chatImages.shift(); // 移除第一张图片
              }
              state.chatImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "avatar":
              state.avatar = action.payload.data.url;
              break;
            case "chatAudio":
              state.chatAudios.push({
                fileName: action.payload.data.fileName,
                fileUrl: action.payload.data.url,
              });
              break;
            case "auth_background":
              state.authImages["background"].push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "auth_corporation":
              state.authImages["corporation"].push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "auth_real_name":
              // index 0 正面 1 反面
              if (state.uploadIndex === 0) {
                state.authImages["real_name"]["front"].push({
                  imgName: action.payload.data.fileName,
                  imgUrl: action.payload.data.url,
                });
              } else {
                state.authImages["real_name"]["back"].push({
                  imgName: action.payload.data.fileName,
                  imgUrl: action.payload.data.url,
                });
              }
              break;
            case "auth_other":
              state.authImages["other"].push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            case "model":
              state.modelImages.push({
                imgName: action.payload.data.fileName,
                imgUrl: action.payload.data.url,
              });
              break;
            default:
              break;
          }
        })
        .addCase(uploadFile.rejected, (state, action) => {
          state.loading = false;
          state.success = false;
        });
    },
  });
  return {
    ...fileSlice,
    actions: {
      ...fileSlice.actions,
      uploadFile,
    },
  };
};
