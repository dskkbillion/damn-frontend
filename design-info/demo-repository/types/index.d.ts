// 为缺失的模块添加声明
declare module '@gorhom/bottom-sheet';
declare module '@tamagui/lucide-icons';
declare module '@shopify/flash-list' {
  import { Component } from 'react';
  export class FlashList<T> extends Component<any> {
    scrollToEnd: (params?: { animated?: boolean }) => void;
    scrollToIndex: (params: { index: number, animated?: boolean }) => void;
    scrollToOffset: (params: { offset: number, animated?: boolean }) => void;
  }
}
declare module 'burnt';
declare module 'expo-av';
declare module 'expo-av/build/Audio' {
  export interface Recording {
    getStatusAsync(): Promise<any>;
    setOnRecordingStatusUpdate(callback: (status: any) => void): void;
    prepareToRecordAsync(options?: any): Promise<any>;
    startAsync(): Promise<any>;
    pauseAsync(): Promise<any>;
    stopAndUnloadAsync(): Promise<any>;
    getURI(): string | null;
    createNewLoadedSoundAsync(): Promise<any>;
  }
}
declare module 'expo-document-picker';
declare module 'expo-image-picker';
declare module 'expo-router';
declare module 'expo-linear-gradient';
declare module 'react-native-svg';

// 为global添加声明
interface Global {
  screenWidth: number;
  screenHeight: number;
  [key: string]: any;
}

declare var global: Global;

declare module 'expo-av' {
  namespace Audio {
    interface Sound {
      loadAsync(source: any, initialStatus?: any, downloadFirst?: boolean): Promise<any>;
      unloadAsync(): Promise<any>;
      playAsync(): Promise<any>;
      pauseAsync(): Promise<any>;
      stopAsync(): Promise<any>;
      setPositionAsync(position: number): Promise<any>;
      setRateAsync(rate: number, shouldCorrectPitch: boolean): Promise<any>;
      setVolumeAsync(volume: number): Promise<any>;
      setIsMutedAsync(isMuted: boolean): Promise<any>;
      setIsLoopingAsync(isLooping: boolean): Promise<any>;
      setProgressUpdateIntervalAsync(intervalMillis: number): Promise<any>;
      getStatusAsync(): Promise<any>;
      setOnPlaybackStatusUpdate(callback: (status: any) => void): void;
    }

    function createAsync(
      source: any,
      initialStatus?: any,
      onPlaybackStatusUpdate?: (status: any) => void,
      downloadFirst?: boolean
    ): Promise<{ sound: Sound; status: any }>;
  }
}
