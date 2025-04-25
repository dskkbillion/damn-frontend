/**
 * @description 支付底部弹窗
 */
import { router } from "expo-router";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Image, Text, TouchableWithoutFeedback } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { SvgXml } from "react-native-svg";
import FeatherIcon from "react-native-vector-icons/Feather";
import { useDispatch, useSelector } from "react-redux";
import {
  Button,
  ButtonText,
  H1,
  Label,
  Paragraph,
  RadioGroup,
  Separator,
  Sheet,
  SizeTokens,
  XStack,
  YStack,
} from "tamagui";

import { ItemFeaturesContent } from "./itemFeaturesContent";

import Alipay from "../../sdk/payment/helloworld";
import { AppDispatch, store, slices } from "@/src/store";
import { toast } from "../styled/toast";
import { useGlobalContext } from "../system/globalContext";
import { alert } from "@/components/styled/alert";
import { ThemeButton } from "@/components/styled/theme_button";
// import Alipay from "../../sdk/payment/alipay";

export function PaymentBottomSheet({
  isShow,
  item,
  tenantId,
  purchaseServiceType,
  source_page,
}: {
  isShow: (isOpen: boolean) => void;
  item: any;
  tenantId: number;
  purchaseServiceType: string;
  source_page?: string;
}) {
  const dispatch = useDispatch<AppDispatch>();
  const snapPoints = [90]; //表单停留在90%的高度
  const [isOpen, setIsOpen] = useState(true);
  const [paymentMethod, setPaymentMethod] = useState("alipay");
  const onClose = () => {
    setIsOpen(false);
    isShow(false);
  };

  let variant;
  if (purchaseServiceType === "bsc") {
    variant = item?.variants?.[0];
  } else if (purchaseServiceType === "std") {
    variant = item?.variants?.[1];
  } else if (purchaseServiceType === "prem") {
    variant = item?.variants?.[2];
  }

  const handlePay = useCallback(
    async ({ paymentMethod }: { paymentMethod: string }) => {
      // 创建订单

      const createOrder = async () => {
        const data = {
          remark: "订单备注",
          tenantId,
          items: [
            {
              productId: item?.id,
              variantId: variant?.id,
              quantity: 1,
            },
          ],
        };
        const res = await dispatch(
          slices.order.actions.OrderCreate(data)
        ).unwrap();
        return res?.data?.id;
      };

      const fetchPaymentParams = async () => {
        let businessId;
        if (source_page === "service_tobepaid") {
          businessId = item?.items?.[0]?.orderId;
        } else {
          businessId = await createOrder();
        }
        const paramsOfPayment = {
          scene: "order",
          payway: paymentMethod,
          businessId,
        };
        return paramsOfPayment;
      };

      try {
        // 余额支付
        if (paymentMethod === "balance") {
          alert({
            title: "余额支付",
            message: "是否使用余额支付？",
            buttons: [
              {
                text: "取消",
                style: "cancel",
              },
              {
                text: "确定",
                onPress: async () => {
                  const paramsOfPayment = await fetchPaymentParams();
                  const businessId = paramsOfPayment.businessId;
                  const res = await dispatch(
                    slices.order.actions.payOrder(paramsOfPayment)
                  ).unwrap();
                  if (res?.code === 200) {
                    router.push({
                      pathname: "/(outer)/reminder/payment",
                      params: {
                        orderId: businessId,
                        payResCode: res?.code,
                      },
                    });
                  }
                  toast({
                    title: res?.msg,
                  });
                },
              },
            ],
          });
        }

        // 调用支付宝支付SDK
        if (paymentMethod === "alipay") {
          // 支付订单
          const paramsOfPayment = await fetchPaymentParams();
          const businessId = paramsOfPayment.businessId;
          const res = await dispatch(
            slices.order.actions.payOrder(paramsOfPayment)
          ).unwrap();
          if (res?.code === 200) {
            try {
              // res.data 是服务器返回的支付字符串
              const result = await Alipay.pay(res.data);

              toast({
                title: result.memo,
              });

              router.push({
                pathname: "/(outer)/reminder/payment",
                params: {
                  orderId: businessId,
                  payResCode: result.resultStatus,
                },
              });
            } catch (error) {
              toast({
                title: "未知错误",
              });
              router.push({
                pathname: "/(outer)/reminder/payment",
                params: {
                  orderId: 517,
                  payResCode: 4000,
                },
              });
            }
          } else {
            toast({
              title: res?.data?.msg,
            });
          }
        }
      } catch (err) {
        console.log("fail to pay order", err);
      }

      // 关闭支付底部弹窗
      onClose();
    },
    []
  );

  useEffect(() => {
    const fetchItemDetail = async () => {
      await dispatch(
        slices.item.actions.fetchItemDetail({
          id: Number(item?.items?.[0]?.productId),
        })
      );
    };

    if (source_page === "service_tobepaid") {
      fetchItemDetail();
    }
  }, [source_page]);

  return (
    <Sheet
      modal
      open={isOpen}
      // defaultOpen
      forceRemoveScrollEnabled={isOpen}
      onOpenChange={onClose}
      snapPoints={snapPoints}
      dismissOnSnapToBottom
      position={0}
      zIndex={100_000}
      disableDrag
      animation="lazy"
    >
      <Sheet.Overlay
        animation="lazy"
        enterStyle={{ opacity: 0 }}
        exitStyle={{ opacity: 0 }}
      />
      <Sheet.Frame>
        <PaymentComp
          purchaseServiceType={purchaseServiceType}
          onClose={onClose}
          paymentMethod={paymentMethod}
          setPaymentMethod={setPaymentMethod}
        />
        {/* -----------一键盘支付------------ */}
        <XStack
          flexDirection="row"
          width="100%"
          height={200}
          paddingBottom="$6"
          justifyContent="center"
        >
          <ThemeButton
            width="80%"
            height={40}
            title="立即支付"
            variant="primary"
            onPress={() => handlePay({ paymentMethod })}
          />
        </XStack>
      </Sheet.Frame>
    </Sheet>
  );
}

