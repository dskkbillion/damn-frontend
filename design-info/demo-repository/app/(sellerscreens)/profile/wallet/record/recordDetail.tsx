import { RootState } from "@/src/store";
import { useSelector } from "react-redux";
import { Avatar, Paragraph, Separator, XStack, YStack } from "tamagui";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import FontAwesomeIcon from "react-native-vector-icons/FontAwesome";
import { QueryDict } from "@/components/queryDict";

export default function RecordDetail() {
  const item = useSelector((state: RootState) => state.user.recordDetail);
  return (
    <YStack flex={1} marginTop="10%" alignItems="center">
      <Avatar circular size={50} backgroundColor="#fff">
        {item?.accountType === "bankcard" && (
          <FontAwesomeIcon name="credit-card" size={24} color="$darkGray" />
        )}
        {item?.accountType === "wechat" && (
          <FontAwesomeIcon name="wechat" size={24} color="$darkGray" />
        )}
        {item?.accountType === "ali" && (
          <AntDesignIcon name="alipay-circle" size={24} color="$darkGray" />
        )}
      </Avatar>
      <Paragraph>
        {QueryDict(global.dictData?.["account_type"], item?.accountType).label}
        提现
      </Paragraph>
      <Paragraph marginVertical="$2" fontSize={20}>
        {item?.applyAmount}
      </Paragraph>

      <Separator marginTop="$8" />

      <YStack width="80%" gap="$2">
        <XStack alignItems="center" justifyContent="space-between">
          <Paragraph color="$darkGray">当前状态</Paragraph>
          <Paragraph>
            {QueryDict(global.dictData?.["cash_status"], item?.state).label}
          </Paragraph>
        </XStack>
        <XStack alignItems="center" justifyContent="space-between">
          <Paragraph color="$darkGray">申请时间</Paragraph>
          <Paragraph>{item?.applyedTime}</Paragraph>
        </XStack>
        <XStack alignItems="center" justifyContent="space-between">
          <Paragraph color="$darkGray">审核时间</Paragraph>
          <Paragraph>{item?.auditedTime || "等待审核"}</Paragraph>
        </XStack>
        {item?.accountType === "bankcard" && (
          <XStack alignItems="center" justifyContent="space-between">
            <Paragraph color="$darkGray">提现机构</Paragraph>
            <Paragraph>{item?.accountInfo?.bankcardCom}</Paragraph>
          </XStack>
        )}
        {item?.accountType === "bankcard" && (
          <XStack alignItems="center" justifyContent="space-between">
            <Paragraph color="$darkGray">提现账户</Paragraph>
            <Paragraph>{item?.accountInfo?.bankcardNum}</Paragraph>
          </XStack>
        )}
        {item?.accountType === "wechat" && (
          <XStack alignItems="center" justifyContent="space-between">
            <Paragraph color="$darkGray">微信账号</Paragraph>
            <Paragraph>{item?.accountInfo?.wechatAccount}</Paragraph>
          </XStack>
        )}
        {item?.accountType === "ali" && (
          <XStack alignItems="center" justifyContent="space-between">
            <Paragraph color="$darkGray">支付宝账号</Paragraph>
            {/* <Paragraph>{item?.accountInfo?.aliAccount}</Paragraph> */}
            <Paragraph>{item?.accountInfo?.wechatAccount}</Paragraph>
          </XStack>
        )}

        <XStack alignItems="center" justifyContent="space-between">
          <Paragraph color="$darkGray">交易单号</Paragraph>
          <Paragraph>{item?.cashSn}</Paragraph>
        </XStack>

        <Separator marginTop="$2" />
        {item?.state === "passed" && (
          <>
            <XStack alignItems="center" justifyContent="space-between">
              <Paragraph color="$darkGray">到账金额</Paragraph>
              <Paragraph>{item?.receivedAmount}</Paragraph>
            </XStack>
            <XStack alignItems="center" justifyContent="space-between">
              <Paragraph color="$darkGray">手续费</Paragraph>
              <Paragraph>{item?.chargeAmount}</Paragraph>
            </XStack>
          </>
        )}
      </YStack>
    </YStack>
  );
}
