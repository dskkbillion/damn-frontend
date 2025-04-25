import { Activity, Airplay } from "@tamagui/lucide-icons";
import { Button, Group, Separator, XGroup } from "tamagui";

export function SelectUni() {
  const GroupSeperator = () => <Separator vertical borderColor="$gray8" />;
  return (
    <Group
      orientation="horizontal"
      width="100%"
      borderColor="$gray8"
      borderWidth={2}
      borderRadius={10}
      separator={<GroupSeperator />}
    >
      <Group.Item>
        <Button width="25%">学历</Button>
      </Group.Item>

      <Group.Item>
        <Button width="48%">就读院校</Button>
      </Group.Item>

      <Group.Item>
        <Button width="25%">专业</Button>
      </Group.Item>
    </Group>
  );
}
