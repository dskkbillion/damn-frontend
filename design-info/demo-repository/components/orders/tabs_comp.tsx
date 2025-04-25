import { memo, useState } from "react";
import {
  Button,
  ButtonText,
  Paragraph,
  SizableText,
  Tabs,
  TabsContentProps,
  XStack,
  YStack,
} from "tamagui";
import { getFilePath } from "../utils/filesystem";

const TabsComponent = ({ tab1Content, tab2Content }) => {
  const [selectedVal, setSelectedVal] = useState("tab1");
  return (
    <Tabs
      size="$3"
      value={selectedVal}
      onValueChange={(val) => setSelectedVal(val)}
      orientation="horizontal"
      flexDirection="column"
      width="100%"
      borderRadius="$2"
    >
      <Tabs.List width="100%" aria-label="Manage your account">
        <Tabs.Tab
          flex={1}
          value="tab1"
          backgroundColor={selectedVal === "tab1" ? "#2F2F2F" : "#EDEDED"}
        >
          <SizableText
            fontFamily="$body"
            color={selectedVal === "tab1" ? "#fff" : "#000"}
          >
            文本
          </SizableText>
        </Tabs.Tab>
        <Tabs.Tab
          flex={1}
          value="tab2"
          backgroundColor={selectedVal === "tab2" ? "#2F2F2F" : "#EDEDED"}
        >
          <SizableText
            fontFamily="$body"
            color={selectedVal === "tab2" ? "#fff" : "#000"}
          >
            附件
          </SizableText>
        </Tabs.Tab>
      </Tabs.List>
      <TabsContent value="tab1">{tab1Content}</TabsContent>

      <TabsContent value="tab2">{tab2Content}</TabsContent>
    </Tabs>
  );
};

const TabsContent = (props: TabsContentProps) => {
  return (
    <Tabs.Content
      backgroundColor="#EDEDED"
      key="tab3"
      marginTop="$3"
      flex={1}
      borderColor="$background"
      borderRadius="$2"
      {...props}
    >
      {props.children}
    </Tabs.Content>
  );
};

// Tabs for text content (show question and answer without memorizing)
export const TabTextContent = memo(({ textMaterial }: { textMaterial }) => {
  return (
    <YStack>
      {textMaterial &&
        textMaterial.map((item, index) => (
          <YStack key={index}>
            <Paragraph marginBottom="$2">
              {index + 1}. {item?.question}
            </Paragraph>
            <Paragraph>{item?.answer}</Paragraph>
          </YStack>
        ))}
    </YStack>
  );
});

// Tabs for file content (show file name)
export const TabFileContent = memo(
  ({
    filesMaterial,
    setPreviewPopup,
    setPreviewUri,
  }: {
    filesMaterial: any;
    setPreviewPopup?: any;
    setPreviewUri?: any;
  }) => {
    const previewFile = (uri) => {
      setPreviewUri(uri);
      setPreviewPopup(true);
    };
    return (
      <YStack flex={1} backgroundColor="#fff" gap="$2">
        {Array.isArray(filesMaterial) && filesMaterial.length > 0 ? (
          filesMaterial.map((item, index) => (
            <XStack
              key={index}
              alignItems="center"
              justifyContent="space-between"
            >
              <Button
                key={index}
                paddingVertical="$3"
                paddingHorizontal="$2"
                width="80%"
                backgroundColor="#EDEDED"
                flex={0}
                borderRadius="$2"
                onPress={() => previewFile(getFilePath(item))}
                unstyled
              >
                <Paragraph ellipsizeMode="tail" numberOfLines={1}>
                  {item}
                </Paragraph>
              </Button>
              {/* 预览按钮 */}
              <Button
                unstyled
                paddingHorizontal="$3"
                height="auto"
                onPress={() => previewFile(getFilePath(item))}
              >
                <ButtonText color="$blue">预览</ButtonText>
              </Button>
            </XStack>
          ))
        ) : (
          <Paragraph alignSelf="center" color="$darkGray">
            暂无文件
          </Paragraph>
        )}
      </YStack>
    );
  }
);

export default TabsComponent;
