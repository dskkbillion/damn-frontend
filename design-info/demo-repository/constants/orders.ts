export interface OrderInfo {
  transaction_id: number;
  file_titles: string[]; // 上传材料的名称
}

const generateData = (count: number): OrderInfo[] => {
  const data: OrderInfo[] = [];

  // 向ServiceDataset中随机取值组成transaction
  for (let i = 1; i <= count; i++) {
    data.push({
      transaction_id: i,
      file_titles: ["CV.docx", "我的文书.docx"],
    });
  }
  return data;
};

export const OrderDataset: OrderInfo[] = generateData(10);