function PaymentComp({
  purchaseServiceType,
  onClose,
  paymentMethod,
  setPaymentMethod,
}) {
  const itemDetail = useSelector((state: any) => state.item.ItemDetail);
  const [expanded, setExpanded] = useState(false);

  const { screenWidth, screenHeight } = useGlobalContext();

  const Materials = useMemo(() => {
    if (
      itemDetail &&
      itemDetail?.productMaterials &&
      itemDetail?.productMaterials.length > 0
    ) {
      return itemDetail?.productMaterials.filter(
        (material) => material.type !== "PROBLEM"
      );
    }
    return [];
  }, [itemDetail]);

  // 设定显示的行数
  const maxVisibleItems = 5;
  const shouldShowExpand =
    Materials.length + Object.keys(Materials).length > maxVisibleItems;

  let variant;
  if (purchaseServiceType === "bsc") {
    variant = itemDetail?.variants?.[0];
  } else if (purchaseServiceType === "std") {
    variant = itemDetail?.variants?.[1];
  } else {
    variant = itemDetail?.variants?.[2];
  }

  const handlePressRadio = (value) => {
    setPaymentMethod(value);
  };

  return (
    <YStack
      flexDirection="column"
      width="100%"
      height="90%"
      backgroundColor="$background"
    >
      {/* --------商品展示--------- */}
      <XStack
        flexDirection="row"
        width="100%"
        height="15%"
        alignItems="center"
        paddingHorizontal="4%"
        paddingVertical="4%"
        backgroundColor="$background"
      >
        <Image
          resizeMode="stretch"
          source={{
            width: screenWidth * 0.35,
            height: screenHeight * 0.1,
            uri: itemDetail?.images?.[0],
          }}
        />
        <YStack marginHorizontal="$3" width="100%" flex={1} gap="10%">
          <Text numberOfLines={1} style={{ fontWeight: "800", fontSize: 16 }}>
            {itemDetail?.description ? itemDetail?.description.slice(0, 8) : ""}
          </Text>
          <Text
            numberOfLines={1}
            style={{
              fontWeight: "800",
              width: "40%",
              fontSize: 30,
              color: "#B66D0E",
            }}
          >
            <Text style={{ fontSize: 15 }}>¥</Text>
            {variant?.sellingPrice}
          </Text>
        </YStack>
        <Button
          height="auto"
          onPress={onClose}
          style={{
            marginLeft: "auto",
          }}
          pressStyle={{
            backgroundColor: "transparent",
            borderColor: "transparent",
            opacity: 0.8,
          }}
        >
          <FeatherIcon name="x" size={30} color="black" />
        </Button>
      </XStack>

      <SafeAreaView
        edges={["bottom"]}
        style={{
          flex: 1,
          height: "auto",
        }}
      >
        <Sheet.ScrollView
          style={{
            width: "100%",
          }}
        >
          <Paragraph
            fontSize={15}
            marginLeft="4%"
            fontWeight="600"
            paddingTop="$3"
          >
            此订单需要提供
          </Paragraph>
          <YStack flexDirection="column" marginHorizontal="4%">
            {Materials.slice(
              0,
              expanded ? Materials.length : maxVisibleItems
            ).map((material, id) => (
              <XStack key={id} alignItems="center" gap="$2">
                <Paragraph>
                  {id + 1}. {material?.type === "TEXT" ? "文本" : "文件"}:
                </Paragraph>
                <Text>{material?.question}</Text>
              </XStack>
            ))}

            {shouldShowExpand && (
              <Button
                marginTop={10}
                unstyled
                onPress={() => setExpanded(!expanded)}
              >
                <ButtonText color="$blue">
                  {" "}
                  {expanded ? "收起" : "展开"}
                </ButtonText>
              </Button>
            )}
          </YStack>

          {/* -------支付方式选择-------- */}
          <Separator marginTop="$2" />
          <H1 fontSize={15} marginLeft="4%">
            支付方式
          </H1>

          <RadioGroup
            flexDirection="column"
            justifyContent="center"
            alignItems="flex-start"
            marginLeft="4%"
            space="$3"
            aria-labelledby="Select one item"
            name="form"
            value={paymentMethod}
            onValueChange={handlePressRadio}
          >
            <TouchableWithoutFeedback
              style={{ width: global.screenWidth }}
              onPress={() => handlePressRadio("alipay")}
            >
              <XStack flexDirection="row" alignItems="center" space="$3">
                <RadioGroup.Item
                  size="$4"
                  value="alipay"
                  backgroundColor={
                    paymentMethod === "alipay" ? "$black" : "transparent"
                  }
                  borderColor={
                    paymentMethod === "alipay" ? "transparent" : "black"
                  }
                >
                  <RadioGroup.Indicator
                    borderColor="#ffffff"
                    backgroundColor="#ffffff"
                  />
                </RadioGroup.Item>
                <SvgXml
                  width={30}
                  height={30}
                  xml={`<svg t="1706083635307" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="4217" width="200" height="200"><path d="M860.16 0C950.272 0 1024 73.889684 1024 164.163368v531.509895s-32.768-4.122947-180.224-53.355789c-40.96-14.362947-96.256-34.896842-157.696-57.478737 36.864-63.595789 65.536-137.485474 86.016-215.444211h-202.752v-71.841684h247.808V256.512h-247.808V135.437474h-100.352c-18.432 0-18.432 18.458947-18.432 18.458947v104.663579H200.704v41.040842h249.856v69.793684H243.712v41.013895H645.12c-14.336 51.307789-34.816 98.519579-57.344 141.608421-129.024-43.115789-268.288-77.985684-356.352-55.403789-55.296 14.362947-92.16 38.992842-112.64 63.595789-96.256 116.978526-26.624 295.504842 176.128 295.504842 120.832 0 237.568-67.718737 327.68-178.526316C757.76 742.858105 1024 853.692632 1024 853.692632v6.144C1024 950.110316 950.272 1024 860.16 1024H163.84C73.728 1024 0 950.137263 0 859.836632V164.163368C0 73.889684 73.728 0 163.84 0h696.32zM268.126316 553.121684c93.049263-10.374737 180.062316 26.974316 283.270737 78.874948-74.886737 95.501474-165.941895 155.701895-256.970106 155.701894-157.830737 0-204.368842-126.652632-125.466947-197.200842 26.300632-22.851368 72.838737-35.301053 99.166316-37.376z" fill="#00A0EA" p-id="4218"></path></svg> `}
                />
                <Text style={{ fontWeight: "500" }}>支付宝支付</Text>
              </XStack>
            </TouchableWithoutFeedback>
            {/* <TouchableWithoutFeedback
              style={{ width: global.screenWidth }}
              onPress={() => handlePressRadio("wemini")}
            >
              <XStack flexDirection="row" alignItems="center" space="$3">
                <RadioGroup.Item
                  size="$4"
                  value="wemini"
                  backgroundColor={
                    paymentMethod === "wemini" ? "$black" : "transparent"
                  }
                  borderColor={
                    paymentMethod === "wemini" ? "transparent" : "black"
                  }
                >
                  <RadioGroup.Indicator
                    borderColor="#ffffff"
                    backgroundColor="#ffffff"
                  />
                </RadioGroup.Item>
                <SvgXml
                  width={30}
                  height={30}
                  xml={`<svg t="1706084224612" class="icon" viewBox="0 0 1144 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1626" width="200" height="200"><path d="M436.314353 632.771765c-68.517647 36.321882-78.667294-20.389647-78.667294-20.389647l-85.835294-190.524236c-33.039059-90.533647 28.581647-40.839529 28.581647-40.839529s52.856471 38.038588 93.003294 61.229176c40.086588 23.190588 85.835294 6.806588 85.835294 6.806589l561.212235-246.362353C936.899765 80.112941 765.891765 0 572.235294 0 256.180706 0 0 213.232941 0 476.310588c0 151.311059 84.811294 285.967059 216.937412 373.248l-23.792941 130.288941s-11.625412 38.038588 28.611764 20.389647c27.437176-12.047059 97.370353-55.115294 138.992941-81.347764 65.445647 21.684706 136.734118 33.731765 211.486118 33.731764 316.024471 0 572.235294-213.232941 572.235294-476.310588 0-76.197647-21.594353-148.178824-59.843764-212.028235-178.808471 102.309647-594.733176 340.118588-648.312471 368.489412z" fill="#43C93E" p-id="1627"></path></svg>`}
                />
                <Text style={{ fontWeight: "500" }}>微信支付</Text>
              </XStack>
            </TouchableWithoutFeedback> */}
            <TouchableWithoutFeedback
              style={{ width: global.screenWidth }}
              onPress={() => handlePressRadio("balance")}
            >
              <XStack flexDirection="row" alignItems="center" space="$3">
                <RadioGroup.Item
                  size="$4"
                  value="balance"
                  backgroundColor={
                    paymentMethod === "balance" ? "$black" : "transparent"
                  }
                  borderColor={
                    paymentMethod === "balance" ? "transparent" : "black"
                  }
                >
                  <RadioGroup.Indicator
                    borderColor="#ffffff"
                    backgroundColor="#ffffff"
                  />
                </RadioGroup.Item>
                <SvgXml
                  width={32}
                  height={32}
                  xml={`<svg t="1730801261884" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="5625" width="200" height="200"><path d="M512.512 47.616c-254.464 0-460.8 206.336-460.8 460.8s206.336 460.8 460.8 460.8 460.8-206.336 460.8-460.8-206.336-460.8-460.8-460.8z m144.896 445.952v46.592h-114.176v64.512h114.176v47.616h-114.176v93.696H484.352v-93.696H365.568v-47.616h118.272v-64.512H365.568v-46.592h100.864l-122.88-211.456H409.6c57.856 104.96 92.672 172.032 104.96 200.192h1.024c4.096-11.776 15.872-34.816 34.304-70.144l70.656-130.048h62.464l-124.416 211.968h98.816z" fill="#FE9C01" p-id="5626"></path></svg>`}
                />
                <Text style={{ fontWeight: "500" }}>余额支付</Text>
              </XStack>
            </TouchableWithoutFeedback>
          </RadioGroup>

          {/* ------------交易提醒----------*/}
          <XStack
            flexDirection="row"
            marginHorizontal="4%"
            width="90%"
            justifyContent="center"
          >
            <Text style={{ marginTop: 10 }}>
              警惕站外交易，平台全天候监管，交易更安全
            </Text>
          </XStack>

          {/* ------------订单详情------------ */}

          <Separator marginTop="$2" />
          <H1 fontSize={15} marginLeft="4%">
            订单详情
          </H1>
          <YStack marginHorizontal="4%">
            <YStack>
              <Text style={{ fontSize: 15 }}>
                {itemDetail?.name}-{itemDetail?.variants?.[0]?.name}
              </Text>
            </YStack>
            <ItemFeaturesContent variant={variant} />
          </YStack>
          <Separator marginTop="$3" />
          {/* -----------其他------------ */}
          <YStack
            marginTop="$3"
            marginHorizontal="$3"
            paddingBottom={100}
            space="$2"
          >
            <XStack
              justifyContent="space-between"
              alignItems="center"
              marginRight="$3"
            >
              <Paragraph style={{ fontSize: 15 }}>总计</Paragraph>
              <Paragraph style={{ fontSize: 15 }}>
                {variant?.sellingPrice}
              </Paragraph>
            </XStack>

            <XStack
              justifyContent="space-between"
              alignItems="center"
              marginRight="$3"
            >
              <Paragraph style={{ fontSize: 15 }}>交付可修改次数</Paragraph>
              <Paragraph style={{ fontSize: 15 }}>{variant?.editNum}</Paragraph>
            </XStack>

            <XStack
              justifyContent="space-between"
              alignItems="center"
              marginRight="$3"
            >
              <Paragraph style={{ fontSize: 15 }}>交付时长</Paragraph>
              <Paragraph style={{ fontSize: 15 }}>
                {variant?.deliveryDay}天
              </Paragraph>
            </XStack>

            <XStack
              justifyContent="space-between"
              alignItems="center"
              marginRight="$3"
            >
              <Paragraph style={{ fontSize: 15 }}>折扣</Paragraph>
              <Paragraph style={{ fontSize: 15 }}>总计</Paragraph>
              <Paragraph style={{ fontSize: 15 }}>交付日期</Paragraph>
            </XStack>

            <YStack space="$4" flexDirection="column">
              <Button
                width={100}
                height={50}
                backgroundColor="#000000"
                unstyled
              >
                <ButtonText color="$background">优惠券</ButtonText>
              </Button>
              <Text style={{ fontSize: 15 }}>¥ {variant?.sellingPrice}</Text>
              {/* <Text style={{ fontSize: 15 }}>{delivery_date}</Text> */}
            </YStack>
          </YStack>
        </Sheet.ScrollView>
      </SafeAreaView>
    </YStack>
  );
}

// Radio setting
export function RadioGroupItemWithLabel(props: {
  size: SizeTokens;
  value: string;
  label: string;
  svg: string;
  svg_height: number;
}) {
  const id = `radiogroup-${props.value}`;
  return (
    <XStack width="100%" alignItems="center">
      <RadioGroup.Item value={props.value} id={id} size={props.size}>
        <RadioGroup.Indicator backgroundColor="$blue" />
      </RadioGroup.Item>

      <SvgXml
        xml={props.svg}
        height={props.svg_height}
        width={50}
        style={{ marginLeft: 20 }}
      />
      <Label size="$5" htmlFor={id}>
        {props.label}
      </Label>
    </XStack>
  );
}
