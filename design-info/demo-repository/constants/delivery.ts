// fake data for file upload
type delivery = {
  id: number;
  seller_id: number;
  buyer_id: number;
  order_id: number;
  delivery_date: Date;
  estimated_delivery_date: Date;
  delivery_status: string;
  notes: string;
  files: string[];
};

const generateData = (count: number): delivery[] => {
  const data: delivery[] = [];
  const status = ["inTime", "delayed"];
  for (let i = 1; i <= count; i++) {
    data.push({
      id: i,
      seller_id: Math.floor(Math.random() * 2000),
      buyer_id: Math.floor(Math.random() * 2000),
      order_id: Math.floor(Math.random() * 19) + 1,
      delivery_date: new Date(),
      estimated_delivery_date: new Date(),
      delivery_status: status[Math.floor(Math.random() * status.length)],
      notes: "this is a delivery",
      files: ["https://www.baidu.com"],
    });
  }
  return data;
};

export const DeliveryDataset: delivery[] = generateData(50);
