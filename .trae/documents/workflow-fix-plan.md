# 修复 GitHub Actions 工作流失败的计划

## 1. 现状分析
通过对项目代码和 GitHub Actions 运行日志的分析（使用 `gh-cli` 和 `curl` 获取了最近一次 `ci.yml` 的运行记录），发现工作流总是失败的根本原因是**依赖版本冲突**。

在 `ci.yml` 和 `release.yml` 的 `flutter pub get` 阶段，出现了如下错误：
```
Because build_runner >=2.4.14 depends on dart_style >=2.3.7 <4.0.0 and dart_style >=2.3.7 <2.3.8 depends on analyzer ^6.5.0, build_runner >=2.4.14 requires analyzer ^6.5.0 or dart_style >=2.3.8 <4.0.0.
...
So, because attenlink depends on both build_runner ^2.4.15 and isar_generator ^3.1.0+1, version solving failed.
```
由于 `isar_generator ^3.1.0+1` 依赖较低版本的 `analyzer` (<6.0.0)，而项目中引入的 `build_runner ^2.4.15` 需要较高版本的 `analyzer` (^6.5.0)，导致依赖解析失败，从而使得 `Analyze` 任务报错并退出，后续的所有构建任务均被跳过。

此外，在对工作流文件进行分析时，还发现了 `ci.yml` 中 iOS 和 macOS 产物上传的潜在问题：
1. **iOS 构建产物路径错误**：`flutter build ios --no-codesign` 生成的是 `.app` 包（位于 `build/ios/iphoneos/`），而不是 `.ipa` 包。`ci.yml` 中 `upload-artifact` 却去寻找 `build/ios/ipa/*.ipa`，这会导致找不到文件而无法正确上传产物。
2. **macOS 构建产物格式问题**：macOS 生成的 `.app` 是一个包含软链接的目录，而 `actions/upload-artifact@v4` 会在上传时丢弃软链接，导致下载后的 `.app` 损坏。正确做法是先将其压缩为 `.zip`。

## 2. 提议的更改

### 2.1 修复依赖冲突
**文件**：`pubspec.yaml`
- **更改**：将 `dev_dependencies` 中的 `build_runner: ^2.4.15` 降级为 `build_runner: ^2.4.13`。
- **原因**：`2.4.13` 版本的 `build_runner` 对 `analyzer` 的版本要求较为宽松，能够与 `isar_generator ^3.1.0+1` 完美兼容，从而解决 `flutter pub get` 失败的问题。

### 2.2 修复 `ci.yml` 中的 iOS 产物打包与上传
**文件**：`.github/workflows/ci.yml`
- **更改**：在 `build-ios` 任务中，添加打包步骤，将生成的 `.app` 放入 `Payload` 目录并压缩为 `ios-build.zip`，然后修改 `upload-artifact` 的路径指向该 `.zip` 文件（参考 `release.yml` 的做法）。
- **原因**：确保 CI 能正确捕获 iOS 构建产物。

### 2.3 修复 `ci.yml` 中的 macOS 产物打包与上传
**文件**：`.github/workflows/ci.yml`
- **更改**：在 `build-macos` 任务中，添加打包步骤，将 `attenlink.app` 压缩为 `macos-build.zip`，然后上传该压缩包。
- **原因**：避免 `upload-artifact@v4` 破坏 macOS 应用包内部的软链接结构。

## 3. 假设与决策
- **假设**：`build_runner: ^2.4.13` 足以支持当前项目中 Isar 和其他代码生成的需要（这是 Flutter 社区中针对 Isar 3.1.0+1 的标准解决方案）。
- **决策**：直接修改 CI 工作流中的打包方式，而不去强行配置复杂的证书以生成 `.ipa`，从而保持 CI 的简洁并验证编译结果。

## 4. 验证步骤
1. 修改完毕后，运行 `flutter pub get` 验证本地依赖解析是否成功。
2. 运行 `dart run build_runner build --delete-conflicting-outputs` 验证代码生成是否正常。
3. 提交代码后，通过 GitHub Actions 观察 `ci.yml` 工作流是否能成功执行并顺利完成各个平台的构建与产物上传。