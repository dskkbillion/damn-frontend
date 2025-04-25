import { PlusCircle, MinusCircle } from "@tamagui/lucide-icons";
import { useRouter } from "expo-router";
import { useState } from "react";
import {
  YStack,
  Separator,
  Theme,
  Avatar,
  Button,
  ButtonText,
  Text,
  XStack,
  Input,
} from "tamagui";

import { Circle } from "@/components/ai_doc/circle";
import {
  Work,
  Language,
  AddLangForm,
  AddWorkForm,
} from "@/components/ai_doc/profile_additions";

export default function NewProfile(props) {
  const router = useRouter();
  const [showWorkForm, setShowWorkForm] = useState<boolean>(true);
  const [showLangForm, setShowLangForm] = useState<boolean>(true);
  const [works, setWorks] = useState<Work[]>([]);
  const [langs, setLangs] = useState<Language[]>([]);
  //TODO: should pass a image uri from previous page
  let image;
  const addWork = (newWork: Work) => {
    setWorks([...works, newWork]);
  };
  const addLang = (newLang: Language) => {
    setLangs([...langs, newLang]);
  };

  return (
    <Theme name="light">
      <YStack
        flex={1}
        alignItems="center"
        justifyContent="flex-start"
        paddingHorizontal="$6"
        space="$2"
      >
        <Separator />
        <XStack
          alignItems="center"
          width="100%"
          justifyContent="space-between"
          space="$2"
          paddingTop="$3"
        >
          <Text fontSize="$5" fontWeight="bold">
            语言能力
          </Text>
          <Button
            padding="$0"
            onPress={() => {
              setShowLangForm(!showLangForm);
            }}
          >
            {showLangForm ? (
              <MinusCircle size="$1" />
            ) : (
              <PlusCircle size="$1" />
            )}
          </Button>
        </XStack>
        {langs.map((lang, idx) => (
          <XStack justifyContent="space-between" key={idx} width="80%">
            <Text>{lang.name}</Text>
            <Text>{lang.score}</Text>
          </XStack>
        ))}
        {showLangForm && (
          <AddLangForm
            addLang={addLang}
            setCloseForm={() => {
              setShowLangForm(false);
            }}
          />
        )}
        <XStack
          alignItems="center"
          width="100%"
          justifyContent="space-between"
          space="$2"
          paddingTop="$3"
        >
          <Text fontSize="$5" fontWeight="bold">
            工作经历
          </Text>
          <Button
            padding="$0"
            onPress={() => {
              setShowWorkForm(!showWorkForm);
            }}
          >
            {showWorkForm ? (
              <MinusCircle size="$1" />
            ) : (
              <PlusCircle size="$1" />
            )}
          </Button>
        </XStack>
        {works.map((work, idx) => (
          <XStack justifyContent="space-between" key={idx} width="80%">
            <YStack>
              <Text fontWeight="bold">{work.companyName}</Text>
              <Text>{work.position}</Text>
            </YStack>
            <Text fontSize="$1">{`${work.startDate}-${work.endDate}`}</Text>
          </XStack>
        ))}
        {showWorkForm && (
          <AddWorkForm
            addWork={addWork}
            setCloseForm={() => {
              setShowWorkForm(false);
            }}
          />
        )}

        <XStack width="80%" space="$2">
          <Button
            width="50%"
            backgroundColor="black"
            marginTop="$5"
            onPress={() => {
              // router.push("/(tabs)/ai_docs/create_profile-1");
              // router.back();
              props.onValueChange(1);
            }}
          >
            <ButtonText color="$gray3">上一页</ButtonText>
          </Button>
          <Button
            width="50%"
            backgroundColor="black"
            marginTop="$5"
            onPress={() => {
              // props.onValueChange(1)
            }}
          >
            <ButtonText color="$gray3">完成</ButtonText>
          </Button>
        </XStack>
      </YStack>
    </Theme>
  );
}
