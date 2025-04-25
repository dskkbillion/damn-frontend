import { memo } from "react";
import { Text } from "react-native";
import { Circle, XStack, YStack } from "tamagui";
import { QueryDict } from "../queryDict";
import { useGlobalContext } from "../system/globalContext";

export const DemandTimeLineComponent = memo(
  ({
    currentStatus,
    role,
    type,
  }: {
    currentStatus;
    role: "seller" | "buyer";
    type;
  }) => {
    let renderList = Array.from({ length: 4 }, (_, i) => i);
    let atTimeVal = 0;
    let titles = [] as any[];
    const contents = [] as any[];
    const { dictData } = useGlobalContext();

    switch (role) {
      case "seller":
        titles = [
          "买家申请" +
            "-" +
            QueryDict(dictData["order_request_type"], type)?.label,
          "等待您的处理",
          "您已同意买家的申请，请重新交付",
          "交付完成，等待买家确认",
        ];
        break;
      case "buyer":
        titles = [
          "您已申请" +
            "-" +
            QueryDict(dictData["order_request_type"], type)?.label,
          "等待卖家的处理",
          "卖家已同意您的申请，请耐心等待卖家重新交付",
          "交付完成，等待您的确认",
        ];
        break;
    }

    if (currentStatus === "SUCCESS") {
      atTimeVal = 2;
    } else if (currentStatus === "FAIL") {
      renderList = Array.from({ length: 3 }, (_, i) => i);
      atTimeVal = 2;
      titles[2] =
        role === "buyer" ? "卖家拒绝了您的申请" : "您已拒绝买家的申请";
    } else if (currentStatus === "WAITING") {
      atTimeVal = 1;
    } else if (currentStatus === "DELIVERED") {
      atTimeVal = 3;
    } else {
      atTimeVal = 1;
    }

    return (
      <YStack width="100%" height="100%">
        {renderList.map((item, index) => (
          <XStack key={index} flexDirection="row" width="100%">
            {/* 时间轴和圆点 */}
            <YStack
              alignItems="center"
              width={20}
              // height={atTimeVal === index ? 80 : index === 3 ? 20 : 40}
              height={index === 3 ? 20 : atTimeVal === index ? 80 : 40}
              marginTop={1.65}
              // backgroundColor="red"
            >
              {/* 圆点 */}
              <Circle
                size={15}
                backgroundColor={
                  atTimeVal === index
                    ? "#B66D0E"
                    : atTimeVal > index
                    ? "#fff"
                    : "gray"
                }
                borderWidth={atTimeVal > index ? 1 : 0}
                borderColor={atTimeVal > index ? "#B66D0E" : "transparent"}
              />
              {/* 竖线 */}
              {index !== renderList.length - 1 && (
                <YStack
                  width={2}
                  backgroundColor={atTimeVal >= index ? "$brown" : "$lightGray"}
                  flex={1}
                  style={{
                    height: atTimeVal === index ? "calc(100% + 5px)" : "100%", // 延长当前时间点下的竖线
                  }}
                />
              )}
            </YStack>
            {/* 时间轴标题 */}
            <YStack
              alignItems="flex-start"
              width="80%"
              marginLeft="$3"
              height={index === 3 ? 20 : atTimeVal === index ? 80 : 40}
            >
              <Text
                style={{
                  fontSize: 15,
                  // fontWeight: atTimeVal ? "bold" : "normal",
                  color:
                    atTimeVal === index
                      ? "#B66D0E"
                      : atTimeVal > index
                      ? "#000"
                      : "gray",
                }}
              >
                {titles[index]}
              </Text>
              {atTimeVal === index && (
                <Text
                  style={{
                    fontSize: 12,
                    color: "gray",
                    marginTop: 5,
                  }}
                >
                  {contents[index] ? contents[index] : null}
                </Text>
              )}
            </YStack>
          </XStack>
        ))}
      </YStack>
    );
  }
);
