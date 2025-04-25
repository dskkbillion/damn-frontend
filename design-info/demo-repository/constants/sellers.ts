// 卖家信息
export interface seller {
  user_id: number;
  username: string;
  university_authenticated: string;
  majority_authenticated: string;
  avatar_url: string;
  authentication: string;
}

// 伪造卖家数据
const generateData = (count: number): seller[] => {
  const data: seller[] = [];
  const fake_universities = ["清华大学", "南京大学", "上海交通大学"];
  const fake_majorities = ["CS", "MFE", "Finance"];
  const fake_avatars = [
    "https://randomuser.me/api/portraits/women/44.jpg",
    "https://randomuser.me/api/portraits/men/24.jpg",
    "https://randomuser.me/api/portraits/men/2.jpg",
  ];
  const fake_authentications = [
    "学历认证 优质卖家",
    "学历认证 优质卖家 准时交付 文书专家 ",
  ];
  // 向ServiceDataset中随机取值组成transaction
  for (let i = 1; i <= count; i++) {
    const randomUniveristy =
      fake_universities[Math.floor(Math.random() * fake_universities.length)];
    const randomMajorioty =
      fake_majorities[Math.floor(Math.random() * fake_majorities.length)];
    const randomAvatar =
      fake_avatars[Math.floor(Math.random() * fake_avatars.length)];
    const randomAuthentications =
      fake_authentications[
        Math.floor(Math.random() * fake_authentications.length)
      ];
    data.push({
      user_id: i,
      username: "用户" + i.toString(),
      university_authenticated: randomUniveristy,
      majority_authenticated: randomMajorioty,
      avatar_url: randomAvatar,
      authentication: randomAuthentications,
    });
  }
  return data;
};

export const sellerDataset = generateData(2000);
