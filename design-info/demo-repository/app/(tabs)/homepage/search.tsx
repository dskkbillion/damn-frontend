import { router } from "expo-router";
import { debounce } from "lodash";
import { useCallback, useState, useMemo, useEffect } from "react";
import { TextInput, TouchableWithoutFeedback } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import AntDesignIcon from "react-native-vector-icons/AntDesign";
import IoniconsIcon from "react-native-vector-icons/Ionicons";
import { useDispatch, useSelector } from "react-redux";
import { Button, ButtonText, H2, Paragraph, XStack, YStack } from "tamagui";

import { isAxiosSuccess } from "@/components/utils";
import { AppDispatch, RootState, slices } from "@/src/store";

export default function SearchPage() {
  const hotKeys = useMemo(() => {
    try {
      const hotKeyWord = global.sysConfig?.system?.hotKeyWord;
      // 检查是否已经是数组
      if (Array.isArray(hotKeyWord)) {
        return hotKeyWord;
      }
      // 检查是否是有效的 JSON 字符串
      if (typeof hotKeyWord === "string" && hotKeyWord.trim()) {
        return JSON.parse(hotKeyWord) || [];
      }
      return [];
    } catch (error) {
      console.error("热搜词解析失败:", error);
      return [];
    }
  }, [global.sysConfig?.system?.hotKeyWord]);

  console.log("hotKeys", global.sysConfig?.system);

  const searchHistory = useSelector(
    (state: RootState) => state.user.searchHistory
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

  const [isSearching, setIsSearching] = useState(false);

  const handleSend = useCallback(
    async (search) => {
      if (!search.trim() || isSearching) {
        return;
      }

      setIsSearching(true);
      try {
        const params = {
          keyword: search.trim(),
        };

        const res = await dispatch(
          slices.item.actions.fetchSearchItemList(params)
        );
        console.log("res", res);

        if (isAxiosSuccess(res.type)) {
          dispatch(slices.user.actions.addSearchList(search.trim()));
          router.push({
            pathname: `/(tabs)/homepage/searchResult`,
            params: { search: encodeURIComponent(search.trim()) },
          });
        } else {
          alert("搜索失败，请重试");
        }
      } catch (e) {
        console.error("搜索出错:", e);
        alert("搜索出错，请重试");
      } finally {
        setIsSearching(false);
      }

      setSearch("");
    },
    [dispatch, isSearching]
  );

  const deleteSearchList = useCallback(() => {
    dispatch(slices.user.actions.deleteSearchList());
  }, [searchHistory]);

  const debouncedSearch = useMemo(
    () => debounce((value: string) => handleSend(value), 300),
    [handleSend]
  );

  // 在组件卸载时取消待执行的防抖函数
  useEffect(() => {
    return () => {
      debouncedSearch.cancel();
    };
  }, [debouncedSearch]);

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
              placeholder="猜你想搜..."
              placeholderTextColor="gray"
              value={search}
              onChangeText={setSearch}
              returnKeyLabel="search"
              onSubmitEditing={() => handleSend(search)}
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

        {/* 多少看看热搜榜 */}
        <H2 fontSize={13} marginHorizontal="4%">
          热搜榜
        </H2>
        <YStack marginHorizontal="4%">
          {/* <Paragraph>1. {hotKeys[0]}</Paragraph> */}
          {hotKeys &&
            hotKeys.map((item, index) => (
              <Button
                key={index}
                alignItems="center"
                height="auto"
                backgroundColor="transparent"
                onPress={() => hotKeysSearch(item)}
              >
                <H2 color="$brown" fontWeight="700" fontSize={14} width={20}>
                  {index + 1}
                </H2>
                <Paragraph color="$darkGray" fontSize={14}>
                  {item}
                </Paragraph>
              </Button>
            ))}
        </YStack>

        <XStack
          flexDirection="row"
          width="100%"
          justifyContent="space-between"
          alignItems="center"
          paddingHorizontal="4%"
        >
          <H2 fontSize={13}>搜索历史</H2>
          <TouchableWithoutFeedback onPress={deleteSearchList}>
            <XStack>
              <AntDesignIcon
                name="delete"
                fontSize="$3"
                style={{ marginLeft: "auto" }}
              />
            </XStack>
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
