import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { useGlobalContext } from "@/components/system/globalContext";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";
import { router } from "expo-router";
import React, { useCallback, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { YStack, Input, Button, Paragraph } from "tamagui";

export default function EditNicknameScreen() {
  const dispatch = useDispatch<AppDispatch>();
  const [nickname, setNickname] = useState("");
  const userInfo = useSelector((state: RootState) => state.user?.data);
  const { screenHeight } = useGlobalContext();
  const handlePress = useCallback(async () => {
    if (!nickname.trim()) {
      alert("昵称不能为空");
      return;
    }
    try {
      const res = await dispatch(
        slices.user.actions.editProfile({ nickName: nickname })
      );
      if (isAxiosSuccess(res.type)) {
        // 重新获取用户信息
        const userRes = await dispatch(
          slices.auth.actions.fetchUserProfile({})
        );
        await dispatch(slices.user.actions.setUserInfo(userRes.payload));
        alert("昵称修改成功");
        router.back();
      } else {
        alert("昵称修改失败");
      }
    } catch (err) {
      console.log("fail to edit nickName", err);
    }
  }, [nickname]);

  return (
    <YStack
      flex={1}
      backgroundColor="$bottom"
      padding="$4"
      space
      paddingTop="20%"
    >
      <Input
        placeholder="请输入"
        value={nickname}
        onChangeText={setNickname}
        height={screenHeight * 0.06}
        borderWidth={0}
      />
      <Paragraph marginTop="$2" color="grey">
        请设置2-20个字符，不包括空格等无效字符
      </Paragraph>
      <AlertDialogComponent
        title="修改昵称"
        description="确定修改昵称？"
        handleConfirm={handlePress}
      >
        <Button
          backgroundColor="#caa472"
          borderRadius="$5"
          paddingHorizontal="$5"
          paddingVertical="$2"
          alignSelf="center"
          style={{ color: "white", marginTop: "$4" }}
          height={global.screenHeight * 0.05}
        >
          提交修改
        </Button>
      </AlertDialogComponent>
    </YStack>
  );
}
