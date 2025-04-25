import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';
import LinearGradient from 'react-native-linear-gradient';

interface GradientButtonProps {
  title: string;
  onPress: () => void;
  width?: number | string;
  height?: number | string;
  fontSize?: number;
  startColor?: string;
  endColor?: string;
  borderRadius?: number;
}

export const GradientButton = ({
  title,
  onPress,
  width = '100%',
  height = 50,
  fontSize = 16,
  startColor = '#B66D0E',
  endColor = '#8A5208',
  borderRadius = 8,
}: GradientButtonProps) => {
  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={onPress}
      style={[styles.buttonContainer, { width, height }]}
    >
      <LinearGradient
        colors={[startColor, endColor]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 0 }}
        style={[styles.gradient, { borderRadius }]}
      >
        <Text style={[styles.text, { fontSize }]}>{title}</Text>
      </LinearGradient>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  buttonContainer: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  gradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: 'white',
    fontWeight: '600',
  },
});
