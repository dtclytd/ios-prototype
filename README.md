# 原型 · iOS 可运行工程

一个能真正装到 iPhone 上的 SwiftUI 骨架：三个页面、本地持久化、深色模式、触感反馈，全部接好。
把它换成你自己的内容，就是你的 App。

工程本身不含任何第三方依赖，也不含 `.xcodeproj` —— Xcode 工程由 `project.yml` 通过 **XcodeGen** 生成，
所以它可以在 Windows 上维护，在云端 macOS 上编译。

---

## 一、目录结构

```
ios-prototype/
├── project.yml                     # XcodeGen 工程描述（唯一源头）
├── Sources/
│   ├── App/
│   │   ├── PrototypeApp.swift      # @main 入口，注入外观/触感设置
│   │   └── RootView.swift          # TabView 三个 Tab
│   ├── DesignSystem/
│   │   ├── Theme.swift             # 配色、渐变、卡片样式、外观枚举
│   │   └── Haptics.swift           # 触感反馈封装
│   ├── Features/
│   │   ├── Home/HomeView.swift     # 首页：主卡 + 统计 + 模块横滑 + 最近记录
│   │   ├── Records/                # 记录页：列表 / 搜索 / 增删 / 置顶
│   │   │   ├── RecordsView.swift
│   │   │   ├── AddRecordView.swift
│   │   │   └── RecordStore.swift   # UserDefaults + JSON 持久化
│   │   └── Settings/SettingsView.swift
│   └── Resources/Assets.xcassets   # AppIcon（已生成）+ AccentColor
├── tools/make_icon.py              # 图标生成脚本（纯标准库，想换图标可改它）
└── .github/workflows/build-ipa.yml # 云端编译 + 打包 ipa
```

---

## 二、三步拿到 IPA

### 第 1 步：推到 GitHub

在 GitHub 新建一个仓库（私有公开都行，**不要**勾选自动创建 README），然后在 `ios-prototype` 目录里执行：

```bash
git init
git add .
git commit -m "init: swiftui prototype"
git branch -M main
git remote add origin https://github.com/<你的用户名>/<仓库名>.git
git push -u origin main
```

### 第 2 步：等云端编译

推送完成后，打开仓库的 **Actions** 标签页，会看到 `Build Unsigned IPA` 自动开始跑。
首次大约 3–5 分钟（要装 XcodeGen）。跑完后：

**Actions → 点进那次运行 → 页面底部 Artifacts → 下载 `PrototypeApp-unsigned-ipa`**

解压得到一个 `PrototypeApp.ipa`。

> 如果 Actions 没自动触发：进 Actions 页面点 `Build Unsigned IPA` → `Run workflow` 手动触发。
> 如果提示 macOS runner 不可用，把 workflow 里的 `macos-15` 改成 `macos-14` 再推一次。

### 第 3 步：签名装到手机

这个 ipa 是**未签名**的，不能直接双击安装，需要你自己用自己的 Apple ID 签一次。

