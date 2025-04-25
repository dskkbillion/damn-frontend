import { createAnimations } from "@tamagui/animations-react-native";
import { createInterFont } from "@tamagui/font-inter";
import { createMedia } from "@tamagui/react-native-media-driver";
import { shorthands } from "@tamagui/shorthands";
import { tokens } from "@tamagui/themes";
import { createFont, createTamagui } from "tamagui";

const animations = createAnimations({
  bouncy: {
    type: "spring",
    damping: 10,
    mass: 0.9,
    stiffness: 100,
  },
  lazy: {
    type: "spring",
    damping: 20,
    stiffness: 60,
  },
  quick: {
    type: "spring",
    damping: 20,
    mass: 1.2,
    stiffness: 250,
  },
});

const headingFont = createInterFont();

const interFont = createFont({
  family: "Inter, Helvetica, Arial, sans-serif",

  size: {
    ...headingFont.size,
    1: 12,
    2: 14,
    3: 15,
    4: 16,
    true: 14,
  },
  lineHeight: {
    1: 18, // 对应 size 1 的行高
    2: 22, // 对应 size 2 的行高
    3: 24, // 对应 size 3 的行高
    true: 40, // 默认行高
  },
  weight: {
    300: "300",
    400: "400",
    500: "500",
    600: "600",
    700: "700",
  },
  letterSpacing: {
    1: 0,
    2: -1,
    // 3 will be -1
  },
  // (native only) swaps out fonts by face/style
  face: {
    300: { normal: "InterLight", italic: "InterItalic" },
    600: { normal: "InterBold" },
  },
  defaultWeight: "600",
});

const customTokens = {
  ...tokens,
  size: {
    ...tokens.size,
    small: 12,
    true: 14,
    medium: 16,
    large: 24,
  },
};
const config = createTamagui({
  defaultFont: "body",
  animations,
  tokens: customTokens,
  shouldAddPrefersColorThemes: true,
  themeClassNameOnRoot: true,
  shorthands,
  fonts: {
    // body: bodyFont,
    body: interFont,
    heading: headingFont,
  },
  themes: {
    light: {
      red: "#BE2020",
      bottomColor: "#F2F2F2",
      bottom: "#EDEDED",
      background: "#ffffff",
      brown0: "#FFF9F4",
      brown: "#B66D0E",
      lightbrown: "#DDBC98",
      themePrimary: "#B66D0E",
      themeLight: "#D8A052",
      themeLighter: "#F2DFC1",
      themeDark: "#8A5208",
      colorPress: "#ffffff",
      black: "#191919",
      color: "#2A2A2A",
      white: "#ffffff",
      borderColor: "#F2F2F2",
      borderColorFocus: "#F2F2F2",
      gray8: tokens.color.gray8Light,
      darkGray: "#6C6C6C",
      lightGray: "#BBBBBB",
      gray7: tokens.color.gray7Light,
      gray3: "#EDEDED",
      gray0: "#F8F8F8",
      blue: "#4095E5",
      green: "#3B790A",
      text: "#ffffff",
      yellow: "#EDB466",
      successBox: "#DAF4E1",
      successText: "#476F5C",
      failBox: "#FEE2E2",
      failText: "#FF453B",
      seachBox: "#E8E8E8",
      wechat: "#02C160",
      ai_chat_bg: "#F5F5F5",
      ai_bottom_sheet_bg: "#F5F5F5",
    },
    dark: {
      background: "#000000",
      color: "#ffffff",
      // 其他主题属性
    },
  },

  media: createMedia({
    xs: { maxWidth: 660 },
    sm: { maxWidth: 800 },
    md: { maxWidth: 1020 },
    lg: { maxWidth: 1280 },
    xl: { maxWidth: 1420 },
    xxl: { maxWidth: 1600 },
    gtXs: { minWidth: 660 + 1 },
    gtSm: { minWidth: 800 + 1 },
    gtMd: { minWidth: 1020 + 1 },
    gtLg: { minWidth: 1280 + 1 },
    short: { maxHeight: 820 },
    tall: { minHeight: 820 },
    hoverNone: { hover: "none" },
    pointerCoarse: { pointer: "coarse" },
  }),
});

export default config;
