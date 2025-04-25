import { useState } from "react";
import { Text } from "react-native";
import FastImage from "react-native-fast-image";
import { Button, ButtonText, Paragraph, XStack, YStack } from "tamagui";

import { getFilePath } from "../utils/filesystem";
import { ItemFeaturesContent } from "../homepage/itemFeaturesContent";

const ServiceComponent = ({ item, isExpanded = true }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <>
      <XStack width="100%" flexDirection="row" alignItems="center">
        <FastImage
          source={{
            uri: getFilePath(item?.productImage),
            priority: FastImage.priority.normal,
          }}
          style={{
            width: global.screenHeight * 0.1,
            height: global.screenHeight * 0.1,
            marginRight: 10,
            borderRadius: 5,
            backgroundColor: "#EDEDED",
          }}
          resizeMode={FastImage.resizeMode.stretch}
        />
        {/* details of the service */}
        <YStack
          flexDirection="column"
          height={global.screenHeight * 0.1}
          width={global.screenWidth * 0.6}
          justifyContent="space-between"
        >
          <Text style={{ fontWeight: "800", fontSize: 15 }} numberOfLines={1}>
            {item?.productName}
          </Text>
          <Text style={{ fontWeight: "400", fontSize: 15 }} numberOfLines={1}>
            {item?.productInfo?.description}...
          </Text>
          <Text style={{ fontSize: 15, color: "gray" }}>
            {item?.variantName}
            {/* {replaceDictionary[service?.service_level!]} */}
          </Text>
          <XStack>
            <Paragraph color="$lightGray">交付时长</Paragraph>
            <Paragraph color="$lightGray">{item?.deliveryDay}</Paragraph>
            <XStack width={10} />
            <Paragraph color="$lightGray">修改次数</Paragraph>
            <Paragraph color="$lightGray">{item?.editNum}</Paragraph>
          </XStack>
        </YStack>
        {/* price of the service */}
        <YStack
          flexDirection="column"
          height={global.screenHeight * 0.1}
          width={global.screenWidth * 0.2}
        >
          <Paragraph style={{ fontSize: 17, fontWeight: "500" }}>
            ¥{item?.payPrice}
          </Paragraph>
          {isExpanded && (
            <Button
              height="auto"
              marginTop="auto"
              unstyled
              onPress={() => setExpanded(!expanded)}
            >
              <ButtonText color="$blue">
                {expanded ? "收起" : "展开"}
              </ButtonText>
            </Button>
          )}
        </YStack>
      </XStack>
      {expanded && (
        <ItemFeaturesContent
          variant={{
            feature: item?.feature,
            deliveryDay: item?.deliveryDay,
            editNum: item?.editNum,
          }}
        />
      )}
    </>
  );
};

export default ServiceComponent;
