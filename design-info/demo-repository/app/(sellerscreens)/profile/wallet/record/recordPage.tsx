import FontAwesomeIcon from "@expo/vector-icons/FontAwesome";
import { FlashList } from "@shopify/flash-list";
import { memo, useEffect } from "react";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import { useDispatch, useSelector } from "react-redux";
import { Button, Paragraph, XStack, YStack } from "tamagui";

import { QueryDict } from "@/components/queryDict";
import { AppDispatch, RootState, slices } from "@/src/store";
import { router } from "expo-router";

export default function Records() {
  const dispatch = useDispatch<AppDispatch>();
  const records = useSelector((state: RootState) => state.user.withdrawRecords);

  useEffect(() => {
    dispatch(
      slices.user.actions.fetchRecordsThunk({ pageNum: 1, pageSize: 9999 })
    );
  }, []);

  return (
    <YStack flex={1} marginTop="$3">
      <FlashList
        data={records}
        renderItem={({ item }) => <RecordItem item={item} />}
        estimatedItemSize={100}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
}

const RecordItem = memo(({ item }: { item: any }) => {
  const dispatch = useDispatch<AppDispatch>();
  return (
    <Button
      space="$3"
      alignItems="center"
      flexDirection="row"
      paddingVertical="$3"
      backgroundColor="#fff"
      padding="$3"
      onPress={() => {
        dispatch(slices.user.actions.setRecordDetail(item));
        router.push("/profile/wallet/record/recordDetail");
      }}
      unstyled
    >
      {item?.accountType === "bankcard" && (
        <FontAwesomeIcon name="credit-card" size={24} color="$darkGray" />
      )}
      {item?.accountType === "wechat" && (
        <FontAwesomeIcon name="wechat" size={24} color="$darkGray" />
      )}
      {item?.accountType === "ali" && (
        <AntDesignIcon name="alipay-circle" size={24} color="$darkGray" />
      )}

      <YStack alignItems="flex-start">
        <Paragraph>
          {
            QueryDict(global.dictData?.["account_type"], item?.accountType)
              .label
          }
          提现
        </Paragraph>
        <Paragraph color="$darkGray">{item?.applyedTime}</Paragraph>
      </YStack>

      <YStack marginLeft="auto" paddingHorizontal="$3" alignItems="flex-end">
        <Paragraph>- {item?.applyAmount}</Paragraph>
        <Paragraph
          color={item?.state === "passed" ? "$successText" : "$failText"}
        >
          {QueryDict(global.dictData?.["cash_status"], item?.state).label}
        </Paragraph>
      </YStack>
    </Button>
  );
});
