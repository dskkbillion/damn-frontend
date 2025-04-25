const questAnswer = {
  content: {
    text: "这道题目给出了函数 ( y = lg(ax^2 + 2ax + 1) ) 并提出了两个问题：\n 1. 当函数的定义域为实数集 ( R ) 时，求 ( a ) 的取值范围；\n2. 当函数的值域为实数集 ( R ) 时，求 ( a ) 的取值范围。\n解答这道题需要利用对数函数的性质以及二次函数的特点。我们来依次解答。\n对于第一个问题：\n函数 ( y = lg(ax^2 + 2ax + 1) ) 的定义域要求内部的表达式 ( ax^2 + 2ax + 1 ) 大于 0。因为 ( ax^2 + 2ax + 1 ) 是一个二次函数，要使它对所有实数 ( x ) 都大于 0，判别式需要小于 0。所以我们要计算判别式 ( b^2 - 4ac < 0 )，即：[ (2a)^2 - 4 cdot a cdot 1 < 0 ][ 4a^2 - 4a < 0 ][ a^2 - a < 0 ][ a(a - 1) < 0 ]\n解这个不等式，我们得到 ( a ) 的取值范围是 ( 0 < a < 1 )。\n 对于第二个问题：\n 函数的值域为实数集 ( R )，即 ( y = lg(ax^2 + 2ax + 1) ) 可以取到任意实数值。这意味着 ( ax^2 + 2ax + 1 ) 必须能够取到所有的正实数值，所以 ( ax^2 + 2ax + 1 ) 必须为一个完全平方数。这样，无论 ( x ) 取什么值，( ax^2 + 2ax + 1 ) 都不会等于零，( y ) 就可以取到所有实数值。 \n 由于 ( ax^2 + 2ax + 1 ) 是 ( (ax+1)^2 ) 的形式，要使 ( (ax+1)^2 ) 对所有的 ( x ) 都大于0，( a ) 只需不等于0即可。但是由于第一个问题中已经限定了 ( a ) 的取值必须在 ( (0,1) ) 内，因此第二个问题中 ( a ) 的取值范围与第一个问题相同，即 ( 0 < a < 1 )。\n 这样我们就解决了这两个问题。如果你需要详细的步骤或者更数学的表述，请告诉我。",
    routeTo: "/(tabs)/ai_docs/question-answer-view",
  },
  isUser: false,
};

const aidocsAnswer = {
  content: {
    text: " 当生成一篇申请研究生的文书时，通常需要包括以下内容：个人介绍： 包括个人背景、教育经历、专业背景等,研究兴趣和目标： 阐述你的研究方向、兴趣爱好以及申请该专业的原因。研究经历： 描述你过去的研究项目、实习经历或相关实践经验。学术成绩： 提供你的学术成绩、考试成绩等。推荐信： 如果有的话，可以附上教授或专业人士的推荐信。未来规划： 阐述你在完成研究生学业后的职业规划和目标。",
    routeTo: "/(tabs)/ai_docs/docs",
  },
  isUser: false,
};

const restaurantAnswer = {
  content: {
    text: "设计一个吧台不仅要考虑美观，还要考虑功能性和实用性。以下是通过您上传的图片，结合关于吧台设计的建议和灵感的方案。您可以在得到复合期望的设计方案后，通过咨询专业的设计师完成最后的修正。",
    images: [
      "https://github.com/DUOSHAOKANKAN/githubTest/blob/main/1311708937166_.pic.jpg?raw=true",
    ],
  },
  isUser: false,
};

const designAnswer = {
  content: {
    text: "这是一个精致而温馨的入口通道的设计，可无缝过渡到用餐区，适合现代家居。这种可视化捕捉了时尚而实用的空间的精髓，将两个区域和谐地结合在一起。同类设计尽在更多服务商",
    images: [
      "https://github.com/DUOSHAOKANKAN/githubTest/blob/main/1331708937206_.pic.jpg?raw=true",
    ],
    routeTo: "/(tabs)/ai_docs/furnish-view",
  },
  isUser: false,
};

const travelAnswer = {
  content: {
    text: "制定一个厦门鼓浪屿的旅游规划，考虑到鼓浪屿的自然风光、历史建筑和文化遗产，可以为你提供一个精彩的一日游计划。###🚢购票建议-**提前预订**：特别是在假期期间，为了避免长时间排队或票务问题，建议至少提前8天通过“屿见厦门”平台预订船票。\n-**出发码头选择**：1.**邮轮中心厦鼓码头**：至三丘田码头35元，至内厝澳码头50元。这是旅行团常用的出发码头。\n 2.**BRT终点站“第一码头”**：至内厝澳码头50元。较少游客，每小时一班，距离景点需多走5-10分钟。\n 3.**厦门轮渡码头**：至钢琴码头，17:00后开放给游客，直达三丘田码头。\n ###🗺️路线规划1.**内厝澳码头（非假期选择三丘田码头）**-码头附近有鼓浪屿美院，有不定期的艺术展和市集，适合闲逛，游客较少，环境安逸。\n 2.**日光岩**-避开正午时段，建议上午或傍晚前往，是俯瞰鼓浪屿的绝佳位置。\n 3.**菽庄花园**-林海中的别墅，被誉为“海边的苏州园林”，美不胜收。 ###注意事项-携带身份证，准时到达。-考虑到码头的选择可能会影响你的行程安排，建议根据实际情况灵活调整。希望这个旅游规划能帮助你享受在鼓浪屿的美好时光！",
    images: [
      "https://github.com/DUOSHAOKANKAN/githubTest/blob/main/1371708941891_.pic.jpg?raw=true",

      "https://github.com/DUOSHAOKANKAN/githubTest/blob/main/1381708941902_.pic.jpg?raw=true",
    ],
  },
  isUser: false,
};

export function routeBasedOnSearch(search: string) {
  if (search.includes("题")) {
    return questAnswer;
  } else if (
    ["吧台", "酒吧", "酒桌"].some((keyword) => search.includes(keyword))
  ) {
    return restaurantAnswer;
  } else if (
    ["餐厅", "玄关", "入门"].some((keyword) => search.includes(keyword))
  ) {
    return designAnswer;
  } else if (
    ["鼓浪屿", "旅游", "厦门"].some((keyword) => search.includes(keyword))
  ) {
    return travelAnswer;
  } else if (["文书", "留学"].some((keywords) => search.includes(keywords))) {
    return aidocsAnswer;
  } else {
    return {
      content: {
        text: "你好呀,请问有什么问题？",
        images: [],
        file: "",
      },
      isUser: false,
    };
  }
}
