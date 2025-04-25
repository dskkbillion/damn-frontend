import { ChevronDown } from "@tamagui/lucide-icons";
import { memo } from "react";
import { useSelector } from "react-redux";
import {
  Accordion,
  Button,
  Paragraph,
  Separator,
  Square,
  XStack,
  YStack,
} from "tamagui";

import { QueryDict } from "../queryDict";
import { useGlobalContext } from "../system/globalContext";
import { getFilePath } from "../utils/filesystem";
import { FileDownloader } from "@/components/styled/file_downloader";
import { RootState } from "@/src/store";

/**
 * @description: 渲染交付的组件（卖家）
 * @param
 * @returns
 */
export const DeliveryResComp = memo(
  ({ item, previewFile }: { item: any; previewFile: any }) => {
    return (
      <>
        <XStack
          paddingVertical={10}
          paddingHorizontal={20}
          backgroundColor="#F2F2F2"
          borderRadius={5}
          marginBottom={10}
        >
          <Paragraph>{item?.content}</Paragraph>
        </XStack>
        <YStack gap="$2">
          {Array.isArray(item?.files) &&
            item?.files.length > 0 &&
            item?.files.map((uri, index) => (
              <XStack
                alignItems="center"
                justifyContent="space-between"
                key={index}
              >
                <Button
                  paddingVertical="$3"
                  paddingHorizontal="$2"
                  width="85%"
                  backgroundColor="#EDEDED"
                  flex={0}
                  borderRadius="$2"
                  onPress={() => previewFile(getFilePath(uri))}
                  unstyled
                >
                  <Paragraph ellipsizeMode="tail" numberOfLines={1}>
                    {uri}
                  </Paragraph>
                </Button>
                {/* 下载按钮 : 这里的filename没有参数*/}
                <FileDownloader url={uri} fileName={String(index)} />
              </XStack>
            ))}
        </YStack>
        <XStack
          flexDirection="row"
          justifyContent="center"
          alignItems="center"
          height={30}
        >
          <Paragraph color="$lightGray">{item?.files?.length}个文件</Paragraph>
        </XStack>
      </>
    );
  }
);

/**
 * @description: 展示交付申请的折叠组件（用于商品详情页）
 * @param {role, order, currentDemand}
 * @returns
 */
export const DeliveryDemandComp = memo(
  ({
    role,
    order,
    currentDemand,
  }: {
    role: "buyer" | "seller";
    order: any;
    currentDemand: any;
  }) => {
    const { dictData } = useGlobalContext();
    const deliveryDemandList = useSelector(
      (state: RootState) => state.order.deliveryDemand
    );

    return (
      <YStack width="100%" backgroundColor="#fff">
        <Accordion
          type="single"
          width="100%"
          overflow="visible"
          collapsible
          borderWidth={0}
        >
          <Accordion.Item value="0" borderRadius={0} borderColor="transparent">
            <Accordion.Trigger
              flexDirection="row"
              justifyContent="space-between"
            >
              {({ open }) => (
                <>
                  <YStack>
                    <YStack width="100%">
                      <Paragraph>
                        买家申请 ({deliveryDemandList?.length || 0})
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
              <YStack padding="$3" space="$2">
                {deliveryDemandList?.map((demand, index) => (
                  <YStack key={index} space="$2">
                    <XStack justifyContent="space-between">
                      <Paragraph fontWeight="700">处理状态</Paragraph>
                      <Paragraph>
                        {
                          QueryDict(
                            dictData["order_demand_status"],
                            demand.status
                          ).label
                        }
                      </Paragraph>
                    </XStack>
                    <XStack justifyContent="space-between">
                      <Paragraph fontWeight="700">申请原因</Paragraph>
                      <Paragraph>{demand.reasonLabel}</Paragraph>
                    </XStack>
                    <XStack justifyContent="space-between">
                      <Paragraph fontWeight="700">详细说明</Paragraph>
                      <Paragraph>{demand.remarks}</Paragraph>
                    </XStack>
                    <XStack justifyContent="space-between">
                      <Paragraph fontWeight="700">申请时间</Paragraph>
                      <Paragraph>{demand.createTime}</Paragraph>
                    </XStack>
                    {index < deliveryDemandList.length - 1 && (
                      <Separator marginVertical="$2" />
                    )}
                  </YStack>
                ))}
              </YStack>
            </Accordion.Content>
          </Accordion.Item>
        </Accordion>
      </YStack>
    );
  }
);
