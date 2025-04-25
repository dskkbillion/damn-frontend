import { PortraitInfo, portraits } from "@/constants/portrait";

export interface user {
  user_id: number;
  username: string;
  portraits: PortraitInfo[];
  avatar_url: string;
}

// 伪造卖家数据
const generateData = (count: number): user[] => {
  const data: user[] = [];
  const fake_avatars = [
    "https://randomuser.me/api/portraits/women/44.jpg",
    "https://randomuser.me/api/portraits/men/24.jpg",
    "https://randomuser.me/api/portraits/men/2.jpg",
  ];
  for (let i = 1; i <= count; i++) {
    const randomAvatar =
      fake_avatars[Math.floor(Math.random() * fake_avatars.length)];

    data.push({
      user_id: i,
      username: "用户" + i.toString(),
      portraits,
      avatar_url: randomAvatar,
    });
  }
  return data;
};

export const userDataset = generateData(2000);
