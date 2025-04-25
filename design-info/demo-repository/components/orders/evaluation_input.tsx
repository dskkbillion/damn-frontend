import React, { useState } from "react";
import {
  YStack,
  Input,
  Text,
  Button,
  Paragraph,
  XStack,
  Switch,
  Label,
} from "tamagui";

const MultilineCommentBox = ({ onSubmit, maxLength = 200 }) => {
  const [comment, setComment] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);

  const handleCommentChange = (text) => {
    if (text.length <= maxLength) {
      setComment(text);
    }
  };

  const handleSubmit = () => {
    if (comment.trim()) {
      onSubmit(comment);
      setComment("");
    }
  };

  return (
    <YStack space="$3" width="100%">
      <Input
        multiline
        numberOfLines={4}
        value={comment}
        onChangeText={handleCommentChange}
        placeholder="请输入您的评论..."
        textAlignVertical="top"
        borderWidth={1}
        borderColor="$borderColor"
        borderRadius="$2"
        padding="$2"
        height={150}
      />
      <Paragraph fontSize="$2" color="$gray8" marginLeft="auto">
        {comment.length}/{maxLength} 字
      </Paragraph>
      <XStack space="$3" alignItems="center">
        <Label htmlFor="anonymous-switch" flex={1} fontSize={14}>
          匿名评论
        </Label>
        <Switch
          id="anonymous-switch"
          checked={isAnonymous}
          onCheckedChange={setIsAnonymous}
          backgroundColor={isAnonymous ? "$brown" : "gray"}
        >
          <Switch.Thumb animation="quick" backgroundColor="#fff" />
        </Switch>
      </XStack>
      <Button
        onPress={handleSubmit}
        disabled={!comment.trim()}
        alignSelf="center"
        marginTop="$3"
        height={40}
        backgroundColor="$brown"
        width="50%"
        color="#fff"
      >
        提交评论
      </Button>
    </YStack>
  );
};

export default MultilineCommentBox;
