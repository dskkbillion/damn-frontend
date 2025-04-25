import React from "react";
import Icon from "react-native-vector-icons/AntDesign";
import { YStack, XStack, Paragraph } from "tamagui";

// 商品规格（服务）的展示
export const ItemFeaturesContent = ({ variant }: { variant: any }) => {
  if (!variant) {
    return null;
  }
  const features = variant?.feature;
  const deliveryDay = variant?.deliveryDay;
  const editNum = variant?.editNum;

  return (
    <XStack
      flexDirection="row"
      marginTop="$1"
      alignItems="center"
      marginHorizontal={18}
    >
      {/* 左侧条目 */}
      <YStack flexDirection="column" space="$1" alignItems="center">
        {features.map((feature, index) => (
          <Paragraph key={index} color="$darkGray">
            {feature?.key}
          </Paragraph>
        ))}

        <Paragraph color="$darkGray">交付次数</Paragraph>
        <Paragraph color="$darkGray">交付周期</Paragraph>
      </YStack>

      <YStack
        flexDirection="column"
        space="$1"
        marginLeft="auto"
        alignItems="center"
      >
        {features.map((feature, index) => {
          return (
            <Paragraph key={index}>
              {feature?.type === "input" ? (
                feature?.val
              ) : (
                <Icon
                  name="check"
                  size={20}
                  color={feature?.val ? "green" : "gray"}
                />
              )}
            </Paragraph>
          );
        })}
        <Paragraph>{editNum}</Paragraph>
        <Paragraph>{deliveryDay}</Paragraph>
      </YStack>
    </XStack>
  );
};
