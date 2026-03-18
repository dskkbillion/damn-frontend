# damn-frontend

DSKK 客户端 Flutter 工程。

## 先看这里

如果你是第一次接手这个仓库，优先关注两件事：

1. 先按下面的“本地联调”章节把项目跑起来
2. 再按“分支流转”章节参与 `dev / test / main` 协作

## 本地联调

### 前置依赖

- Flutter SDK
- Xcode 和 iOS 模拟器
- `tmux`

### 脚本速查

```bash
./scripts/run-ios-unified-local.sh
./scripts/tail-ios-unified-local.sh
./scripts/stop-ios-unified-local.sh
```

### 配置文件

先准备本地联调环境文件：

```bash
cp .env.local-debug.example .env.local-debug
```

说明：

- 模板文件：`.env.local-debug.example`
- 本地实际文件：`.env.local-debug`

### 日志路径

- 当前日志：`.logs/flutter-ios-unified.latest.log`
- 上一轮日志：`.logs/flutter-ios-unified.previous.log`

### 安装依赖

```bash
flutter pub get
```

### 启动

```bash
./scripts/run-ios-unified-local.sh
```

### 查看日志

```bash
./scripts/tail-ios-unified-local.sh
```

### 停止

```bash
./scripts/stop-ios-unified-local.sh
```

## 脚本和日志

`./scripts/run-ios-unified-local.sh` 默认会：

- 执行 `flutter run --machine`
- 使用入口 `lib/main_unified.dart`
- 使用环境文件 `.env.local-debug`
- 通过 `tmux` 托管进程
- 将日志写入 `.logs/flutter-ios-unified.latest.log`

常用覆盖方式：

```bash
DEVICE_ID=<模拟器ID> ./scripts/run-ios-unified-local.sh
ENTRYPOINT=lib/main_unified.dart ./scripts/run-ios-unified-local.sh
ENV_FILE=.env.local-debug ./scripts/run-ios-unified-local.sh
```

日志文件：

- 当前日志：`.logs/flutter-ios-unified.latest.log`
- 上一轮日志：`.logs/flutter-ios-unified.previous.log`

跨端排查顺序：

1. 先看前端日志
2. 再看后端日志
3. 再看模型端日志
4. 最后再看代码

## 分支流转

本仓库固定维护三条分支：

- `dev`：开发和联调
- `test`：测试复测
- `main`：稳定验收

协作规则：

- 开发只推进 `dev`
- 测试同事只基于 `test` 复测
- 正式验收只认 `main`
- 每次切分支、合并、复测前先执行 `git fetch origin`
- 每轮复测都要记录 `test` 对应的 commit

标准流程：

1. 开发在 `dev`
2. `dev -> test`
3. 测试同事复测 `test`
4. 通过后 `test -> main`

## 补充说明

- 统一入口固定为 `lib/main_unified.dart`
- 不要为了本地调试随意新增临时入口文件
- 不要直接拿 `dev` 给测试同事验证
