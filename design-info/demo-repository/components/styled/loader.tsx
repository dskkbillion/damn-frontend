import { memo } from "react";
import { ActivityIndicator } from "react-native";
import { Portal, YStack, styled } from "tamagui";

const LoaderContainer = styled(YStack, {
  flex: 1,
  justifyContent: "center",
  alignItems: "center",
  backgroundColor: "transparent",
  position: "absolute",
  zIndex: 999,
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
});

const Loader = memo(({ loading }: { loading: boolean }) => {
  return (
    <Portal>
      {loading && (
        <LoaderContainer>
          <ActivityIndicator size="large" color="$brown" animating={loading} />
        </LoaderContainer>
      )}
    </Portal>
  );
});

export default Loader;
