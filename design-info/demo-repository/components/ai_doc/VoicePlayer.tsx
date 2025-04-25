import { Play, Pause } from "@tamagui/lucide-icons";
import { Audio } from "expo-av";
import React, { useEffect, useState, useRef } from "react";
import { ActivityIndicator, Image, ImageSourcePropType } from "react-native";
import { Button, Paragraph, Stack, XStack, Text, View } from "tamagui";

interface VoicePlayerProps {
  uri: string;
  color?: string;
}

// 全局音频管理器
class AudioManager {
  static currentPlayer: AudioPlayerInstance | null = null;

  static async switchPlayer(newPlayer: AudioPlayerInstance) {
    try {
      if (this.currentPlayer && this.currentPlayer !== newPlayer) {
        await this.currentPlayer.pauseAndReset();
      }
      this.currentPlayer = newPlayer;
    } catch (error) {
      console.error("Error switching player:", error);
    }
  }
}

class AudioPlayerInstance {
  private sound: any | null = null; // 使用any类型避免类型错误
  private onPlaybackStatusUpdate: ((isPlaying: boolean, durationMillis?: number) => void) | null = null;
  private isLoaded: boolean = false;
  private isPlaying: boolean = false;
  private uri: string = "";
  private durationMillis: number = 0;

  async load(uri: string) {
    try {
      this.uri = uri;
      await this.unload();
      await this.createSound();
    } catch (error) {
      console.error("Error loading audio:", error);
      throw error;
    }
  }

  private async createSound() {
    try {
      console.log("开始创建音频实例，URI:", this.uri);

      // 确保URI有效
      if (!this.uri || typeof this.uri !== 'string' || !this.uri.trim()) {
        throw new Error("Invalid audio URI");
      }

      // 创建音频实例
      const { sound } = await Audio.Sound.createAsync(
        { uri: this.uri },
        {
          shouldPlay: false,
          progressUpdateIntervalMillis: 100,
          playsInSilentModeIOS: true, // 确保在静音模式下也能播放
        },
        (status) => {
          if (status.isLoaded) {
            this.isPlaying = status.isPlaying;
            this.onPlaybackStatusUpdate?.(status.isPlaying, status.durationMillis);
            if (status.didJustFinish) {
              this.isPlaying = false;
              this.onPlaybackStatusUpdate?.(false, this.durationMillis);
              // 不再自动重新创建音频实例，避免资源问题
              // 只重置播放位置
              this.sound?.setPositionAsync(0).catch(e => console.log("重置播放位置失败:", e));
            }
          }
        }
      );

      console.log("音频实例创建成功，获取状态");
      const status = await sound.getStatusAsync();
      if (!status.isLoaded) {
        console.error("音频加载失败，状态:", status);
        throw new Error("Failed to load audio");
      }

      // 保存音频时长
      if (status.durationMillis) {
        this.durationMillis = status.durationMillis;
        console.log("音频时长:", this.durationMillis);
      }

      this.sound = sound;
      this.isLoaded = true;
      console.log("音频实例创建和加载完成");
    } catch (error) {
      console.error("创建音频实例失败:", error);
      this.isLoaded = false;
      this.sound = null;
      throw error;
    }
  }

  private async recreateSound() {
    try {
      await this.unload();
      await this.createSound();
    } catch (error) {
      console.error("Error recreating sound:", error);
    }
  }

