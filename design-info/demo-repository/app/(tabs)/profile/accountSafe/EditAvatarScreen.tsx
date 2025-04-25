import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { goToUpload } from "@/components/utils/filesystem";
import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";
import { router } from "expo-router";
import React, { useCallback, useState } from "react";
import { TouchableWithoutFeedback } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { YStack, Button, Paragraph, Avatar, XStack } from "tamagui";
import { BottomImagePickerSheet } from "@/components/styled/bottomsheet_picker";

export default function EditAvatarScreen() {
  const dispatch = useDispatch<AppDispatch>();
  const userProfile = useSelector((state: RootState) => state.user?.data);
  const [pickImagePopup, setPickImagePopup] = useState(false);

  const uploadAvatar = useSelector((state: RootState) => state.file.avatar);

  const editAvatar = useCallback(async () => {
    if (!uploadAvatar || uploadAvatar === "") {
      alert("头像不能为空");
      return;
    }
    try {
      const res = await dispatch(
        slices?.user?.actions?.editProfile({
          avatar: uploadAvatar,
        })
      );
      if (isAxiosSuccess(res.type)) {
        // 重新获取用户信息
        const userRes = await dispatch(
          slices.auth.actions.fetchUserProfile({})
        );
        await dispatch(slices.user.actions.setUserInfo(userRes.payload));
        alert("头像修改成功");
        router.back();
      } else {
        alert("头像修改失败");
      }
    } catch (err) {
      console.log("fail to edit avatar", err);
    }
  }, [uploadAvatar]);

  return (
    <YStack
      flexDirection="column"
      justifyContent="center"
      alignItems="center"
      marginTop="20%"
      space="$2"
      marginBottom="$5"
    >
      <TouchableWithoutFeedback onPress={() => setPickImagePopup(true)}>
        <Avatar
          size="$12"
          // circular
          backgroundColor="$gray8"
          alignSelf="center"
          marginBottom="$1"
        >
          <Avatar.Image
            src={
              uploadAvatar !== undefined && uploadAvatar !== ""
                ? uploadAvatar
                : userProfile?.avatar
            }
          />
        </Avatar>
      </TouchableWithoutFeedback>
      <Paragraph color="$lightGray">点击修改头像</Paragraph>

      <XStack marginTop="20%">
        <AlertDialogComponent
          title="修改头像"
          description="是否修改头像？"
          handleConfirm={editAvatar}
        >
          <Button
            backgroundColor="#caa472"
            borderRadius="$5"
            paddingHorizontal="$5"
            paddingVertical="$2"
            alignSelf="center"
            height={35}
            alignItems="center"
            marginTop="$4"
            color="white"
          >
            提交修改
          </Button>
        </AlertDialogComponent>
      </XStack>
      <BottomImagePickerSheet
        isOpen={pickImagePopup}
        onClose={setPickImagePopup}
        goToUpload={(action) =>
          goToUpload({
            action,
            setPopup: setPickImagePopup,
            dispatch,
            type: "avatar",
            selectionLimit: 1,
          })
        }
      />
    </YStack>
  );
}
