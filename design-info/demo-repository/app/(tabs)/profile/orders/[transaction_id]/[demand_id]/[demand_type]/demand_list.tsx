import { useLocalSearchParams } from "expo-router";
import { memo } from "react";
import { useSelector } from "react-redux";
import { FlatList } from "react-native";
import { Paragraph, XStack, YStack } from "tamagui";

import { QueryDict } from "@/components/queryDict";
import { useGlobalContext } from "@/components/system/globalContext";
import { RootState } from "@/src/store";

const DemandListPage = memo(() => {
  const materialDemand = useSelector(
    (state: RootState) => state.order.materialDemand
  );
  const deliveryDemand = useSelector(
    (state: RootState) => state.order.deliveryDemand
  );

  const demandType = useLocalSearchParams()?.demand_type;

  console.log("type", demandType);
  console.log("deliveryDemand", deliveryDemand);

  const { dictData } = useGlobalContext();

  const DemandItem = memo(({ item }: { item }) => {
    return (
      <YStack
        backgroundColor="#fff"
        marginBottom="$2"
        paddingHorizontal="$3"
        paddingVertical="$2"
      >
        <XStack alignItems="center">
          {/* 申请类型 */}
          <Paragraph fontSize={20} fontWeight="500">
            {QueryDict(dictData?.["order_request_type"], item.type).label}
          </Paragraph>
          {/* 申请状态 */}
          <XStack
            flexDirection="row"
            alignItems="center"
            marginLeft="auto"
            marginRight={10}
            borderRadius={5}
            paddingVertical="$1"
            paddingHorizontal="$2"
            backgroundColor={
              item.status === "SUCCESS" ? "$successBox" : "$failBox"
            }
          >
            <Paragraph
              color={
                item.status === "SUCCESS" ? "$successText" : "$successText"
              }
              fontSize={12}
            >
              {QueryDict(dictData?.["order_demand_status"], item?.status).label}
            </Paragraph>
          </XStack>
        </XStack>
        <XStack>
          <Paragraph>申请原因: </Paragraph>
          <Paragraph>{item?.reasonLabel}</Paragraph>
        </XStack>
        <XStack>
          <Paragraph>详情: </Paragraph>
          <Paragraph numberOfLines={2} width="80%" overflow="hidden">
            {item?.remarks}
          </Paragraph>
        </XStack>
        <XStack>
          <Paragraph>申请时间：</Paragraph>
          <Paragraph>{item?.createTime}</Paragraph>
        </XStack>
      </YStack>
    );
  });

  return (
    <FlatList
      data={
        demandType === "material"
          ? materialDemand
          : demandType === "delivery"
            ? deliveryDemand
            : []
      }
      keyExtractor={(item) => item.id}
      renderItem={({ item, index }) => <DemandItem item={item} />}
      contentContainerStyle={{ marginTop: 10 }}
      showsVerticalScrollIndicator={false}
    />
  );
});

export default DemandListPage;
