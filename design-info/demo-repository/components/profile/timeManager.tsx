// 定时关闭组件（暂时搁置）
// import { useCallback, useState } from "react";
// import { Text } from "react-native";
// import { Calendar, DateData, LocaleConfig } from "react-native-calendars";
// import { FlatList } from "react-native-gesture-handler";
// import {
//   Accordion,
//   H2,
//   Paragraph,
//   Switch,
//   XStack,
//   YStack,
// } from "tamagui";

// import { dateToString } from "@/components/time_processor";

// LocaleConfig.locales["zh"] = {
//   monthNames: [
//     "一月",
//     "二月",
//     "三月",
//     "四月",
//     "五月",
//     "六月",
//     "七月",
//     "八月",
//     "九月",
//     "十月",
//     "十一月",
//     "十二月",
//   ],
//   monthNamesShort: [
//     "一月",
//     "二月",
//     "三月",
//     "四月",
//     "五月",
//     "六月",
//     "七月",
//     "八月",
//     "九月",
//     "十月",
//     "十一月",
//     "十二月",
//   ],
//   dayNames: [
//     "星期日",
//     "星期一",
//     "星期二",
//     "星期三",
//     "星期四",
//     "星期五",
//     "星期六",
//   ],
//   dayNamesShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
//   today: "今天",
// };

// LocaleConfig.defaultLocale = "zh";

// export default function TimeManagementPage() {
//   const [isOnline, setIsOnline] = useState(true);
//   const [isAllDay, setIsAllDay] = useState(true);
//   const [selected, setSelected] = useState(""); //日历中被选择的日期
//   const [open, setOpen] = useState(false);
//   const [startDate, setStartDate] = useState("");
//   const current_date = new Date();
//   const year = current_date.getFullYear();
//   const month = current_date.getMonth() + 1;
//   const day = current_date.getDate();
//   const hour = current_date.getHours();
//   const min = current_date.getMinutes();

//   // 处理点击行为
//   const onDayPress = useCallback((day: DateData) => {
//     console.log("12121");
//     setSelected(day.dateString);
//   }, []);

//   const handleStartDatePress = useCallback((day: DateData) => {
//     console.log(day.dateString);
//     console.log("111");
//     setStartDate(day.dateString);
//   }, []);

//   const toggleOpen = () => setOpen(!open);

//   const renderItem = (item) => {
//     return (
//       <>
//         <XStack
//           flex={0}
//           width="90%"
//           marginVertical="4%"
//           paddingVertical="4%"
//           alignSelf="center"
//           paddingHorizontal="4%"
//           alignItems="center"
//           backgroundColor="$text"
//           borderRadius={10}
//         >
//           <Text
//             style={{ marginRight: "auto", fontSize: 16, fontWeight: "500" }}
//           >
//             当前状态
//           </Text>

//           <Text
//             style={{ paddingHorizontal: 5, color: isOnline ? "green" : "red" }}
//           >
//             {isOnline ? "在线" : "不在线"}
//           </Text>
//           <Switch
//             size="$3"
//             checked={isOnline}
//             onCheckedChange={() => {
//               setIsOnline(!isOnline);
//             }}
//             style={
//               isOnline
//                 ? { backgroundColor: "$green" }
//                 : { backgroundColor: "#A1A1A1" }
//             }
//           >
//             <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
//           </Switch>
//         </XStack>
//         {/* <Calendar
//           minDate={dateToString({ date: new Date(), separator: "-" })}
//           markedDates={{
//             [startDate]: { selected: true, selectedColor: "blue" },
//           }}
//           renderHeader={(date) => {
//             const year = dateToString({ date, separator: "-" })?.split("-")[0];
//             const month = dateToString({ date, separator: "-" })?.split("-")[1];
//             return (
//               <Paragraph>
//                 {" "}
//                 {year}-{month}
//               </Paragraph>
//             );
//           }}
//           style={{
//             margin: "4%",
//           }}
//           onDayPress={handleStartDatePress}
//         /> */}

