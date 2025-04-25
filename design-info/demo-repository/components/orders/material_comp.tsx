import { ChevronDown } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { memo, useState, useEffect } from "react";
import {
  Accordion,
  Button,
  ButtonText,
  H2,
  Paragraph,
  Separator,
  Square,
  XStack,
  YStack,
} from "tamagui";

import { DemandDetailComponent } from "./common_funcs";
import { useGlobalContext } from "../system/globalContext";

/**
 * @description: 申请的展示组件（用于订单进度页面）
 * @param {role, order, currentDemand}
 * @returns
 */
export const MaterialDemandDetail = memo(
  ({ role, order, materialDemand }: { role; order; materialDemand }) => {
    const [openAccordion, setOpenAccordion] = useState<string | undefined>(
      materialDemand && Object.keys(materialDemand).length > 0
        ? "item-1"
        : undefined
    );
    const { screenHeight } = useGlobalContext();

    useEffect(() => {
      if (materialDemand && Object.keys(materialDemand).length > 0) {
        setOpenAccordion("item-1");
      }
    }, [materialDemand]);

    if (materialDemand === undefined || materialDemand === null) {
      return;
    }

    return (
      <XStack
        height="auto"
        borderRadius={20}
        alignSelf="center"
        backgroundColor="#fff"
        justifyContent="center"
        paddingVertical="$3"
        marginBottom="$3"
        flex={1}
      >
        <Accordion
          type="single"
          width="100%"
          overflow="visible"
          value={openAccordion}
          onValueChange={setOpenAccordion}
          collapsible
          borderWidth={0}
        >
          <Accordion.Item
            value="item-1"
            borderRadius={0}
            borderColor="transparent"
          >
            <Accordion.Trigger
              flexDirection="row"
              justifyContent="space-between"
              paddingHorizontal={18}
              paddingVertical="$1"
              style={{
                backgroundColor: "#ffffff",
                opacity: Object.keys(materialDemand).length > 0 ? 1 : 0.7,
              }}
              unstyled
            >
              {({ open }: { open: boolean }) => (
                <>
                  <YStack>
                    <YStack width="100%">
                      <Paragraph>
                        {role === "buyer" ? "卖家申请" : "你的申请"}
                      </Paragraph>

                      <Paragraph color="$lightGray">
                        {/* {timeLeft.hours}时{timeLeft.minutes}分{timeLeft.seconds} */}
                        卖家超时未接单，本次订单将自动取消
                      </Paragraph>
                      <Paragraph color="$brown">
                        请根据卖家的申请进行材料补充
                      </Paragraph>
                    </YStack>
                  </YStack>

                  <Square animation="quick" rotate={open ? "180deg" : "0deg"}>
                    <ChevronDown size="$1" />
                  </Square>
                </>
              )}
            </Accordion.Trigger>
            <Accordion.Content
              width="100%"
              borderRadius={20}
              //   justifyContent="center"
              height={
                materialDemand && Object.keys(materialDemand).length > 0
                  ? screenHeight * 0.35
                  : screenHeight * 0.2
              }
            >
              <XStack
                flex={0}
                justifyContent="space-between"
                marginBottom="$3"
                alignItems="center"
                backgroundColor="#EDEDED"
                borderRadius={20}
                paddingHorizontal="$3"
              >
                {materialDemand && Object.keys(materialDemand).length > 0 ? (
                  <YStack alignItems="flex-start">
                    <Paragraph color="$darkGary">最近申请</Paragraph>
                    <Paragraph color="$darkGray">
                      {materialDemand?.createTime}
                    </Paragraph>
                  </YStack>
                ) : (
                  <Paragraph color="$darkGray">暂无申请</Paragraph>
                )}
                <Button
                  backgroundColor="transparent"
                  borderRadius={20}
                  paddingHorizontal="$3"
                  height={35}
                  justifyContent="center"
                  unstyled
                  onPress={() => {
                    if (role === "buyer") {
                      router.push(
                        `/(tabs)/profile/orders/${order.id}/${materialDemand.id}/material/demand_list`
                      );
                    } else {
                      router.push(
                        `/(sellerscreens)/profile/orders/${order.id}/${materialDemand.id}/material/demand_list`
                      );
                    }
                  }}
                >
                  <ButtonText color="$blue">查看更多</ButtonText>
                </Button>
              </XStack>

              <YStack
                height={Object.keys(materialDemand).length > 0 ? "60%" : "100%"}
                flexDirection="column"
                justifyContent="center"
                marginBottom="$2"
                marginTop={Object.keys(materialDemand).length > 0 ? "$2" : "$0"}
              >
                {Object.keys(materialDemand).length > 0 ? (
                  <DemandDetailComponent demandDetail={materialDemand} />
                ) : (
                  <H2 fontSize={16} color="$gray8" alignSelf="center">
                    {role === "buyer"
                      ? "卖家暂无申请，等待卖家接单"
                      : "暂无申请"}
                  </H2>
                )}
              </YStack>
            </Accordion.Content>
          </Accordion.Item>
        </Accordion>
      </XStack>
    );
  }
);

/**
 * @description: 材料申请的展示组件（用于商品详情页）
 * @param {role, materialDemandList}
 * @returns
 */
export const MaterialDemandComp = memo(
  ({ role, materialDemandList }: { role; materialDemandList }) => {
    const [openAccordion, setOpenAccordion] = useState<string | undefined>(
      materialDemandList && Object.keys(materialDemandList).length > 0
        ? "0"
        : undefined
    );

    useEffect(() => {
      if (materialDemandList && Object.keys(materialDemandList).length > 0) {
        setOpenAccordion("0");
      }
    }, [materialDemandList]);

    if (materialDemandList === undefined || materialDemandList === null) {
      return;
    }

    return (
      <XStack
        height="auto"
        borderRadius={20}
        alignSelf="center"
        backgroundColor="#fff"
        justifyContent="center"
        flex={1}
      >
        <Accordion
          type="single"
          width="100%"
          overflow="visible"
          value={openAccordion}
          onValueChange={setOpenAccordion}
          collapsible
          borderWidth={0}
        >
          <Accordion.Item value="0" borderRadius={0} borderColor="transparent">
            <Accordion.Trigger
              flexDirection="row"
              justifyContent="space-between"
            >
              {({ open }: { open: boolean }) => (
                <>
                  <YStack>
                    <YStack width="100%">
                      <Paragraph>
                        {role === "buyer"
                          ? `卖家申请( ${materialDemandList?.length} )`
                          : `你的申请( ${materialDemandList?.length} )`}
                      </Paragraph>
                    </YStack>
                  </YStack>

                  <Square animation="quick" rotate={open ? "180deg" : "0deg"}>
                    <ChevronDown size="$1" />
                  </Square>
                </>
              )}
            </Accordion.Trigger>
            <Accordion.Content
              width="100%"
              borderRadius={20}
              paddingVertical="$3"
            >
              {materialDemandList?.length > 0 &&
                materialDemandList?.map((item, index) => (
                  <>
                    <DemandDetailComponent demandDetail={item} />
                    <Separator marginVertical={10} />
                  </>
                ))}
            </Accordion.Content>
          </Accordion.Item>
        </Accordion>
      </XStack>
    );
  }
);
