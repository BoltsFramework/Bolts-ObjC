# Change Log

## [1.9.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.9.0) (2017-12-31)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.8.4...1.9.0)

**Implemented enhancements:**

- Removal of automatic exception catching. [\#252](https://github.com/BoltsFramework/Bolts-ObjC/issues/252)
- Allow usage of only app extension APIs in all schemes. [\#313](https://github.com/BoltsFramework/Bolts-ObjC/pull/313) ([nlutsenko](https://github.com/nlutsenko))
- Update shared configurations for Xcode 9. [\#312](https://github.com/BoltsFramework/Bolts-ObjC/pull/312) ([nlutsenko](https://github.com/nlutsenko))
- Upgrade to use Xcode 8.2. [\#293](https://github.com/BoltsFramework/Bolts-ObjC/pull/293) ([nlutsenko](https://github.com/nlutsenko))
- Add BFVoid macro to allow enforcing 'void' result types on BFTask. [\#289](https://github.com/BoltsFramework/Bolts-ObjC/pull/289) ([nlutsenko](https://github.com/nlutsenko))

**Closed issues:**

- Working on above iOS8? [\#311](https://github.com/BoltsFramework/Bolts-ObjC/issues/311)
- Build failed when running scripts [\#295](https://github.com/BoltsFramework/Bolts-ObjC/issues/295)
- Carthage compatibility with Facebook-sdk  [\#285](https://github.com/BoltsFramework/Bolts-ObjC/issues/285)
- Files not found after Parse + Facebook pod update [\#278](https://github.com/BoltsFramework/Bolts-ObjC/issues/278)
- Bolts/BFTask.h file not found  [\#277](https://github.com/BoltsFramework/Bolts-ObjC/issues/277)
- Swift 3 Naming Collision [\#276](https://github.com/BoltsFramework/Bolts-ObjC/issues/276)
- Is this library compatible with swift 3.0? [\#275](https://github.com/BoltsFramework/Bolts-ObjC/issues/275)

**Merged pull requests:**

- Fix Xcode analyze warning [\#304](https://github.com/BoltsFramework/Bolts-ObjC/pull/304) ([baoshan](https://github.com/baoshan))
- Blocks should have void as argument if it accepts no arguments [\#298](https://github.com/BoltsFramework/Bolts-ObjC/pull/298) ([Dahlgren](https://github.com/Dahlgren))
- Remove automatic exception catching. [\#294](https://github.com/BoltsFramework/Bolts-ObjC/pull/294) ([nlutsenko](https://github.com/nlutsenko))
- Mark classes and methods unavailable for extensions [\#290](https://github.com/BoltsFramework/Bolts-ObjC/pull/290) ([felix-dumit](https://github.com/felix-dumit))
- Fix method name collisions in Swift 3.0. [\#288](https://github.com/BoltsFramework/Bolts-ObjC/pull/288) ([nlutsenko](https://github.com/nlutsenko))
- Upgrade to Xcode 8.1 and enable all latest warnings. [\#287](https://github.com/BoltsFramework/Bolts-ObjC/pull/287) ([nlutsenko](https://github.com/nlutsenko))
- Update to proper full gitignore for Cocoa projects. [\#286](https://github.com/BoltsFramework/Bolts-ObjC/pull/286) ([nlutsenko](https://github.com/nlutsenko))
- Sanitation fix [\#283](https://github.com/BoltsFramework/Bolts-ObjC/pull/283) ([valeriyvan](https://github.com/valeriyvan))
- Sanitation fix [\#282](https://github.com/BoltsFramework/Bolts-ObjC/pull/282) ([valeriyvan](https://github.com/valeriyvan))

## [1.8.4](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.8.4) (2016-07-14)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.8.3...1.8.4)

**Closed issues:**

- \[BFTask waitUntilFinished\] wait forever. [\#141](https://github.com/BoltsFramework/Bolts-ObjC/issues/141)

**Merged pull requests:**

- Bolts 1.8.4 🔩 [\#271](https://github.com/BoltsFramework/Bolts-ObjC/pull/271) ([nlutsenko](https://github.com/nlutsenko))
- Fix breaking change in DYLIB\_COMPATIBILITY\_VERSION. [\#270](https://github.com/BoltsFramework/Bolts-ObjC/pull/270) ([nlutsenko](https://github.com/nlutsenko))

## [1.8.3](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.8.3) (2016-07-12)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.8.2...1.8.3)

**Merged pull requests:**

- Bolts 1.8.3 🔩 [\#269](https://github.com/BoltsFramework/Bolts-ObjC/pull/269) ([nlutsenko](https://github.com/nlutsenko))
- Fix potential deadlock in waitUntilFinished. [\#268](https://github.com/BoltsFramework/Bolts-ObjC/pull/268) ([nlutsenko](https://github.com/nlutsenko))

## [1.8.2](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.8.2) (2016-07-11)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.8.1...1.8.2)

**Closed issues:**

- Xcode 8 beta 2: dyld: Library not loaded: /Library/Frameworks/Bolts.framework/Bolts [\#265](https://github.com/BoltsFramework/Bolts-ObjC/issues/265)

**Merged pull requests:**

- Bolts 1.8.2 🔩 [\#267](https://github.com/BoltsFramework/Bolts-ObjC/pull/267) ([nlutsenko](https://github.com/nlutsenko))
- Use latest xctoolchain to fix dynamic library loading and code signing. [\#266](https://github.com/BoltsFramework/Bolts-ObjC/pull/266) ([nlutsenko](https://github.com/nlutsenko))
- Add CodeCov and default clang-format configurations. [\#264](https://github.com/BoltsFramework/Bolts-ObjC/pull/264) ([nlutsenko](https://github.com/nlutsenko))
- Make Travis-CI run faster on CocoaPods phase. [\#263](https://github.com/BoltsFramework/Bolts-ObjC/pull/263) ([nlutsenko](https://github.com/nlutsenko))
- Unbreak packaging script. [\#262](https://github.com/BoltsFramework/Bolts-ObjC/pull/262) ([nlutsenko](https://github.com/nlutsenko))

## [1.8.1](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.8.1) (2016-07-08)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.8.0...1.8.1)

**Merged pull requests:**

- Bolts 1.8.1 🔩 [\#261](https://github.com/BoltsFramework/Bolts-ObjC/pull/261) ([nlutsenko](https://github.com/nlutsenko))
- Update toolchain to unbreak compilation of dynamic frameworks. [\#260](https://github.com/BoltsFramework/Bolts-ObjC/pull/260) ([nlutsenko](https://github.com/nlutsenko))

## [1.8.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.8.0) (2016-07-07)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.7.0...1.8.0)

**Implemented enhancements:**

- Opt out exceptions [\#250](https://github.com/BoltsFramework/Bolts-ObjC/issues/250)
- -\[BFTask waitUntilFinished\] does not account for spurious thread wakeup [\#134](https://github.com/BoltsFramework/Bolts-ObjC/issues/134)

**Closed issues:**

- FBSDKCoreKit 4.10.0 is forcing Bolts 1.6 through CocoaPods, using a faulty waitUntilFinished method on BFTask [\#257](https://github.com/BoltsFramework/Bolts-ObjC/issues/257)
- Meeting me  [\#248](https://github.com/BoltsFramework/Bolts-ObjC/issues/248)
- Chained BFTask\(s\) run during "Background Fetching" task stopped at the first task [\#234](https://github.com/BoltsFramework/Bolts-ObjC/issues/234)
- Can add additional result data when error? [\#200](https://github.com/BoltsFramework/Bolts-ObjC/issues/200)
- “Include of non-modular header inside framework module” error in project with framework sub-dependency [\#192](https://github.com/BoltsFramework/Bolts-ObjC/issues/192)
- Bracket typing autocomplete issue. [\#109](https://github.com/BoltsFramework/Bolts-ObjC/issues/109)
- NSInternalInconsistencyException for seemingly no reason [\#102](https://github.com/BoltsFramework/Bolts-ObjC/issues/102)

**Merged pull requests:**

- Bolts 1.8.0 🔩 [\#259](https://github.com/BoltsFramework/Bolts-ObjC/pull/259) ([nlutsenko](https://github.com/nlutsenko))
- Update all configurations to latest and improve naming of targets. [\#258](https://github.com/BoltsFramework/Bolts-ObjC/pull/258) ([nlutsenko](https://github.com/nlutsenko))
- Make sure that internal headers are not exposed in AppLinks pod. [\#254](https://github.com/BoltsFramework/Bolts-ObjC/pull/254) ([nlutsenko](https://github.com/nlutsenko))
- Deprecate BFTask automatic exception catching. [\#251](https://github.com/BoltsFramework/Bolts-ObjC/pull/251) ([nlutsenko](https://github.com/nlutsenko))
- Fix potential spurious thread wakeup. [\#247](https://github.com/BoltsFramework/Bolts-ObjC/pull/247) ([nlutsenko](https://github.com/nlutsenko))
- Unbreak build framework script. [\#246](https://github.com/BoltsFramework/Bolts-ObjC/pull/246) ([nlutsenko](https://github.com/nlutsenko))
- Add no-side-effects version of navigateToAppLink:error: and navigate: [\#245](https://github.com/BoltsFramework/Bolts-ObjC/pull/245) ([biasedbit](https://github.com/biasedbit))

## [1.7.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.7.0) (2016-03-31)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.6.0...1.7.0)

**Implemented enhancements:**

- Create separate API using Swift generics [\#61](https://github.com/BoltsFramework/Bolts-ObjC/issues/61)

**Closed issues:**

- Retry primitive? [\#233](https://github.com/BoltsFramework/Bolts-ObjC/issues/233)
- How to get \(older version of\) Bolts working with Xcode 6.4? I need to test in iOS7 simulator. [\#228](https://github.com/BoltsFramework/Bolts-ObjC/issues/228)
- BFTask's -continueWithExecutor cannot make use of Swift block syntactic sugar [\#222](https://github.com/BoltsFramework/Bolts-ObjC/issues/222)
- Syntax for conditional check for errors in README doesn't work [\#221](https://github.com/BoltsFramework/Bolts-ObjC/issues/221)
- Bolts 1.6.0 build errors after a pod update  [\#220](https://github.com/BoltsFramework/Bolts-ObjC/issues/220)
- "Cannot set the result on a completed task." even with trySetResult [\#207](https://github.com/BoltsFramework/Bolts-ObjC/issues/207)
- Duplicate interface definition for class 'BFAppLink' [\#178](https://github.com/BoltsFramework/Bolts-ObjC/issues/178)

**Merged pull requests:**

- Bolts 1.7.0 🔩 [\#244](https://github.com/BoltsFramework/Bolts-ObjC/pull/244) ([nlutsenko](https://github.com/nlutsenko))
- Fix flaky test in TaskTests. [\#243](https://github.com/BoltsFramework/Bolts-ObjC/pull/243) ([nlutsenko](https://github.com/nlutsenko))
- Use Xcode 7.3 for Travis-CI. [\#242](https://github.com/BoltsFramework/Bolts-ObjC/pull/242) ([nlutsenko](https://github.com/nlutsenko))
- Remove unused viewToMoveWithNavController property [\#241](https://github.com/BoltsFramework/Bolts-ObjC/pull/241) ([ejensen](https://github.com/ejensen))
- Change iOS Tests deployment target to 7.0. [\#240](https://github.com/BoltsFramework/Bolts-ObjC/pull/240) ([nlutsenko](https://github.com/nlutsenko))
- Replace Bolts class, BoltsVersion macro with constant string. [\#239](https://github.com/BoltsFramework/Bolts-ObjC/pull/239) ([nlutsenko](https://github.com/nlutsenko))
- Define constant variables for multiple {errors, exceptions} userInfo keys [\#238](https://github.com/BoltsFramework/Bolts-ObjC/pull/238) ([chuganzy](https://github.com/chuganzy))
- Reduce stack frame from continuation stack trace if task is completed. [\#237](https://github.com/BoltsFramework/Bolts-ObjC/pull/237) ([nlutsenko](https://github.com/nlutsenko))
- Use Barrier version of OSAtomic in taskForCompletionOfAllTasks:. [\#235](https://github.com/BoltsFramework/Bolts-ObjC/pull/235) ([nlutsenko](https://github.com/nlutsenko))
- Update xctoolchain, fix new warnings in Xcode 7.3 [\#231](https://github.com/BoltsFramework/Bolts-ObjC/pull/231) ([nlutsenko](https://github.com/nlutsenko))
- Update README.md  [\#230](https://github.com/BoltsFramework/Bolts-ObjC/pull/230) ([wzs](https://github.com/wzs))
- Adds race task [\#229](https://github.com/BoltsFramework/Bolts-ObjC/pull/229) ([flovilmart](https://github.com/flovilmart))
- Add tests/cleanup code to improve code coverage. [\#227](https://github.com/BoltsFramework/Bolts-ObjC/pull/227) ([nlutsenko](https://github.com/nlutsenko))
- Fix disposing of CancellationTokenSource with registrations. [\#226](https://github.com/BoltsFramework/Bolts-ObjC/pull/226) ([nlutsenko](https://github.com/nlutsenko))
- Rename Bolts-iOS to Bolts-ObjC. [\#224](https://github.com/BoltsFramework/Bolts-ObjC/pull/224) ([nlutsenko](https://github.com/nlutsenko))

## [1.6.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.6.0) (2016-01-12)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.5.1...1.6.0)

**Fixed bugs:**

- Compile erros on Xcode 7.3 [\#215](https://github.com/BoltsFramework/Bolts-ObjC/issues/215)

**Closed issues:**

- BFTask: returning nil [\#195](https://github.com/BoltsFramework/Bolts-ObjC/issues/195)

**Merged pull requests:**

- Bolts 1.6.0 🔩 [\#219](https://github.com/BoltsFramework/Bolts-ObjC/pull/219) ([nlutsenko](https://github.com/nlutsenko))
- Remove nonnull requirement from BFTask.taskFromExecutor\(\_ ,block:\). [\#218](https://github.com/BoltsFramework/Bolts-ObjC/pull/218) ([nlutsenko](https://github.com/nlutsenko))
- Specify generic type for BFTask.taskForCompletionOfAllTasks\*\(\). [\#217](https://github.com/BoltsFramework/Bolts-ObjC/pull/217) ([nlutsenko](https://github.com/nlutsenko))
- Fix Xcode 7.3 warnings. [\#216](https://github.com/BoltsFramework/Bolts-ObjC/pull/216) ([nlutsenko](https://github.com/nlutsenko))
- Add Carthage to Travis-CI. [\#214](https://github.com/BoltsFramework/Bolts-ObjC/pull/214) ([nlutsenko](https://github.com/nlutsenko))
- Move error code constant for multiple errors into BFTask. [\#213](https://github.com/BoltsFramework/Bolts-ObjC/pull/213) ([nlutsenko](https://github.com/nlutsenko))
- Strip macros for generics in Task, TaskCompletionSource. [\#212](https://github.com/BoltsFramework/Bolts-ObjC/pull/212) ([nlutsenko](https://github.com/nlutsenko))

## [1.5.1](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.5.1) (2015-12-30)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.5.0...1.5.1)

**Implemented enhancements:**

- Carthage compatibility [\#152](https://github.com/BoltsFramework/Bolts-ObjC/issues/152)

**Closed issues:**

- Is it possible to create 'cold' \(lazy evaluated\) tasks? [\#203](https://github.com/BoltsFramework/Bolts-ObjC/issues/203)

**Merged pull requests:**

- Use PRODUCT\_BUNDLE\_IDENTIFIER build setting for all targets. [\#211](https://github.com/BoltsFramework/Bolts-ObjC/pull/211) ([nlutsenko](https://github.com/nlutsenko))
- Bolts 1.5.1 🔩 [\#209](https://github.com/BoltsFramework/Bolts-ObjC/pull/209) ([nlutsenko](https://github.com/nlutsenko))
- Add Carthage compatibility badge. [\#208](https://github.com/BoltsFramework/Bolts-ObjC/pull/208) ([nlutsenko](https://github.com/nlutsenko))
- Add tvOS and watchOS dynamic framework targets to support Carthage. [\#206](https://github.com/BoltsFramework/Bolts-ObjC/pull/206) ([nlutsenko](https://github.com/nlutsenko))
- Use Xcode 7.2 for Travis-CI. [\#205](https://github.com/BoltsFramework/Bolts-ObjC/pull/205) ([nlutsenko](https://github.com/nlutsenko))
- Make most executor types create an autorelease pool for each individual task. [\#202](https://github.com/BoltsFramework/Bolts-ObjC/pull/202) ([richardjrossiii](https://github.com/richardjrossiii))
- Dynamic Library for iOS Carthage Support [\#168](https://github.com/BoltsFramework/Bolts-ObjC/pull/168) ([lucasderraugh](https://github.com/lucasderraugh))

## [1.5.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.5.0) (2015-11-14)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.4.0...1.5.0)

**Implemented enhancements:**

- Add nullability annotations to header files [\#161](https://github.com/BoltsFramework/Bolts-ObjC/issues/161)

**Closed issues:**

- Generics not detected in framework code [\#191](https://github.com/BoltsFramework/Bolts-ObjC/issues/191)

**Merged pull requests:**

- Bolts 1.5.0 🔩 [\#199](https://github.com/BoltsFramework/Bolts-ObjC/pull/199) ([nlutsenko](https://github.com/nlutsenko))
- Improve BFTask.continue return type when used with generics. [\#198](https://github.com/BoltsFramework/Bolts-ObjC/pull/198) ([nlutsenko](https://github.com/nlutsenko))
- Changed `-defaultExecutor`'s dispatch policy to check stack space. [\#197](https://github.com/BoltsFramework/Bolts-ObjC/pull/197) ([richardjrossiii](https://github.com/richardjrossiii))
- Add explicit target dependencies to all tests. [\#190](https://github.com/BoltsFramework/Bolts-ObjC/pull/190) ([nlutsenko](https://github.com/nlutsenko))
- Update README.md [\#189](https://github.com/BoltsFramework/Bolts-ObjC/pull/189) ([peymano](https://github.com/peymano))
- Recreate Bolts-iOS target to unbreak building via subproject reference. [\#188](https://github.com/BoltsFramework/Bolts-ObjC/pull/188) ([nlutsenko](https://github.com/nlutsenko))
- Improve performance, memory usage for tasks that are created with result/error/exception/cancelled. [\#187](https://github.com/BoltsFramework/Bolts-ObjC/pull/187) ([nlutsenko](https://github.com/nlutsenko))
- Make tvOS tests run in Travis-CI. [\#186](https://github.com/BoltsFramework/Bolts-ObjC/pull/186) ([nlutsenko](https://github.com/nlutsenko))
- Fix TaskTests.testDescription [\#185](https://github.com/BoltsFramework/Bolts-ObjC/pull/185) ([nlutsenko](https://github.com/nlutsenko))
- Simplify settings properties on a Task from TaskCompletionSource. [\#184](https://github.com/BoltsFramework/Bolts-ObjC/pull/184) ([nlutsenko](https://github.com/nlutsenko))
- Fix warning in BFWebViewAppLinkResolver.m. [\#183](https://github.com/BoltsFramework/Bolts-ObjC/pull/183) ([nlutsenko](https://github.com/nlutsenko))
- Fixed potential memory corruption on accessing a description of a task. [\#182](https://github.com/BoltsFramework/Bolts-ObjC/pull/182) ([nlutsenko](https://github.com/nlutsenko))
- Improve performance of task constructors. [\#181](https://github.com/BoltsFramework/Bolts-ObjC/pull/181) ([nlutsenko](https://github.com/nlutsenko))
- Enable Xcode code coverage for all schemes. [\#180](https://github.com/BoltsFramework/Bolts-ObjC/pull/180) ([nlutsenko](https://github.com/nlutsenko))
- Added nullability annotations to Bolts Tasks. [\#162](https://github.com/BoltsFramework/Bolts-ObjC/pull/162) ([nlutsenko](https://github.com/nlutsenko))

## [1.4.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.4.0) (2015-10-23)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.3.0...1.4.0)

**Closed issues:**

- tvos support in V1.3.0? [\#163](https://github.com/BoltsFramework/Bolts-ObjC/issues/163)

**Merged pull requests:**

- Bolts 1.4.0 🔩 [\#177](https://github.com/BoltsFramework/Bolts-ObjC/pull/177) ([nlutsenko](https://github.com/nlutsenko))
- Update xctoolchain to latest. [\#176](https://github.com/BoltsFramework/Bolts-ObjC/pull/176) ([nlutsenko](https://github.com/nlutsenko))
- Add tvOS SDK to deployment packages. [\#175](https://github.com/BoltsFramework/Bolts-ObjC/pull/175) ([nlutsenko](https://github.com/nlutsenko))
- Add tvOS to the list of supported platforms in podspec. [\#174](https://github.com/BoltsFramework/Bolts-ObjC/pull/174) ([nlutsenko](https://github.com/nlutsenko))
- Enable bitcode for iOS 9.1 SDK. [\#173](https://github.com/BoltsFramework/Bolts-ObjC/pull/173) ([nlutsenko](https://github.com/nlutsenko))
- Make Travis-CI run using Xcode7.1 and run tvOS tests. [\#172](https://github.com/BoltsFramework/Bolts-ObjC/pull/172) ([nlutsenko](https://github.com/nlutsenko))
- Update all projects/schemes for Xcode 7.1 [\#171](https://github.com/BoltsFramework/Bolts-ObjC/pull/171) ([nlutsenko](https://github.com/nlutsenko))
- Fix all new warnings, use modular imports in tests. [\#170](https://github.com/BoltsFramework/Bolts-ObjC/pull/170) ([nlutsenko](https://github.com/nlutsenko))
- Up the minimum required OS version to 6.0, 10.8. [\#169](https://github.com/BoltsFramework/Bolts-ObjC/pull/169) ([nlutsenko](https://github.com/nlutsenko))
- Fix build of tvOS framework. [\#167](https://github.com/BoltsFramework/Bolts-ObjC/pull/167) ([nlutsenko](https://github.com/nlutsenko))
- \[scripts\] Have `test` paths match execution paths [\#166](https://github.com/BoltsFramework/Bolts-ObjC/pull/166) ([modocache](https://github.com/modocache))
- Unify schemes and targets names. [\#165](https://github.com/BoltsFramework/Bolts-ObjC/pull/165) ([nlutsenko](https://github.com/nlutsenko))
- Use configurations from xctoolchain. [\#164](https://github.com/BoltsFramework/Bolts-ObjC/pull/164) ([nlutsenko](https://github.com/nlutsenko))

## [1.3.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.3.0) (2015-09-23)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.2.2...1.3.0)

**Implemented enhancements:**

- linker command failed with exit code 1 when bitcode enabled [\#153](https://github.com/BoltsFramework/Bolts-ObjC/issues/153)

**Closed issues:**

- watchOS 2 Support [\#155](https://github.com/BoltsFramework/Bolts-ObjC/issues/155)

**Merged pull requests:**

- Bolts 1.3.0 [\#160](https://github.com/BoltsFramework/Bolts-ObjC/pull/160) ([nlutsenko](https://github.com/nlutsenko))
- Add watchOS 2 to deployment. [\#159](https://github.com/BoltsFramework/Bolts-ObjC/pull/159) ([nlutsenko](https://github.com/nlutsenko))
- Added watchOS2 support for Bolts pod. [\#158](https://github.com/BoltsFramework/Bolts-ObjC/pull/158) ([nlutsenko](https://github.com/nlutsenko))
- Added watchOS 2 target. [\#157](https://github.com/BoltsFramework/Bolts-ObjC/pull/157) ([nlutsenko](https://github.com/nlutsenko))
- Update schemes for Xcode 7. [\#156](https://github.com/BoltsFramework/Bolts-ObjC/pull/156) ([nlutsenko](https://github.com/nlutsenko))
- Fix warnings when compiling for iOS 9. [\#154](https://github.com/BoltsFramework/Bolts-ObjC/pull/154) ([nlutsenko](https://github.com/nlutsenko))
- Use code coverage from CodeCov. [\#151](https://github.com/BoltsFramework/Bolts-ObjC/pull/151) ([nlutsenko](https://github.com/nlutsenko))
- Added tvOS build target [\#150](https://github.com/BoltsFramework/Bolts-ObjC/pull/150) ([richardjrossiii](https://github.com/richardjrossiii))
- Use only Xcode 7 for Travis-CI. [\#149](https://github.com/BoltsFramework/Bolts-ObjC/pull/149) ([nlutsenko](https://github.com/nlutsenko))
- Fixed undefined behavior caused by casting block types. [\#147](https://github.com/BoltsFramework/Bolts-ObjC/pull/147) ([richardjrossiii](https://github.com/richardjrossiii))

## [1.2.2](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.2.2) (2015-09-10)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.2.1...1.2.2)

**Fixed bugs:**

- BFIncludeStatusBarInSizeAlways never includes the status bar in the size [\#110](https://github.com/BoltsFramework/Bolts-ObjC/issues/110)
- BFURL crash on initialization when target\_url is null [\#114](https://github.com/BoltsFramework/Bolts-ObjC/issues/114)

**Closed issues:**

- forCompletionOfAllTasksWithResults: exception 'Cannot set the result on a completed task.' [\#140](https://github.com/BoltsFramework/Bolts-ObjC/issues/140)

**Merged pull requests:**

- Update the bolts version define to 1.2.2 [\#148](https://github.com/BoltsFramework/Bolts-ObjC/pull/148) ([nlutsenko](https://github.com/nlutsenko))
- Fixed handling of BFIncludeStatusBarInSizeAlways [\#129](https://github.com/BoltsFramework/Bolts-ObjC/pull/129) ([widescape](https://github.com/widescape))
- Update bitcode flag resolution for Xcode 7 GM. [\#146](https://github.com/BoltsFramework/Bolts-ObjC/pull/146) ([nlutsenko](https://github.com/nlutsenko))
- Bolts 1.2.2 [\#145](https://github.com/BoltsFramework/Bolts-ObjC/pull/145) ([nlutsenko](https://github.com/nlutsenko))
- Fixed packaging placing a framework inside a framework. [\#144](https://github.com/BoltsFramework/Bolts-ObjC/pull/144) ([nlutsenko](https://github.com/nlutsenko))
- Enable Xcode 7 code coverage. [\#143](https://github.com/BoltsFramework/Bolts-ObjC/pull/143) ([nlutsenko](https://github.com/nlutsenko))
- Add bitcode support to precompiled frameworks on iOS 9. [\#142](https://github.com/BoltsFramework/Bolts-ObjC/pull/142) ([nlutsenko](https://github.com/nlutsenko))
- Update xcodeproj to use Configuration Files. [\#139](https://github.com/BoltsFramework/Bolts-ObjC/pull/139) ([nlutsenko](https://github.com/nlutsenko))
- Add test runs on Xcode 7. [\#137](https://github.com/BoltsFramework/Bolts-ObjC/pull/137) ([nlutsenko](https://github.com/nlutsenko))
- Add backward compatible Obj-C Generic support for Tasks. [\#136](https://github.com/BoltsFramework/Bolts-ObjC/pull/136) ([nlutsenko](https://github.com/nlutsenko))
- Removed precompiled prefix header from all targets. [\#133](https://github.com/BoltsFramework/Bolts-ObjC/pull/133) ([nlutsenko](https://github.com/nlutsenko))
- Fixed crash when creating a BFURL when target\_url is null. [\#128](https://github.com/BoltsFramework/Bolts-ObjC/pull/128) ([nlutsenko](https://github.com/nlutsenko))

## [1.2.1](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.2.1) (2015-08-26)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.2.0...1.2.1)

**Implemented enhancements:**

- 2 issues in iOS 9  [\#126](https://github.com/BoltsFramework/Bolts-ObjC/issues/126)

**Closed issues:**

- El Café Nadaista - Un Café de la Muerte con sabor a Colombia [\#123](https://github.com/BoltsFramework/Bolts-ObjC/issues/123)
- Tasks not chaining properly [\#116](https://github.com/BoltsFramework/Bolts-ObjC/issues/116)
- Issue when chaining BFTasks created from Swift [\#111](https://github.com/BoltsFramework/Bolts-ObjC/issues/111)
- fetchAsync example no longer valid [\#107](https://github.com/BoltsFramework/Bolts-ObjC/issues/107)
- Update podspec to include "cancellation" commit [\#98](https://github.com/BoltsFramework/Bolts-ObjC/issues/98)

**Merged pull requests:**

- Bolts 1.2.1 [\#131](https://github.com/BoltsFramework/Bolts-ObjC/pull/131) ([nlutsenko](https://github.com/nlutsenko))
- Fix command line build scripts when bolts is contained in paths with spaces. [\#130](https://github.com/BoltsFramework/Bolts-ObjC/pull/130) ([nlutsenko](https://github.com/nlutsenko))
- Fixed deprecations in iOS 9 that cause warnings. [\#127](https://github.com/BoltsFramework/Bolts-ObjC/pull/127) ([nlutsenko](https://github.com/nlutsenko))
- Build only master for pushes on Travis-CI. [\#125](https://github.com/BoltsFramework/Bolts-ObjC/pull/125) ([nlutsenko](https://github.com/nlutsenko))
- Updated README to use new method signature. [\#124](https://github.com/BoltsFramework/Bolts-ObjC/pull/124) ([nlutsenko](https://github.com/nlutsenko))
- spelling [\#121](https://github.com/BoltsFramework/Bolts-ObjC/pull/121) ([Coeur](https://github.com/Coeur))
- Remove the need to check canOpenURL and just use openURL instead. [\#120](https://github.com/BoltsFramework/Bolts-ObjC/pull/120) ([mingflifb](https://github.com/mingflifb))
- Add more tests, remove dead code to improve code coverage. [\#119](https://github.com/BoltsFramework/Bolts-ObjC/pull/119) ([nlutsenko](https://github.com/nlutsenko))
- Update and parallelize Travis-CI. [\#118](https://github.com/BoltsFramework/Bolts-ObjC/pull/118) ([nlutsenko](https://github.com/nlutsenko))
- Fixed never completed task if continuation returns a task and cancellation was requested. [\#106](https://github.com/BoltsFramework/Bolts-ObjC/pull/106) ([nlutsenko](https://github.com/nlutsenko))

## [1.2.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.2.0) (2015-06-04)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.5...1.2.0)

**Closed issues:**

-  Avoid using unavailable APIs when linking against app extension targets. [\#80](https://github.com/BoltsFramework/Bolts-ObjC/issues/80)

**Merged pull requests:**

- Release 1.2.0 [\#104](https://github.com/BoltsFramework/Bolts-ObjC/pull/104) ([nlutsenko](https://github.com/nlutsenko))
- Fixing warning with Appcode [\#103](https://github.com/BoltsFramework/Bolts-ObjC/pull/103) ([Coeur](https://github.com/Coeur))
- Lint all the things! [\#101](https://github.com/BoltsFramework/Bolts-ObjC/pull/101) ([nlutsenko](https://github.com/nlutsenko))
- Update travis configuration to get better last coverage reports. [\#100](https://github.com/BoltsFramework/Bolts-ObjC/pull/100) ([nlutsenko](https://github.com/nlutsenko))
- Generate coverage reports using Coveralls. [\#99](https://github.com/BoltsFramework/Bolts-ObjC/pull/99) ([nlutsenko](https://github.com/nlutsenko))
- Fix: use 'completed' accessor instead of 'isCompleted' [\#97](https://github.com/BoltsFramework/Bolts-ObjC/pull/97) ([BrunoBerisso](https://github.com/BrunoBerisso))
- Fixing a typo in a comment [\#96](https://github.com/BoltsFramework/Bolts-ObjC/pull/96) ([richardgroves](https://github.com/richardgroves))
- Add Task Cancellation [\#89](https://github.com/BoltsFramework/Bolts-ObjC/pull/89) ([josephearl](https://github.com/josephearl))
- Avoid unnecessary call to ‘continueWithBlock:’ when a task is completed [\#57](https://github.com/BoltsFramework/Bolts-ObjC/pull/57) ([BrunoBerisso](https://github.com/BrunoBerisso))

## [1.1.5](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.5) (2015-04-22)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.4...1.1.5)

**Closed issues:**

- Cancellation trumps error in -\[BFTask taskForCompletionOfAllTasks:\] [\#87](https://github.com/BoltsFramework/Bolts-ObjC/issues/87)
- BFTask cancellation [\#86](https://github.com/BoltsFramework/Bolts-ObjC/issues/86)
- Nice to Have: Cocoapods Subspecs [\#60](https://github.com/BoltsFramework/Bolts-ObjC/issues/60)

**Merged pull requests:**

- Release 1.1.5 [\#95](https://github.com/BoltsFramework/Bolts-ObjC/pull/95) ([ghost](https://github.com/ghost))
- Split AppLinks and Tasks into separate subspecs. [\#94](https://github.com/BoltsFramework/Bolts-ObjC/pull/94) ([ghost](https://github.com/ghost))
- Fix State Priority Bug \#87 [\#93](https://github.com/BoltsFramework/Bolts-ObjC/pull/93) ([josephearl](https://github.com/josephearl))
- Cleanup code and improve subclassing for BFTask, BFExecutor, BFTaskCompletionSource. [\#92](https://github.com/BoltsFramework/Bolts-ObjC/pull/92) ([ghost](https://github.com/ghost))
- Update Patent Grant and License [\#91](https://github.com/BoltsFramework/Bolts-ObjC/pull/91) ([ghost](https://github.com/ghost))
- Fixed warnings on clang modulemaps and potentially no module map in release configuration. [\#90](https://github.com/BoltsFramework/Bolts-ObjC/pull/90) ([ghost](https://github.com/ghost))
- Fix up the app link return to referer view/controller [\#88](https://github.com/BoltsFramework/Bolts-ObjC/pull/88) ([toddkrabach](https://github.com/toddkrabach))

## [1.1.4](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.4) (2015-03-03)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.3...1.1.4)

**Closed issues:**

- Errors with Bolts-Pod when using Facbook-iOS-SDK on CI Server [\#79](https://github.com/BoltsFramework/Bolts-ObjC/issues/79)
- NSError cannot be used as a boolean [\#73](https://github.com/BoltsFramework/Bolts-ObjC/issues/73)
- \[Crash\] on iPhone 4 iOS 7.0.4 FYI [\#72](https://github.com/BoltsFramework/Bolts-ObjC/issues/72)
- Missing tag v1.1.0 [\#69](https://github.com/BoltsFramework/Bolts-ObjC/issues/69)
- Attempt to read non existent folder [\#66](https://github.com/BoltsFramework/Bolts-ObjC/issues/66)
- Codesign OSX10.9.5 [\#65](https://github.com/BoltsFramework/Bolts-ObjC/issues/65)
- Completed set before the task has actually completed [\#58](https://github.com/BoltsFramework/Bolts-ObjC/issues/58)
- Use NSProgress for progress info and cancellation token [\#42](https://github.com/BoltsFramework/Bolts-ObjC/issues/42)
- Not compatible with UISearchDisplayController [\#35](https://github.com/BoltsFramework/Bolts-ObjC/issues/35)
- Add 'isFaulted' property to BFTask - keep in line with Android [\#33](https://github.com/BoltsFramework/Bolts-ObjC/issues/33)
- Small hitTargets of BFAppLinkRefererView... [\#29](https://github.com/BoltsFramework/Bolts-ObjC/issues/29)
- Provide a result for taskForCompletionOfAllTasks [\#23](https://github.com/BoltsFramework/Bolts-ObjC/issues/23)
- For asynch parse operations when testing - waitUntilFinished hangs indefinitely [\#19](https://github.com/BoltsFramework/Bolts-ObjC/issues/19)
- How to re-throw exceptions? [\#16](https://github.com/BoltsFramework/Bolts-ObjC/issues/16)

**Merged pull requests:**

- Release 1.1.4 [\#85](https://github.com/BoltsFramework/Bolts-ObjC/pull/85) ([ghost](https://github.com/ghost))
- Make BFTaskErrorDomain, BFTaskMultipleExceptionsException public. [\#84](https://github.com/BoltsFramework/Bolts-ObjC/pull/84) ([ghost](https://github.com/ghost))
- Add podspec linting to Travis-CI. [\#83](https://github.com/BoltsFramework/Bolts-ObjC/pull/83) ([ghost](https://github.com/ghost))
- Convert static library target to iOS Static Framework. [\#82](https://github.com/BoltsFramework/Bolts-ObjC/pull/82) ([ghost](https://github.com/ghost))
- Enable more pedantic warnings and fix them. [\#81](https://github.com/BoltsFramework/Bolts-ObjC/pull/81) ([ghost](https://github.com/ghost))
- Better -\(NSString\*\)description for BFTask [\#78](https://github.com/BoltsFramework/Bolts-ObjC/pull/78) ([josephearl](https://github.com/josephearl))
- Increase Size of Hit Targets on BFAppLinkRefererView [\#77](https://github.com/BoltsFramework/Bolts-ObjC/pull/77) ([josephearl](https://github.com/josephearl))
- Add taskForCompletionOfAllTasksWithResults and faulted property [\#76](https://github.com/BoltsFramework/Bolts-ObjC/pull/76) ([josephearl](https://github.com/josephearl))
- Fixed Swift syntax in Readme. [\#75](https://github.com/BoltsFramework/Bolts-ObjC/pull/75) ([ghost](https://github.com/ghost))
- Fix minor typo in Readme.md [\#70](https://github.com/BoltsFramework/Bolts-ObjC/pull/70) ([alexshepard](https://github.com/alexshepard))
- fixed incorrect string syntax [\#68](https://github.com/BoltsFramework/Bolts-ObjC/pull/68) ([revolter](https://github.com/revolter))

## [1.1.3](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.3) (2014-10-09)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.2...1.1.3)

**Merged pull requests:**

- Change from `\#import "foo"` to `\#import \<Bolts/foo\>`. [\#63](https://github.com/BoltsFramework/Bolts-ObjC/pull/63) ([bolinfest](https://github.com/bolinfest))
- Update Bolts to work on OS X 10.10 and enable modules. Update iOS to include armv7s. [\#62](https://github.com/BoltsFramework/Bolts-ObjC/pull/62) ([ghost](https://github.com/ghost))
- Make Bolts subproject referencable. Introduced build\_release script. [\#59](https://github.com/BoltsFramework/Bolts-ObjC/pull/59) ([ghost](https://github.com/ghost))

## [1.1.2](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.2) (2014-08-21)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.1...1.1.2)

**Closed issues:**

- Custom URL Schemes not supported in \[BFAppLinkNavigation navigateToURLInBackground:url\] [\#47](https://github.com/BoltsFramework/Bolts-ObjC/issues/47)
- Prevent duplicate tasks [\#40](https://github.com/BoltsFramework/Bolts-ObjC/issues/40)
- How to stop BFTask Chain ？ [\#39](https://github.com/BoltsFramework/Bolts-ObjC/issues/39)
- navigateToURLInBackground returns NSURLErrorDomain - code 1002 [\#30](https://github.com/BoltsFramework/Bolts-ObjC/issues/30)

**Merged pull requests:**

- Applink Events [\#56](https://github.com/BoltsFramework/Bolts-ObjC/pull/56) ([agener917](https://github.com/agener917))
- Added Swift versions of most examples. [\#55](https://github.com/BoltsFramework/Bolts-ObjC/pull/55) ([gfosco](https://github.com/gfosco))
- Fixed potential crash in BFAppLinkReturnToRefererController when it is initialized without navigation controller. [\#54](https://github.com/BoltsFramework/Bolts-ObjC/pull/54) ([ghost](https://github.com/ghost))
- Fixed documentation in the common parts of Bolts. [\#51](https://github.com/BoltsFramework/Bolts-ObjC/pull/51) ([ghost](https://github.com/ghost))
- Added badges for CI/CocoaPods/License/Dependencies/References. [\#48](https://github.com/BoltsFramework/Bolts-ObjC/pull/48) ([ghost](https://github.com/ghost))

## [1.1.1](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.1) (2014-08-02)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.1.0...1.1.1)

**Closed issues:**

- back view is missing [\#36](https://github.com/BoltsFramework/Bolts-ObjC/issues/36)
- AppLink Release Date? [\#24](https://github.com/BoltsFramework/Bolts-ObjC/issues/24)

**Merged pull requests:**

- Specified proper install path and dynamic library install name. [\#45](https://github.com/BoltsFramework/Bolts-ObjC/pull/45) ([ghost](https://github.com/ghost))
- Make Bolts for Mac being built as a dynamic library. [\#43](https://github.com/BoltsFramework/Bolts-ObjC/pull/43) ([ghost](https://github.com/ghost))
- Fix typo [\#32](https://github.com/BoltsFramework/Bolts-ObjC/pull/32) ([wiruzx](https://github.com/wiruzx))
- Update `respondsToSelector` checks to reflect the new method names [\#31](https://github.com/BoltsFramework/Bolts-ObjC/pull/31) ([ide](https://github.com/ide))
- UITextAlignment is deprecated, so for iOS 6+, use NSTextAlignment instead [\#28](https://github.com/BoltsFramework/Bolts-ObjC/pull/28) ([toddkrabach](https://github.com/toddkrabach))
- +\[BFTask taskFromExecutor:withBlock\] to easily create ad-hoc tasks [\#21](https://github.com/BoltsFramework/Bolts-ObjC/pull/21) ([ide](https://github.com/ide))

## [1.1.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.1.0) (2014-04-30)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/v1.1.0...1.1.0)

## [v1.1.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/v1.1.0) (2014-04-30)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/1.0.0...v1.1.0)

**Closed issues:**

- Task Cancellation [\#18](https://github.com/BoltsFramework/Bolts-ObjC/issues/18)
- No facility for automatically generating array of results for grouped tasks [\#15](https://github.com/BoltsFramework/Bolts-ObjC/issues/15)

**Merged pull requests:**

- Fix minor typo in Readme.md \(pod syntax\) [\#22](https://github.com/BoltsFramework/Bolts-ObjC/pull/22) ([jai](https://github.com/jai))
- Updated Readme.md - \#\#Task Cancellation [\#20](https://github.com/BoltsFramework/Bolts-ObjC/pull/20) ([saniul](https://github.com/saniul))
- Minor typo in CONTRIBUTING.md [\#17](https://github.com/BoltsFramework/Bolts-ObjC/pull/17) ([saniul](https://github.com/saniul))
- Update Readme.md [\#13](https://github.com/BoltsFramework/Bolts-ObjC/pull/13) ([RuiAAPeres](https://github.com/RuiAAPeres))
- Fix method names with args [\#12](https://github.com/BoltsFramework/Bolts-ObjC/pull/12) ([travisjeffery](https://github.com/travisjeffery))
- Fix code examples \(fixes \#4\) [\#11](https://github.com/BoltsFramework/Bolts-ObjC/pull/11) ([travisjeffery](https://github.com/travisjeffery))
- Switched to the newer Objective-C convention of “instancetype”  [\#10](https://github.com/BoltsFramework/Bolts-ObjC/pull/10) ([mrplants](https://github.com/mrplants))
- Minor typo fix [\#9](https://github.com/BoltsFramework/Bolts-ObjC/pull/9) ([chroman](https://github.com/chroman))
- Added a few pragma marks. [\#7](https://github.com/BoltsFramework/Bolts-ObjC/pull/7) ([RuiAAPeres](https://github.com/RuiAAPeres))
- Update Readme.md [\#6](https://github.com/BoltsFramework/Bolts-ObjC/pull/6) ([RuiAAPeres](https://github.com/RuiAAPeres))
- Podspec updated [\#5](https://github.com/BoltsFramework/Bolts-ObjC/pull/5) ([jvenegas](https://github.com/jvenegas))
- Removing a piece of Android related code in the iOS documentation [\#3](https://github.com/BoltsFramework/Bolts-ObjC/pull/3) ([caherrerapa](https://github.com/caherrerapa))

## [1.0.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/1.0.0) (2014-01-31)
[Full Changelog](https://github.com/BoltsFramework/Bolts-ObjC/compare/v1.0.0...1.0.0)

**Merged pull requests:**

- Add CocoaPods support. [\#2](https://github.com/BoltsFramework/Bolts-ObjC/pull/2) ([hramos](https://github.com/hramos))
- getStringAsync should return BFTask [\#1](https://github.com/BoltsFramework/Bolts-ObjC/pull/1) ([sheepsteak](https://github.com/sheepsteak))

## [v1.0.0](https://github.com/BoltsFramework/Bolts-ObjC/tree/v1.0.0) (2014-01-30)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*