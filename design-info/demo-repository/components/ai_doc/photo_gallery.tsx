import { AnimatePresence } from "@tamagui/animate-presence";
import { ArrowLeft, ArrowRight } from "@tamagui/lucide-icons";
import { useState } from "react";
import { Button, Image, XStack, YStack, styled } from "tamagui";

const GalleryItem = styled(YStack, {
  zIndex: 1,
  x: 0,
  opacity: 1,
  fullscreen: true,
  variants: {
    // 1 = right, 0 = nowhere, -1 = left
    going: {
      ":number": (going) => ({
        enterStyle: {
          x: going > 0 ? 1000 : -1000,
          opacity: 0,
        },
        exitStyle: {
          zIndex: 0,
          x: going < 0 ? 1000 : -1000,
          opacity: 0,
        },
      }),
    },
  } as const,
});
const wrap = (min: number, max: number, v: number) => {
  const rangeSize = max - min;

  return ((((v - min) % rangeSize) + rangeSize) % rangeSize) + min;
};

//TODO: add gesture handler
export function PhotoGallery({ images }: { images: any }) {
  const [[page, going], setPage] = useState([0, 0]);
  const imageIndex = wrap(0, images.length, page);

  const paginate = (going: number) => {
    setPage([page + going, going]);
  };
  return (
    <XStack
      overflow="hidden"
      backgroundColor="#000"
      position="relative"
      height={300}
      width="100%"
      alignItems="center"
    >
      {/* TODO: make this work */}
      {/* <AnimatePresence initial={false} custom={{ going }}> */}
      {/* <GalleryItem key={page} animation="slowest" going={going}> */}
      <GalleryItem key={page}>
        <Image source={{ uri: images[imageIndex], width: 500, height: 300 }} />
      </GalleryItem>
      {/* </AnimatePresence> */}
      <Button
        accessibilityLabel="Carousel left"
        icon={ArrowLeft}
        size="$5"
        position="absolute"
        left="$4"
        circular
        elevate
        onPress={() => paginate(-1)}
        zIndex={100}
      />

      <Button
        accessibilityLabel="Carousel right"
        icon={ArrowRight}
        size="$5"
        position="absolute"
        right="$4"
        circular
        elevate
        onPress={() => paginate(1)}
        zIndex={100}
      />
    </XStack>
  );
}
