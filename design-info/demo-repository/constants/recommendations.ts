import { fake_image_urls, fake_services, service } from "./services";

// 伪造category=i的服务数据
const generateData = (props: {
  count: number;
  category_id: number;
}): service[] => {
  const data: service[] = [];
  const services = fake_services.filter(
    (item) => item.category_id === props.category_id
  );

  for (let i = 1; i <= props.count; i++) {
    const fake_provider_user_id = Math.floor(Math.random() * 2000); // 从2000（伪造）个卖家的id中抽取
    const randomService = services[Math.floor(Math.random() * services.length)];
    const urlForService = fake_image_urls[props.category_id];
    const randomImageUrl =
      urlForService[Math.floor(Math.random() * urlForService.length)];
    const randomHeight = Math.floor(Math.random() * (200 - 100 + 1)) + 100; // 生成 [100, 300] 范围内的随机数
    const randomSaapId = randomService.saap_id;

    const basic: Record<string, (number | string | boolean)[]> = {};
    const standard: Record<string, (number | string | boolean)[]> = {};
    const premium: Record<string, (number | string | boolean)[]> = {};

    const randomCategory = fake_services.find(
      (p) => p.category_id === props.category_id
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

export const RecommendDataset = generateData({ count: 20, category_id: 4 });

export interface ServiceDataset {
  service_id: number;
  height: number;
}
