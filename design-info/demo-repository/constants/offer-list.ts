export interface AdmissionInfo {
  PreviousInstitutions: string;
  AdmissionInstitution: string;
  Major: string;
  UserAvatar: string;
  UpdateTime: string;
}

export const AdmissionList: AdmissionInfo[] = [
  {
    PreviousInstitutions: "清华大学",
    AdmissionInstitution: "普林斯顿大学(PU)",
    Major: "计算机科学",
    UserAvatar: "https://randomuser.me/api/portraits/women/44.jpg",
    UpdateTime: "12/01/23, 11:30",
  },

  {
    PreviousInstitutions: "五道口职业技术学院",
    AdmissionInstitution: "哥伦比亚大学(CU)",
    Major: "金融工程",
    UserAvatar: "https://randomuser.me/api/portraits/men/2.jpg",
    UpdateTime: "12/01/23, 14:15",
  },

  {
    PreviousInstitutions: "清华大学",
    AdmissionInstitution: "纽约大学(NYU)",
    Major: "信息管理",
    UserAvatar: "https://randomuser.me/api/portraits/men/24.jpg",
    UpdateTime: "12/01/23, 14:15",
  },
];
