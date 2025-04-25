import { Button, Text } from "tamagui";
import * as DropdownMenu from "zeego/dropdown-menu";

export function InputSelectMenu({
  selctors,
}: {
  selctors: { name: string; onSelect: () => void }[];
}) {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Button />
      </DropdownMenu.Trigger>
      <DropdownMenu.Content>
        <DropdownMenu.Label>Input Select</DropdownMenu.Label>
        {selctors.map((inputSelect) => (
          <DropdownMenu.Item
            key={inputSelect.name}
            onSelect={inputSelect.onSelect}
          >
            <DropdownMenu.ItemTitle>{inputSelect.name}</DropdownMenu.ItemTitle>
          </DropdownMenu.Item>
        ))}
        <DropdownMenu.Arrow />
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
