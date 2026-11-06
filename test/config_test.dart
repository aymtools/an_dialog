import 'package:an_dialogs/an_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // DialogsConfig 配置项测试组
  group('DialogsConfig Tests', () {
    // 测试 DialogsConfig 单例模式
    test('singleton instance', () {
      final config1 = DialogsConfig.instance;
      final config2 = DialogsConfig.instance;
      expect(config1, equals(config2));
    });

    // 测试默认文本对齐配置
    test('default configuration values', () {
      final config = DialogsConfig.instance;
      expect(config.dialogTitleTextAlign, equals(TextAlign.center));
      expect(config.dialogContentTextAlign, equals(TextAlign.center));
    });

    // 测试默认按钮标签生成器返回的默认文字
    testWidgets('default label builders return expected values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final config = DialogsConfig.instance;
              // 验证 Alert 按钮默认文字为 'OK'
              expect(config.alertDialogActionDefaultLabel(context), equals('OK'));
              // 验证 Confirm 确认按钮默认文字为 'OK'
              expect(config.confirmDialogConfirmActionDefaultLabel(context),
                  equals('OK'));
              // 验证 Confirm 取消按钮默认文字为 'Cancel'
              expect(config.confirmDialogCancelActionDefaultLabel(context),
                  equals('Cancel'));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    // 测试自定义设置 alert 和 confirm 的路由构建器 (routeBuilder)
    test('alert and confirm route builder custom overrides', () {
      final config = DialogsConfig.instance;
      final defaultRouteBuilder = config.dialogRouteBuilder;

      // 默认情况下 Alert 和 Confirm 的路由构建器等于全局默认构建器
      expect(config.alertDialogRouteBuilder, equals(defaultRouteBuilder));
      expect(config.confirmDialogRouteBuilder, equals(defaultRouteBuilder));

      RawDialogRoute<void> customAlertBuilder(
          BuildContext context, Widget child) {
        return DialogRoute<void>(context: context, builder: (_) => child);
      }

      RawDialogRoute<void> customConfirmBuilder(
          BuildContext context, Widget child) {
        return DialogRoute<void>(context: context, builder: (_) => child);
      }

      // 设置自定义路由构建器
      config.alertDialogRouteBuilder = customAlertBuilder;
      config.confirmDialogRouteBuilder = customConfirmBuilder;

      expect(config.alertDialogRouteBuilder, equals(customAlertBuilder));
      expect(config.confirmDialogRouteBuilder, equals(customConfirmBuilder));

      // 测试完毕后还原配置，避免影响其他测试
      config.alertDialogRouteBuilder = defaultRouteBuilder;
      config.confirmDialogRouteBuilder = defaultRouteBuilder;
    });

    // 测试自定义设置 alert 和 confirm 的按钮 Widget 构建器 (labelActionBuilder)
    test('alert and confirm label action builder custom overrides', () {
      final config = DialogsConfig.instance;
      final defaultActionBuilder = config.dialogLabelActionBuilder;

      expect(config.alertDialogLabelActionBuilder, equals(defaultActionBuilder));
      expect(config.confirmDialogConfirmLabelActionBuilder,
          equals(defaultActionBuilder));
      expect(config.confirmDialogCancelLabelActionBuilder,
          equals(defaultActionBuilder));

      Widget customAlertAction(
          BuildContext context, String label, VoidCallback onPressed) {
        return TextButton(onPressed: onPressed, child: Text('Alert: $label'));
      }

      Widget customConfirmAction(
          BuildContext context, String label, VoidCallback onPressed) {
        return TextButton(onPressed: onPressed, child: Text('Confirm: $label'));
      }

      Widget customCancelAction(
          BuildContext context, String label, VoidCallback onPressed) {
        return TextButton(onPressed: onPressed, child: Text('Cancel: $label'));
      }

      // 设置自定义按钮构建逻辑
      config.alertDialogLabelActionBuilder = customAlertAction;
      config.setConfirmDialogLabelActionBuilder(
          customConfirmAction, customCancelAction);

      expect(
          config.alertDialogLabelActionBuilder, equals(customAlertAction));
      expect(config.confirmDialogConfirmLabelActionBuilder,
          equals(customConfirmAction));
      expect(config.confirmDialogCancelLabelActionBuilder,
          equals(customCancelAction));

      // 还原配置
      config.alertDialogLabelActionBuilder = defaultActionBuilder;
      config.confirmDialogConfirmLabelActionBuilder = defaultActionBuilder;
      config.confirmDialogCancelLabelActionBuilder = defaultActionBuilder;
    });
  });

  // LoadingConfig 配置项测试组
  group('LoadingConfig Tests', () {
    // 测试 LoadingConfig 单例
    test('singleton instance', () {
      final config1 = LoadingConfig.instance;
      final config2 = LoadingConfig.instance;
      expect(config1, equals(config2));
    });

    // 测试无消息描述时默认 Loading 弹窗布局
    testWidgets('defaultLoadingDialogContentBuilder renders indicator without message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return defaultLoadingDialogContentBuilder(context, null);
            },
          ),
        ),
      );

      // 应当渲染 CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // 测试带有消息描述时默认 Loading 弹窗布局
    testWidgets('defaultLoadingDialogContentBuilder renders message widget when messageBuilder provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return defaultLoadingDialogContentBuilder(
                context,
                (ctx) => const Text('Loading Test Message'),
              );
            },
          ),
        ),
      );

      // 应当同时包含 CircularProgressIndicator 和消息文本
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Test Message'), findsOneWidget);
    });

    // 测试 loadingMessageWidgetBuilder 创建文本 Widget
    testWidgets('loadingMessageWidgetBuilder creates text widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return LoadingConfig.instance
                  .loadingMessageWidgetBuilder(context, 'Test Msg');
            },
          ),
        ),
      );

      expect(find.text('Test Msg'), findsOneWidget);
    });
  });
}
