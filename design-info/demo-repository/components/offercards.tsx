import { Dimensions } from "react-native";
import Icon from "react-native-vector-icons/Ionicons";
import {
  ScrollView,
  YStack,
  Button,
  Card,
  CardProps,
  H2,
  Image,
  Paragraph,
  XStack,
  Avatar,
  Text,
} from "tamagui";

import { AdmissionInfo, AdmissionList } from "@/constants/offer-list";

// 创建offer卡

const screenWidth = Dimensions.get("window").width;

export function OfferCards() {
  const cardStyle: CardProps = {
    height: "$12",
    width: Math.floor((screenWidth - 26) / 2.8),
    bordered: true,
  };

  return (
    <>
      <>
        <>
          <H2 fontSize={20}>多看Offer榜</H2>
        </>
        <ScrollView
          horizontal
          pagingEnabled
          showsHorizontalScrollIndicator={false}
          style={{ flexDirection: "row" }}
        >
          <XStack $sm={{ flexDirection: "row" }} space="$2">
            {AdmissionList.map((admissionItem, index) => (
              <DemoCard
                key={index}
                cardProps={cardStyle}
                admissionInfo={admissionItem}
              />
            ))}
          </XStack>
        </ScrollView>
      </>
      <Paragraph theme="alt2" fontSize={10} textAlign="center">
        下拉进行刷新
      </Paragraph>
    </>
  );
}

export function DemoCard({
  cardProps,
  admissionInfo,
}: {
  cardProps: CardProps;
  admissionInfo: AdmissionInfo;
}) {
  return (
    <Card size={1} {...cardProps} paddingHorizontal="$2" bordered={0}>
      <YStack padding="$2">
        <XStack alignSelf="center" padding="$2">
          <Text
            numberOfLines={1}
            ellipsizeMode="tail"
            style={{
              maxWidth: "100%",
              overflow: "hidden",
              fontSize: 12,
              fontWeight: 500,
            }}
          >
            {admissionInfo.PreviousInstitutions}
          </Text>
        </XStack>
        <XStack alignSelf="center">
          <Avatar circular size="$3">
            <Avatar.Image src={admissionInfo.UserAvatar} />
          </Avatar>
        </XStack>
      </YStack>

      {/* <XStack flexDirection='row' alignItems='center' position='absolute' >
            <Avatar circular size="$3" >
                <Avatar.Image src={admissionInfo.UserAvatar}/>
            </Avatar>
            <XStack paddingLeft ='$3' flex={1} alignItems='center'>
                <Text marginRight='$2'>•</Text> 
                <Paragraph fontSize={12} >{admissionInfo.PreviousInstitutions}</Paragraph>
            </XStack>
        </XStack> */}

      <YStack marginTop="$1" alignItems="center">
        <Text fontSize={13}>{admissionInfo.AdmissionInstitution}</Text>
        <Text fontSize={12} padding="$2">
          {admissionInfo.Major}
        </Text>
      </YStack>

      <Card.Footer>
        <Paragraph theme="alt2" fontSize={8} marginLeft="auto">
          {admissionInfo.UpdateTime}
        </Paragraph>
      </Card.Footer>

      <Card.Background>{/* Card background content */}</Card.Background>
    </Card>
  );
}
