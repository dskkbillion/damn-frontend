import { useState } from "react";
import EntypoIcon from "react-native-vector-icons/Entypo";
import { ActivityIndicator } from "react-native";
import { Button, Paragraph, XStack, YStack } from "tamagui";

import { downloadAndSaveFile } from "../utils/filesystem";

// --------------文件下载-------------
export const FileDownloader = ({ url, fileName }) => {
  const [isLoading, setIsLoading] = useState(false);

  const handleDownload = async () => {
    setIsLoading(true);
    try {
      await downloadAndSaveFile(url);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <YStack>
      <Button height="auto" onPress={handleDownload} disabled={isLoading}>
        <XStack>
          {isLoading ? (
            <ActivityIndicator size="small" color="black" />
          ) : (
            <Paragraph color="$blue">下载</Paragraph>
          )}
        </XStack>
      </Button>
    </YStack>
  );
};
