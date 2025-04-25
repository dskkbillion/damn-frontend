// 底部导航栏
import {
  Home,
  MessageCircle,
  Sparkles,
  UserCircle,
} from "@tamagui/lucide-icons";
import { Tabs, useSegments } from "expo-router";

import { useEffect, useState } from "react";

export const unstable_settings = {
  // Ensure any route can link back to `/`
  initialRouteName: "index",
};

export default function TabLayout() {
  const [segment, setSegment] = useState("");
  const segments = useSegments();
  // console.log('screen',globalParams.screen)

  useEffect(() => {
    if (segments.length > 0) {
      setSegment(segments[segments.length - 1]);
    }
  }, [segments]);

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: "#B66D0F",
        tabBarStyle: {
          backgroundColor: "#ffffff",
          // 其他样式...
        },
      }}

      // // backBehavior="history"
      // // initialRouteName="homepage"
      // initialRouteName="ai_docs/chat-view"
    >
      <Tabs.Screen
        name="ai_docs"
        options={{
          title: "多少看看",
          headerShown: false,
          tabBarIcon: ({ color }) => <Sparkles color={color} />,
        }}
      />
      <Tabs.Screen
        name="homepage"
        options={{
          title: "主页",
          headerTitle: "",
          tabBarStyle: {
            display: segment !== "homepage" ? "none" : "flex",

            position: "absolute",
            left: 0,
            bottom: 0,
          },
          headerShown: false,
          tabBarIcon: ({ color }) => <Home color={color} />,
        }}
      />
      <Tabs.Screen
        name="chat"
        options={{
          title: "消息",
          headerShown: true,
          tabBarStyle: {
            display: segment === "chat" ? "flex" : "none",
            position: "absolute",
            left: 0,
            bottom: 0,
          },
          tabBarIcon: ({ color }) => <MessageCircle color={color} />,
        }}
      />

      <Tabs.Screen
        name="profile"
        options={{
          title: "我的",
          headerShown: false,
          tabBarStyle: {
            display: segment === "profile" ? "flex" : "none",
            position: "absolute",
            left: 0,
            bottom: 0,
          },
          tabBarIcon: ({ color }) => <UserCircle color={color} />,
        }}
      />
    </Tabs>
  );
}
