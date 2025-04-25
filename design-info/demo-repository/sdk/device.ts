/**
 * @description 获取设备信息
 */

import DeviceInfo from "react-native-device-info";

interface DeviceInfoType {
  brand: string;
  buildNumber: string;
  deviceId: string;
  deviceName: string;
}

export class Device {
  // 获取设备信息
  async getDeviceInfo(): Promise<DeviceInfoType> {
    try {
      const brand = await DeviceInfo.getBrand(); // 品牌
      const buildNumber = await DeviceInfo.getBuildNumber(); // 版本号
      const deviceId = DeviceInfo.getDeviceId(); // 设备ID
      const deviceName = await DeviceInfo.getDeviceName(); // 设备名称

      // 确保返回的都是简单的字符串值
      return {
        brand: String(brand),
        buildNumber: String(buildNumber),
        deviceId: String(deviceId),
        deviceName: String(deviceName),
      };
    } catch (error) {
      console.error("Error getting device info:", error);
      // 返回默认值
      return {
        brand: "",
        buildNumber: "",
        deviceId: "",
        deviceName: "",
      };
    }
  }
}
