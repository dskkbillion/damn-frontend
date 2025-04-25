export interface Profile {
  qualifications: string;
  university: string;
  majority: string;
  gpa: string;
  gpa_rule: string;
  interships: IntershipInfo[];
}

interface IntershipInfo {
  company: string;
  position: string;
  start_time: string;
  end_time: string;
  responsibility: string;
}

// 伪造实习数据
const intership_experiences: IntershipInfo[] = [
  {
    company: "字节跳动",
    position: "软件工程实习生",
    start_time: "2022-06-01",
    end_time: "2022-08-31",
    responsibility:
      "参与了公司旗舰产品的新功能开发。与一组经验丰富的工程师合作，实现和测试了该功能。参与了代码审查，并为整体代码库的改进做出了贡献。",
  },
  {
    company: "阿里淘天集团",
    position: "产品管理实习生",
    start_time: "2022-09-01",
    end_time: "2022-12-31",
    responsibility:
      "协助产品管理团队进行市场调研和竞争对手分析。贡献了产品路线图的制定和功能优先级的确定。与工程、设计和市场团队密切合作，确保产品成功上线。",
  },
  {
    company: "华为创新实验室",
    position: "数据科学实习生",
    start_time: "2021-01-15",
    end_time: "2021-05-15",
    responsibility:
      "参与数据分析和机器学习项目。清理和处理大型数据集以进行模型训练。实施统计模型从数据中提取洞察。与高级数据科学家合作，开发并部署机器学习模型以应用于实际场景。",
  },
];

// 伪造用户生成资料
export const fake_profile: Profile = {
  qualifications: "本科",
  university: "清华大学",
  majority: "计算机科学",
  gpa: "4.0",
  gpa_rule: "5.0",
  interships: intership_experiences,
};

// export const profiles: Profile[] = [
//   {
//     id: 1,
//     name: "主申",
//     avatar: "https://randomuser.me/api/portraits/women/44.jpg",
//     category: "top30学校 CS专业",
//   },
//   {
//     id: 2,
//     name: "主申",
//     avatar: "https://randomuser.me/api/portraits/men/2.jpg",
//     category: "top30学校 Econ专业",
//   },
//   {
//     id: 3,
//     name: "辅申",
//     avatar: "https://randomuser.me/api/portraits/men/24.jpg",
//     category: "top100学校 Finance专业",
//   },

//   {
//     id: 4,
//     name: "辅申",
//     avatar: "https://randomuser.me/api/portraits/men/50.jpg",
//     category: "top100学校 Finance专业",
//   },
// ];
