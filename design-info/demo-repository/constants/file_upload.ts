// fake data for file upload
type file = {
  id: number;
  order_id: number;
  file_name: string;
  file_path: string;
  file_size: number;
  file_type: string;
  description: string;
};

const generateData = (count: number): file[] => {
  const data: file[] = [];
  for (let i = 1; i <= count; i++) {
    data.push({
      id: i,
      order_id: Math.floor(Math.random() * 19) + 1,
      file_name: "CV.docx",
      file_path: "https://www.baidu.com",
      file_size: 100,
      file_type: "docx",
      description: "this is a file",
    });
  }
  return data;
};

export const FileDataset: file[] = generateData(50);
