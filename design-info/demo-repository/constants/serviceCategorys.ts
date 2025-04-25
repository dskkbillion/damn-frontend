export interface SAAPModel {
  saap_id: number;
  saap_name: string;
  saap_items: Record<string, Record<string, string | boolean>>;
}

export const SAAPModels: SAAPModel[] = [];

SAAPModels.push(
  {
    saap_id: 1,
    saap_name: "文书润色",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      revise_times: { type: "number", unit: "次", unlimited: true },
      revise_grammar: { type: "boolen", unit: "NA", unlimited: false },
      detailed_suggestion: { type: "boolen", unit: "NA", unlimited: false },
    },
  },
  {
    saap_id: 2,
    saap_name: "留学咨询",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      tele_consult: { type: "boolen", unit: "NA", unlimited: false },
      video_consult: { type: "boolen", unit: "NA", unlimited: false },
      times: { type: "number", unit: "次", unlimited: false },
    },
  },
  {
    saap_id: 3,
    saap_name: "选校服务",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      university_num: { type: "number", unit: "天", unlimited: false },
      country_num: { type: "number", unit: "个", unlimited: false },
    },
  },
  {
    saap_id: 4,
    saap_name: "学业辅导",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      times: { type: "number", unit: "次", unlimited: false },
      subject: { type: "string", unit: "NA", unlimited: false },
      bilingualism: { type: "boolen", unit: "NA", unlimited: false },
      teaching: { type: "boolen", unit: "NA", unlimited: false },
    },
  },

  {
    saap_id: 5,
    saap_name: "装修咨询",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      tele_consult: { type: "boolen", unit: "NA", unlimited: false },
      video_consult: { type: "boolen", unit: "NA", unlimited: false },
      times: { type: "number", unit: "次", unlimited: false },
    },
  },

  {
    saap_id: 6,
    saap_name: "设计图修改",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      times: { type: "number", unit: "次", unlimited: false },
    },
  },

  {
    saap_id: 7,
    saap_name: "旅游咨询",
    saap_items: {
      delivery: { type: "number", unit: "天", unlimited: false },
      times: { type: "number", unit: "次", unlimited: false },
    },
  },
);
