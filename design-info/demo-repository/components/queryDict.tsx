export function QueryDict(dict, query) {
  if (!dict || dict === undefined) {
    return { label: "未知", value: query };
  }
  // console.log("dict", dict);
  const res = dict.find((item) => item.value === query);
  if (res) {
    return res;
  } else {
    return { label: query, value: query };
  }
}
