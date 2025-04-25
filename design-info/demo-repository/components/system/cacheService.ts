import AsyncStorage from "@react-native-async-storage/async-storage";
import { Platform } from "react-native";
import * as FileSystem from "expo-file-system";
import JVerification from "jverification-react-native";

export class CacheService {
  // 定义可以清理的目录
  private static CACHE_DIRS = [
    FileSystem.cacheDirectory,
    FileSystem.documentDirectory,
    `${FileSystem.documentDirectory}images/`,
    `${FileSystem.documentDirectory}downloads/`,
  ];

  /**
   * 获取缓存大小
   */
  static async getCacheSize(): Promise<string> {
    try {
      let totalSize = 0;

      // 遍历所有缓存目录
      for (const dir of this.CACHE_DIRS) {
        if (!dir) continue;

        try {
          const info = await FileSystem.getInfoAsync(dir);
          if (info.exists && info.isDirectory) {
            const contents = await FileSystem.readDirectoryAsync(dir);

            for (const item of contents) {
              // 跳过.开头的系统文件
              if (item.startsWith(".")) continue;

              const filePath = dir + item;
              const fileInfo = await FileSystem.getInfoAsync(filePath);
              if (fileInfo.exists && !fileInfo.isDirectory) {
                totalSize += fileInfo.size;
              }
            }
          }
        } catch (err) {
          console.warn(`获取目录 ${dir} 大小失败:`, err);
        }
      }

      // 转换为 MB
      const sizeMB = (totalSize / (1024 * 1024)).toFixed(2);
      return `${sizeMB}MB`;
    } catch (error) {
      console.error("获取缓存大小失败:", error);
      return "0MB";
    }
  }

  /**
   * 清除所有缓存
   */
  static async clearAllCache(): Promise<void> {
    try {
      // 1. 清除 AsyncStorage
      await AsyncStorage.clear();

      // 2. 清除文件缓存
      for (const dir of this.CACHE_DIRS) {
        if (!dir) continue;

        try {
          const info = await FileSystem.getInfoAsync(dir);
          if (!info.exists || !info.isDirectory) continue;

          const contents = await FileSystem.readDirectoryAsync(dir);

          for (const item of contents) {
            // 跳过.开头的系统文件
            if (item.startsWith(".")) continue;

            try {
              const filePath = dir + item;
              const fileInfo = await FileSystem.getInfoAsync(filePath);

              if (fileInfo.exists && !fileInfo.isDirectory) {
                await FileSystem.deleteAsync(filePath, { idempotent: true });
              }
            } catch (err) {
              console.warn(`删除文件 ${item} 失败:`, err);
            }
          }
        } catch (err) {
          console.warn(`清理目录 ${dir} 失败:`, err);
        }
      }

      // 3. 清除极光认证缓存
      if (Platform.OS === "ios") {
        JVerification.clearPreLoginCache();
      }

      console.log("缓存清除成功");
    } catch (error) {
      console.error("清除缓存失败:", error);
      throw error;
    }
  }

  /**
   * 清除指定类型的缓存
   */
  static async clearCacheByType(type: "auth" | "file"): Promise<void> {
    try {
      switch (type) {
        case "auth":
          await AsyncStorage.multiRemove([
            "auth_token",
            "user_profile",
            "login_info",
          ]);
          if (Platform.OS === "ios") {
            JVerification.clearPreLoginCache();
          }
          break;

        case "file":
          await this.clearAllCache();
          break;
      }
    } catch (error) {
      console.error(`清除${type}缓存失败:`, error);
      throw error;
    }
  }
}
