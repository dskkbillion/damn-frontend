export interface ApplicationState {
  application_university: string;
  application_majority: string;
  officialProgramName: string;
  generating_num: number;
  supplementary_info: string;
  finished: boolean;
}

export const applications: ApplicationState[] = [
  {
    application_university: "CUHK",
    application_majority: "CS",
    officialProgramName: "MSC",
    generating_num: 0,
    supplementary_info: "我是一个乐观、热情的人",
    finished: false,
  },
  {
    application_university: "UCB",
    application_majority: "CS",
    officialProgramName: "MSCS",
    generating_num: 1,
    supplementary_info: "",
    finished: false,
  },
  {
    application_university: "NUS",
    application_majority: "CS",
    officialProgramName: "MFE",
    generating_num: 2,
    supplementary_info: "",
    finished: true,
  },
  {
    application_university: "NYU",
    application_majority: "CS",
    officialProgramName: "MSCS",
    generating_num: 5,
    supplementary_info: "",
    finished: true,
  },
];

export interface DocState {
  name: string;
  createAt: string;
  updateAt: string;
}

export const docs: DocState[] = [
  {
    name: "第一版",
    createAt: "2020-10-10",
    updateAt: "2020-10-12",
  },
  {
    name: "第二版",
    createAt: "2020-10-13",
    updateAt: "2020-10-15",
  },
  {
    name: "最终版",
    createAt: "2020-10-17",
    updateAt: "2020-10-20",
  },
];
