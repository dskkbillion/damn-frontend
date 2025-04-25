import { Stack, useLocalSearchParams } from "expo-router";
import React from "react";

import headerComponent from "@/components/headerShown";
import { QueryDict } from "@/components/queryDict";
import { useGlobalContext } from "@/components/system/globalContext";

/**
 * @description: 认证页面布局
 * @returns {JSX.Element}
 */
export default function AuthApplicationLayout() {
  const params = useLocalSearchParams();
  const applicationString: string = params.application as string;
  const { dictData } = useGlobalContext();

  console.log("applicationString", applicationString);
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{
          headerShown: true,
          headerTitle: "",
          header: () =>
            headerComponent({
              title: QueryDict(
                dictData["authentication_type"],
                applicationString
              ).label,
              canBack: true,
            }),
        }}
      />
    </Stack>
  );
}
