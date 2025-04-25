import { Float } from "react-native/Libraries/Types/CodegenTypes";

export interface Review {
  id: number;
  reviewer: string;
  comment: string;
  rating: string;
  UserAvatar: string;
  UpdateTime: string;
}

export const Reviews: Review[] = [
  {
    id: 1,
    reviewer: "ryan",
    comment: "卖家交货准时，服务质量高！推荐",
    rating: "4.1",
    UserAvatar: "https://randomuser.me/api/portraits/women/44.jpg",
    UpdateTime: "12/01/23, 11:30",
  },
  {
    id: 2,
    reviewer: "hyda",
    comment: "卖家交货准时，服务质量高！推荐",
    rating: "4.9",
    UserAvatar: "https://randomuser.me/api/portraits/men/2.jpg",
    UpdateTime: "12/01/23, 14:15",
  },

  {
    id: 3,
    reviewer: "葱油饼",
    comment: "卖家交货准时，服务质量高！推荐",
    rating: "4.6",
    UserAvatar: "https://randomuser.me/api/portraits/men/24.jpg",
    UpdateTime: "12/01/23, 14:15",
  },
];