  async play() {
    try {
      console.log("开始播放音频");

      // 如果没有音频实例或未加载，尝试创建
      if (!this.sound || !this.isLoaded) {
        console.log("音频未加载，尝试创建");
        await this.createSound();
      }

      // 先切换播放器
      await AudioManager.switchPlayer(this);

      // 获取当前状态
      const status = await this.sound?.getStatusAsync();
      console.log("播放前状态:", status);

      // 如果已经播放完毕，重置位置
      if (status?.isLoaded &&
          (status.didJustFinish ||
           (status.positionMillis !== undefined &&
            status.durationMillis !== undefined &&
            status.positionMillis >= status.durationMillis - 100))) {
        console.log("音频已播放完毕，重置位置");
        await this.sound.setPositionAsync(0);
      }

      // 播放音频
      console.log("开始播放");
      await this.sound?.playAsync();
      this.isPlaying = true;
      console.log("播放成功");
    } catch (error) {
      console.error("播放音频失败:", error);
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);

      // 尝试重新创建音频实例
      try {
        console.log("尝试重新创建音频实例");
        await this.unload();
        await this.createSound();
      } catch (recreateError) {
        console.error("重新创建音频实例失败:", recreateError);
      }

      throw error;
    }
  }

  async pause() {
    try {
      if (!this.sound || !this.isLoaded || !this.isPlaying) return;
      await this.sound.pauseAsync();
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);
    } catch (error) {
      console.error("Error pausing audio:", error);
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);
    }
  }

  async pauseAndReset() {
    try {
      if (!this.sound || !this.isLoaded) return;

      if (this.isPlaying) {
        await this.sound.pauseAsync();
        this.isPlaying = false;
        this.onPlaybackStatusUpdate?.(false);
      }

      await this.recreateSound();
    } catch (error) {
      console.error("Error pausing and resetting audio:", error);
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);
    }
  }

  async unload() {
    try {
      console.log("开始卸载音频");
      if (this.sound) {
        // 先暂停播放
        if (this.isLoaded && this.isPlaying) {
          console.log("音频正在播放，先暂停");
          try {
            await this.sound.pauseAsync();
          } catch (pauseError) {
            console.log("暂停音频失败，继续卸载:", pauseError);
          }
        }

        // 卸载音频
        console.log("卸载音频实例");
        try {
          await this.sound.unloadAsync();
        } catch (unloadError) {
          console.log("卸载音频实例失败，可能已经卸载:", unloadError);
        }

        this.sound = null;
      }
      this.isLoaded = false;
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);
      console.log("音频卸载完成");
    } catch (error) {
      console.error("卸载音频时出错:", error);
      // 即使出错，也重置状态
      this.sound = null;
      this.isLoaded = false;
      this.isPlaying = false;
      this.onPlaybackStatusUpdate?.(false);
    }
  }

  setPlaybackStatusUpdate(callback: (isPlaying: boolean, durationMillis?: number) => void) {
    this.onPlaybackStatusUpdate = callback;
    // 如果已经加载，立即回调当前状态和时长
    if (this.isLoaded) {
      callback(this.isPlaying, this.durationMillis);
    }
  }

  getDuration(): number {
    return this.durationMillis;
  }
}

// 修改格式化时间函数，使用秒数加双引号的格式
function formatDuration(milliseconds: number): string {
  if (!milliseconds) return "0''";

  const totalSeconds = Math.floor(milliseconds / 1000);
  return `${totalSeconds}''`;
}

