import { useState } from "react";
import { PortalProvider, Sheet, XStack } from "tamagui";

/**
 * @description : 空白底部弹窗
 * @param {boolean} isOpen - 是否打开
 * @param {function} onClose - 关闭回调
 * @param {React.ReactNode} children - 子组件
 * @param {number[]} snapPoints - 弹窗高度
 * @param {number} zIndex - 弹窗层级
 * @param {number} position - 弹窗位置
 * @returns
 */
const BlankBottomSheet = ({
  isOpen,
  onClose,
  children = null as any,
  snapPoints = [40],
  zIndex = 100000,
  position = 0,
  ...props
}) => {
  const [currentPosition, setCurrentPosition] = useState(position);

  return (
    <PortalProvider shouldAddRootHost>
      <Sheet
        forceRemoveScrollEnabled
        modal
        open={isOpen}
        onOpenChange={(open) => onClose(open)}
        snapPoints={snapPoints}
        dismissOnSnapToBottom
        dismissOnOverlayPress
        position={currentPosition}
        onPositionChange={setCurrentPosition}
        zIndex={zIndex}
        animation="medium"
      >
        <Sheet.Overlay
          animation="lazy"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="rgba(0, 0, 0, 0.5)"
        />
        <Sheet.Frame
          padding="$4"
          alignItems="center"
          space="$5"
          backgroundColor="#fff"
        >
          <XStack
            flexDirection="row"
            width="100%"
            marginHorizontal={10}
            boxSizing="border-box"
          >
            {children}
          </XStack>
        </Sheet.Frame>
      </Sheet>
    </PortalProvider>
  );
};

export default BlankBottomSheet;
