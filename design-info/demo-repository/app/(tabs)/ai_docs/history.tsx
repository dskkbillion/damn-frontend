import { Search } from "@tamagui/lucide-icons";
import { Stack, useRouter } from "expo-router";
import { useEffect, useState } from "react";
import { FlatList, Pressable } from "react-native";
import { useSelector, useDispatch } from "react-redux";
import { YStack, XStack, Text, Input, styled, Theme, Button } from "tamagui";
import { ChevronLeft } from "@tamagui/lucide-icons";

import { AppDispatch, RootState, model } from "@/src/store";

// 历史记录项样式
const HistoryItem = styled(XStack, {
  padding: 16,
  borderBottomWidth: 1,
  borderBottomColor: "#EEEEEE",
  backgroundColor: "white",
});

export default function HistoryView() {
  const router = useRouter();
  const [searchText, setSearchText] = useState("");
  const dispatch = useDispatch<AppDispatch>();
  const userId = useSelector((state: RootState) => state.user.data.id);
  const changed = useSelector((state: RootState) => state.chatBot.changed);
  // 从 Redux 获取历史记录
  const chatHistory = useSelector((state: RootState) => state.chatBot.history);
  // 处理搜索
  const filteredHistory = (chatHistory || []).filter(
    (item) =>
      item?.title?.toLowerCase().includes(searchText.toLowerCase()) ?? false
  );

  // 返回聊天页面（保留此函数以备其他地方使用）
  const goBackToChat = () => {
    if (router.canGoBack()) {
      router.back();
    } else {
      router.push("/ai_docs/chat-view");
    }
  };

  // 加载聊天室
  useEffect(() => {
    if (userId && userId !== undefined) {
      dispatch(model.chatBot.actions.fectchChatRooms({ user_id: userId }));
    }
  }, [userId, changed]);

  return (
    <Theme name="light">
      <YStack flex={1} backgroundColor="#F8F8F8">
        <Stack.Screen
          options={{
            title: "历史记录",
            headerShadowVisible: false,
            headerStyle: {
              backgroundColor: "#FFF8F4",
            },
          }}
        />

        {/* 搜索框 */}
        <XStack
          padding="$4"
          backgroundColor="white"
          borderBottomWidth={1}
          borderBottomColor="#EEEEEE"
          alignItems="center"
        >
          <Search
            size={20}
            color="#999"
            style={{ position: "relative", left: 30, zIndex: 999 }}
          />
          <Input
            flex={1}
            placeholder="搜索"
            value={searchText}
            onChangeText={setSearchText}
            backgroundColor="#F5F5F5"
            borderWidth={0}
            borderRadius={8}
            paddingLeft={40}
            height={40}
          />
        </XStack>

        {/* 历史记录列表 */}
        <FlatList
          data={filteredHistory}
          keyExtractor={(item) =>
            item?.conversation_id?.toString() || `chat-${Date.now()}`
          }
          renderItem={({ item }) => (
            <Pressable
              onPress={() => {
                dispatch(
                  model.chatBot.actions.setConversationId(item?.conversation_id)
                );
                router.push({
                  pathname: "/ai_docs/chat-view",
                });
              }}
            >
              <HistoryItem>
                <YStack flex={1}>
                  <Text
                    fontSize={16}
                    color="#333"
                    numberOfLines={1}
                    ellipsizeMode="tail"
                  >
                    {item?.title || "未命名对话"}
                  </Text>
                  <Text fontSize={14} color="#999" marginTop={4}>
                    {new Date(item?.updated_at).toLocaleDateString()}
                  </Text>
                </YStack>
              </HistoryItem>
            </Pressable>
          )}
          showsVerticalScrollIndicator={false}
        />
      </YStack>
    </Theme>
  );
}
