import { useLocalSearchParams } from "expo-router";
import { FlatList, Text } from "react-native";
import {
  Button,
  ButtonText,
  Paragraph,
  View,
  XStack,
  YStack,
  useTheme,
  Image,
  Separator,
} from "tamagui";

import { dateToString } from "@/components/time_processor";
import { sellerDataset } from "@/constants/sellers";
import { ServiceDataset } from "@/constants/services";
import { TransactionDataset } from "@/constants/transactions";

export default function PostSalePage() {
  // 取3个service状态为refund进行演示
  const transactions = TransactionDataset.filter(
    (p) => p.transaction_state === "refund"
  ).slice(0, 3);
  // 获取日期的数字形式

  const Data = transactions.map((transaction) => ({
    transaction_id: transaction.transaction_id,
    service_id: transaction.service_id,
    transaction_date: transaction.transaction_date,
    transaction_amount: transaction.transaction_amount,
    service: ServiceDataset.find(
      (p) => p.service_id === transaction.service_id
    ),
    seller: sellerDataset.find((p) => p.user_id === transaction.seller_id),
  }));

  const theme = useTheme();

  const renderCard = ({ item }) => (
    <YStack
      paddingHorizontal="$2"
      paddingTop="$3"
      backgroundColor="$background"
    >
      <XStack paddingVertical={5}>
        <Paragraph>{item.seller.username}</Paragraph>
        <Paragraph marginLeft="auto" color="$red">
          退款成功
        </Paragraph>
      </XStack>

      {/* 商品介绍 */}
      <XStack padding="$2" backgroundColor="$bottomColor">
        <Image
          resizeMode="stretch"
          borderRadius={10}
          source={{
            width: global.screenWidth * 0.18,
            height: global.screenHeight * 0.08,
            uri: `${item?.service?.image_url}`,
          }}
        />
        <Text numberOfLines={2} style={{ width: "60%", marginLeft: 10 }}>
          {item?.service?.description}
        </Text>
        <Text style={{ marginLeft: "auto" }}>¥{item?.transaction_amount}</Text>
      </XStack>

      <XStack
        flexDirection="row"
        marginLeft="auto"
        paddingLeft="4%"
        paddingVertical="4%"
        space="$2"
      >
        <Text style={{ marginLeft: 10 }}>实付: ¥ 0</Text>
        <Text style={{ marginLeft: 10 }}>退款金额:</Text>
        <Text style={{ color: "#FF0000" }}>
          ¥{item?.transaction_amount}
        </Text>
      </XStack>

      {/* button */}
      <XStack
        flexDirection="row"
        paddingBottom={5}
        marginLeft="auto"
        space="$2"
      >
        <Button
          borderColor="$lightGray"
          borderRadius={5}
          paddingHorizontal={5}
          borderWidth={0.5}
          height="$2"
        >
          <ButtonText fontSize={12}>删除售后单</ButtonText>
        </Button>
        <Button
          borderColor="$lightGray"
          borderRadius={5}
          paddingHorizontal={5}
          borderWidth={0.5}
          height="$2"
        >
          <ButtonText fontSize={12}>售后详情</ButtonText>
        </Button>
      </XStack>

      <XStack backgroundColor="$bottomColor" paddingVertical="$1.5" />
    </YStack>
  );

  return (
    <YStack flexDirection="column">
      <FlatList
        data={Data}
        renderItem={renderCard}
        keyExtractor={(item) => item.transaction_id.toString()}
        showsVerticalScrollIndicator={false}
      />
    </YStack>
  );
}
