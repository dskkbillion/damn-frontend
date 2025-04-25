import React, { useState } from "react";
import Icon from "react-native-vector-icons/FontAwesome";
import { XStack, YStack, Text, Button } from "tamagui";

/*
the StarRating component is a simple star rating component that allows users to rate a product or service.
*/
const StarRating = ({ maxStars = 5, initialRating = 0, onRatingChange }) => {
  const [rating, setRating] = useState(initialRating);

  const handleStarPress = (selectedRating) => {
    setRating(selectedRating);
    if (onRatingChange) {
      onRatingChange(selectedRating);
    }
  };

  return (
    <YStack>
      <XStack space="$2" justifyContent="center">
        {[...Array(maxStars)].map((_, index) => {
          const starNumber = index + 1;
          return (
            <Button
              key={index}
              onPress={() => handleStarPress(starNumber)}
              unstyled
              paddingHorizontal="$1"
            >
              <Icon
                name="star"
                size={20}
                // fill={starNumber < rating ? "$yellow" : "$gray8"}
                color={starNumber <= rating ? "#EDB466" : "#D3D3D3"}
              />
            </Button>
          );
        })}
      </XStack>
    </YStack>
  );
};

export default StarRating;