export function VoicePlayer({ uri, color = "#000" }: VoicePlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [duration, setDuration] = useState(0);
  const [loadError, setLoadError] = useState(false);
  const playerRef = useRef<AudioPlayerInstance | null>(null);

  useEffect(() => {
    const initAudio = async () => {
      try {
        console.log("初始化音频播放器，URI:", uri);
        setIsLoading(true);
        setLoadError(false);

        // 确保URI有效
        if (!uri || typeof uri !== 'string' || !uri.trim()) {
          console.error("无效的音频URI:", uri);
          setLoadError(true);
          return;
        }

        // 设置音频模式
        try {
          await Audio.setAudioModeAsync({
            playsInSilentModeIOS: true,
            staysActiveInBackground: true,
            shouldDuckAndroid: true,
            allowsRecordingIOS: false,
            // 移除可能导致错误的中断模式设置
          });
          console.log("音频模式设置成功");
        } catch (audioModeError) {
          console.error("设置音频模式失败:", audioModeError);
          // 继续尝试加载音频，不要因为模式设置失败而中断
        }

        // 创建播放器实例
        const player = new AudioPlayerInstance();

        // 尝试加载音频
        try {
          await player.load(uri);
          console.log("音频加载成功");

          // 更新回调函数，接收播放状态和时长
          player.setPlaybackStatusUpdate((playing, durationMs) => {
            setIsPlaying(playing);
            if (durationMs) setDuration(durationMs);
          });

          playerRef.current = player;
        } catch (loadError) {
          console.error("加载音频失败:", loadError);
          setLoadError(true);
          // 不要抛出错误，让组件继续渲染
        }
      } catch (error) {
        console.error("初始化音频时出错:", error);
        setLoadError(true);
      } finally {
        setIsLoading(false);
      }
    };

    // 调用初始化函数
    initAudio();

    // 清理函数
    return () => {
      console.log("组件卸载，清理音频资源");
      if (playerRef.current) {
        try {
          playerRef.current.unload();
        } catch (error) {
          console.error("卸载音频时出错:", error);
        }
        playerRef.current = null;
      }
    };
  }, [uri]);

  const handlePlayPause = async () => {
    try {
      console.log("处理播放/暂停，当前状态:", isPlaying);

      if (!playerRef.current) {
        console.log("播放器实例不存在，尝试重新初始化");
        setIsLoading(true);

        try {
          // 重新初始化播放器
          const player = new AudioPlayerInstance();
          await player.load(uri);

          player.setPlaybackStatusUpdate((playing, durationMs) => {
            setIsPlaying(playing);
            if (durationMs) setDuration(durationMs);
          });

          playerRef.current = player;
          await player.play();
        } catch (initError) {
          console.error("重新初始化播放器失败:", initError);
          setLoadError(true);
        } finally {
          setIsLoading(false);
        }
        return;
      }

      if (isPlaying) {
        console.log("正在播放，执行暂停");
        await playerRef.current.pause();
      } else {
        console.log("未播放，执行播放");
        await playerRef.current.play();
      }
    } catch (error) {
      console.error("处理播放/暂停时出错:", error);
      setIsPlaying(false);

      // 尝试重置播放器
      try {
        if (playerRef.current) {
          await playerRef.current.unload();
        }
        setIsLoading(true);
        const player = new AudioPlayerInstance();
        await player.load(uri);

        player.setPlaybackStatusUpdate((playing, durationMs) => {
          setIsPlaying(playing);
          if (durationMs) setDuration(durationMs);
        });

        playerRef.current = player;
      } catch (resetError) {
        console.error("重置播放器失败:", resetError);
        setLoadError(true);
      } finally {
        setIsLoading(false);
      }
    }
  };

  return (
    <Button
      alignItems="center"
      gap="$2"
      width={70}
      height="auto"
      backgroundColor="transparent"
      onPress={handlePlayPause}
      disabled={isLoading}
    >
      {isLoading ? (
        <ActivityIndicator size="small" color={color} />
      ) : loadError ? (
        // 显示加载错误状态
        <Text color={color} fontSize={12}>错误</Text>
      ) : isPlaying ? (
        <Pause size={14} color={color} />
      ) : (
        <Play size={14} color={color} />
      )}
      <Paragraph color={color} fontSize={14}>
        {loadError ? "--''" : formatDuration(duration)}
      </Paragraph>
    </Button>
  );
}

interface ChatBubbleProps {
  isUser: boolean;
  content?: string;
  audioUri?: string;
  imageUri?: string;
  timestamp?: string;
}

// 主题色
const THEME_COLOR = "#B66D0E"; // 棕色主题色

export function ChatBubble({ isUser, content, audioUri, imageUri, timestamp }: ChatBubbleProps) {
  return (
    <XStack
      width="100%"
      justifyContent={isUser ? "flex-end" : "flex-start"}
      marginVertical={8}
    >
      {/* 消息内容 */}
      <Stack maxWidth="80%">
        {/* 文本消息 */}
        {content && (
          <View
            backgroundColor={isUser ? THEME_COLOR : "#f0f0f0"}
            paddingHorizontal={12}
            paddingVertical={8}
            borderRadius={16}
            borderBottomRightRadius={isUser ? 4 : 16}
            borderBottomLeftRadius={isUser ? 16 : 4}
          >
            <Text color={isUser ? "white" : "black"}>{content}</Text>
          </View>
        )}

        {/* 语音消息 */}
        {audioUri && (
          <View
            backgroundColor={isUser ? THEME_COLOR : "#f0f0f0"}
            paddingHorizontal={12}
            paddingVertical={8}
            borderRadius={16}
            borderBottomRightRadius={isUser ? 4 : 16}
            borderBottomLeftRadius={isUser ? 16 : 4}
            minWidth={100} // 确保语音消息有最小宽度
            alignItems="center"
          >
            <VoicePlayer
              uri={audioUri}
              color={isUser ? "white" : "black"}
            />
          </View>
        )}

        {/* 图片消息 - 直接显示图片，不放在气泡中 */}
        {imageUri && (
          <Image
            source={{ uri: imageUri }}
            style={{
              width: 200,
              height: 200,
              borderRadius: 8,
              marginVertical: 4
            }}
            resizeMode="cover"
          />
        )}

        {/* 时间戳 */}
        {timestamp && (
          <Text
            fontSize={10}
            color="gray"
            marginTop={4}
            textAlign={isUser ? "right" : "left"}
          >
            {timestamp}
          </Text>
        )}
      </Stack>
    </XStack>
  );
}
