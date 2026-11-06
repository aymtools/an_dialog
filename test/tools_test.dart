import 'package:an_dialogs/src/tools/tools.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 工具函数/帮助方法测试组
  group('tools.dart Tests', () {
    // 测试 loadingMessageBuilder 当消息为空字符串时返回 null
    test('loadingMessageBuilder returns null for empty string', () {
      expect(loadingMessageBuilder(''), isNull);
    });

    // 测试 loadingMessageBuilder 当消息非空时返回构建器函数
    testWidgets('loadingMessageBuilder returns builder for non-empty string',
        (WidgetTester tester) async {
      final builder = loadingMessageBuilder('Hello World');
      expect(builder, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => builder!(context),
          ),
        ),
      );

      // 验证生成的 Widget 中展示了正确文本
      expect(find.text('Hello World'), findsOneWidget);
    });

    // 测试 actionWidget 在提供 actionBuilder 时优先使用 actionBuilder
    testWidgets('actionWidget uses actionBuilder when provided',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return actionWidget(
                context: context,
                actionBuilder: (ctx, onTap) => ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Custom Builder Action'),
                ),
                labelBuilder: (_) => 'Default',
                onPressed: () => pressed = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Custom Builder Action'), findsOneWidget);
      await tester.tap(find.text('Custom Builder Action'));
      expect(pressed, isTrue);
    });

    // 测试 actionWidget 在提供 action Widget 时包装为 GestureDetector
    testWidgets('actionWidget uses action Widget with GestureDetector when provided',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return actionWidget(
                context: context,
                action: const Text('Widget Action'),
                labelBuilder: (_) => 'Default',
                onPressed: () => pressed = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Widget Action'), findsOneWidget);
      await tester.tap(find.text('Widget Action'));
      expect(pressed, isTrue);
    });

    // 测试 actionWidget 在提供 label 和 labelActionBuilder 时的行为
    testWidgets('actionWidget uses label and labelActionBuilder',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return actionWidget(
                context: context,
                label: 'Custom Label',
                labelBuilder: (_) => 'Default Label',
                labelActionBuilder: (ctx, label, onTap) => TextButton(
                  onPressed: onTap,
                  child: Text('CustomAction: $label'),
                ),
                onPressed: () => pressed = true,
              );
            },
          ),
        ),
      );

      expect(find.text('CustomAction: Custom Label'), findsOneWidget);
      await tester.tap(find.text('CustomAction: Custom Label'));
      expect(pressed, isTrue);
    });

    // 测试 actionWidget 回退到 labelBuilder 与全局默认对话框按钮构建器
    testWidgets('actionWidget falls back to labelBuilder and default dialogLabelActionBuilder',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return actionWidget(
                context: context,
                labelBuilder: (_) => 'Default Label Text',
                onPressed: () => pressed = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Default Label Text'), findsOneWidget);
      await tester.tap(find.text('Default Label Text'));
      expect(pressed, isTrue);
    });

    // 测试 safeShowDialog 在 cancellable 已不可用时不进行展示
    testWidgets('safeShowDialog does nothing if cancellable is unavailable',
        (WidgetTester tester) async {
      bool displayed = false;
      final c = Cancellable()..cancel();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final nav = Navigator.of(context);
              final route = DialogRoute<void>(
                context: context,
                builder: (_) => const SizedBox(),
              );
              safeShowDialog(
                (n, cancellable, r) => displayed = true,
                nav,
                c,
                route,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(displayed, isFalse);
    });
  });
}
