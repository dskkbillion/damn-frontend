import React from "react";
import WordCloud from "rn-wordcloud";

const WorldCloudComponent = () => {
  const data = [
    // { text: "happy", value: 8 },
    // { text: "joyful", value: 6 },
    // { text: "sad", value: 3 },
    // { text: "exciting", value: 7 },
    // { text: "angry", value: 4 },
    // { text: "hopeful", value: 8 },
    // { text: "inspiring", value: 9, color: "green" },
    // { text: "dismal", value: 3 },
    { text: "gloomy", value: 4 },
    { text: "boring", value: 4 },
    { text: "ordinary", value: 5 },
    { text: "satisfied", value: 7 },
    { text: "pleasing", value: 8 },
    // Add more words as needed
  ];

  return (
    <WordCloud
      options={{
        words: data,
        verticalEnabled: true,
        minFont: 30,
        maxFont: 50,
        fontOffset: 1,
        width: global.screenWidth,
        height: 200,
        fontFamily: "Arial",
      }}
    />
  );
};

export default WorldCloudComponent;
