# Bolts CHANGELOG

## 1.8.4

**Fixed**
- Fix potential breaking change related to dynamic library compatibility version.  
  [#270](https://github.com/BoltsFramework/Bolts-ObjC/pull/270)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

## 1.8.3

**Fixed**
- Fix potential deadlock when using `BFTask.-waitUntilFinished`.  
  [#263](https://github.com/BoltsFramework/Bolts-ObjC/pull/263)
  by [Nikita Lutsenko](https://github.com/nlutsenko)


## 1.8.2

**Fixed**
- Fixed custom build frameworks script.  
  [#263](https://github.com/BoltsFramework/Bolts-ObjC/pull/263)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Fixed incorrect dynamic framework install name base and install name making dynamic framework not load in some cases.  
  [#266](https://github.com/BoltsFramework/Bolts-ObjC/pull/266)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Fixed compilation of dynamic frameworks for watchOS/tvOS when no code signing identity is present.  
  [#266](https://github.com/BoltsFramework/Bolts-ObjC/pull/266)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

## 1.8.1

**Fixed**
- Fixed compilation of dynamic frameworks due to codesigning requirements.  
  [#260](https://github.com/BoltsFramework/Bolts-ObjC/pull/260)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

## 1.8.0

**New**
- Deprecated exception catching in `BFTask`. This feature will be removed in `1.9.0`.  
  Read [here](https://github.com/BoltsFramework/Bolts-ObjC/issues/252) on the motivation and follow the discussion.  
  [#251](https://github.com/BoltsFramework/Bolts-ObjC/pull/251)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Added temporary API to opt-out from automatic `BFTask` exception catching.  
  [#251](https://github.com/BoltsFramework/Bolts-ObjC/pull/251)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Added no-side-effects version of `BFAppLinkNavigation.-navigate:` and `BFAppLinkNavigation.-navigateToAppLink:error:`.  
  [#245](https://github.com/BoltsFramework/Bolts-ObjC/pull/245)
  by [Bruno de Carvalho](https://github.com/biasedbit)

**Improved**
- Improved naming for `BFContinuationBlock` to avoid local variable shadowing.  
  [#258](https://github.com/BoltsFramework/Bolts-ObjC/pull/258)
  by [Nikita Lutsenko](https://github.com/nlutsenko)  

**Fixed**
- Fixed exposure of internal headers in AppLinks subspec.  
  [#254](https://github.com/BoltsFramework/Bolts-ObjC/pull/254)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Fixed potential spurious thread wakeup when using `BFTask.-waitUntilFinished`.  
  [#247](https://github.com/BoltsFramework/Bolts-ObjC/pull/247)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

## 1.7.0

**New**
- Added `BFTask.+taskForCompletionOfAnyTask:`.  
  This method creates a task that will be completed when first of the provided task completes.  
  [#229](https://github.com/BoltsFramework/Bolts-ObjC/pull/229)
  by [Florent Vilmart](https://github.com/flovilmart)  
- New constants defined for userInfo keys of multi-error/multi-exception.  
  [#238](https://github.com/BoltsFramework/Bolts-ObjC/pull/238)
  by [Takeru Chuganji](https://github.com/hoppenichu)
- Replaced `Bolts` class, `BoltsVersion` macro with a constant string.  
  [#239](https://github.com/BoltsFramework/Bolts-ObjC/pull/239)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

**Improved**
- Reduced stack frame from continuation stack trace if task is completed.  
  [#237](https://github.com/BoltsFramework/Bolts-ObjC/pull/237)
  by [Nikita Lutsenko](https://github.com/nlutsenko)  

**Fixed**
- Fixed disposing of `BFCancellationToken` when it has registrations.  
  [#226](https://github.com/BoltsFramework/Bolts-ObjC/pull/226)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Fixed and improved documentation.  
  [#230](https://github.com/BoltsFramework/Bolts-ObjC/pull/230)
  by [Paweł Wrzosek](https://github.com/wzs)
- Fix warnings that surfaced in the release version of Xcode 7.3.  
  [#231](https://github.com/BoltsFramework/Bolts-ObjC/pull/231)
  by [Nikita Lutsenko](https://github.com/nlutsenko)
- Fixed edge case scenario of `BFTask.+taskForCompletionOfAllTasks:` wouldn't finish or wouldn't be cancelled.  
  [#235](https://github.com/BoltsFramework/Bolts-ObjC/pull/235)
  by [Nikita Lutsenko](https://github.com/nlutsenko)

## 1.6.0

**New**
- Bolts now requires Xcode 7.0+.  
  [#212](https://github.com/BoltsFramework/Bolts-iOS/pull/212)
  by @nlutsenko
  
**Improved**
- Specify generic type for `BFTask.+taskForCompletionofAllTasks*()`.
  [#217](https://github.com/BoltsFramework/Bolts-iOS/pull/217)
  by @nlutsenko
- Remove `nonnull` requirement for return type from the block of `BFTas,+taskFromExecutor(_ , block:)`.
  [#218](https://github.com/BoltsFramework/Bolts-iOS/pull/218)
  by @nlutsenko

**Fixed**
- Fixed compiler warnings on Xcode 7.3.
  [#216](https://github.com/BoltsFramework/Bolts-iOS/pull/216)
  by @nlutsenko

## 1.5.1

**New**
- Bolts is now compatible with [Carthage](https://github.com/carthage/carthage) on all platforms (iOS, OS X, watchOS, tvOS).  
  [#168](https://github.com/BoltsFramework/Bolts-iOS/pull/168)
  by [lucasderraugh](https://github.com/lucasderraugh)  
  [#206](https://github.com/BoltsFramework/Bolts-iOS/pull/206)
  by [nlutsenko](https://github.com/nlutsenko)  

**Improved**
- Most executor types will create and drain an autorelease pool for each individual task.  
  [#202](https://github.com/BoltsFramework/Bolts-iOS/pull/206) by [richardjrossiii](https://github.com/richardjrossiii)  

## 1.5.0
**New**
- Bolts Tasks now have nullability annotations. #161
**Improved**
- Improved return types for continuation methods of a `BFTask` when used with generics. #198
- Improved performance of constructing a `BFTask` with result/error/exception. #181, #187
- Improved performance and dispatch policy of `BFExecutor.defaultExecutor()`. #197
- Improved performance and removed a stack frame when completing a `BFTask`. #184
**Fixed**
- Fixed rare issue when compilation would fail if Bolts is used as a subproject reference. #188
- Fixed potential data inconsistency when getting description of a `BFTask`. #182
- Fixed a warning in `BFWebViewAppLinkResolver`. #183

## 1.4.0
**New**
- Bolts now fully supports tvOS and Xcode 7.1.
**Changes**
- Bolts for iOS requires at least iOS 6.0.
- Bolts for OS X requires at least OS X 10.8.

## 1.3.0
**New**
- Bolts now fully supports watchOS 2.
- Bolts for iOS is now compilied with Bitcode slice.
**Fixed**
- Potential undefined behavior caused by casting block types.

## 1.2.2
- New: Added bitcode support when built from source for iOS 9.
- New: `BFTask` and `BFTaskCompletionSource` now supports Obj-C Generics for types of the result.
- Fixed: Resolved a crash when creating a BFURL when `target_url` is not a string (null or a number).
- Fixed: `BFIncludeStatusBarInSizeAlways` is properly handled now.

## 1.2.1
- Improved: Removed the need to check canOpenURL: and just use openURL: directly which improves App Links behavior on iOS 9.
- Fixed: Potentially never completed task if continuation returns a task and cancellation was requested.
- Fixed: iOS 9 deprecations that cause warnings when building from source and targeting iOS 9+.

## 1.2.0
- Added: `BFCancellationToken`, `BFCancellationTokenSource`, `BFCancellationTokenRegistration`
- Updated: `BFTask` APIs to have methods that accept `BFCancellationToken` as an argument.
- Documentation updates and small bug fixes.

## 1.1.5
- Better subclassing support for `BFTask`, `BFTaskCompletionSource`, `BFExecutor`.
- Improved `taskForCompletionOfAllTasks:` to check for `error`/`exception` before cancelling a task.
- Fixed and improved layout of `BFAppLinkReturnToRefererController`.
- Improve optional importing for AppLinks code in umbrella header.
- Split Tasks and AppLinks in subspecs.

## 1.1.4
- New: Bolts for iOS is easily importable from Swift code (via `import Bolts`).
- New: Added `BFTask +taskForCompletionOfAllTaskResults`.
- New: Added `faulted` property on `BFTask`.
- New: Made `BFTaskErrorDomain` and `BFTaskMultipleExceptionsException` constants publicly available.
- New: `BFTask -description` now shows completed/cancelled/faulted status of a task.

## 1.1.3
- Made Bolts work if added as a subproject
- Support for iOS 8
- Support for OS X 10.10
- Updated headers to support llvm header maps

## 1.1.2

- [App Links Analytics](https://github.com/BoltsFramework/Bolts-iOS#analytics)

## 1.1.1

- Bolts for Mac is now a dynamic framework
- Bug fixes

## 1.1.0

- Adds App Links.

## 1.0.0

- Initial release.
