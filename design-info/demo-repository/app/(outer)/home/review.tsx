import { FlashList } from "@shopify/flash-list";
import { memo, useState } from "react";
import FastImage from "react-native-fast-image";
import { useDispatch, useSelector } from "react-redux";
import { Avatar, H1, Paragraph, XStack, YStack } from "tamagui";

import { AppDispatch, RootState } from "@/src/store";
import { getFilePath } from "@/components/utils/filesystem";

export default function ReviewPage() {
  const dispatch = useDispatch<AppDispatch>();
  const item_comments = useSelector(
    (state: RootState) => state.item.item_comments
  );
  // console.log("item_comments:", item_comments);
  if (!item_comments || item_comments.length === 0) {
    return (
      <YStack justifyContent="center" alignItems="center" flex={1}>
        <H1 color="$gray8" fontSize={30}>
          暂无评论
        </H1>
      </YStack>
    );
  }
  // const order = useSelector((state: RootState) => state.order.order);

  // const addEvaluation = async ({ text, is_anonymity }) => {
  //   // 添加评论(仅文本)
  //   const params = {
  //    orderId: order.id,
  //    remark: text,
  //    anoymityFlag: is_anonymity,
  //   };
  //   try {
  //     await dispatch(slices.item.actions.(params));
  //   } catch (e) {
  //     console.log(e);
  //   }
  // };

  // 根据 orderId 对评论进行分组
  // const groupedComments = useMemo(() => {
  //   const grouped = item_comments.reduce((acc, comment) => {
  //     if (!acc[comment.orderId]) {
  //       acc[comment.orderId] = [];
  //     }
  //     acc[comment.orderId].push(comment);
  //     return acc;
  //   }, {});
  //   return Object.entries(grouped).map(([orderId, comments]) => ({
  //     orderId,
  //     comments,
  //   }));
  // }, [item_comments]);

  return (
    <FlashList
      data={item_comments}
      keyExtractor={(item: any, index) => item.orderId.toString()}
      renderItem={({ item }: any) => <CommentItem item={item} />}
      estimatedItemSize={100}
      // contentContainerStyle={{ paddingBottom: 30 }}
    />
  );
}

const CommentItem = ({ item }: any) => {
  const [popup, setPopup] = useState(false);
  return (
    <YStack
      padding="$3"
      backgroundColor="$background"
      space="$2"
      marginBottom="$1"
    >
      {/* 头像 && 昵称 */}
      <XStack alignItems="center" space="$2">
        <Avatar size={30} circular backgroundColor="#EDEDED">
          <Avatar.Image source={{ uri: item.buyer?.avatar }} />
        </Avatar>
        <Paragraph>{item?.buyer?.nickName}</Paragraph>
        <Paragraph size="$small" color="$lightGray">
          - {item?.skuName}
        </Paragraph>
      </XStack>

      <Paragraph size="$1">{item.remark}</Paragraph>
      {/* 评论图片 */}
      {item?.images && item.images.length > 0 && (
        <ImagesContainer images={item.images} />
      )}

      {/* 添加评论 (暂不支持) */}
      {/* <Button
        alignItems="center"
        space="$2"
        justifyContent="flex-end"
        height="auto"
        onPress={() => setPopup(true)}
      >
        <IoniconsIcon name="chatbox-ellipses-outline" size={18} color="#000" />
      </Button> */}

      {/* <ReviewBottomSheet
        isOpen={popup}
        onClose={() => setPopup(false)}
        zIndex={100000}
        sendComment= {}
      /> */}
    </YStack>
  );
};

const ImagesContainer = memo(({ images }: { images: string[] }) => {
  // console.log("images:", images);
  return (
    <XStack flexWrap="wrap" space="$2">
      {images.map((uri, index) => (
        <FastImage
          source={{
            uri: getFilePath(uri),
            priority: FastImage.priority.normal,
          }}
          style={{
            width: "32%",
            backgroundColor: "#EDEDED",
            aspectRatio: 1,
            marginBottom: index < 3 ? 8 : 0,
          }}
          key={index}
          resizeMode="contain"
        />
      ))}
    </XStack>
  );
});

