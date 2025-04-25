import {
  createContext,
  useRef,
  useContext,
  useMemo,
  useCallback,
  useState,
  useEffect,
} from "react";
import { H2, Sheet, YStack } from "tamagui";

import ServiceWaterFall from "../homepage/waterfallLayout";
import { fake_services, generateData, service } from "@/constants/services";

function getCategoryId(search: string): 0 | 1 | 2 | 3 | 4 {
  if (search.includes("题")) {
    return 2;
  } else if (
    ["吧台", "酒吧", "酒桌", "餐厅", "玄关", "入门"].some((keyword) =>
      search.includes(keyword)
    )
  ) {
    return 3;
  } else if (
    ["鼓浪屿", "旅游", "厦门"].some((keyword) => search.includes(keyword))
  ) {
    return 4;
  } else if (["文书", "留学"].some((keywords) => search.includes(keywords))) {
    return 1;
  } else {
    return 0;
  }
}

export interface ChatMessage {
  text?: string;
  //
  file?: string;
  // image urls
  images?: string[];

  routeTo?: string;
}

const BottomSheetContext = createContext({
  presented: false,
  searchParam: {},
  handlePresentModal: (snap = 0) => {},
  handleDismissModal: () => {},
  handleSnapChange: (index) => {},
  setSearchParam: (param: ChatMessage) => {},
});

export const BottomSheetProvider = ({ children }) => {
  const [presented, setPresented] = useState(false);
  const [searchParam, setSearchParam] = useState<ChatMessage>({});
  const [position, setPosition] = useState<number>(0); // 默认打开到 60%

  const handlePresentModal = useCallback((snap = 0) => {
    setPresented(true);
    setPosition(snap === 0 ? 0 : 1);
  }, []);

  const handleDismissModal = useCallback(() => {
    setPresented(false);
  }, []);

  const handleSnapChange = useCallback((pos: number) => {
    setPosition(pos);
  }, []);

  const contextValue = useMemo(
    () => ({
      presented,
      searchParam,
      handlePresentModal,
      handleDismissModal,
      handleSnapChange,
      setSearchParam,
    }),
    [
      presented,
      searchParam,
      handlePresentModal,
      handleDismissModal,
      handleSnapChange,
      setSearchParam,
    ]
  );

  return (
    <BottomSheetContext.Provider value={contextValue}>
      {children}
      <Sheet
        modal
        open={presented}
        onOpenChange={setPresented}
        snapPoints={[80, 60]}
        position={position}
        onPositionChange={setPosition}
        dismissOnSnapToBottom
        zIndex={100000}
        // snapPointsMode="per"
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
          borderTopLeftRadius="$4"
          borderTopRightRadius="$4"
          space="$5"
          flex={1}
          overflow="hidden"
          backgroundColor="$ai_bottom_sheet_bg"
        >
          <Sheet.Handle />
          <YStack gap="$2" flex={1} overflow="hidden">
            <H2 fontSize={18} alignSelf="center">推荐服务</H2>
            <YStack flex={1} overflow="hidden">
              <ServiceWaterFall
                showListHeaderComponent={false}
                itemVisiblePercentThreshold={70}
                source="home"
                priceAlignLeft={true}
              />
            </YStack>
          </YStack>
        </Sheet.Frame>
      </Sheet>
    </BottomSheetContext.Provider>
  );
};

export const useBottomSheet = () => useContext(BottomSheetContext);
