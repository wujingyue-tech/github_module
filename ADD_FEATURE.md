# 新增业务

复制 `features/repos` 这一条链。最后只改 `lib/app/di.dart` 和 `lib/app/router.dart` 两处全局文件。网络、登录、错误映射不用重写。

依赖规则见 [ARCHITECTURE.md](ARCHITECTURE.md)。

下面以「仓库 Issues」为例。

## 1. 建 feature 目录

```text
lib/features/issues/
  domain/
    issue.dart
    issue_repository.dart
  data/
    issue_dto.dart
    github_issue_remote.dart
    issue_repository_impl.dart
  presentation/
    issue_list_provider.dart
    issue_list_page.dart
```

不要把业务类型放进 `core/`。`core` 只放所有 feature 都要用的东西。

## 2. domain：实体 + 接口

这里只定义「业务要什么」，不定义 GitHub JSON、MQTT payload 或蓝牙特征值长什么样。不要 import `dio`、`mqtt_client`、`flutter_blue`、`flutter/material.dart`。

```dart
class Issue {
  const Issue({required this.id, required this.title, required this.number});
  final int id;
  final String title;
  final int number;
}

abstract interface class IssueRepository {
  Future<List<Issue>> listIssues({required String fullName});
}
```

## 3. data：请求、解析、映射

- `IssueDto.fromJson` → `toDomain()`
- `GitHubIssueRemote` 只负责 I/O 和 `mapDioException`（或该通道自己的错误映射）
- `IssueRepositoryImpl` 只做 `dto.toDomain()`

Repository **不要** `ref.read(sessionProvider)`。HTTP 的 token 由 `AuthInterceptor` 自动带上。

GET 默认走 `DioCacheInterceptor`（`CachePolicy.request`，跟浏览器一样看响应的 `Cache-Control` / ETag）。某次请求不要缓存时，传标准头，不要自造 `refresh` / `noCache`：

```dart
headers: const {'cache-control': 'no-cache'}, // 强制再校验
headers: const {'cache-control': 'no-store'}, // 不读也不写缓存
```

## 4. 在 `app/di.dart` 挂上实现

```dart
final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return IssueRepositoryImpl(GitHubIssueRemote(ref.watch(dioProvider)));
});
```

presentation 依赖的是 `IssueRepository`，不是 Impl。测 Notifier 时用 `overrideWithValue(FakeIssueRepository())`。

## 5. presentation：Notifier 编排，Page 只渲染

```dart
class IssueListNotifier extends AsyncNotifier<List<Issue>> {
  @override
  Future<List<Issue>> build() {
    return ref.read(issueRepositoryProvider).listIssues(
      fullName: 'octocat/hello',
    );
  }
}
```

页面 `watch` 这个 provider，用 `Issue.title` 画 UI。不要在 Page 里解析 `Map`，不要在 Page 里直接 `dio.get`。

需要登录态时：

```dart
ref.read(sessionProvider).token
ref.read(sessionProvider.notifier).clearAuth()
```

不要 import `features/session/data/auth_store_impl.dart`。测登录时 override `authStoreProvider` 成内存实现，不要为了测 Notifier 去 mock `SharedPreferences`。

## 6. 接到路由和文案

在 `lib/app/router.dart` 加 `GoRoute`。需要登录的页面，现有 redirect 会挡住未登录用户。

文案加到 `lib/l10n/*.arb`，不要在页面里写死中英文。

## 7. 补测试

至少两层：

- Remote / Repository：用假 `HttpClientAdapter`（或假 MQTT/蓝牙 client）喂数据
- Notifier：override 一个 Fake Repository，测 loading / data / error

对照 `test/repo_repository_test.dart` 和 `test/repo_list_provider_test.dart`。

## 8. 预览某一帧 UI

后端或蓝牙还没好、只想看空态 / 错误 / 满页时：假 **domain 端口**，不要假 Dio，也不要假 Notifier。

