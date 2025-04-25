import { Mic, MicOff, X } from "@tamagui/lucide-icons";
import { Audio } from "expo-av";
import { Recording, RecordingStatus } from "expo-av/build/Audio";
import { useState, useEffect } from "react";
import { StyleSheet, View, Pressable } from "react-native";
import Animated, {
  interpolate,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from "react-native-reanimated";
import { useDispatch, useSelector } from "react-redux";
import { Adapt, Button, Dialog, Sheet, Unspaced, XStack } from "tamagui";

import { useToast } from "@/hooks/hook-utils";
import { AppDispatch, fileSlice, RootState } from "@/src/store";
import React from "react";

export function VoiceDialog({
  onVoiceSend,
}: {
  onVoiceSend: (url: string) => void;
}) {
  const [open, setOpen] = useState(false);

  const [recording, setRecording] = useState<Recording>();
  const { toastSuccess, toastError } = useToast();

  const metering = useSharedValue(-100);
  const [audioMetering, setAudioMetering] = useState<number[]>([]);

  const dispatch = useDispatch<AppDispatch>();
  const chatAudios = useSelector((state: RootState) => state.file.chatAudios);

  async function startRecording() {
    try {
      console.log("Requesting permissions..");
      await Audio.requestPermissionsAsync();

      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
      });

      console.log("Starting recording..");
      // 使用旧版API方式
      const { recording: newRecording } = await Audio.Recording.createAsync(
        Audio.RecordingOptionsPresets.LOW_QUALITY,
        status => {
          metering.value = status.metering || -160;
        }
      );

      setRecording(newRecording);
      console.log("Recording started");
    } catch (err: any) {
      console.error("Failed to start recording", err);
      toastError({ title: `录音失败: ${err.message}` });
    }
  }

  async function stopRecording() {
    if (!recording) return;

    try {
      console.log("清理录音资源..");

      // 获取URI（在停止录音前）
      const uri = recording.getURI();

      try {
        // 尝试停止录音，如果已经停止会抛出错误
        console.log("停止录音..");
        await recording.stopAndUnloadAsync();
      } catch (stopError) {
        // 忽略"已卸载"错误
        console.log("录音停止时出现错误（可能已经停止）:", stopError);
      }

      // 清除录音引用
      setRecording(undefined);

      if (!uri) {
        console.log("没有获取到录音URI");
        return;
      }

      await Audio.setAudioModeAsync({ allowsRecordingIOS: false });

      // 创建 FormData
      const data = new FormData();
      data.append("file", {
        uri,
        type: "audio/mp3",
        name: `voice_${Date.now()}.mp3`,
      } as any);
      data.append("needTranscode", "true");
      data.append("targetBitRate", "16000");

      // 设置类型并上传
      await dispatch(fileSlice.file.actions.setType("chatAudio"));
      const res = await dispatch(fileSlice.file.actions.uploadFile(data));

      console.log("Upload response:", res);

      if (res.payload?.code === 200 && res.payload?.data) {
        onVoiceSend(res.payload.data);
        toastSuccess({ title: "语音发送成功" });
        setOpen(false);
      } else {
        toastError({ title: "语音发送失败" });
      }
    } catch (error) {
      console.error("Upload failed:", error);
      toastError({ title: "语音上传失败" });
    } finally {
      metering.value = -100;
    }
  }

  const animatedRedCircle = useAnimatedStyle(
    () => ({
      width: withTiming(recording ? "60%" : "100%"),
      borderRadius: withTiming(recording ? 5 : 35),
    }),
    [recording]
  );

  const animatedRecordWave = useAnimatedStyle(() => {
    const size = withTiming(
      interpolate(metering.value, [-160, -60, 0], [0, 0, -30]),
      { duration: 100 }
    );
    return {
      top: size,
      bottom: size,
      left: size,
      right: size,
      backgroundColor: `rgba(255, 45, 0, ${interpolate(
        metering.value,
        [-160, -60, -10],
        [0.7, 0.3, 0.7]
      )})`,
    };
  }, [metering.value]);

  useEffect(() => {
    return () => {
      if (recording) {
        console.log("清理录音资源");
        // 检查录音状态后再停止
        recording.getStatusAsync().then(status => {
          if (status.canRecord) {
            recording.stopAndUnloadAsync().catch(error => {
              console.log("清理录音时出错:", error);
            });
          } else {
            console.log("录音已停止，无需再次卸载");
          }
        }).catch(error => {
          console.log("获取录音状态失败:", error);
        });
      }
    };
  }, [recording]);

  const onRecordingStatusUpdate = (status) => {
    console.log("录音状态更新:", status);
    metering.value = status.metering || -160;
  };

  return (
    <>
      <Button
        alignItems="center"
        justifyContent="center"
        padding={0}
        minWidth={0}
        circular
        size="$3"
        borderWidth="0"
        onPress={() => setOpen(true)}
      >
        {recording ? <MicOff /> : <Mic />}
      </Button>

      <Sheet
        modal
        open={open}
        onOpenChange={(o) => {
          if (!o && recording) {
            stopRecording();
          }
          setOpen(o);
        }}
        snapPoints={[40]}
        dismissOnSnapToBottom
        zIndex={100000}
        animation="medium"
      >
        <Sheet.Overlay
          animation="quick"
          enterStyle={{ opacity: 0 }}
          exitStyle={{ opacity: 0 }}
          backgroundColor="transparent"
          onPress={() => {
            console.log("onPress overlay");
            if (recording) {
              stopRecording();
            }
            setOpen(false);
          }}
        />

        <Sheet.Handle />

        <Sheet.Frame
          padding="$4"
          backgroundColor="white"
          justifyContent="center"
        >
          <XStack width="100%" justifyContent="center" paddingBottom="$4">
            <View>
              <Animated.View
                key="record-wave"
                style={[styles.recordWave, animatedRecordWave]}
              />
              <Pressable
                style={styles.recordButton}
                onPress={recording ? stopRecording : startRecording}
              >
                <Animated.View
                  key="record-circle"
                  style={[styles.redCircle, animatedRedCircle]}
                />
              </Pressable>
            </View>
          </XStack>

          <Button
            position="absolute"
            top="$3"
            right="$3"
            size="$3"
            circular
            icon={X}
            onPress={() => setOpen(false)}
          />
        </Sheet.Frame>
      </Sheet>
    </>
  );
}

const styles = StyleSheet.create({
  recordWave: {
    position: "absolute",
    top: -20,
    bottom: -20,
    left: -20,
    right: -20,
    borderRadius: 1000,
  },
  recordButton: {
    width: 70,
    height: 70,
    borderRadius: 35,

    borderWidth: 3,
    borderColor: "gray",
    padding: 3,

    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "white",
  },
  redCircle: {
    backgroundColor: "orangered",
    aspectRatio: 1,
  },
});

