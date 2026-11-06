import 'package:an_dialogs/an_dialogs.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Navigator 扩展方法中关于 Loading 加载弹窗的测试组
  group('NavigatorLoadingExt Tests', () {
    // 测试 showLoading 能够正确弹出 Loading 并在 cancellable 取消后自动关闭
    testWidgets('showLoading displays indicator and dismisses when cancellable is cancelled',
        (WidgetTester tester) async {
      final cancellable = Cancellable();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.showLoading(
                    message: 'Loading Data...',
                    cancellable: cancellable,
                  );
                },
                child: const Text('Show Loading'),
              );
            },
          ),
        ),
      );

      // 点击弹出 Loading
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 验证加载圈和文本已在屏幕上显示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Data...'), findsOneWidget);

      // 取消操作
      cancellable.cancel();
      await tester.pumpAndSettle();

      // 验证 Loading 弹窗被正常移除
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loading Data...'), findsNothing);
    });

    // 测试 showLoading 当传入已取消的 cancellable 时自动忽略
    testWidgets('showLoading ignores unavailable cancellable',
        (WidgetTester tester) async {
      final cancellable = Cancellable()..cancel();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.showLoading(
                    message: 'Will Not Show',
                    cancellable: cancellable,
                  );
                },
                child: const Text('Show Loading'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Loading'));
      await tester.pumpAndSettle();

      // 不应当弹出对话框
      expect(find.text('Will Not Show'), findsNothing);
    });

    // 测试 showCustomLoading 自定义构建 Loading UI 的渲染
    testWidgets('showCustomLoading renders custom widget builder',
        (WidgetTester tester) async {
      final cancellable = Cancellable();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.showCustomLoading(
                    messageBuilder: (ctx) => const Text('Custom Progress Widget'),
                    cancellable: cancellable,
                  );
                },
                child: const Text('Show Custom Loading'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Custom Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 验证渲染了自定义的 Text Widget
      expect(find.text('Custom Progress Widget'), findsOneWidget);

      cancellable.cancel();
      await tester.pumpAndSettle();

      expect(find.text('Custom Progress Widget'), findsNothing);
    });

    // 测试多次并发调用 showLoading 时队列依次更新显示内容，直到所有 cancellables 取消后弹窗才关闭
    testWidgets('multiple loading calls update active message and keep dialog open until all cancel',
        (WidgetTester tester) async {
      final c1 = Cancellable();
      final c2 = Cancellable();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.showLoading(message: 'Task 1', cancellable: c1);
                  nav.showLoading(message: 'Task 2', cancellable: c2);
                },
                child: const Text('Start Tasks'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Start Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 队列中最新添加的任务为 Task 2，因此应当优先展示 Task 2 的提示
      expect(find.text('Task 2'), findsOneWidget);

      // 取消第一个任务
      c1.cancel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // 弹窗依然保留，展示 Task 2
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);

      // 取消第二个任务
      c2.cancel();
      await tester.pumpAndSettle();
      // 队列中所有任务均已取消，Loading 弹窗关闭
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
