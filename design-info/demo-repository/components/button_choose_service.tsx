import React, { useContext, useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { Input, YStack, Button, XStack, ButtonText, useTheme } from "tamagui";

// import { ItemPostContext } from "@/app/(sellerscreens)/post/[id]/itemEdit";
import { ItemPostContext } from "@/app/(sellerscreens)/post/[id]/itemEdit";
import { RootState } from "@/src/store";

// enableEdit: 编辑模式
// disableEdit：阅览模式
// newEdit：添加模式
const ButtonWithText = ({
  status,
  onValueChange,
  children,
}: {
  status: "enableEdit" | "disableEdit" | "newEdit";
  onValueChange;
  children: React.ReactNode;
}) => {
  const theme = useTheme();
  const [selectedButton, setSelectedButton] = useState<string>("bsc");
  const { prices, setPrices } = useContext(ItemPostContext);
  const ItemDetail = useSelector((state: RootState) => state.item.ItemDetail);
  const [savedPrices, setSavedPrices] = useState<{
    bsc: string;
    std: string;
    prem: string;
  }>({
    bsc: "",
    std: "",
    prem: "",
  });

  const handlePress = (type: string) => () => {
    setSelectedButton(type);
    onValueChange(type);
  };

  useEffect(() => {
    if (ItemDetail?.variants) {
      setSavedPrices({
        bsc: ItemDetail?.variants[0]?.sellingPrice
          ? String(ItemDetail?.variants[0]?.sellingPrice)
          : "",
        std: ItemDetail?.variants[1]?.sellingPrice
          ? String(ItemDetail?.variants[1]?.sellingPrice)
          : "",
        prem: ItemDetail?.variants[2]?.sellingPrice
          ? String(ItemDetail?.variants[2]?.sellingPrice)
          : "",
      });
    }
  }, [ItemDetail]);

  useEffect(() => {
    if (status !== "disableEdit") {
      setPrices({
        bsc: savedPrices?.bsc,
        std: savedPrices?.std,
        prem: savedPrices?.prem,
      });
    }
  }, [savedPrices]);

  return (
    <YStack>
      <XStack
        flexDirection="row"
        backgroundColor="white"
        justifyContent="center"
        paddingHorizontal="$7"
        marginBottom="$3"
      >
        {/* button of basic  */}
        <Button
          width={global.screenWidth / 3.3}
          size="$4"
          backgroundColor="white"
          borderBottomColor={
            selectedButton === "bsc" ? "#B66D0E" : "transparent"
          }
          borderBottomWidth="$1"
          borderRadius={0}
          onPress={handlePress("bsc")}
        >
          {status === "disableEdit" ? (
            <ButtonText
              fontSize={17}
              color={selectedButton === "bsc" ? "#B66D0E" : "gray"}
              fontWeight="600"
            >
              {savedPrices?.bsc}
            </ButtonText>
          ) : (
            <Input
              placeholder="基础金额"
              value={prices?.bsc}
              style={{
                fontWeight: "700",
                fontSize: 16,
                color: "#B66D0E",
              }}
              onChangeText={(text: string) =>
                setPrices({ ...prices, bsc: text })
              }
              unstyled
            />
          )}
        </Button>

        {/* button of standard  */}
        <Button
          size="$4"
          width={global.screenWidth / 3.3}
          backgroundColor="white"
          borderBottomWidth="$1"
          borderBottomColor={
            selectedButton === "std" ? "#B66D0E" : "transparent"
          }
          borderRadius={0}
          onPress={handlePress("std")}
        >
          {status === "disableEdit" ? (
            <ButtonText
              fontSize={17}
              color={selectedButton === "std" ? "#B66D0E" : "gray"}
              fontWeight="600"
            >
              {savedPrices?.std}
            </ButtonText>
          ) : (
            <Input
              placeholder="进阶金额"
              value={prices?.std}
              style={{
                fontWeight: "700",
                fontSize: 16,
                color: "#B66D0E",
              }}
              onChangeText={(text: string) =>
                setPrices({ ...prices, std: text })
              }
              unstyled
            />
          )}
        </Button>

        {/* button of premium */}
        <Button
          size="$4"
          width={global.screenWidth / 3.3}
          backgroundColor="white"
          borderBottomWidth="$1"
          borderBottomColor={
            selectedButton === "prem" ? "#B66D0E" : "transparent"
          }
          borderRadius={0}
          onPress={handlePress("prem")}
        >
          {status === "disableEdit" ? (
            <ButtonText
              fontSize={17}
              color={selectedButton === "prem" ? "#B66D0E" : "gray"}
              fontWeight="600"
            >
              {savedPrices?.prem}
            </ButtonText>
          ) : (
            <Input
              placeholder="豪华金额"
              value={prices?.prem}
              style={{
                fontWeight: "700",
                fontSize: 16,
                color: "#B66D0E",
              }}
              onChangeText={(text: string) =>
                setPrices({ ...prices, prem: text })
              }
              unstyled
            />
          )}
        </Button>
      </XStack>
      {children}
    </YStack>
  );
};

export default ButtonWithText;
