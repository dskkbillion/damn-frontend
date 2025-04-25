import { Languages } from "@tamagui/lucide-icons";
import { useState } from "react";
import { View } from "react-native";
import {
  YStack,
  Button,
  ButtonText,
  Input,
  Text,
  XStack,
  Popover,
  Adapt,
  PopoverProps,
  SelectProps,
} from "tamagui";

import { GeneralSelect } from "../select-country-code";
export interface Addition {
  name: string;
  achievement: string;
}

export interface Work {
  companyName: string;
  position: string;
  startDate: string;
  endDate: string;
  responsibilities: string;
}

export interface Language {
  name: "托福" | "雅思" | "GRE" | "DUOLINGO";
  score: number;
}

// export function GradeTypeDropdown() {
//   return (
//     <DropdownMenu.Root>
//       <DropdownMenu.Trigger>
//         <Button
//           width="50%"
//           height="$sm"
//           display="flex"
//           gap="$0"
//           justifyContent="flex-start"
//           pressStyle={{
//             backgroundColor: "transparent",
//             borderColor: "transparent",
//           }}
//         >
//           <ButtonText color="$gray10">成绩类型</ButtonText>
//         </Button>
//       </DropdownMenu.Trigger>
//       <DropdownMenu.Content>
//         <DropdownMenu.Item key="百分制">
//           <DropdownMenu.ItemTitle>百分制</DropdownMenu.ItemTitle>
//         </DropdownMenu.Item>
//         <DropdownMenu.Item key="4分制">
//           <DropdownMenu.ItemTitle>4分制</DropdownMenu.ItemTitle>
//         </DropdownMenu.Item>
//         <DropdownMenu.Item key="5分制">
//           <DropdownMenu.ItemTitle>5分制</DropdownMenu.ItemTitle>
//         </DropdownMenu.Item>
//       </DropdownMenu.Content>
//     </DropdownMenu.Root>
//   );
// }

export function SelectGradeType({ ...props }: SelectProps) {
  return (
    <GeneralSelect
      label="成绩类型"
      first="1"
      options={
        new Map([
          ["百分制", 1],
          ["4分制", 2],
          ["5分制", 3],
        ])
      }
      snapPoints={[22]}
      val="1"
      setVal={() => {}}
      {...props}
    />
  );
}

export function AddtiionForm({
  addAddition,
  setCloseForm,
}: {
  addAddition: (newAdd: Addition) => void;
  setCloseForm: () => void;
}) {
  const [name, setName] = useState<string>("");
  const [achievement, setAchievement] = useState<string>("");
  return (
    <YStack width="80%" space="$1">
      <Input
        placeholder="自定义"
        value={name}
        width="50%"
        size="$3"
        onChangeText={(t) => {
          setName(t);
        }}
      />
      <XStack alignItems="center">
        <Input
          placeholder="请输入"
          value={achievement}
          size="$3"
          width="80%"
          onChangeText={(t) => {
            setAchievement(t);
          }}
        />
        <Button
          size="$2"
          onPress={() => {
            setCloseForm();
            addAddition({ name, achievement });
          }}
        >
          保存
        </Button>
      </XStack>
    </YStack>
  );
}

export function AddLangForm({
  addLang,
  setCloseForm,
}: {
  addLang: (newAdd: Language) => void;
  setCloseForm: () => void;
}) {
  const [name, setName] = useState<"托福" | "雅思" | "GRE" | "DUOLINGO">(
    "托福",
  );
  const [score, setScore] = useState<number | undefined>();
  return (
    <XStack
      alignItems="center"
      space="$1"
      width="100%"
      justifyContent="space-between"
    >
      <View style={{ flexDirection: "row", width: "20%" }}>
        <GeneralSelect
          label="考试"
          first="托福"
          val={name}
          setVal={setName}
          options={
            new Map([
              ["托福", "托福"],
              ["雅思", "雅思"],
              ["GRE", "GRE"],
              ["DUOLINGO", "DUOLINGO"],
            ])
          }
          snapPoints={[22]}
          size="$3"
        />
      </View>

      <Input
        placeholder="请输入"
        value={score?.toString()}
        backgroundColor="$gray3"
        size="$3"
        width="50%"
        onChangeText={(t) => {
          setScore(parseInt(t) || 0);
        }}
      />
      <Button
        size="$2"
        onPress={() => {
          setCloseForm();
          addLang({ name, score: score! });
        }}
      >
        保存
      </Button>
    </XStack>
  );
}

export function AddWorkForm({
  addWork,
  setCloseForm,
}: {
  addWork: (newAdd: Work) => void;
  setCloseForm: () => void;
}) {
  const [companyName, setCompanyName] = useState<string>("");
  const [position, setPosition] = useState<string>("");
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");
  const [responsibilities, setResponsibilities] = useState<string>("");
  return (
    <YStack justifyContent="center" alignItems="center">
      <XStack
        flexDirection="row"
        justifyContent="center"
        alignItems="center"
        width="100%"
        paddingHorizontal="$7"
      >
        <YStack width="30%" space="$6">
          <Text fontWeight="bold">公司名称</Text>
          <Text fontWeight="bold">职位</Text>
          <Text fontWeight="bold">工作时间</Text>
          <Text fontWeight="bold">工作职责</Text>
        </YStack>
        <YStack justifyContent="flex-start" alignContent="center" space="$3">
          <Input
            placeholder="请输入"
            value={companyName}
            backgroundColor="$gray3"
            width="100%"
            size="$3"
            onChangeText={(t) => {
              setCompanyName(t);
            }}
          />
          <Input
            placeholder="请输入"
            value={position}
            backgroundColor="$gray3"
            size="$3"
            width="100%"
            onChangeText={(t) => {
              setPosition(t);
            }}
          />
          <XStack
            alignItems="center"
            width="90%"
            justifyContent="center"
            space="$2"
          >
            <Input
              borderWidth={0}
              borderRadius={0}
              size="$3"
              backgroundColor="$gray3"
              borderBottomWidth={2}
              borderColor="$gray8"
              width="40%"
              placeholder="开始时间"
              fontSize="$2"
              value={startDate}
              onChangeText={(t) => {
                setStartDate(t);
              }}
            />
            <Text>——</Text>
            <Input
              borderWidth={0}
              borderRadius={0}
              borderBottomWidth={2}
              borderColor="$gray8"
              backgroundColor="$gray3"
              width="40%"
              placeholder="结束时间"
              fontSize="$2"
              size="$3"
              value={endDate}
              onChangeText={(t) => {
                setEndDate(t);
              }}
            />
          </XStack>
          <Input
            size="$3"
            width="100%"
            placeholder="请输入"
            backgroundColor="$gray3"
            value={responsibilities}
            onChangeText={(t) => {
              setResponsibilities(t);
            }}
          />
        </YStack>
      </XStack>
      <Button
        width="20%"
        size="$3"
        onPress={() => {
          setCloseForm();
          addWork({
            companyName,
            position,
            startDate,
            endDate,
            responsibilities,
          });
        }}
      >
        <ButtonText alignContent="center">保存</ButtonText>
      </Button>
    </YStack>
  );
}
