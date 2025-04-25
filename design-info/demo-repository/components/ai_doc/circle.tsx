import {
  Avatar,
  Card,
  Circle,
  Paragraph,
  Stack,
  View,
  XStack,
  YStack,
  styled,
  useEvent,
} from "tamagui";

import { seller } from "@/constants/sellers";
import { ServiceDataset } from "@/constants/services";

export class MatchCircle {
  radius: number;
  centerX: number;
  centerY: number;
  bgColor: string;
  recommend_seller: seller;

  // 初始化圆的半径、圆心的位置、颜色
  constructor(
    radius: number,
    centerX: number,
    centerY: number,
    bgColor: string,
    recommend_seller: seller,
  ) {
    this.radius = radius;
    this.centerX = centerX;
    this.centerY = centerY;
    this.bgColor = bgColor;
    this.recommend_seller = recommend_seller;
  }

  // 定制字体大小
  formatFontSize() {
    if (this.radius >= 100) {
      return 20;
    } else if (this.radius >= 60) {
      return 18;
    } else {
      return 15;
    }
  }

  // 定制圆的样式
  fotmatCircle() {
    const radius = this.radius;
    const services = ServiceDataset.filter(
      (p) => p.provider_user_id === this.recommend_seller.user_id,
    );

    return (
      //  渲染一个圆
      <Card
        animation="bouncy"
        position="absolute"
        left={this.centerX}
        top={this.centerY}
        width={this.radius * 2}
        height={this.radius * 2}
        borderRadius={this.radius}
        backgroundColor={this.bgColor}
        enterStyle={{
          opacity: 0.3,
          y: 10,
          scale: 0.7,
        }}
        exitStyle={{
          opacity: 0,
          y: -10,
          scale: 0.9,
        }}
        pressStyle={{
          scale: 0.9,
        }}
      >
        <Card.Header alignItems="center" justifyContent="center">
          <Avatar size={this.radius * 0.5} borderRadius={this.radius * 0.25}>
            <Avatar.Image src={this.recommend_seller.avatar_url} />
          </Avatar>
          {/* 卖家认证学校 */}
          <XStack paddingTop={radius * 0.1}>
            <Paragraph color="#ffffff" fontSize={this.formatFontSize()}>
              {this.recommend_seller.university_authenticated}
            </Paragraph>
            <Paragraph color="#ffffff" fontSize={this.formatFontSize()}>
              {this.recommend_seller.majority_authenticated}
            </Paragraph>
          </XStack>
          <XStack>
            <YStack flexDirection="column" alignItems="center">
              <Paragraph
                color="#ffffff"
                fontSize={this.formatFontSize() * 0.8}
                numberOfLines={1}
              >
                正在提供{services[0]?.category}等服务
              </Paragraph>
            </YStack>
          </XStack>
        </Card.Header>
      </Card>
    );
  }
}

export { Circle };
// // 判断是否有重叠的圆
// circlesOverlap(centerX: number, centerY: number,overlap_ratio:number): boolean {
//   return this.circles_existed.some((otherCircle) => {
//     const distance = Math.sqrt((otherCircle.centerX - centerX)**2 + (otherCircle.centerY - centerY)**2)
//     if (distance  < this.radius + otherCircle.radius + overlap_ratio) {
//       // console.log('当前半径的圆与别的圆重叠了',this.radius)
//       console.log(distance)
//       return true; // 找到重叠的圆，立即返回 true
//     }
//     return false; // 当前圆不重叠
//   });
// }

// private findEmptyPosition(overlap_ratio:number){
//   const MAX_ATTEMPTS = 100; //最大尝试次数
//   const isOverlap = this.circlesOverlap(this.centerX,this.centerY,overlap_ratio)

//   // 如果重叠则再找位置
//   if (isOverlap){
//     for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++){
//       const new_centerX = Math.random() * (global.screenWidth - 2 * this.radius)  // 防止生成超出边界的无意义位置[0,screenwidth - 2 * radius]
//       const new_centerY = Math.random() * (global.screenHeight - 2 * this.radius - 140) + 70 // 防止生成超出边界的无意义位置[50,screenwidth-50-2*radius]
//       const isOverlap = this.circlesOverlap(new_centerX,new_centerY,overlap_ratio)
//       if (!isOverlap) {
//         this.centerX = new_centerX
//         this.centerY = new_centerY
//         break
//       }
//     }
//     // 在最大次数中没有找到重叠的位置
//     if (overlap_ratio < 1){
//       console.log('进入')
//       overlap_ratio += 0.3
//       this.findEmptyPosition(overlap_ratio)

//     }else{
//       console.log('在最大次数中没有找到重叠的位置')
//       return false
//     }

//   }
//   // 返回当前圆心的坐标
//   return [this.centerX,this.centerY]
//   }
