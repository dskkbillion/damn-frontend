import { router } from "expo-router";
import { useCallback, useState } from "react";
import { TextInput, TouchableWithoutFeedback } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import IoniconsIcon from "react-native-vector-icons/Ionicons";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, H2, Paragraph, XStack, YStack } from "tamagui";

import { AppDispatch, RootState, slices } from "@/src/store";

export default function SearchPage() {
  const searchHistory = useSelector(
    (state: RootState) => state.orderList.searchHistory
  );
  const [search, setSearch] = useState("");
  const dispatch = useDispatch<AppDispatch>();

  const hotKeysSearch = useCallback(
    (key) => {
      setSearch(key);
      handleSend(key);
    },
    [search]
  );

  const handleSend = useCallback(
    async (search) => {
      if (!search.trim()) {
        return;
      }

      try {
        dispatch(
          slices.orderList.actions.addSearchList({
            searchItem: search,
            role: "buyer",
          })
        );
        router.push({
          pathname: `/(tabs)/profile/orders/searchOrderRes`,
          params: { search: search },
        });
      } catch (e) {
        console.log(e);
      }

      setSearch("");
    },
    [search, dispatch]
  );

  const deleteSearchList = useCallback(() => {
    dispatch(slices.orderList.actions.deleteSearchList({ role: "buyer" }));
  }, [searchHistory]);

  return (
    // 搜索栏
    <SafeAreaProvider>
      <YStack
        flexDirection="column"
        alignItems="flex-start"
        width="100%"
        height="15%"
        backgroundColor="$brown"
      >
        <XStack
          flexDirection="row"
          alignItems="center"
          marginTop="5%"
          marginLeft="$4"
          justifyContent="center"
          height="100%"
        >
          <XStack
            flexDirection="row"
            alignItems="center"
            backgroundColor="#ffffff"
            borderRadius={20}
            width="80%"
            height="30%"
          >
            <IoniconsIcon
              fontSize="$3"
              name="search"
              color="#A4A4A4"
              style={{
                marginLeft: 20,
              }}
            />
            <TextInput
              style={{
                flexDirection: "row",
                paddingHorizontal: 20,
                width: "100%",
              }}
              placeholder="搜索订单..."
              placeholderTextColor="gray"
              value={search}
              onChangeText={setSearch}
              returnKeyLabel="search"
              onSubmitEditing={() => handleSend(search)}
            />

            <AntDesignIcon
              name="camera"
              fontSize="$5"
              style={{ paddingHorizontal: 10, marginLeft: "auto" }}
            />
          </XStack>
          <Button
            flexDirection="row"
            marginLeft="auto"
            paddingLeft="$5"
            alignItems="center"
            justifyContent="center"
            color="#ffffff"
            onPress={
              search.trim() !== ""
                ? () => handleSend(search)
                : () => router.back()
            }
            unstyled
          >
            <ButtonText fontSize={16}>
              {search.trim() !== "" ? "搜索" : "取消"}
            </ButtonText>
          </Button>
        </XStack>

        <XStack
          flexDirection="row"
          width="100%"
          justifyContent="space-between"
          alignItems="center"
          paddingHorizontal="4%"
        >
          <H2 fontSize={13}>搜索历史</H2>
          <TouchableWithoutFeedback onPress={deleteSearchList}>
            <AntDesignIcon
              name="delete"
              fontSize="$3"
              style={{ marginLeft: "auto" }}
            />
          </TouchableWithoutFeedback>
        </XStack>
        <XStack paddingHorizontal="$3" flexWrap="wrap" gap="$2">
          {searchHistory &&
            searchHistory.map((item, index) => (
              <Button
                key={index}
                alignItems="center"
                height="auto"
                onPress={() => hotKeysSearch(item)}
                backgroundColor="$lightGray"
                borderRadius={10}
              >
                <Paragraph color="$darkGray" fontSize={14}>
                  {item}
                </Paragraph>
              </Button>
            ))}
        </XStack>
      </YStack>
    </SafeAreaProvider>
  );
}
