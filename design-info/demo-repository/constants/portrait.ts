import { Key } from "@tamagui/lucide-icons";
import { Item } from "zeego/dropdown-menu";

import { Profile, fake_profile } from "./fake-profiles";

import Index from "@/app";
import { ApplicationState, applications } from "@/constants/application";

// 伪造画像数据
export interface PortraitInfo {
  id: number;
  name: string;
  description: string;
  profile: Profile; // 文书资料
  applications: ApplicationState[];
}

interface GenerateInfo {
  num_generation: number;
}
// 使用 reduce 将数组转换为对象
const portrait_1_applications = applications.reduce(
  (acc, item, index) => {
    acc[index] = item;
    return acc;
  },
  {} as { [key: number]: ApplicationState },
);

export const portraits: PortraitInfo[] = [
  {
    id: 1,
    name: "CS申请",
    description: "申请美国TOP30 CS专业",
    profile: fake_profile,
    applications,
  },
  {
    id: 2,
    name: "IMIS申请",
    description: "申请美国TOP30 IMIS专业",
    profile: fake_profile,
    applications,
  },
  {
    id: 3,
    name: "金融工程专业",
    description: "申请美国TOP30 MFE专业",
    profile: fake_profile,
    applications,
  },
];
