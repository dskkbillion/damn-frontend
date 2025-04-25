import { MoreHorizontal } from "@tamagui/lucide-icons";
import React from "react";
import { Button, ButtonText, XStack, YStack } from "tamagui";

// 认证： 一行最多渲染三个，最多渲染两行
export default function renderApplicationItem({
  maxRows,
  maxItemsPerRow,
  renderObjects,
  renderContent,
  ...props
}) {
  const items: JSX.Element[] = [];

  for (let rowIndex = 0; rowIndex < maxRows; rowIndex++) {
    const startIdx = rowIndex * maxItemsPerRow;
    const endIdx = startIdx + maxItemsPerRow;
    const chunk = renderObjects.slice(startIdx, endIdx);
    const chunkElements = chunk.map((object, index) => (
      <React.Fragment key={index}>{renderContent(object)}</React.Fragment>
    ));
    items.push(
      <XStack
        key={rowIndex}
        style={{ flexDirection: "column", alignItems: "center" }}
      >
        {chunkElements}
      </XStack>,
    );
    // 如果是最后一行，且有查看更多的元素，将其放在第二列末尾
    if (
      rowIndex === maxRows - 1 &&
      renderObjects.length > maxRows * maxItemsPerRow
    ) {
      items.push(
        <YStack flexDirection="column" alignItems="center">
          <MoreHorizontal size="$1" color="#ffffff" />
        </YStack>,
      );
    }
    if (endIdx >= renderObjects.length) {
      break; // Stop if we have reached the end of the array
    }
  }
  return items;
}
