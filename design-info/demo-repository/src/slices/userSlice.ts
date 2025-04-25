import { createSlice } from "@reduxjs/toolkit";

import {
  createAddCommentThunk,
  createFetchBalanceThunk,
  createFetchCommentsThunk,
  createFetchRecordsThunk,
  createWithdrawThunk,
} from "../util/itemActions";
import {
  createAddAuthThunk,
  createAddMyStoryThunk,
  createEditUserProfile,
  createFetchLikedStoryListThunk,
  createFetchMyStoriesThunk,
  createFetchPercentageStatDataThunk,
  createFetchStatDataThunk,
  createFetchUpgradeLevelStatDataThunk,
  createFetchUserAuthThunk,
  createMemberUpdateThunk,
} from "../util/userActions";

interface UserState {
  loading: boolean;
  msg: string;
  code: number | null;
  data: object; // user profile
  statData: object; // seller statistic data
  authList: any[]; // user auth list
  authOpenList: any[]; // user auth list
  searchHistory: any[]; // search user list
  stories: object; // user stories
  story_comments: any[]; // comments for user story
  likedStoryList: any[];
  autoReply: string; // 用户的自动回复设置
  autoReplyStatus: boolean; // 用户的自动回复状态
  wallet: any;
  withdrawRecords: any[]; // 提现记录
  recordDetail: any; // 提现记录详情
  success: boolean;
  error: boolean;
  initilized: boolean;
  storyChanged: boolean;
  platformDetail: any; // 添加平台介入详情状态
}

const initialState: UserState = {
  loading: false,
  msg: "",
  code: null,
  data: {},
  statData: {},
  authList: [],
  authOpenList: [],
  stories: {},
  searchHistory: [],
  story_comments: [],
  likedStoryList: [],
  autoReply: "",
  autoReplyStatus: false,
  wallet: {},
  withdrawRecords: [],
  recordDetail: {},
  success: false,
  error: false,
  initilized: false,
  storyChanged: false,
  platformDetail: null,
};