//         <H2 marginHorizontal="6%" fontSize={20}>
//           设置定时关闭
//         </H2>
//         <XStack
//           flex={0}
//           width="90%"
//           marginVertical="4%"
//           paddingVertical="4%"
//           alignSelf="center"
//           paddingHorizontal="4%"
//           backgroundColor="$text"
//           borderRadius={10}
//         >
//           <YStack space="$3">
//             <XStack alignItems="center" width="100%">
//               <Text style={{ fontSize: 16, fontWeight: "500" }}>当前状态</Text>
//               <Switch
//                 size="$3"
//                 checked={isAllDay}
//                 onCheckedChange={() => {
//                   setIsAllDay(!isAllDay);
//                 }}
//                 style={
//                   isOnline
//                     ? { backgroundColor: "$green" }
//                     : { backgroundColor: "#A1A1A1" }
//                 }
//                 marginLeft="auto"
//               >
//                 <Switch.Thumb animation="bouncy" backgroundColor="#ffffff" />
//               </Switch>
//             </XStack>

//             {/* Accordion for choosing start and end date */}
//             <Accordion overflow="hidden" width="100%" type="multiple">
//               <Accordion.Item value="a1">
//                 <Accordion.Trigger
//                   flex={0}
//                   alignItems="center"
//                   onPress={toggleOpen}
//                   unstyled
//                 >
//                   <XStack alignItems="center" width="100%" space="$3">
//                     <Text style={{ fontSize: 16, fontWeight: "500" }}>
//                       开始
//                     </Text>
//                     <XStack
//                       backgroundColor="$lightGray"
//                       paddingVertical="$2"
//                       borderRadius={8}
//                       marginLeft="auto"
//                       width="30%"
//                       justifyContent="center"
//                     >
//                       <Text
//                         style={{
//                           fontSize: 16,
//                           fontWeight: "500",
//                         }}
//                       >
//                         {startDate ? startDate : `${year}-${month}-${day}`}
//                       </Text>
//                     </XStack>
//                     <XStack
//                       backgroundColor="$lightGray"
//                       paddingVertical="$2"
//                       paddingHorizontal="$3"
//                       borderRadius={8}
//                     >
//                       <Text style={{ fontSize: 16, fontWeight: "500" }}>
//                         {hour}:{min}
//                       </Text>
//                     </XStack>
//                   </XStack>
//                 </Accordion.Trigger>

//                 <Accordion.Content flex={0} unstyled>
//                   <Calendar
//                     minDate={dateToString({ date: new Date(), separator: "-" })}
//                     markedDates={{
//                       [startDate]: { selected: true, selectedColor: "blue" },
//                     }}
//                     renderHeader={(date) => {
//                       const year = dateToString({
//                         date,
//                         separator: "-",
//                       })?.split("-")[0];
//                       const month = dateToString({
//                         date,
//                         separator: "-",
//                       })?.split("-")[1];
//                       return (
//                         <Paragraph>
//                           {" "}
//                           {year}-{month}
//                         </Paragraph>
//                       );
//                     }}
//                     onDayPress={handleStartDatePress}
//                   />
//                 </Accordion.Content>
//               </Accordion.Item>
//             </Accordion>

//             <XStack alignItems="center" width="100%" space="$3">
//               <Text style={{ fontSize: 16, fontWeight: "500" }}>结束</Text>
//               <XStack
//                 backgroundColor="$lightGray"
//                 paddingVertical="$2"
//                 borderRadius={8}
//                 marginLeft="auto"
//               >
//                 <Text style={{ fontSize: 16, fontWeight: "500" }}>
//                   {year}年{month}月{day}日
//                 </Text>
//               </XStack>
//               <XStack
//                 backgroundColor="$lightGray"
//                 paddingVertical="$2"
//                 paddingHorizontal="$3"
//                 borderRadius={8}
//               >
//                 <Text style={{ fontSize: 16, fontWeight: "500" }}>
//                   {hour}:{min}
//                 </Text>
//               </XStack>
//             </XStack>
//             <XStack alignItems="center" width="100%">
//               <Text style={{ fontSize: 16, fontWeight: "500" }}>重复</Text>
//             </XStack>
//           </YStack>
//         </XStack>
//       </>
//     );
//   };

//   return (
//     <FlatList
//       data={[0]}
//       keyExtractor={(item) => String(item)}
//       renderItem={renderItem}
//     />
//   );
// }

// // const Accordion = ({children}) => {
// //   const [open,setOpen] = useState(false);

// //   const toggleOpen = () => setOpen(!open)

// //   return (
// //     <>
// //     {children({open,toggleOpen})}
// //     </>
// //   )
// // }
