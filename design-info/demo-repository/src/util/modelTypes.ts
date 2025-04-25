// 定义共享的类型和接口
export interface SSEConfig {
  api: string;
  api_key: string;
  data: any;
  onOpen: (event: any) => void;
  onMessage: (event: any) => void;
  onError: (event: any) => void;
  onEnd: (event: any) => void;
}

export interface SSEConnection {
  close: () => void;
}
