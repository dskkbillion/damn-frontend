// import { ChevronDown } from "@tamagui/lucide-icons";
// import { memo } from "react";
// import { Accordion, Paragraph, Square } from "tamagui";

// import TabsComponent from "./tabs_comp";

// // 商品详情页的组件（不包括材料和交付申请）

// /**
//  * @description: 展示买家提交的组件(用于detail详情页)
//  * @param
//  * @returns
//  */
// export const SubmissionDetail = memo(
//   ({
//     role,
//     length,
//     item,
//     index,
//     tab1Content,
//     tab2Content,
//   }: {
//     role;
//     length;
//     item;
//     index;
//     tab1Content;
//     tab2Content;
//   }) => {
//     return (
//       <Accordion
//         flexDirection="column"
//         overflow="visible"
//         width="100%"
//         type="multiple"
//         defaultValue={[(length - 1).toString()]}
//       >
//         <Accordion.Item key={item} value={item.toString()}>
//           <Accordion.Trigger flexDirection="row" justifyContent="space-between">
//             {({ open }: { open: boolean }) => (
//               <>
//                 <Paragraph>
//                   {role === "seller" ? "买家提交" : "你的提交"}
//                   <Paragraph>#{index + 1}</Paragraph>
//                 </Paragraph>
//                 <Square animation="quick" rotate={open ? "180deg" : "0deg"}>
//                   <ChevronDown size="$1" />
//                 </Square>
//               </>
//             )}
//           </Accordion.Trigger>
//           <Accordion.Content>
//             <TabsComponent
//               tab1Content={tab1Content}
//               tab2Content={tab2Content}
//             />
//             {item === length - 1 && <>{/* 此处显示卖家的申请 */}</>}
//           </Accordion.Content>
//         </Accordion.Item>
//       </Accordion>
//     );
//   }
// );
