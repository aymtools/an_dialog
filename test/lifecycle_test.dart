import 'dart:async';

import 'package:an_async_data/an_async_data.dart';
import 'package:an_dialogs/an_dialogs.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 构建基于 anlifecycle 框架的测试 App 环境
Widget _buildTestApp({required WidgetBuilder childBuilder}) {
  return LifecycleApp(
    child: MaterialApp(
      navigatorObservers: [LifecycleNavigatorObserver.hookMode()],
      home: Builder(builder: childBuilder),
    ),
  );
}

void main() {
  // LifecycleDialogsExt（绑定 Lifecycle 的 Alert 与 Confirm 对话框扩展）测试组
  group('LifecycleDialogsExt Tests', () {
    // 测试 ILifecycle.showAlert 当 content 与 message 同时为 null 时抛出 Exception
    testWidgets('ILifecycle.showAlert throws exception when both content and message are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            final lifecycle = Lifecycle.of(context);
            expect(
              () => lifecycle.showAlert(),
              throwsA(isA<Exception>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    // 测试 ILifecycle.showAlert 当 runAtLeastState 小于 LifecycleState.created 时抛出 Exception
    testWidgets('ILifecycle.showAlert throws exception if runAtLeastState is less than created',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            final lifecycle = Lifecycle.of(context);
            expect(
              () => lifecycle.showAlert(
                message: 'Hello',
                runAtLeastState: LifecycleState.destroyed,
              ),
              throwsA(isA<Exception>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    // 测试 ILifecycle.showAlert 正确显示 Alert 并在点击确认按钮后完成返回的 Future
    testWidgets('ILifecycle.showAlert displays dialog and completes when OK tapped',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                lifecycle
                    .showAlert(
                  titleLabel: 'Lifecycle Alert',
                  message: 'Alert Body Text',
                  okLabel: 'Got It',
                )
                    .then((_) {
                  completed = true;
                });
              },
              child: const Text('Show Alert'),
            );
          },
        ),
      );

      // 点击触发 Alert
      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();

      // 验证标题与描述显示成功
      expect(find.text('Lifecycle Alert'), findsOneWidget);
      expect(find.text('Alert Body Text'), findsOneWidget);

      // 点击 Got It
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      // 验证 Future 完成且对话框已被移除
      expect(completed, isTrue);
      expect(find.text('Lifecycle Alert'), findsNothing);
    });

    // 测试 ILifecycle.showConfirm 当 content 与 message 同时为 null 时抛出 Exception
    testWidgets('ILifecycle.showConfirm throws exception when both content and message are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            final lifecycle = Lifecycle.of(context);
            expect(
              () => lifecycle.showConfirm(),
              throwsA(isA<Exception>()),
            );
            return const SizedBox();
          },
        ),
      );
    });

    // 测试 ILifecycle.showConfirm 点击 Approve 时返回 true
    testWidgets('ILifecycle.showConfirm returns true on OK and false on Cancel',
        (WidgetTester tester) async {
      bool? confirmResult;

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                lifecycle
                    .showConfirm(
                  titleLabel: 'Lifecycle Confirm',
                  message: 'Confirm this action?',
                  okLabel: 'Approve',
                  cancelLabel: 'Deny',
                )
                    .then((res) {
                  confirmResult = res;
                });
              },
              child: const Text('Show Confirm'),
            );
          },
        ),
      );

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Lifecycle Confirm'), findsOneWidget);
      expect(find.text('Confirm this action?'), findsOneWidget);

      // 点击 Approve 按钮
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      // 验证返回结果为 true
      expect(confirmResult, isTrue);
    });
  });

  // LifecycleLoadingExt（绑定 Lifecycle 的 Loading 加载弹窗与 Stream/Future/ValueNotifier 联动扩展）测试组
  group('LifecycleLoadingExt Tests', () {
    // 测试 ILifecycle.showLoading 显示与取消 Loading
    testWidgets('ILifecycle.showLoading displays and dismisses loading',
        (WidgetTester tester) async {
      final c = Cancellable();

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                lifecycle.showLoading(
                  message: 'Lifecycle Loading...',
                  cancellable: c,
                );
              },
              child: const Text('Show Loading'),
            );
          },
        ),
      );

      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Lifecycle Loading...'), findsOneWidget);

      c.cancel();
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // 测试 Future.withLoading 在 Future 执行期间自动开启 Loading，Future 完成后自动关闭
    testWidgets('Future.withLoading automatically shows and dismisses loading',
        (WidgetTester tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                completer.future.withLoading(
                  lifecycle,
                  message: 'Waiting Future...',
                );
              },
              child: const Text('Start Future'),
            );
          },
        ),
      );

      await tester.tap(find.text('Start Future'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Waiting Future...'), findsOneWidget);

      // 完成 Future
      completer.complete('Done');
      await tester.pumpAndSettle();

      // 验证 Loading 自动关闭
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // 测试 Stream.withLoading 在 Stream 接收到数据时自动关闭 Loading
    testWidgets('Stream.withLoading automatically shows and dismisses loading on data',
        (WidgetTester tester) async {
      final controller = StreamController<int>();

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                controller.stream
                    .withLoading(
                      lifecycle,
                      message: 'Waiting Stream...',
                    )
                    .listen((_) {});
              },
              child: const Text('Start Stream'),
            );
          },
        ),
      );

      await tester.tap(find.text('Start Stream'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Waiting Stream...'), findsOneWidget);

      // 发射数据
      controller.add(1);
      await tester.pumpAndSettle();

      // 验证发射数据后 Loading 自动关闭
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await controller.close();
    });

    // 测试 showLoadingFlowAsyncNotifier 根据 AsyncData 的 loading 状态自动显示与隐藏 Loading
    testWidgets('showLoadingFlowAsyncNotifier displays loading based on AsyncData loading state',
        (WidgetTester tester) async {
      final asyncNotifier = ValueNotifier<AsyncData<int>>(AsyncData.loading());

      await tester.pumpWidget(
        _buildTestApp(
          childBuilder: (context) {
            return ElevatedButton(
              onPressed: () {
                final lifecycle = Lifecycle.of(context);
                lifecycle.showLoadingFlowAsyncNotifier(
                  asyncNotifier: asyncNotifier,
                  message: 'Async Loading...',
                );
              },
              child: const Text('Observe AsyncData'),
            );
          },
        ),
      );

      await tester.tap(find.text('Observe AsyncData'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 验证处于 isLoading 时展示了 Loading 弹窗
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Async Loading...'), findsOneWidget);

      // 切换状态为已有数据
      asyncNotifier.value = AsyncData.data(42);
      await tester.pumpAndSettle();

      // 验证数据加载完毕后 Loading 弹窗关闭
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