1. 在该 feature 的 `data/` 写 `FakeXxxRepository`，实现同一个接口。对照 `features/repos/data/fake_repo_repository.dart`。
2. 在 `lib/app/preview.dart` 加一个 `AppPreview` 枚举值，并在 `previewOverrides()` 里 `overrideWithValue`。`bootstrap()` 只 spread 这一份列表，不用再改。`Override` 从 `package:flutter_riverpod/misc.dart` 导入，不要从主库找这个类型。
3. 把 `appPreview` 改成那个值，**hot restart**（`ProviderContainer` 只在启动时建一次）。
4. 需要登录的页，先用真登录走进去；预览只替换这一页用到的端口。

Release 不会挂这些 override。看完改回 `AppPreview.off`。

同一份 Fake 给 Notifier 测试用，不要在 `test/` 再写一套只会 `return []` 的类。

多步操作路径不要在客户端排队列。以后用独立假后端 / sandbox，App 仍走真 Dio 和真 Notifier。

## 落点清单

| 你在写的东西 | 放哪 | 不要做 |
| --- | --- | --- |
| `Issue`、`IssueRepository`、`AuthStore` | `domain/` | import Dio / MQTT / 蓝牙 / Flutter |
| JSON、HTTP、本地存储、设备协议 | `data/` | import Notifier |
| 页面、Notifier | `presentation/` | import 别的 feature 的 `data/` |
| 组装 client / Repository | `app/di.dart` | 在 Page 里 `XxxRemote()` |
| 会话 / 设置存储 | `authStoreProvider` / `settingsStoreProvider` | 在 Notifier 里直接 `SharedPreferences.getInstance()` |
| 某一帧预览 | `data/fake_*.dart` + `app/preview.dart` | 假 Dio / 假 Notifier 来看空态、错误页 |
| 超时、主题、通用错误 | `core/` | 把某个业务的 `Issue` 塞进来 |

跨 feature 只走两条路：对方的 **domain 类型**（例如 Issues 用 `User`），或 **`app/di.dart` 里的 provider**。

## MQTT / 蓝牙

**能接，而且应该按同一套分层接。** 当前骨架已经按「通道可替换」设计：Page 不认识 Dio，只认识 Repository。MQTT 和蓝牙只是另一种 I/O，不是另一种架构。

它们和 HTTP 的差别在于：**长连接、推送流、连接生命周期、系统权限**。这些放在 data / core，不要漏到 Page。

### 和 HTTP 怎么对齐

| | HTTP（现有） | MQTT | 蓝牙 |
| --- | --- | --- | --- |
| 传输 | `core/network` + `dioProvider` | `core/mqtt` + `mqttClientProvider` | `core/ble` + `bleClientProvider` |
| 业务入口 | `GitHubRepoRemote` | `XxxMqttRemote`（订阅/发布） | `XxxBleRemote`（扫描/读写） |
| 领域端口 | `RepoRepository` | 同一套 `XxxRepository` | 同一套 `XxxRepository` |
| 页面 | `AsyncNotifier` | 多为 `StreamProvider` / 带连接态的 Notifier | 同左 |
| 错误 | `mapDioException` | `mapMqttException` | `mapBleException` |
| 鉴权 | `AuthInterceptor` 自动带 token | connect 时用 session 里的凭据 | 配对/密钥在 data 层，不在 Page |

一个业务可以同时用几种通道。例如仓库列表走 HTTP，设备告警走 MQTT：`domain` 仍是一份 `Alert`，data 里可以有 `HttpAlertRemote` 和 `MqttAlertRemote`。

### 什么时候进 `core/`，什么时候进 feature

- **多个 feature 共用同一条连接**（全应用一个 MQTT broker、一台蓝牙网关）→ client 放 `core/mqtt` 或 `core/ble`，在 `app/di.dart` 组装，feature 的 Remote 只注入 client。
- **只有一个 feature 用**（仅设备页连某类 BLE 外设）→ client 可以先放在该 feature 的 `data/`，以后有第二个调用方再抽到 `core/`。

