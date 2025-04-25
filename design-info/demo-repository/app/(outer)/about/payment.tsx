import { AppDispatch, RootState, slices } from "@/src/store";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { H1, Paragraph, YStack, Text } from "tamagui";

export default function PrivacyContentPage() {
  const dispatch = useDispatch<AppDispatch>();
  const content = useSelector((state: RootState) => state?.sys?.content);

  useEffect(() => {
    dispatch(slices.sys.actions.fetchContent({ id: 3 }));
  }, []);

  return (
    <YStack flex={1} alignItems="center">
      <H1 fontSize={16}>{content?.payment?.title}</H1>
      <Text>{content?.payment?.content}</Text>
    </YStack>
  );
}
