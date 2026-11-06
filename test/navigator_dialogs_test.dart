import 'package:an_dialogs/an_dialogs.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Navigator 扩展方法中关于 Dialog（Alert 与 Confirm）的测试组
  group('NavigatorDialogsExt Tests', () {
    // 测试 showAlert 当 content 与 message 同时为 null 时抛出 Exception 异常
    testWidgets('showAlert throws exception when both content and message are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final nav = Navigator.of(context);
              expect(
                () => nav.showAlert(),
                throwsA(isA<Exception>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    // 测试 showAlert 当传入已取消的 cancellable 时抛出 Exception 异常
    testWidgets('showAlert throws exception if cancellable is unavailable',
        (WidgetTester tester) async {
      final c = Cancellable()..cancel();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final nav = Navigator.of(context);
              expect(
                () => nav.showAlert(
                  message: 'Hello',
                  cancellable: c,
                ),
                throwsA(isA<Exception>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    // 测试 showAlert 能够正常显示 Alert 对话框，并在点击确认按钮后完成返回的 Future
    testWidgets('showAlert displays dialog and completes when OK button is pressed',
        (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav
                      .showAlert(
                    titleLabel: 'Alert Title',
                    message: 'Alert Message Content',
                    okLabel: 'Custom OK',
                  )
                      .then((_) {
                    completed = true;
                  });
                },
                child: const Text('Show Alert'),
              );
            },
          ),
        ),
      );

      // 点击按钮触发 Alert
      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();

      // 校验对话框标题、内容和按钮正常弹出
      expect(find.text('Alert Title'), findsOneWidget);
      expect(find.text('Alert Message Content'), findsOneWidget);
      expect(find.text('Custom OK'), findsOneWidget);

      // 点击确认按钮
      await tester.tap(find.text('Custom OK'));
      await tester.pumpAndSettle();

      // 验证 Future 完成，弹窗已被关闭
      expect(completed, isTrue);
      expect(find.text('Alert Title'), findsNothing);
    });

    // 测试 showConfirm 当 content 与 message 同时为 null 时抛出 Exception 异常
    testWidgets('showConfirm throws exception when both content and message are null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final nav = Navigator.of(context);
              expect(
                () => nav.showConfirm(),
                throwsA(isA<Exception>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    // 测试 showConfirm 在点击确认按钮时返回 true
    testWidgets('showConfirm returns true when OK is pressed',
        (WidgetTester tester) async {
      bool? confirmResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav
                      .showConfirm(
                    titleLabel: 'Confirm Title',
                    message: 'Are you sure?',
                    okLabel: 'Yes',
                    cancelLabel: 'No',
                  )
                      .then((res) {
                    confirmResult = res;
                  });
                },
                child: const Text('Show Confirm'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Title'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);

      // 点击确认按钮 "Yes"
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // 验证确认结果为 true
      expect(confirmResult, isTrue);
      expect(find.text('Confirm Title'), findsNothing);
    });

    // 测试 showConfirm 在点击取消按钮时返回 false
    testWidgets('showConfirm returns false when Cancel is pressed',
        (WidgetTester tester) async {
      bool? confirmResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav
                      .showConfirm(
                    titleLabel: 'Confirm Title',
                    message: 'Are you sure?',
                  )
                      .then((res) {
                    confirmResult = res;
                  });
                },
                child: const Text('Show Confirm'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      // 点击取消按钮 "Cancel"
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // 验证确认结果为 false
      expect(confirmResult, isFalse);
    });

    // 测试 showConfirm 当关联的 cancellable 在外部被手动取消时返回 false
    testWidgets('showConfirm returns false when cancellable is cancelled externally',
        (WidgetTester tester) async {
      bool? confirmResult;
      final c = Cancellable();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav
                      .showConfirm(
                    message: 'Cancel me',
                    cancellable: c,
                  )
                      .then((res) {
                    confirmResult = res;
                  });
                },
                child: const Text('Show Confirm'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel me'), findsOneWidget);

      // 在外部取消 cancellable
      c.cancel();
      await tester.pumpAndSettle();

      // 验证确认结果为 false，且弹窗消失
      expect(confirmResult, isFalse);
      expect(find.text('Cancel me'), findsNothing);
    });
  });
}
