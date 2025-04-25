/**
 * @description 首页轮播图
 * @use 首页
 */

import React, { useCallback, useEffect, useState } from "react";
import { Dimensions } from "react-native";
import { useSharedValue } from "react-native-reanimated";
import Carousel from "react-native-reanimated-carousel";
import { useDispatch, useSelector } from "react-redux";
import { View } from "tamagui";

import { CRItem } from "./CRItem";

import { AppDispatch, RootState, slices } from "@/src/store";

const PAGE_WIDTH = Dimensions.get("window").width;
const PAGE_HEIGHT = Dimensions.get("window").height;

interface BannerState {
  index: number;
  is_plural: boolean;
  imgs: string[];
  item: any[];
}

function BannerList() {
  const dispatch = useDispatch<AppDispatch>();
  const scrollOffsetValue = useSharedValue<number>(0);
  const bannerList = useSelector((state: RootState) => state.item.bannerList);
  const [banners, setBanners] = useState<BannerState[]>([]);

  useEffect(() => {
    const fetchBannerList = async () => {
      dispatch(
        slices.item.actions.fetchBannerList({
          pageSize: 10,
          pageNum: 1,
        })
      );
    };
    fetchBannerList();
  }, []);

  useEffect(() => {
    if (bannerList.length === 0) return;
    const res = handleData(bannerList);
    setBanners(res);
  }, [bannerList]);

  // 按照是否有内容分类
  const handleData = useCallback((data: any[]): any => {
    let banners = [] as any;
    let pluralList = [] as any;
    const sortedData = data.sort((a, b) => a.sort - b.sort);
    sortedData.forEach((item) => {
      // const image = item.image;
      const fakeImages = [
        "https://gitee.com/Ryan_here/images/raw/master/do-anything-related-to-civil-engineering-bae5.jpg",
        "https://gitee.com/Ryan_here/images/raw/master/WechatIMG74.jpg",
        "https://gitee.com/Ryan_here/images/raw/01af6d33624d32fdcb91a98571dc3f4ca273dd2e/WechatIMG73.jpg",
      ];
      const image = fakeImages[Math.floor(Math.random() * fakeImages.length)];
      if (item?.content) {
        if (pluralList.length === 0) {
          pluralList.push({
            image: image,
            item: item,
          });
        } else {
          banners.push({
            index: banners.length,
            is_plural: true,
            imgs: [...pluralList.map((item: any) => item.image), image],
            item: [...pluralList.map((item: any) => item.item), item],
          });
          pluralList = [];
        }
      } else {
        banners.push({
          index: banners.length,
          is_plural: false,
          imgs: [image],
          item: [item],
        });
      }
    });

    return banners;
  }, []);

  // 按照图片的大小分类
  // const handleData = useCallback(async (data: any[]) => {
  //   let banners = [] as any;
  //   let pluralList = [] as any;

  //   const promises = data.map((item) => {
  //     return new Promise<void>((resolve) => {
  //       const image =
  //         "https://gitee.com/Ryan_here/images/raw/master/WechatIMG74.jpg";
  //       // const image = item.image;

  //       Image.getSize(
  //         image,
  //         (width, height) => {
  //           const ratio = width / height;
  //           const screenRatio = global.screenWidth / global.screenHeight;

  //           if (ratio < screenRatio) {
  //             if (pluralList.length === 0) {
  //               pluralList.push(item);
  //             } else {
  //               banners.push({
  //                 index: banners.length,
  //                 is_plural: true,
  //                 imgs: [...pluralList.map((item: any) => item.image), image],
  //               });
  //               pluralList = [];
  //             }
  //           } else {
  //             banners.push({
  //               index: banners.length,
  //               is_plural: false,
  //               is_img: true,
  //               imgs: [image],
  //             });
  //           }

  //           resolve(); // 成功处理后 resolve
  //         },
  //         (error) => {
  //           console.log("获取图像宽高失败:", error);
  //           banners.push({
  //             index: banners.length,
  //             is_plural: false,
  //             imgs: [image],
  //           });
  //           resolve(); // 处理完成后 resolve
  //         }
  //       );
  //     });
  //   });

  //   await Promise.all(promises); // 等待所有图像处理完成
  //   return banners; // 返回 banners
  // }, []);

  return (
    <View style={{ flex: 1 }} marginVertical={10}>
      <Carousel
        loop
        enabled
        defaultScrollOffsetValue={scrollOffsetValue}
        style={{ width: "100%", height: PAGE_HEIGHT * 0.2 }}
        width={PAGE_WIDTH}
        autoPlay
        autoPlayInterval={4000}
        pagingEnabled
        data={banners}
        renderItem={({ index, item }) => {
          return (
            <CRItem
              key={index}
              index={index}
              is_plural={item.is_plural}
              imgs={item.imgs}
              item={item.item}
            />
          );
        }}
      />
    </View>
  );
}

export default BannerList;
