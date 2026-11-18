Used to manage route-based dialogs and loading states, controlling when they are pushed and
dismissed.

## Usage

#### 1.1 Prepare the lifecycle environment.

```dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use LifecycleApp to wrap the default App
    return LifecycleApp(
      child: MaterialApp(
        title: 'Dialog Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          //Use LifecycleNavigatorObserver.hookMode() to register routing event changes
          LifecycleNavigatorObserver.hookMode(),
        ],
        home: const HomeRememberDemo(title: 'Dialog Home Page'),
      ),
    );
  }
}
```

The current usage of PageView and TabBarViewPageView should be replaced with LifecyclePageView and
LifecycleTabBarView. Alternatively, you can wrap the items with LifecyclePageViewItem. You can refer
to [anlifecycle](https://pub.dev/packages/anlifecycle) for guidance.

#### 1.2 Configure your UI visual style (optional, the default is to use the MD style).

```dart
void initDialogs() {
  LoadingConfig.instance.XXXX;
  DialogsConfig.instance.XXX;
}
```

> **Note / 特殊说明**:
> If your project disables or does not depend on `flutter/material.dart` (e.g. using `material_ui` package), you must explicitly specify and configure the corresponding functions in `DialogsConfig.instance` and `LoadingConfig.instance` to override the defaults in `material_support.dart`.
>
> 如果使用了 `material_ui` 等自定义 UI 包或禁用了默认的 `flutter/material.dart`，则必须在 `DialogsConfig.instance` 和 `LoadingConfig.instance` 中显式指定 `material_support.dart` 对应的函数内容：
>
> ```dart
> void initDialogs() {
>   // 自定义 Dialog 路由、内容与按钮构建器
>   DialogsConfig.instance.dialogRouteBuilder = (context, dialogContent) { ... };
>   DialogsConfig.instance.dialogContentBuilder = (context, title, content, confirm, cancel) { ... };
>   DialogsConfig.instance.dialogLabelActionBuilder = (context, label, onPressed) { ... };
>
>   // 自定义 Loading 路由与内容构建器
>   LoadingConfig.instance.loadingDialogRouteBuilder = (context, dialogContent) { ... };
>   LoadingConfig.instance.loadingDialogContentBuilder = (context, messageBuilder) { ... };
> }
> ```

#### 1.3 Use loading to automatically manage appearance and disappearance.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lifecycle = context.lifecycle;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextButton(
              onPressed: () {
                lifecycle.showAlert(
                    titleLabel: 'Title', message: 'Alert message');
              },
              child: Text('showAlert'),
            ),
            TextButton(
              onPressed: () async {
                final select = await lifecycle.showConfirm(
                    titleLabel: 'Confirm', message: 'Confirm message');
                print('select:$select');
              },
              child: Text('showConfirm'),
            ),
            TextButton(
              onPressed: () async {
                final loading = lifecycle.makeLiveCancellable();
                lifecycle.showLoading(cancellable: loading);
                try {
                  await _loading1Future();
                } finally {
                  loading.cancel();
                }
              },
              child: Text('showLoading 3s'),
            ),
            TextButton(
              onPressed: () async {
                final loading = lifecycle.makeLiveCancellable();
                lifecycle.showLoading(cancellable: loading, message: 'loading');
                try {
                  await _loading1Future();
                } finally {
                  loading.cancel();
                }
              },
              child: Text('showMessageLoading 3s'),
            ),
            TextButton(
              onPressed: () {
                _loading1Future()
                    .withLoading(lifecycle)
                    .then((_) => print('future 1 end'));
                _loading2Future()
                    .withLoading(lifecycle)
                    .then((_) => print('future 2 end'));
              },
              child: Text('showLoading 3s & 5s '),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _loading1Future() async {
  await Future.delayed(const Duration(seconds: 3));
}

Future<void> _loading2Future() async {
  await Future.delayed(const Duration(seconds: 5));
}

extension on BuildContext {
  Lifecycle get lifecycle => Lifecycle.of(this);
}

```

## Additional information

See [anlifecycle](https://pub.dev/packages/anlifecycle)

See [cancelable](https://pub.dev/packages/cancellable)

See [an_lifecycle_cancellable](https://pub.dev/packages/an_lifecycle_cancellable)

See [an_viewmodel](https://pub.dev/packages/an_viewmodel)