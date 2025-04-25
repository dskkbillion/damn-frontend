import * as Burnt from "burnt";

// import { Toast, useToastController, useToastState } from "@tamagui/toast";
import React from "react";
import { Button, Label, Switch, XStack, YStack } from "tamagui";

export const toast = ({
  title,
  message,
  symbol,
  haptic = "success",
  duration = 2,
  shouldDismissByDrag = true,
  from = "top",
}: {
  title: string;
  message?: string;
  symbol?: string;
  haptic?: "success" | "warning" | "error";
  duration?: number;
  shouldDismissByDrag?: boolean;
  from?: "top" | "bottom";
}) => {
  console.log("symbol", symbol);
  Burnt.toast({
    title, // required
    message, // optional
    haptic, // or "success", "warning", "error"
    duration, // duration in seconds
    shouldDismissByDrag,
    from, // "top" or "bottom"
    // optionally customize layout
    layout: {
      iconSize: {
        height: 24,
        width: 24,
      },
    },
    // icon: {
    //   ios: {
    //     // SF Symbol. For a full list, see https://developer.apple.com/sf-symbols/.
    //     name: symbol || "checkmark",
    //     color: "#87D96C",
    //   },
    // },
  });
};

/**
 *  IMPORTANT NOTE: if you're copy-pasting this demo into your code, make sure to add:
 *    - <ToastProvider> at the root
 *    - <ToastViewport /> where you want to show the toasts
 */
// export const TamaguiToast = ({
//   title,
//   message,
// }: {
//   title: string;
//   message: string;
// }) => {
//   const [native, setNative] = React.useState(false);

//   const CustomToast = () => {
//     const currentToast = useToastState();

//     if (!currentToast || currentToast.isHandledNatively) return null;
//     return (
//       <Toast
//         key={currentToast.id}
//         duration={currentToast.duration}
//         enterStyle={{ opacity: 0, scale: 0.5, y: -25 }}
//         exitStyle={{ opacity: 0, scale: 1, y: -20 }}
//         y={0}
//         opacity={1}
//         scale={1}
//         animation="100ms"
//         viewportName={currentToast.viewportName}
//       >
//         <YStack>
//           <Toast.Title>{title}</Toast.Title>
//           {!!message && <Toast.Description>{message}</Toast.Description>}
//         </YStack>
//       </Toast>
//     );
//   };

//   return (
//     <YStack space alignItems="center">
//       <ToastControl native={native} />
//       <CustomToast />

//       <NativeOptions native={native} setNative={setNative} />
//     </YStack>
//   );
// };

// const ToastControl = ({ native }: { native: boolean }) => {
//   const toast = useToastController();
//   return (
//     <XStack gap="$2" justifyContent="center">
//       <Button
//         onPress={() => {
//           toast.show("Successfully saved!", {
//             message: "Don't worry, we've got your data.",
//             native,
//           });
//         }}
//       >
//         Show
//       </Button>
//       <Button
//         onPress={() => {
//           toast.hide();
//         }}
//       >
//         Hide
//       </Button>
//     </XStack>
//   );
// };

// const NativeOptions = ({
//   native,
//   setNative,
// }: {
//   native: boolean;
//   setNative: (native: boolean) => void;
// }) => {
//   return (
//     <XStack gap="$3">
//       <Label size="$1" onPress={() => setNative(false)}>
//         Custom
//       </Label>
//       <Switch
//         id="native-toggle"
//         nativeID="native-toggle"
//         theme="active"
//         size="$1"
//         checked={!!native}
//         onCheckedChange={(val) => setNative(val)}
//       >
//         <Switch.Thumb
//           animation={[
//             "quick",
//             {
//               transform: {
//                 overshootClamping: true,
//               },
//             },
//           ]}
//         />
//       </Switch>

//       <Label size="$1" onPress={() => setNative(true)}>
//         Native
//       </Label>
//     </XStack>
//   );
// };
