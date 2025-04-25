export interface service {
  service_id: number;
  provider_user_id: number;
  description: string;
  category: string;
  category_id: number;
  saap_id: number;
  basic: Record<string, (number | string | boolean)[]>;
  standard: Record<string, (number | string | boolean)[]>;
  premium: Record<string, (number | string | boolean)[]>;
  service_requirements: string[]; //卖家提问
  image_url: string;
  image_height: number;
  service_title: string;
  rating: number;
  rating_num: number;
}

/*
 构造服务数据集
 @params[number] category_id: 服务所处大类标识（1：留学，2: 搜题，3:家装，4:旅游）
 @params[string] category: 服务所处大类描述
 @params[number] saap_id: 服务的SAAP模型标识
 @params[string] service_title: 服务标题
 @params[string] description: 服务描述
 @params[Record] category_items: 服务SAAP模型规范化条目 {条目名称: {type：数据类型, unit: 数据单位, unlimited: 是否允许为无限制,min_value: 最小值 ,max_value:最大值}}
 **/
export const fake_services = [
  {
    category_id: 1,
    category: "留学",
    saap_id: 1,
    service_title: "文书润色，语言优化，逻辑和结构优化",
    description:
      "精炼文书笔触，我们的专业写作服务致力于以简洁有力的语言传递您的核心价值，确保每一字都经过精心雕琢，以最直接的方式影响您的目标受众...",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      revise_times: {
        type: "number",
        min_value: 2,
        max_value: 5,
        unit: "次",
        unlimited: true,
      },
      revise_grammar: { type: "boolean", unit: "NA", unlimited: false },
      detailed_suggestion: { type: "boolean", unit: "NA", unlimited: false },
    },
  },

  {
    category_id: 1,
    category: "留学",
    saap_id: 2,
    service_title: "留学顾问，解答您的留学疑问",
    description:
      "留学顾问，为您提供专业留学建议，解答疑问，助您顺利踏上留学征程...",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      tele_consult: { type: "boolen", unit: "NA", unlimited: false },
      video_consult: { type: "boolen", unit: "NA", unlimited: false },
      times: {
        type: "number",
        unit: "次",
        min_value: 1,
        max_value: 5,
        unlimited: false,
      },
    },
  },
  {
    category_id: 1,
    category: "留学",
    saap_id: 3,
    service_title: "精准选校，打造升学保障",
    description:
      "精准选校，为您量身打造升学保障计划，确保您的学业道路顺畅无阻...",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      university_num: {
        type: "number",
        min_value: 8,
        max_value: 15,
        unit: "天",
        unlimited: false,
      },
      country_num: {
        type: "number",
        unit: "个",
        min_value: 1,
        max_value: 3,
        unlimited: false,
      },
    },
  },

  {
    category_id: 2,
    category: "搜题",
    saap_id: 4,
    service_title: "辅导答疑",
    description:
      "细致辅导答疑，解决您学习中的疑难问题，提供专业指导，助您轻松掌握知识要点...",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      times: {
        type: "number",
        min_value: 1,
        max_value: 3,
        unit: "次",
        unlimited: false,
      },
      subject: {
        type: "string",
        value: ["高等数学", "建筑学原理"],
        unit: "NA",
        unlimted: false,
      },
    },
  },
  {
    category_id: 3,
    category: "家装",
    saap_id: 5,
    service_title: "装修咨询",
    description:
      "无论您是在考虑新房装修、旧房翻新，还是办公空间改造，我们提供全面的装修风格建议和专业意见",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      tele_consult: { type: "boolen", unit: "NA", unlimited: false },
      video_consult: { type: "boolen", unit: "NA", unlimited: false },
      times: {
        type: "number",
        unit: "次",
        min_value: 1,
        max_value: 5,
        unlimited: false,
      },
    },
  },
  {
    category_id: 3,
    category: "家装",
    saap_id: 6,
    service_title: "设计图修改服务",
    description:
      "设计图修改服务，精准调整您的构想，确保每个细节都符合您的需求和品味",
    category_items: {
      delivery: {
        type: "number",
        min_value: 3,
        max_value: 7,
        unit: "天",
        unlimited: false,
      },
      times: {
        type: "number",
        unit: "次",
        min_value: 1,
        max_value: 10,
        unlimited: true,
      },
    },
  },
  {
    category_id: 4,
    category: "旅游",
    saap_id: 7,
    service_title: "重庆旅游景点咨询",
    description:
      "重庆旅游景点咨询，为您推荐巴渝风情、长江索道等独特景点，让您畅游山城之美",
    category_items: {
      delivery: {
        type: "number",
        min_value: 1,
        max_value: 2,
        unit: "天",
        unlimited: false,
      },
      times: {
        type: "number",
        unit: "次",
        min_value: 1,
        max_value: 2,
        unlimited: true,
      },
    },
  },
  {
    category_id: 4,
    category: "旅游",
    saap_id: 7,
    saap_model: "旅游咨询",
    service_title: "上海旅游避雷指南",
    description:
      "上海旅游避雷指南，提供实用建议，避免高峰拥堵，发现本地美食，安心畅游上海风情",
    category_items: {
      delivery: {
        type: "number",
        min_value: 1,
        max_value: 2,
        unit: "天",
        unlimited: false,
      },
      times: {
        type: "number",
        unit: "次",
        min_value: 1,
        max_value: 2,
        unlimited: true,
      },
    },
  },
];