// const ReviewBottomSheet = memo(
//   ({
//     isOpen,
//     onClose,
//     children,
//     zIndex = 100000,
//     position = 0,
//     sendComment,
//     ...props
//   }: {
//     isOpen: boolean;
//     onClose: () => void;
//     children: React.ReactNode;
//     zIndex: number;
//     position: number;
//     sendComment: any;
//   }) => {
//     const [currentPosition, setCurrentPosition] = useState(position);
//     const [text, setText] = useState("");
//     const dispatch = useDispatch<AppDispatch>();
//     const [anonymity, setAnonymity] = useState(false);
//     // const commentAdded = useSelector((state: RootState) => state.item.comment_added);

//     const handleSendComment = () => {
//       sendComment({ text, is_anonymity: anonymity });
//       setText("");
//     };
//     //   console.log("anonymity", anonymity);
//     return (
//       <PortalProvider shouldAddRootHost>
//         <Sheet
//           forceRemoveScrollEnabled
//           modal
//           open={isOpen}
//           onOpenChange={(open) => onClose(open)}
//           snapPoints={[70]}
//           dismissOnSnapToBottom
//           position={crrentPosition}
//           onPositionChange={setCurrentPosition}
//           zIndex={zIndex}
//           disableDrag
//           animation="medium"
//         >
//           <
//             animation="lazy"
//             enterStyle={{ opacity: 0 }}
//             exitStyle={{ opacity: 0 }}
//             backgroundColor="rgba(0, 0, 0, 0.5)"
//           />
//           <Sheet.Frame
//             padding="$4"
//             height="100%"
//             alignItems="center"
//             space="$5"
//             backgroundColor="#fff"
//           >
//             <XStack
//               position="fixed"
//               left={0}
//               top={0}
//               justifyContent="space-between"
//               width="100%"
//               height="5%"
//             >
//               <Paragraph>评论</Paragraph>
//               <TouchableWithoutFeedback onPress={() => onClose(false)}>
//                 <XStack>
//                   <X size={20} color="#000" />
//                 </XStack>
//               </TouchableWithoutFeedback>
//             </XStack>
//             <XStack flexDirection="row" width="100%" height="70%">
//               {children}
//             </XStack>
//             <YStack
//               width="100%"
//               marginTop="auto"
//               paddingBottom="$5"
//               space="$2"
//               height="25%"
//             >
//               <TextArea
//                 placeholder="评论"
//                 width="100%"
//                 height={80}
//                 borderRadius={20}
//                 borderColor="$darkGray"
//                 value={text}
//                 onChangeText={(text) => {
//                   setText(text);
//                 }}
//               />
//               <XStack space="$2" width="100%" alignItems="center">
//                 <Switch
//                   size="$3"
//                   checked={anonymity}
//                   onCheckedChange={(val) => {
//                     setAnonymity(val);
//                   }}
//                   style={
//                     anonymity
//                       ? { backgroundColor: "$brown" }
//                       : { backgroundColor: "#A1A1A1" }
//                   }
//                 >
//                   <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
//                 </Switch>
//                 <Label color="$lightGray">匿名评论</Label>
//                 <Button
//                   paddingVertical="$2"
//                   width={60}
//                   paddingHorizontal="$3"
//                   borderRadius={10}
//                   backgroundColor="$brown"
//                   color="#fff"
//                   marginLeft="auto"
//                   alignItems="center"
//                   justifyContent="center"
//                   unstyled
//                   onPress={() => handleSendComment()}
//                 >
//                   发送
//                 </Button>
//               </XStack>
//             </YStack>
//           </Sheet.Frame>
//         </Sheet>
//       </PortalProvider>
//     );
//   }
// );
