import 'package:an_dialogs/src/tools.dart';
import 'package:an_dialogs/src/tools/material_support.dart';
import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:flutter/widgets.dart';

typedef LoadingMessageBuilder = Widget Function(BuildContext context);

typedef LoadingMessageWidgetBuilder = Widget Function(
    BuildContext context, String message);

typedef LoadingDialogContentBuilder = Widget Function(
    BuildContext context, LoadingMessageBuilder? messageBuilder);

/// loading 配置
class LoadingConfig {
  LoadingConfig._();

  static final LoadingConfig _instance = LoadingConfig._();

  static LoadingConfig get instance => _instance;

  /// 定义如何展示
  DialogDisplayer loadingDialogDisplayer =
      (navigator, cancellable, dialogRoute) =>
          navigator.pushCancellableRoute(dialogRoute, cancellable);

  /// 自己控制如何兼容拦截返回键
  OnBackPressedInterceptBuilder onBackPressedIntercept =
      (Widget child) => child;

  /// 定义 如何构建loading的route
  DialogRouteBuilder loadingDialogRouteBuilder =
      loadingDialogRouteBuilderSupport;

  ///
  LoadingMessageWidgetBuilder loadingMessageWidgetBuilder =
      (_, message) => Text(message);

  /// 定义如何构建loading的布局
  LoadingDialogContentBuilder loadingDialogContentBuilder =
      defaultLoadingDialogContentBuilder;
}

/// 默认的loading dialog content
Widget defaultLoadingDialogContentBuilder(
  BuildContext context,
  LoadingMessageBuilder? messageBuilder,
) {
  Widget child;
  if (messageBuilder == null) {
    child = SizedBox(
      width: 60,
      height: 60,
      child: Center(child: circularProgressIndicatorBuilderSupport()),
    );
  } else {
    child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circularProgressIndicatorBuilderSupport(),
        const SizedBox(height: 16),
        Builder(builder: messageBuilder),
      ],
    );
  }
  return loadingDialogContentBuilderSupport(child);
}
//
// /// 默认的loading dialog
// void defaultLoadingDialogDisplayer(
//   NavigatorState navigator,
//   CancellableQueue<String> messageQueue,
// ) {
//   navigator.showDialog(
//     cancellable: messageQueue.managerCancellable,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         content: LoadingConfig.instance.loadingOnBackPressedIntercept(
//           AnimatedBuilder(
//             animation: messageQueue,
//             builder: (context, child) {
//               final message =
//                   messageQueue.isAvailable && messageQueue.isNotEmpty
//                       ? messageQueue.lastValue
//                       : '';
//               return LoadingConfig.instance.loadingDialogContentBuilder(
//                 context,
//                 message,
//               );
//             },
//           ),
//         ),
//       );
//     },
//   );
// }
