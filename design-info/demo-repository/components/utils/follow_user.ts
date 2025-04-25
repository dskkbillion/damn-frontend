/**
 * 关注/取消用户关注的相关操作
 */

import { toast } from "@/components/styled/toast";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, slices } from "@/src/store";

interface FollowParams {
  objectId: number;
  type: string;
  feature?: object;
}

/**
 * 关注用户
 * @param dispatch Redux dispatch
 * @param params 关注参数
 * @returns Promise<boolean> 是否关注成功
 */
export const followUser = async ({
  dispatch,
  params,
}: {
  dispatch: AppDispatch;
  params: FollowParams;
}): Promise<boolean> => {
  try {
    const res = await dispatch(slices.cart.actions.followUser(params));
    if (isAxiosSuccess(res.type)) {
      // 更新粉丝数
      await dispatch(slices.item.actions.updateFansNum({ increment: true }));
      // 更新关注状态
      const isFollowing = await checkIsFollowing(dispatch, {
        type: params.type,
        searchIds: [params.objectId],
        memberId: params.objectId,
      });
      await dispatch(slices.cart.actions.setIsFollowing(isFollowing));
      toast({
        title: "关注成功",
        symbol: "checkmark",
      });
      return true;
    } else {
      toast({
        title: "关注失败",
        symbol: "close",
      });
      return false;
    }
  } catch (error) {
    console.error("Follow user failed:", error);
    toast({
      title: "关注失败",
      symbol: "close",
    });
    return false;
  }
};

/**
 * 取消关注用户(根据objectId，需要先获取关注列表id)
 * @param dispatch Redux dispatch
 * @param params 取消关注参数
 * @returns Promise<boolean> 是否取消关注成功
 */
export const unfollowUser = async ({
  dispatch,
  params,
}: {
  dispatch: AppDispatch;
  params: FollowParams;
}): Promise<boolean> => {
  try {
    const followListRes = await dispatch(
      slices.cart.actions.fetchCollecList({
        type: params.type,
      })
    );

    let follingIds: number[] = [];

    if (
      isAxiosSuccess(followListRes.type) &&
      followListRes.payload &&
      typeof followListRes.payload === "object" &&
      followListRes.payload !== null &&
      "rows" in followListRes.payload
    ) {
      const followList = followListRes.payload?.rows;
      follingIds = followList
        ?.filter((item: any) => item.objectId === params.objectId)
        .map((item: any) => item.id);
      // console.log("follingIds", follingIds);
    } else {
      toast({
        title: "取消关注失败",
        symbol: "close",
      });
      return false;
    }

    const res = await dispatch(
      slices.cart.actions.unFollowUser({ ids: follingIds })
    );
    if (isAxiosSuccess(res.type)) {
      // 更新粉丝数
      await dispatch(slices.item.actions.updateFansNum({ increment: false }));
      // 更新关注状态
      const isFollowing = await checkIsFollowing(dispatch, {
        type: params.type,
        searchIds: [params.objectId],
        memberId: params.objectId,
      });
      console.log("isFollowing", isFollowing);
      await dispatch(slices.cart.actions.setIsFollowing(isFollowing));
      toast({
        title: "取消关注成功",
        symbol: "checkmark",
      });
      return true;
    } else {
      toast({
        title: "取消关注失败",
        symbol: "close",
      });
      return false;
    }
  } catch (error) {
    console.error("Unfollow user failed:", error);
    toast({
      title: "取消关注失败",
      symbol: "close",
    });
    return false;
  }
};

/**
 * 检查是否已关注用户
 * @param dispatch Redux dispatch
 * @param params 检查参数
 * @returns Promise<boolean> 是否已关注
 */
export const checkIsFollowing = async (
  dispatch: AppDispatch,
  params: { type: string; searchIds: number[]; memberId: number }
): Promise<boolean> => {
  try {
    const res = await dispatch(slices.cart.actions.fetchIsFollow(params));
    if (
      isAxiosSuccess(res.type) &&
      res.payload &&
      typeof res.payload === "object" &&
      res.payload !== null &&
      "data" in res.payload
    ) {
      const isFollowing = Boolean(res.payload.data[params.memberId]);
      // 直接返回布尔值
      return isFollowing;
    }
    return false;
  } catch (error) {
    console.error("Check following status failed:", error);
    return false;
  }
};
