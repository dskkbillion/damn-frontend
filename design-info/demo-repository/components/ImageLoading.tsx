import React from "react";
import { Image, ImageProps } from "react-native";
import { YStack, Text, Spinner } from "tamagui";

export function ImageWithLoading(props: ImageProps) {
  const [loading, setLoading] = React.useState(true);
  return (
    <YStack width={80} height={80} alignItems="center" justifyContent="center">
      <Image
        {...props}
        onLoad={() => setLoading(false)}
        onError={() => setLoading(false)}
      />
      {loading && <Spinner size="small" color="$green10" alignSelf="center" />}
    </YStack>
  );
}
