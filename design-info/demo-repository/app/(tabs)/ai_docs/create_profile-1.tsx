import { Dot, PlusCircle, MinusCircle } from "@tamagui/lucide-icons";
import * as ImagePicker from "expo-image-picker";
import { useRouter } from "expo-router";
import { useState } from "react";
import {
  YStack,
  H2,
  Separator,
  Theme,
  Avatar,
  Button,
  ButtonText,
  Input,
  Text,
  XStack,
  View,
  Stack,
  styled,
  Popover,
  Adapt,
  Label,
  PopoverProps,
  useTheme,
  Paragraph,
} from "tamagui";

import { Circle } from "@/components/ai_doc/circle";
import {
  Addition,
  // GradTypeDropdown,
  SelectGradeType,
  AddtiionForm,
} from "@/components/ai_doc/profile_additions";
import { SelectUni } from "@/components/select-uni";

// TODO: switch to react-native-tab-view
export default function NewProfile(props) {
  const router = useRouter();
  const [image, setImage] = useState<any>(null);
  const [showForm, setShowForm] = useState<boolean>(false);
  const [additions, setAddition] = useState<Addition[]>([]);

  const addAddition = (newAdd: Addition) => {
    setAddition([
      ...additions,
      { name: newAdd.name, achievement: newAdd.achievement },
    ]);
  };

  const pickImage = async () => {
    // No permissions request is necessary for launching the image library
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.All,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    // console.log(result);

    if (!result.canceled) {
      setImage(result.assets[0].uri);
    }
  };

  return (
    <Theme name="light">
      <YStack
        flex={1}
        alignItems="center"
        justifyContent="flex-start"
        paddingHorizontal="$6"
        space="$4"
      >
        {/* <Avatar size="$7" circular>
          <Avatar.Image src={image} />
          <Avatar.Fallback delayMs={600} backgroundColor="$gray6" />
        </Avatar> */}
        {/* <Button onPress={pickImage} transparent>
          <ButtonText color="$gray10">为你的画像设置照片</ButtonText>
        </Button> */}
        {/* <Input placeholder="设置标签" width="60%" borderColor="$gray9" /> */}
        <Separator />
        {/* <SelectUni />
         */}

        <XStack
          flexDirection="row"
          alignItems="center"
          justifyContent="space-between"
        >
          <View flexDirection="row" width="30%">
            <Text fontSize="$5" fontWeight="bold">
              标签
            </Text>
          </View>
          <View flexDirection="row" width="70%">
            <Input size="$2" width="50%" backgroundColor="$gray3" />
          </View>
        </XStack>

        <XStack
          flexDirection="row"
          alignItems="center"
          justifyContent="space-between"
        >
          <View flexDirection="row" width="30%">
            <Text fontSize="$5" fontWeight="bold">
              描述
            </Text>
          </View>
          <View flexDirection="row" width="70%">
            <Input size="$2" width="100%" backgroundColor="$gray3" />
          </View>
        </XStack>

        <XStack
          flexDirection="row"
          alignItems="center"
          justifyContent="space-between"
        >
          <View flexDirection="row" width="30%">
            <Text fontSize="$5" fontWeight="bold">
              学历
            </Text>
            <Text fontSize="$5" fontWeight="bold">
              *
            </Text>
          </View>
          <View flexDirection="row" width="70%">
            <Input size="$3" width="100%" backgroundColor="$gray3" />
          </View>
        </XStack>

        <XStack
          flexDirection="row"
          alignItems="center"
          justifyContent="space-between"
        >
          <View flexDirection="row" width="30%">
            <Text fontSize="$5" fontWeight="bold">
              就读院校
            </Text>
            <Text fontSize="$5" fontWeight="bold">
              *
            </Text>
          </View>
          <View flexDirection="row" width="70%">
            <Input size="$3" width="100%" backgroundColor="$gray3" />
          </View>
        </XStack>

        <XStack
          flexDirection="row"
          alignItems="center"
          justifyContent="space-between"
        >
          <View flexDirection="row" width="30%">
            <Text fontSize="$5" fontWeight="bold">
              专业
            </Text>
            <Text fontSize="$5" fontWeight="bold">
              *
            </Text>
          </View>
          <View flexDirection="row" width="70%">
            <Input size="$3" width="100%" backgroundColor="$gray3" />
          </View>
        </XStack>

        <XStack
          alignItems="center"
          justifyContent="center"
          space="$2"
          paddingTop="$3"
        >
          <Input
            borderWidth={0}
            borderRadius={5}
            borderBottomWidth={2}
            borderColor="$gray8"
            backgroundColor="#F2F2F2"
            width="45%"
            placeholder="入学时间"
            fontSize="$2"
            size="$3"
          />
          <Text>——</Text>
          <Input
            borderWidth={0}
            borderRadius={5}
            borderBottomWidth={2}
            borderColor="$gray8"
            backgroundColor="$gray3"
            width="45%"
            placeholder="毕业时间"
            fontSize="$2"
            size="$3"
          />
        </XStack>
        <XStack
          alignItems="center"
          width="80%"
          justifyContent="space-between"
          space="$2"
          paddingTop="$3"
        >
          <View
            flexDirection="row"
            alignItems="center"
            width="40%"
            justifyContent="space-between"
          >
            <Text fontSize="$5" fontWeight="bold">
              绩点
            </Text>
            <Input
              backgroundColor="$gray3"
              width="50%"
              placeholder="4.0"
              fontSize="$2"
              height="$3"
            />
          </View>

          <Text>/</Text>
          {/* <GradeTypeDropdown /> */}
          <View
            flexDirection="row"
            alignItems="center"
            width="40%"
            justifyContent="space-between"
          >
            <SelectGradeType size="$3" />
          </View>
        </XStack>
        <XStack
          alignItems="center"
          width="80%"
          justifyContent="space-between"
          space="$2"
          paddingTop="$3"
        >
          <YStack justifyContent="flex-start" space="$2">
            <Text fontSize="$5" fontWeight="bold">
              自定义加分项(选填)
            </Text>
            <Text color="$gray10">如所获得荣誉、获奖证书等</Text>
          </YStack>
          <Button
            padding="$0"
            onPress={() => {
              setShowForm(!showForm);
            }}
          >
            {showForm ? <MinusCircle size="$1" /> : <PlusCircle size="$1" />}
          </Button>
        </XStack>
        {additions.map((add) => (
          <XStack
            width="80%"
            justifyContent="space-between"
            alignItems="center"
            paddingBottom="$1"
          >
            <Text fontWeight="bold">{add.name}</Text>
            <Text>{add.achievement}</Text>
          </XStack>
        ))}
        {showForm && (
          <AddtiionForm
            addAddition={addAddition}
            setCloseForm={() => {
              setShowForm(false);
            }}
          />
        )}
        <Button
          width="60%"
          backgroundColor="black"
          alignSelf="center"
          marginTop="$3"
          onPress={() => {
            // router.push("/(tabs)/ai_docs/create_profile-2");
            props.onValueChange(2);
          }}
        >
          <ButtonText color="$gray3">下一页</ButtonText>
        </Button>
      </YStack>
    </Theme>
  );
}
