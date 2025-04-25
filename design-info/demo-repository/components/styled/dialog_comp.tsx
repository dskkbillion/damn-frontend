import { AlertDialog, Button, XStack, YStack } from "tamagui";

export const AlertDialogComponent = ({
  title,
  children,
  description,
  handleConfirm,
}) => {
  let isCancel = false;
  if (title === "取消订单") {
    isCancel = true;
  }
  return (
    <AlertDialog native>
      <AlertDialog.Trigger asChild>{children}</AlertDialog.Trigger>

      <AlertDialog.Portal>
        <AlertDialog.Overlay
          key="overlay"
          animation="quick"
          opacity={0.5}
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <AlertDialog.Content
          elevate
          key="content"
          width={global.screenWidth * 0.7}
          animation={[
            "quick",
            {
              opacity: {
                overshootClamping: true,
              },
            },
          ]}
          enterStyle={{ x: 0, y: -20, opacity: 0, scale: 0.9 }}
          exitStyle={{ x: 0, y: 10, opacity: 0, scale: 0.95 }}
          x={0}
          scale={1}
          opacity={1}
          y={0}
        >
          <YStack space>
            <AlertDialog.Title fontSize={20} alignSelf="center">
              {title}
            </AlertDialog.Title>
            <AlertDialog.Description>{description}</AlertDialog.Description>
            <XStack gap="$3" justifyContent="flex-end">
              <AlertDialog.Cancel asChild>
                <Button>取消</Button>
              </AlertDialog.Cancel>

              <AlertDialog.Action asChild onPress={handleConfirm}>
                <Button>确定</Button>
              </AlertDialog.Action>
            </XStack>
          </YStack>
        </AlertDialog.Content>
      </AlertDialog.Portal>
    </AlertDialog>
  );
};
