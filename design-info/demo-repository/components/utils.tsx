// 判断字符串是否为数字（最多两位小数）
export function isFloatNumber(value) {
  const isFloat = /^\d+(\.\d{1,2})?$/.test(value);
  return isFloat;
}

// 判断字符串是否为整数
export function isIntNumber(value) {
  const isInt = /^\d+$/.test(value);
  return isInt;
}

// 拼接参数和值到 URL
// 拼接参数和值到 URL
export const joinUrl = (...parts) => {
  if (!parts || parts.length === 0) {
    return ""; // 如果没有传入任何部分，返回空字符串
  }

  return parts
    .filter((part) => part !== undefined) // 只过滤掉 undefined，保留 0 等值
    .map((part, index) => {
      const safePart = String(part); // 确保 part 是字符串

      if (index === 0) {
        // 对于第一个部分，不移除开头的 `/`，以确保根路径存在
        return safePart.replace(/\/+$/, ""); // 只移除末尾的 `/`
      } else {
        // 对于其余部分，移除两端的 `/`
        return safePart.replace(/^\/+|\/+$/g, ""); // 移除开头和末尾的 `/`
      }
    })
    .join("/"); // 用 `/` 连接
};

export const isAxiosSuccess = (url: string) => {
  const parts = url.split("/");
  const reduxType = parts[parts.length - 1];
  // console.log("reduxType", reduxType);
  if (reduxType === "fulfilled") {
    return true;
  } else {
    return false;
  }
};
