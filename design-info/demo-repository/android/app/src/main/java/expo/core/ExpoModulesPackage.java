package expo.core;

import android.content.Context;

import java.util.List;

import expo.modules.adapters.react.ReactAdapterPackage;
import expo.modules.core.interfaces.InternalModule;

/**
 * 桥接类，用于解决Expo SDK 52中包路径变化的问题。
 * 在新版本的Expo SDK中，ExpoModulesPackage类已经被移动到不同的包中。
 * 这个类将请求转发到正确的实现类（ReactAdapterPackage）。
 */
public class ExpoModulesPackage extends ReactAdapterPackage {
    
    @Override
    public List<InternalModule> createInternalModules(Context context) {
        // 调用父类的方法，将请求转发到ReactAdapterPackage
        return super.createInternalModules(context);
    }
}