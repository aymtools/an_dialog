// ignore: deprecated_member_use
import 'package:flutter/material.dart';

RawDialogRoute<void> dialogRouteBuilderSupport(
    BuildContext context, Widget dialogContent) {
  return DialogRoute<void>(
    context: context,
    builder: (BuildContext context) => dialogContent,
  );
}

Widget dialogContentBuilderSupport(BuildContext context, Widget? title,
    Widget content, Widget? confirm, Widget? cancel) {
  return AlertDialog(
    title: title,
    content: content,
    actions: [if (cancel != null) cancel, if (confirm != null) confirm],
  );
}

Widget dialogLabelActionBuilderSupport(
    BuildContext context, String label, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    child: Text(label),
  );
}

RawDialogRoute<void> loadingDialogRouteBuilderSupport(context, dialogContent) {
  return DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => dialogContent,
  );
}

Widget loadingDialogContentBuilderSupport(Widget child) {
  return Dialog(
    insetPadding: const EdgeInsets.all(100),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: child,
    ),
  );
}

Widget circularProgressIndicatorBuilderSupport() =>
    const CircularProgressIndicator();