/*
  根据category构造随机图片
  category_id : [图片]
**/
export const fake_image_urls = {
  // category === 1 : ai_docs
  1: [
    "https://gitee.com/Ryan_here/images/raw/master/IMG_6877.JPG",
    "https://gitee.com/Ryan_here/images/raw/master/IMG_6878.JPG",
    "https://gitee.com/Ryan_here/images/raw/master/IMG_6879-2.JPG",
  ],
  // category === 2: education
  2: [
    "https://gitee.com/Ryan_here/images/raw/master/do-anything-related-to-civil-engineering-bae5.jpg",
    "https://gitee.com/Ryan_here/images/raw/master/do-material-engineering-related-works-assignments-and-projects.jpg",
    "https://gitee.com/Ryan_here/images/raw/master/do-psychology-sociology-nursing-political-science-and-american-and-us-history.jpeg",
  ],
  //  category ===  3 : design
  3: [
    "https://gitee.com/Ryan_here/images/raw/master/build-painting-contractor-website-residential-painting-landing-page-for-leads.jpg",
    "https://gitee.com/Ryan_here/images/raw/master/design-and-render-interior-exterior-by-3dmax.jpg",
    "https://gitee.com/Ryan_here/images/raw/master/3d-interior-interior-design-with-realistic-render.jpg",
  ],
  // category === 4: travel
  4: [
    "https://gitee.com/Ryan_here/images/raw/master/be-your-tour-guide-and-show-you-around-osaka.png.jpeg",
    "https://gitee.com/Ryan_here/images/raw/master/create-a-comprehensive-travel-itinerary-for-your-holiday.jpg",
    "https://gitee.com/Ryan_here/images/raw/master/do-travel-consultation-if-you-need-help-with-something-specific.jpg",
  ],
};