不要把 `MqttServerClient` 或 `FlutterBluePlus` 写进 Page / Notifier。

### MQTT 怎么落文件

```text
lib/core/mqtt/
  mqtt_config.dart          # broker、clientId、keepalive
  mqtt_client_factory.dart  # 创建并配置 client
  map_mqtt_exception.dart

lib/features/alerts/
  domain/alert.dart
  domain/alert_repository.dart
  data/alert_dto.dart
  data/mqtt_alert_remote.dart
  data/alert_repository_impl.dart
  presentation/alert_list_provider.dart
  presentation/alert_list_page.dart
```

`AlertRepository` 用领域语言，不要出现 topic 字符串：

```dart
abstract interface class AlertRepository {
  Stream<Alert> watchAlerts();
  Future<void> ack(String id);
}
```

`MqttAlertRemote` 负责：订阅 topic、把 payload 收成 `AlertDto`、发布 ack。连接、重连、用 `sessionProvider` 的 token 做 MQTT 用户名/密码，都在 `core/mqtt` 或 Remote 里完成。

Notifier 典型写法：

```dart
final alertListProvider = StreamProvider<List<Alert>>((ref) {
  return ref.watch(alertRepositoryProvider).watchAlerts().scanToList();
});
```

在 `app/di.dart`：

```dart
final mqttClientProvider = Provider((ref) {
  return createMqttClient(ref.watch(mqttConfigProvider));
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl(MqttAlertRemote(ref.watch(mqttClientProvider)));
});
```

生命周期：在 `bootstrap()` 或某个长生命周期 Notifier 里 `connect`，`ref.onDispose` 里 `disconnect`。不要每个页面各连一次。

### 蓝牙怎么落文件

```text
lib/core/ble/
  ble_client.dart           # 扫描、连接、读写的薄封装
  map_ble_exception.dart

lib/features/device/
  domain/device.dart
  domain/device_repository.dart
  data/ble_device_remote.dart
  data/device_repository_impl.dart
  presentation/device_page.dart
  presentation/device_provider.dart
```

`DeviceRepository` 同样用领域方法：`scan()`、`connect(id)`、`watchTelemetry()`。Service UUID、characteristic 只出现在 `data/`。

权限（定位 / 蓝牙 / 邻近设备）和系统对话框放在 `core/ble` 或单独的 `core/permissions`，Page 只展示「未授权 / 未打开蓝牙」这种 **domain 或 UI 状态**，不要在按钮回调里直接调 `Permission.bluetooth.request()` 再接着 `dio` 式地堆逻辑。

### 当前架构已经够用的部分

- feature-first 和三条依赖规则对 MQTT / 蓝牙同样成立
- 换通道（HTTP ↔ MQTT ↔ 假数据）只动 `data/` 和 `di.dart`
- 错误继续收敛到 `AppException`（或同级的领域错误），页面继续走 `authErrorText` 那套映射
- 测试方式不变：Fake Repository，不启动真 broker / 真手机

### 需要额外补的（HTTP 骨架里还没有）

这些不是推倒重来，而是给长连接补基础设施：

1. **连接态**：`disconnected / connecting / connected / reconnecting`，用 provider 暴露，多个页面共享
2. **Stream 而不是一次性 Future**：推送用 `StreamProvider` 或 Notifier 订阅 Repository 的 `Stream`
3. **权限与平台通道**：蓝牙、后台保活、iOS 的 Background Modes
4. **独立配置**：`MqttConfig` / `BleConfig` 与 `AppConfig` 并列，不要把 broker 地址写进 `AppConfig.github`

先做 HTTP 业务时不必提前引入 MQTT 包。第一条真连接出现时，再加 `core/mqtt` 或 `core/ble` 即可。
