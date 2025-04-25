import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";
import { useCallback, useEffect } from "react";
import { Text } from "react-native";
import { useDispatch, useSelector } from "react-redux";
import { Circle, H1, Paragraph, XStack, YStack } from "tamagui";

import { useGlobalContext } from "@/components/system/globalContext";
// import { SellerGuide } from "./seller_guide";

export default function SellerHomepage() {
  const dispatch = useDispatch<AppDispatch>();
  const statData = useSelector((state: RootState) => state?.user?.statData);
  const { screenWidth } = useGlobalContext();

  const fetchSellerData = useCallback(async () => {
    const res1 = await dispatch(slices?.user?.actions?.fetchStatData({}));
    const res2 = await dispatch(
      slices?.user?.actions?.fetchPercentageStatData({})
    );
    const res3 = await dispatch(
      slices?.user?.actions?.fetchUpgradeStatData({})
    );
    if (
      isAxiosSuccess(res1.type) &&
      isAxiosSuccess(res2.type) &&
      isAxiosSuccess(res3.type)
    ) {
      return;
    } else {
      console.log("fail to fetch stat data");
      return;
    }
  }, []);

  useEffect(() => {
    fetchSellerData();
  }, []);

  return (
    <YStack flexDirection="column" height="100%" width="100%">
      {/* <SellerGuide visible={isModalVisible} onClose={closeModal} /> */}

      <XStack
        flexDirection="row"
        alignItems="center"
        space={screenWidth * 0.04}
        paddingHorizontal={screenWidth * 0.04}
        backgroundColor="$background"
        width="100%"
        height="20%"
      >
        {/* 热度值 */}
        <YStack flexDirection="column" alignItems="center">
          <Circle
            borderWidth="$1"
            borderColor="$brown"
            width={screenWidth * 0.2}
            height={screenWidth * 0.2}
            backgroundColor="$background"
          >
            <Paragraph>{statData?.heatPercent}%</Paragraph>
          </Circle>
          <Paragraph>热度值</Paragraph>
        </YStack>

        {/* 回复率 */}
        <YStack flexDirection="column" alignItems="center">
          <Circle
            borderWidth="$1"
            borderColor="$brown"
            width={screenWidth * 0.2}
            height={screenWidth * 0.2}
            backgroundColor="&background"
          >
            <Paragraph>{statData?.recoverPercent}%</Paragraph>
          </Circle>
          <Paragraph>回复率</Paragraph>
        </YStack>

        {/* 完成率 */}
        <YStack flexDirection="column" alignItems="center">
          <Circle
            borderWidth="$1"
            borderColor="$darkGray"
            width={screenWidth * 0.2}
            height={screenWidth * 0.2}
            backgroundColor="$background"
          >
            <Paragraph>{statData?.completePercent}%</Paragraph>
          </Circle>
          <Paragraph>完成率</Paragraph>
        </YStack>

        {/* 好评率 */}
        <YStack flexDirection="column" alignItems="center">
          <Circle
            borderWidth="$1"
            borderColor="$darkGray"
            width={screenWidth * 0.2}
            height={screenWidth * 0.2}
            backgroundColor="$background"
          >
            <Paragraph>{statData?.goodPercent}%</Paragraph>
          </Circle>
          <Paragraph>好评率</Paragraph>
        </YStack>
      </XStack>

      {/*--------------------- 升级到下一级: 需要替换为真实数据，使用函数统一render-----------------------------*/}
      <H1 fontSize={16} marginLeft="4%">
        升到下一级
      </H1>

      <XStack
        flexDirection="row"
        justifyContent="space-between"
        alignItems="center"
        width="90%"
        height="23%"
        backgroundColor="$background"
        marginHorizontal="4%"
        borderRadius={20}
      >
        {/* 左侧指标 */}
        <YStack flexDirection="column" paddingHorizontal="$5" space="15%">
          <Text style={{ fontSize: 16 }}>{statData?.copyWritingDays}</Text>
          <Text style={{ fontSize: 16 }}>{statData?.copyWritingOrderNum}</Text>
          <Text style={{ fontSize: 16 }}>
            {statData?.copyWritingOrderPrice}
          </Text>
        </YStack>
        {/* 右侧完成度 */}
        <YStack flexDirection="column" paddingHorizontal="$5" space="15%">
          <XStack marginLeft="auto">
            <Paragraph color="$brown" fontSize={15} fontWeight="800">
              {statData?.totalDays}
            </Paragraph>
            <Text style={{ fontSize: 16, fontWeight: "600" }}>/</Text>
            <Paragraph fontSize={16} fontWeight="600">
              {statData?.days}
            </Paragraph>
          </XStack>
          <XStack marginLeft="auto">
            <Paragraph color="#B66D0E" fontSize={15} fontWeight="800">
              {statData?.totalOrderNum}
            </Paragraph>
            <Paragraph fontSize={16} fontWeight="600">
              /
            </Paragraph>
            <Paragraph fontSize={16} fontWeight="600">
              {statData?.orderNum}
            </Paragraph>
          </XStack>
          <XStack marginLeft="auto">
            <Paragraph color="$brown" fontSize={15} fontWeight="800">
              {statData?.totalOrderPrice}
            </Paragraph>
            <Paragraph fontSize={16} fontWeight="600">
              /
            </Paragraph>
            <Paragraph fontSize={16} fontWeight="600">
              {statData?.orderPrice}
            </Paragraph>
          </XStack>
        </YStack>
      </XStack>
      {/*--------------------- 指标--------------------------*/}
      <H1 fontSize={16} marginLeft="4%">
        指标
      </H1>

      <XStack
        flexDirection="row"
        justifyContent="space-between"
        alignItems="center"
        width="90%"
        height="15%"
        backgroundColor="$background"
        marginHorizontal="4%"
        borderRadius={20}
      >
        {/* 左侧 */}
        <YStack width="50%" space="20%" paddingHorizontal="$5">
          <XStack flexDirection="row" justifyContent="space-between">
            <Text style={{ fontSize: 16 }}>总盈利</Text>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.totalEarnings}
            </Paragraph>
          </XStack>
          <XStack flexDirection="row" justifyContent="space-between">
            <Text style={{ fontSize: 16 }}>总订单数</Text>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.totalOrderNum}
            </Paragraph>
          </XStack>
        </YStack>

        {/* 右侧 */}
        <YStack width="50%" space="20%" paddingHorizontal="$5">
          <XStack flexDirection="row" justifyContent="space-between">
            <Paragraph style={{ fontSize: 16 }}>本月盈利</Paragraph>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.thisMonthTotalEarnings}
            </Paragraph>
          </XStack>
          <XStack flexDirection="row" justifyContent="space-between">
            <Text style={{ fontSize: 16 }}>活跃订单数</Text>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.activeOrderNum}
            </Paragraph>
          </XStack>
        </YStack>
      </XStack>

      {/*--------------------- 待处理--------------------------*/}

      <H1 fontSize={16} marginLeft="4%">
        待处理
      </H1>

      <XStack
        flexDirection="row"
        justifyContent="space-between"
        alignItems="center"
        width="90%"
        height="16%"
        backgroundColor="$background"
        marginHorizontal="4%"
        borderRadius={20}
      >
        {/* 左侧 */}
        <YStack flexDirection="column" paddingHorizontal="$5" space="15%">
          <Text style={{ fontSize: 16 }}>未完成订单数</Text>
          <Text style={{ fontSize: 16 }}>距离下次递交日</Text>
        </YStack>
        {/* 右侧 */}
        <YStack flexDirection="column" paddingHorizontal="$5" space="15%">
          <XStack marginLeft="auto">
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.pendingOrderNum}
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              (待完成)
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              {" "}
              /{" "}
            </Paragraph>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.receiptOrderNum}
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              (回单)
            </Paragraph>
          </XStack>

          <XStack marginLeft="auto">
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.earlyTime}
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              (最早)
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              {" "}
              /{" "}
            </Paragraph>
            <Paragraph color="$brown" fontSize={16} fontWeight="800">
              {statData?.earlyTime}
            </Paragraph>
            <Paragraph style={{ fontSize: 16, fontWeight: "500" }}>
              (最晚)
            </Paragraph>
          </XStack>
        </YStack>
      </XStack>
    </YStack>
  );
}