/*
  生成主页服务数据 && 推荐服务数据
  @params[any] dataset : 生成数据的基础数据
  @params[number] count : 生成数据的数量
  @params[number] props.category_id:  如果提供category_id则返回指定id的服务数据
**/
export const generateData = ({
  dataset,
  count,
  ...props
}: {
  dataset: any;
  count: number;
  [key: string]: any;
}): service[] => {
  const data: service[] = [];

  if (props.category_id) {
    dataset = dataset.filter((item) => item.category_id === props.category_id);
  }

  // 向ServiceDataset中随机取值组成transaction
  for (let i = 1; i <= count; i++) {
    const fake_provider_user_id = Math.floor(Math.random() * 2000); // 从2000（伪造）个卖家的id中抽取
    const randomService = dataset[Math.floor(Math.random() * dataset.length)];
    const randomCategoryId = randomService.category_id;
    const randomSaapId = randomService.saap_id;
    const randomImageUrl =
      fake_image_urls[randomCategoryId][
        Math.floor(Math.random() * fake_image_urls[randomCategoryId].length)
      ];
    const randomHeight = Math.floor(Math.random() * (200 - 100 + 1)) + 100; // 生成 [100, 300] 范围内的随机数

    const basic: Record<string, (number | string | boolean)[]> = {};
    const standard: Record<string, (number | string | boolean)[]> = {};
    const premium: Record<string, (number | string | boolean)[]> = {};

    const randomCategory = fake_services.find(
      (p) => p.category_id === randomCategoryId,
    )!;

    const items = randomCategory.category_items; //{diliver: {} , ...}
    const item_keys = Object.keys(items); //dilivery

    // 构造fake data for basic、standard、premium
    for (let j = 0; j < item_keys.length; j++) {
      const key = item_keys[j];

      // case number
      if (items[key].type === "number") {
        basic[key] = [items[key].min_value, items[key].unit];
        standard[key] = [
          Math.floor(Math.random() * items[key].min_value) +
            items[key].max_value -
            1,
          items[key].unit,
        ];
        premium[key] = [items[key].max_value, items[key].unit];

        if (key === "delivery") {
          basic[key] = [items[key].max_value, items[key].unit];
          standard[key] = [
            items[key].max_value -
              1 -
              Math.floor(Math.random() * items[key].min_value),
            items[key].unit,
          ];
          premium[key] = [items[key].min_value, items[key].unit];
        }
      }

      // case string
      if (items[key].type === "string") {
        const values = items[key].value;
        const randomVal = values[Math.floor(Math.random() * values.length)];
        basic[key] = randomVal;
        standard[key] = randomVal;
        premium[key] = randomVal;
      }

      // 如果数据有可能是无限制
      if (items[key].unlimited === true) {
        basic[key] = [items[key].min_value, items[key].unit];
        standard[key] = [
          Math.floor(Math.random() * items[key].min_value) +
            items[key].max_value,
          items[key].unit,
        ];
        premium[key] = ["无限制", "NA"];
      }
      // 如果数据是boolen类型
      if (items[key].type === "boolen") {
        basic[key] = [false, items[key].unit];
        standard[key] = [Math.random() > 0.5, items[key].unit];
        premium[key] = [true, items[key].unit];
      }
    }

    basic["price"] = [Math.floor(Math.random() * 300)];
    standard["price"] = [Math.floor(Math.random() * 300 + 300)];
    premium["price"] = [Math.floor(Math.random() * 300 + 600)];

    data.push({
      category_id: randomService.category_id,
      service_id: i,
      provider_user_id: fake_provider_user_id,
      category: randomService.category,
      saap_id: randomSaapId,
      service_title: randomService.service_title,
      description: randomService.description,
      basic,
      standard,
      premium,
      image_url: randomImageUrl,
      image_height: randomHeight,
      rating: 4.8,
      rating_num: Math.floor(Math.random() * 2000),
      service_requirements: [
        "您订购的是基本服务(30￥/150字)、标准服务(150￥/1000字)还是高级服务(350￥/1000 字）？如果您支付的是 5 美元,您的订单包含150字的基本校对,因此在这种情况下不要选择'标准'和'高级'",
        "您的稿件具体字数是多少？",
        "如果你有任何额外的需求，请在这里描述。",
      ],
    });
  }
  return data;
};

export const ServiceDataset = generateData({
  count: 2000,
  dataset: fake_services,
});
