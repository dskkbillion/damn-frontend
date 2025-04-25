import { fetchContent } from "@/app/(outer)/about/aboutUs";
import { AlertDialogComponent } from "@/components/styled/dialog_comp";
import { AppDispatch, RootState, slices } from "@/src/store";
import { useCallback, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, H2, Paragraph, ScrollView, YStack } from "tamagui";

export default function AccountDeactivation() {
  const dispatch = useDispatch<AppDispatch>();
  const isDeleted = useSelector((state: RootState) => state.auth.deleteAccount);
  const deleteAccount = useCallback(async () => {
    await dispatch(slices.auth.actions.deleteAccount());
  }, []);
  const cancleDeleteAccount = useCallback(async () => {
    await dispatch(slices.auth.actions.cancleDeleteAccount());
  }, []);
  const content = useSelector((state: RootState) => state?.sys?.content);

  useEffect(() => {
    if (Object.keys(content?.delete).length === 0) {
      fetchContent({ dispatch, id: 6 });
    }
  }, [content]);
  return (
    <ScrollView paddingHorizontal="$3" paddingTop="$5">
      <H2 fontSize={25}>{isDeleted ? "已申请注销账号" : "注销账号？"}</H2>
      <Paragraph>
        {isDeleted
          ? "您的注销申请还未生效，请耐心等待。生效前可撤销申请"
          : "注销账号后，您的账号将无法使用，且账号内信息将被永久删除，请谨慎操作。"}
      </Paragraph>
      <AlertDialogComponent
        title={isDeleted ? "撤销注销账号" : "确认注销账号"}
        description={
          isDeleted
            ? "您的注销申请还未生效，请耐心等待。生效前可撤销申请"
            : "注销账号后，您的账号将无法使用，且账号内信息将被永久删除，请谨慎操作。"
        }
        handleConfirm={isDeleted ? cancleDeleteAccount : deleteAccount}
      >
        <Button width="100%" backgroundColor="$brown" size="$4" marginTop="$3">
          <ButtonText color="#fff">
            {isDeleted ? "撤销申请" : "确认注销"}
          </ButtonText>
        </Button>
      </AlertDialogComponent>

      <H2 fontSize={18} marginTop="$5">
        注销协议
      </H2>
      <Paragraph color="$darkGray">{content["delete"]?.content}</Paragraph>
    </ScrollView>
  );
}
