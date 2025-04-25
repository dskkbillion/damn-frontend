const createExpoWebpackConfigAsync = require("@expo/webpack-config");

module.exports = async function (env, argv) {
  const config = await createExpoWebpackConfigAsync(env, argv);

  // 自定义配置
  config.resolve.alias = {
    ...config.resolve.alias,
    "react-native$": "react-native-web",
  };

  return config;
};
