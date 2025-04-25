import { Text } from "react-native";
import { Calendar, LocaleConfig } from "react-native-calendars";
import { Paragraph, XStack } from "tamagui";

import { dateToString } from "@/components/time_processor";

LocaleConfig.locales["zh"] = {
  monthNames: [
    "一月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月",
  ],
  monthNamesShort: [
    "一月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月",
  ],
  dayNames: [
    "星期日",
    "星期一",
    "星期二",
    "星期三",
    "星期四",
    "星期五",
    "星期六",
  ],
  dayNamesShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
  today: "今天",
};

LocaleConfig.defaultLocale = "zh";

export default function TimeManagementPage() {
  return (
    <>
      <Calendar
        minDate={dateToString({ date: new Date(), separator: "-" })}
        // markingType={'period'}
        markedDates={{
          "2024-01-30": { selected: true, marked: true, selectedColor: "blue" },
        }}
        renderHeader={(date) => {
          const year = dateToString({ date, separator: "-" })?.split("-")[0];
          const month = dateToString({ date, separator: "-" })?.split("-")[1];
          return (
            <Paragraph>
              {" "}
              {year}-{month}
            </Paragraph>
          );
        }}
        style={{
          margin: "4%",
        }}
      />

      <XStack
        flexDirection="row"
        justifyContent="space-between"
        backgroundColor="$background"
        padding="$3"
        alignItems="center"
        borderRadius={10}
        marginTop="8%"
      >
        <Text>2024年2月5-13日</Text>
        <Text>已满</Text>
      </XStack>
    </>
  );
}
