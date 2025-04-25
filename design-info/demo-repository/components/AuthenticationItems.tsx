import React from "react";
import { Text, XStack, Paragraph } from "tamagui";

// 渲染卖家认证
export function renderAuthenticationItems(
  maxRows: number,
  maxItemsPerRow: number,
  authentication_array: string[],
  renderAuthenticationStyle: (auth: string) => React.ReactNode,
) {
  const items: JSX.Element[] = [];

  for (let rowIndex = 0; rowIndex < maxRows; rowIndex++) {
    const startIdx = rowIndex * maxItemsPerRow;
    const endIdx = startIdx + maxItemsPerRow;
    const chunk = authentication_array.slice(startIdx, endIdx);
    const chunkElements = chunk.map((auth, i) => (
      <React.Fragment key={startIdx + i}>
        {renderAuthenticationStyle(auth)}
      </React.Fragment>
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
    // if (
    //   rowIndex === maxRows - 1 &&
    //   authentication_array.length > maxRows * maxItemsPerRow
    // ) {
    //   chunkElements.push(
    //     <XStack key="viewMore" flexDirection="row" alignItems="center">
    //       <Text>查看更多</Text>
    //     </XStack>
    //   );
    // }
    if (endIdx >= authentication_array.length) {
      break; // Stop if we have reached the end of the array
    }
  }
  return items;
}