export const createUserSlice = (axiosFn) => {
  const fetchUserAuthThunk = createFetchUserAuthThunk(axiosFn);
  const fetchUserStores = createFetchMyStoriesThunk(axiosFn);
  const addMyStory = createAddMyStoryThunk(axiosFn);
  const fetchStoryComments = createFetchCommentsThunk(axiosFn);
  const addStoryComment = createAddCommentThunk(axiosFn);
  const addAuthAudit = createAddAuthThunk(axiosFn);
  const editProfile = createEditUserProfile(axiosFn);
  const fetchBalance = createFetchBalanceThunk(axiosFn);
  const withdraw = createWithdrawThunk(axiosFn);
  const fetchRecordsThunk = createFetchRecordsThunk(axiosFn);

  // 卖家主页
  const fetchStatData = createFetchStatDataThunk(axiosFn);
  const fetchPercentageStatData = createFetchPercentageStatDataThunk(axiosFn);
  const fetchUpgradeStatData = createFetchUpgradeLevelStatDataThunk(axiosFn);
  const updateMember = createMemberUpdateThunk(axiosFn);

  // 点赞记录
  const fetchLikedStoryList = createFetchLikedStoryListThunk(axiosFn);

  // 在线状态设置
  const userSlice = createSlice({
    name: "user",
    initialState,
    reducers: {
      setUserInfo: (state, action) => {
        if (action.payload.code !== 200) {
          state.code = action.payload.code;
          state.msg = action.payload.msg;
          state.error = true;
          return;
        }
        state.code = action.payload.code;
        state.data = action.payload.data;
        state.error = false;
      },
      setInitilized: (state) => {
        if (Object.keys(state.data).length > 0) {
          state.initilized = true;
        }
      },
      resetSuccess: (state) => {
        state.success = false;
      },
      resetUserStories: (state) => {
        state.stories = [];
      },
      addAuthAuditList: (state, action) => {
        state.authList = action.payload;
      },
      setAuthOpenList: (state, action) => {
        state.authOpenList = action.payload;
      },
      resetAuthList: (state) => {
        state.authList = [];
      },
      addSearchList: (state, action) => {
        const searchItem = action.payload;

        // 检查搜索项是否已经存在，若存在则将其移到最前面
        const existingIndex = state.searchHistory.findIndex(
          (item) => item === searchItem
        );
        if (existingIndex !== -1) {
          state.searchHistory.splice(existingIndex, 1);
        }

        // 将新搜索项添加到历史记录的最前面
        state.searchHistory.unshift(searchItem);

        // 保持最多十条记录
        if (state.searchHistory.length > 10) {
          state.searchHistory.pop();
        }
      },

      deleteSearchList: (state) => {
        state.searchHistory = [];
      },

      resetStatData: (state) => {
        state.statData = {};
      },
      setRecordDetail: (state, action) => {
        state.recordDetail = action.payload;
      },
      setAutoReplyStatus: (state, action) => {
        state.autoReplyStatus = action.payload;
      },
      setReplyContent: (state, action) => {
        state.autoReply = action.payload.content;
      },

      resetLikedStoryList: (state) => {
        state.likedStoryList = [];
      },
      setStoryChanged: (state) => {
        state.storyChanged = !state.storyChanged;
      },

      setPlatformDetail: (state, action) => {
        state.platformDetail = action.payload;
      },
      resetPlatformDetail: (state) => {
        state.platformDetail = null;
      },
    },
    extraReducers: (builder) => {
      builder
        .addCase(fetchUserAuthThunk.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchUserAuthThunk.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.code = action.payload.code;
          if (state.code === 200) {
            state.authList = action.payload.rows!;
          }
        })
        .addCase(fetchUserAuthThunk.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchUserStores.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchUserStores.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.stories = action.payload.rows;
        })
        .addCase(fetchUserStores.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(addMyStory.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(addMyStory.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(addMyStory.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // add application auth
        .addCase(addAuthAudit.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(addAuthAudit.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(addAuthAudit.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(editProfile.pending, (state, action) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(editProfile.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(editProfile.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 卖家主页数据获取
        .addCase(fetchStatData.pending, (state) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchStatData.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.statData = {
            ...(state.statData || {}),
            ...action.payload.data,
          };
          state.error = false;
        })
        .addCase(fetchStatData.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchPercentageStatData.pending, (state) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchPercentageStatData.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.statData = {
            ...(state.statData || {}),
            ...action.payload.data,
          };
          state.error = false;
        })
        .addCase(fetchPercentageStatData.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        .addCase(fetchUpgradeStatData.pending, (state) => {
          state.loading = true;
          state.error = false;
        })

        .addCase(fetchUpgradeStatData.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.statData = {
            ...(state.statData || {}),
            ...action.payload.data,
          };
          state.error = false;
        })
        .addCase(fetchUpgradeStatData.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        // 获取钱包余额数据
        .addCase(fetchBalance.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchBalance.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.wallet = action.payload.data;
          state.error = false;
        })
        .addCase(fetchBalance.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(withdraw.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(withdraw.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(withdraw.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })
        .addCase(fetchRecordsThunk.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchRecordsThunk.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.withdrawRecords = action.payload.rows;
          state.error = false;
        })
        .addCase(fetchRecordsThunk.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 设置自动回复
        .addCase(updateMember.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(updateMember.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
        })
        .addCase(updateMember.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        })

        // 设置点赞记录
        .addCase(fetchLikedStoryList.pending, (state) => {
          state.loading = true;
          state.error = false;
        })
        .addCase(fetchLikedStoryList.fulfilled, (state, action) => {
          state.loading = false;
          state.success = true;
          state.error = false;
          state.likedStoryList = action.payload.rows;
        })
        .addCase(fetchLikedStoryList.rejected, (state, action) => {
          state.loading = false;
          state.error = true;
          state.msg = action.payload?.msg as string;
          state.code = action.payload?.code as number;
        });
    },
  });
  return {
    ...userSlice,
    actions: {
      ...userSlice.actions,
      fetchUserAuthThunk,
      fetchUserStores,
      addMyStory,
      addAuthAudit,
      editProfile,
      fetchStatData,
      fetchPercentageStatData,
      fetchUpgradeStatData,
      withdraw,
      fetchBalance,
      fetchRecordsThunk,
      fetchLikedStoryList,
      updateMember,
      // fetchStoryComments,
      // addStoryComment,
    },
  };
};
