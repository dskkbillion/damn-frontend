import { useCallback, useState } from "react";
import { Text } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { Switch, XStack } from "tamagui";

import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function TimeManagementPage() {
  const dispatch = useDispatch<AppDispatch>();
  const user = useSelector((state: RootState) => state.user.data);
  const [isOnline, setIsOnline] = useState(user?.onlineFlag);

  const updateOnlineState = useCallback(async (state) => {
    const res = await dispatch(
      slices.user.actions.updateMember({
        onlineFlag: state,
      })
    );
    if (isAxiosSuccess(res.type)) {
      // 重新获取用户数据
      const userRes = await dispatch(slices.auth.actions.fetchUserProfile({}));
      await dispatch(slices.user.actions.setUserInfo(userRes.payload));
      const text = state ? "在线" : "离线";
      alert(`设置成功，当前卖家状态${text}`);
    } else {
      alert("设置失败，请稍后再试");
    }
  }, []);

  return (
    <>
      <XStack
        flex={0}
        width="90%"
        marginVertical="4%"
        paddingVertical="4%"
        alignSelf="center"
        paddingHorizontal="4%"
        alignItems="center"
        backgroundColor="$text"
        borderRadius={10}
      >
        <Text style={{ marginRight: "auto", fontSize: 16, fontWeight: "500" }}>
          当前状态
        </Text>

        <Text
          style={{ paddingHorizontal: 5, color: isOnline ? "green" : "red" }}
        >
          {isOnline ? "在线" : "不在线"}
        </Text>
        <Switch
          size="$3"
          checked={isOnline}
          onCheckedChange={() => {
            updateOnlineState(!isOnline);
            setIsOnline(!isOnline);
          }}
          backgroundColor={isOnline ? "$green" : "#A1A1A1"}
        >
          <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
        </Switch>
      </XStack>
    </>
  );
}