**Windows / macOS 都可以，用 [Sideloadly](https://sideloadly.io/)：**

1. 先装 **iTunes**（或微软商店的「Apple 设备」App），Sideloadly 需要它的驱动才能识别 iPhone
2. 打开 Sideloadly，数据线连上 iPhone，手机上点「信任此电脑」
3. 把 `PrototypeApp.ipa` 拖进 Sideloadly 窗口
4. `Apple ID` 填你自己的 Apple ID（免费账号即可），点 **Start**，输入密码
5. 装完后在手机上：**设置 → 通用 → VPN与设备管理 → 信任「你的 Apple ID」**
6. iOS 16 及以上还要开开发者模式：**设置 → 隐私与安全性 → 开发者模式 → 打开 → 重启手机**

图标出现在桌面上，点开就能用。

---

## 三、关于免费账号的硬限制（必须知道）

用免费 Apple ID 自签，苹果的限制是：

| 限制 | 说明 |
|---|---|
| **7 天有效期** | 7 天后 App 打不开，需要重新用 Sideloadly 签一次（数据还在，不会丢） |
| 同时最多 3 个 | 免费账号最多同时装 3 个自签 App |
| 每周 10 个 App ID | 频繁改 bundle id 会很快耗尽 |

想省事的话有两条路：
- **付费开发者账号（$99/年）**：签名有效期 1 年，可以开 TestFlight 分发给别人
- **[AltStore](https://altstore.io/) / SideStore**：装在电脑或手机上，每 7 天自动帮你重签，不用手动操作

---

## 四、改成你自己的 App

### 改名字

`project.yml` 里两处：

```yaml
CFBundleDisplayName: 原型          # 桌面上显示的名字
PRODUCT_BUNDLE_IDENTIFIER: com.example.prototype   # 包名，改成 com.你的名字.xxx
```

`PRODUCT_NAME: PrototypeApp` 是产物文件名，改不改都行，但改了要同步改 `build-ipa.yml` 里的路径。

### 换图标

图标是**构建时生成**的，仓库里不存 PNG（`AppIcon.png` 已在 `.gitignore` 里）。
云端构建的第一步就是 `python3 tools/make_icon.py`。

想换图标，改 `tools/make_icon.py` 里的配色和图形即可，push 后下次构建自动生效。

想用自己的图，两种办法：

1. 把你的 1024×1024 PNG 命名成 `AppIcon.png`，放到
   `Sources/Resources/Assets.xcassets/AppIcon.appiconset/` 下，然后
   `git add -f` 强制提交（绕过 .gitignore）
2. 或者删掉 workflow 里 `Generate app icon` 那一步，直接提交图片

> App Store 要求图标不能有透明通道、不能有圆角（系统自己切）。

### 换内容

- 首页文案和模块卡片 → `Sources/Features/Home/HomeView.swift` 里的 `heroCard` 和 `modules`
- 配色 → `Sources/DesignSystem/Theme.swift`
- 数据层 → `Sources/Features/Records/RecordStore.swift`（要换 Core Data / SwiftData / 后端接口，只改这一个类，界面层不用动）
- 页面结构 → `Sources/App/RootView.swift` 里的三个 Tab

### 加新页面

1. 在 `Sources/Features/` 下新建目录和 `.swift` 文件
2. 在 `RootView.swift` 的 `TabView` 里加一个 `.tabItem`
3. push —— XcodeGen 会自动把新文件扫进工程，不需要手动改配置

---

## 五、如果你有 Mac

```bash
brew install xcodegen
cd ios-prototype
python3 tools/make_icon.py
xcodegen generate
open PrototypeApp.xcodeproj
```

Xcode 里选你的开发者账号（Signing & Capabilities → Team），连上 iPhone 直接 Run。
这种方式不需要 Sideloadly，也不需要每周重签（免费账号仍是 7 天，付费账号 1 年）。

---

## 六、常见问题

**Q: Actions 报 `xcodegen: command not found`？**
`brew install xcodegen` 那一步失败了，重跑一次即可；国内网络偶尔会卡在 brew 更新，可在 workflow 里加
`HOMEBREW_NO_AUTO_UPDATE: 1` 环境变量。

**Q: 编译报 `Signing for "PrototypeApp" requires a development team`？**
说明签名没关掉。检查 workflow 里 `CODE_SIGNING_ALLOWED=NO` 这三个参数是否都在。

**Q: Sideloadly 提示 `Provision.cpp:150` 或一直卡在 `Generating...`？**
Apple ID 二次验证问题。先在 [appleid.apple.com](https://appleid.apple.com) 登录一次通过验证，再回 Sideloadly 试。

**Q: 装上了但点开闪退？**
看手机的「设置 → 隐私与安全性 → 分析与改进 → 分析数据」，找 `PrototypeApp` 开头的崩溃日志。
最常见原因是 ipa 里的架构不对（必须是 arm64，workflow 默认就是）。

**Q: 这个能上架 App Store 吗？**
工程结构没问题，但上架需要：付费开发者账号、App Store Connect 里建 App 记录、隐私清单、截图、
审核。这是另一条完整流程，需要的话可以单独做。
