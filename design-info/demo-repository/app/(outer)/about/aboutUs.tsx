import { ArrowRight } from "@tamagui/lucide-icons";
import { router } from "expo-router";
import { useEffect } from "react";
import { SvgXml } from "react-native-svg";
import { useDispatch, useSelector } from "react-redux";
import { Avatar, Button, Paragraph, YStack, styled } from "tamagui";

import { LOGO_XML_WITHOUT_BACKGROUND } from "@/constants/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export const fetchContent = async ({
  dispatch,
  id,
}: {
  dispatch: AppDispatch;
  id: number;
}) => {
  await dispatch(slices.sys.actions.fetchContent({ id: id }));
};

export default function AboutDSKKPage() {
  const dispatch = useDispatch<AppDispatch>();
  const content = useSelector((state: RootState) => state?.sys?.content);

  const StyledButton = styled(Button, {
    width: global.screenWidth,
    height: global.screenHeight * 0.05,
    flexDirection: "row",
    backgroundColor: "#fff",
    justifyContent: "space-between",
    alignItems: "center",
    color: "$darkGray",
  });

  useEffect(() => {
    fetchContent({ dispatch, id: 4 });
  }, []);

  return (
    <YStack flex={1}>
      <Avatar
        size="$6"
        borderRadius={10}
        marginTop="16s%"
        display="flex"
        flexDirection="row"
        alignSelf="center"
      >
        <Avatar.Fallback backgroundColor="$brown" />
        <SvgXml xml={LOGO_XML_WITHOUT_BACKGROUND} width={50} height={50} />
      </Avatar>
      <Paragraph alignSelf="center" marginTop="$3" color="$darktGray">
        多少看看
      </Paragraph>
      <Paragraph alignSelf="center" color="$darktGray">
        {content?.about?.content}
      </Paragraph>
      <StyledButton
        marginTop="$5"
        onPress={() => router.push("/about/privacy")}
      >
        <Paragraph>隐私协议</Paragraph>
        <ArrowRight size={15} />
      </StyledButton>
      <StyledButton onPress={() => router.push("/about/payment")}>
        <Paragraph>支付协议</Paragraph>
        <ArrowRight size={15} />
      </StyledButton>
    </YStack>
  );
}
