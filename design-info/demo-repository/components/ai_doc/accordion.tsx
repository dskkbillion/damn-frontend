import { MoreHorizontal } from "@tamagui/lucide-icons";
import { Link, router } from "expo-router";
import React, { Component } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
} from "react-native";
import Accordion from "react-native-collapsible/Accordion";
import {
  YStack,
  Theme,
  Avatar,
  XStack,
  H2,
  Paragraph,
  Button,
  ButtonText,
  Card,
  Image,
  Separator,
} from "tamagui";
import { Item } from "zeego/dropdown-menu";

import { PortraitInfo } from "@/constants/portrait";
import { userDataset } from "@/constants/users";

// 画像1中的profile

// 取字：如果第一个字为中文则返回，如果第一个字为英文则检测第二个字是否为英文
// 如果为英文则取第二个字，否则只返回一个字母
export const formatName = (str: string) => {
  if (/[\u4E00-\u9FA5]/.test(str.slice(0, 1))) {
    return str.slice(0, 1);
  } else {
    if (/^[A-Z]$/.test(str.slice(1, 2))) {
      return str.slice(0, 2);
    } else {
      return str.slice(0, 1);
    }
  }
};

type propType = {
  sections: PortraitInfo[];
};

interface AccordionView {
  props: propType;
}

class AccordionView extends Component {
  constructor(props) {
    super(props);
  }

  state = {
    activeSections: [],
  };

  _renderHeader = (section) => {
    return (
      <XStack
        flexDirection="row"
        paddingVertical="$3"
        paddingHorizontal="$5"
        marginHorizontal="$3"
        alignItems="center"
      >
        {/* 头像 */}
        <Avatar circular size="$5">
          <Avatar.Fallback backgroundColor="#0B3954" />
          <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
            {formatName(section.name)}
          </H2>
        </Avatar>
        {/* 画像名&画像描述 */}
        <XStack flexDirection="row" alignItems="center">
          <YStack paddingLeft="$3" minWidth={global.screenWidth * 0.7}>
            <Paragraph>{section.name}</Paragraph>
            <Paragraph theme="alt2">{section.description}</Paragraph>
          </YStack>
          {/* 添加画像按钮 */}
          <Button
            size="$2"
            backgroundColor="#transparent"
            pressStyle={{
              backgroundColor: "transparent",
              borderColor: "transparent",
            }}
            onPress={() => router.push(`/(tabs)/ai_docs/${section.id}/`)}
          >
            <MoreHorizontal fontSize={15} />
          </Button>
        </XStack>
      </XStack>
    );
  };

  _renderContent = (section) => {
    const internships = section.profile.interships;
    const applications = section.applications;
    const display_internships_suffix = internships.length > 2 ? "..." : ""; // 是否在末尾添加省略号
    const display_applications_suffix = applications.length > 3 ? "..." : ""; // 是否在末尾添加省略号
    let generating_num = 0;

    applications.map((item, index) => (generating_num += item.generating_num));

    return (
      <XStack
        flexDirection="row"
        paddingVertical="$2"
        paddingHorizontal="$5"
        marginHorizontal="$3"
        alignItems="center"
        backgroundColor="#F2F2F2"
      >
        <YStack marginHorizontal="$3" paddingLeft="$9">
          <XStack space="$2">
            {/* 显示实习信息 */}
            <Paragraph space="$2" ellipsizeMode="tail" numberOfLines={1}>
              实习经历:
              {internships.slice(0, 2).map((item, index) => (
                <XStack key={index}>
                  <Paragraph key={index}>
                    {index === 0
                      ? item.company
                      : item.company + display_internships_suffix}
                  </Paragraph>
                </XStack>
              ))}
            </Paragraph>
          </XStack>

          {/* 显示申请信息 */}
          <Paragraph space="$2" ellipsizeMode="tail" numberOfLines={1}>
            {applications.slice(0, 3).map((item, index) => (
              <XStack key={index}>
                <Paragraph>
                  {item.application_university} {item.application_majority} |
                </Paragraph>
                <Paragraph>
                  {index === 2 ? display_applications_suffix : ""}{" "}
                </Paragraph>
              </XStack>
            ))}
          </Paragraph>
          {/* 显示生成文书数量 */}
          <YStack>
            <Paragraph>生成文书 {generating_num}</Paragraph>
          </YStack>
        </YStack>
      </XStack>
    );
  };

  _updateSections = (activeSections) => {
    this.setState({ activeSections });
  };

  render() {
    // console.log(this.props.sections[0].profile)
    // console.log(this.props.sections[0].profile.gpa)
    return (
      <Accordion
        sections={this.props.sections}
        activeSections={this.state.activeSections}
        renderHeader={this._renderHeader}
        renderContent={this._renderContent}
        onChange={this._updateSections}
        underlayColor="transparent"
        touchableComponent={TouchableWithoutFeedback} // Use TouchableOpacity as the touchable component
      />
    );
  }
}

export default AccordionView;

// const AccordionItem = (index:number,openIndexes:number[],item) => {
//     const isOpen = openIndexes.includes(index); // index的according是否打开

//     const handleToggle = () => {
//       if (isOpen){
//         // 如果打开则关闭（返回不含index的数组）
//         setOpenIndexes(openIndexes.filter((i) => i != index));
//       }else{
//         // 如果没有打开，则打开（加入index）
//         setOpenIndexes([...openIndexes, index]);
//       }
//   };
//     return (
//       <View>
//           <TouchableOpacity onPress={handleToggle}>
//           <XStack key={index} marginLeft="$5" space="$2">
//           {/* 头像：中文取第一个字，英文取前两个字母 */}
//           <Avatar circular size="$5">
//             <Avatar.Image />
//             <Avatar.Fallback delayMs={600} backgroundColor="#0B3954" />
//             <H2 fontSize={20} style={{ color: "#FFFFFF" }}>
//               {formatName(item.name)}
//             </H2>
//           </Avatar>
//           {/*  */}
//           <YStack>
//             <Paragraph>{item.name}</Paragraph>
//             <Paragraph theme={'alt2'}>{item.description}</Paragraph>
//           </YStack>
//         </XStack>
//       </TouchableOpacity>
//       {isOpen && <Paragraph>{item.description}</Paragraph>}
//       </View>
//     );
//   };
