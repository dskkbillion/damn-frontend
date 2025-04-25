export interface ServiceProps {
  onSelect?: (service: any) => void;
  selectedService?: any;
  // ... 其他共享的类型定义
}

export interface ServiceItem {
  id: number;
  name: string;
  description: string;
  // ... 其他服务项目相关的类型
}
