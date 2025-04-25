import React from 'react';
import { Button, ButtonText } from 'tamagui';

interface ThemeButtonProps {
  title: string;
  onPress: () => void;
  width?: number | string;
  height?: number | string;
  fontSize?: number;
  variant?: 'primary' | 'light' | 'dark';
  borderRadius?: number;
}

export const ThemeButton = ({
  title,
  onPress,
  width,
  height = 50,
  fontSize = 16,
  variant = 'primary',
  borderRadius = 8,
}: ThemeButtonProps) => {
  // 根据变体选择颜色
  const getBackgroundColor = () => {
    switch (variant) {
      case 'light':
        return '#D8A052';
      case 'dark':
        return '#8A5208';
      default:
        return '#B66D0E';
    }
  };

  return (
    <Button
      backgroundColor={getBackgroundColor()}
      width={width}
      height={height}
      borderRadius={borderRadius}
      onPress={onPress}
      pressStyle={{
        opacity: 0.8,
        scale: 0.98,
        backgroundColor: variant === 'primary' ? '#8A5208' : variant === 'light' ? '#B66D0E' : '#6A3F06',
      }}
      animation="bouncy"
    >
      <ButtonText color="white" fontSize={fontSize}>
        {title}
      </ButtonText>
    </Button>
  );
};
