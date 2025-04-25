import { service, ServiceDataset } from "./services";

export interface transactions {
  transaction_id: number;
  // buyer_user_id: number;
  seller_id: number;
  service_id: number;
  transaction_amount: number;
  transaction_date: Date;
  transaction_state: number;
  service_level: string;
}

const serviceMap: Map<string, service> = new Map<string, service>();

const generateData = (count: number): transactions[] => {
  const data: transactions[] = [];
  const states = [
    "toBePaid",
    "inProgress",
    "toBeEvaluated",
    "evaluated",
    "refund",
  ]; // 待支付、进行中、待评价、已评价、售后

  const status = [
    "successToCreate", // 订单创建成功(0)
    "failToCreate", // 订单创建失败(0)

    "successToPay", // 订单支付成功(1)
    "failToPay", // 订单支付失败(1)

    "successToSubReqir", // 要求提交成功(2)
    "failToSubReqir", // 要求提交失败(2)

    "successToStart", // 订单开始成功（卖家同意接单）(3)
    "failToStart", // 订单开始失败（卖家拒绝接单）(3)

    "successToDelivery", // 交付成功(4)
    "failToDelivery", // 交付失败(未交付、逾期交付)(4)

    "successToComfirm", // 确认接单成功(5)
    "failToComfirm", // 拒绝接单(5)
    "successToApplyForRevision", // 申请修改成功(5)
    "failToApplyForRevision", // 申请修改失败(5)
    "successToApplyForRedo", // 申请重做成功(5)
    "failToApplyForRedo", // 申请重做失败(5)

    "successToEval", // 评价成功(6)
    "failToEval", // 评价失败(6)

    "successToRefund", // 买家退款成功(7)
    "failToRefund", // 买家退款失败(卖家拒绝退款/买家撤销退款) (7)
    "successToCancel", // 取消订单成功(7)
    "failToCancel", // 取消订单失败(7)

    "successToMediation", // 申请调解成功(8)
    "failToMediation", // 申请调解失败(8)

    "successToClose", // 订单关闭成功(9)
    "failToClose", // 订单关闭失败(9)
  ];

  // status in progress for user
  const inProgressStatus = [
    "awaitingPayment", // 等待支付(0)
    "awaitingSubmission", // 等待提交要求(1)
    "awaitingStart", // 等待开始(卖家接单)(2)
    "awaitingDelivery", // 等待卖家交付 (3)
    "awaitingComfirm", // 等待确认(4)
    "awaitingEvaluation", // 等待评价(5)
    "completed", // 订单完成(6)
    "awaitingAddition", // 等待重传材料(7)
    "applyingForRevision", // 申请修改(8)
    "applyingForRedo", // 申请重做(9)
    "awaitingReDelivery", // 等待卖家重交付(10)
    "applyingForRefund", // 买家提交退款(11)
    "awaitingAgreeWithRefund", // 等待卖家同意退款(12)
    "awaitingRefund", // 等待款项(13)
    "applyingForMediation", // 申请调解(14)
  ];

  // status completed for user
  // const completedEvent = [
  //   "successToCreate", // 订单创建成功(0)
  //   "successToPay", // 订单支付成功(1)
  //   "successToSubReqir", // 要求提交成功(2)
  //   "successToStart", // 订单开始成功（卖家同意接单）(3)
  //   "successToDelivery" , // 交付成功(4)
  //   "successToComfirm" , // 确认接单成功(5)
  //   "successToEval", // 评价成功(6)
  // ]

  const serviceLevels = ["basic", "standard", "premium"]; //购买服务的等级
  // 向ServiceDataset中随机取值组成transaction
  for (let i = 1; i <= count; i++) {
    const randomIndex = Math.floor(Math.random() * ServiceDataset.length);
    const randomService = ServiceDataset[randomIndex];

    // status in progress for user
    const randomState = Math.floor(Math.random() * inProgressStatus.length);

    // spec of the transaction
    const serviceLevel =
      serviceLevels[Math.floor(Math.random() * serviceLevels.length)];

    data.push({
      transaction_id: i,
      seller_id: randomService.provider_user_id,
      service_id: randomService.service_id,
      transaction_amount: randomService[serviceLevel].price, // 后续需判断购买的是什么等级服务的价格
      transaction_date: new Date(),
      transaction_state: randomState,
      service_level: serviceLevel,
    });
  }
  return data;
};

export const TransactionDataset: transactions[] = generateData(20); //构造五个transaction
