import 'package:an_dialogs/src/tools.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // CancellableQueue 取消队列的核心逻辑测试
  group('CancellableQueue Tests', () {
    // 测试 CancellableQueue 的初始状态属性
    test('initial state of CancellableQueue', () {
      final queue = CancellableQueue<String>();
      // 校验队列初始化时为空且可用
      expect(queue.isEmpty, isTrue);
      expect(queue.isNotEmpty, isFalse);
      expect(queue.length, equals(0));
      expect(queue.isAvailable, isTrue);
      expect(queue.isUnavailable, isFalse);
      expect(queue.managerCancellable.isAvailable, isTrue);
    });

    // 测试向队列添加元素以及获取首尾元素
    test('add items and retrieve first/last values', () {
      final queue = CancellableQueue<String>();
      final c1 = Cancellable();
      final c2 = Cancellable();

      // 添加第一个元素
      queue.add('first', c1);
      expect(queue.isEmpty, isFalse);
      expect(queue.length, equals(1));
      expect(queue.firstValue, equals('first'));
      expect(queue.lastValue, equals('first'));

      // 添加第二个元素
      queue.add('second', c2);
      expect(queue.length, equals(2));
      expect(queue.firstValue, equals('first'));
      expect(queue.lastValue, equals('second'));
    });

    // 测试添加已取消（不可用）的 Cancellable 应该被忽略
    test('ignore adding unavailable/cancelled cancellable', () {
      final queue = CancellableQueue<String>();
      final c = Cancellable()..cancel();

      // 添加已取消的对象
      queue.add('ignored', c);
      expect(queue.isEmpty, isTrue);
      expect(queue.length, equals(0));
    });

    // 测试取消单个元素的 Cancellable 后，该元素被自动从队列移除
    test('removing single item when its cancellable is cancelled', () async {
      final queue = CancellableQueue<String>();
      final c1 = Cancellable();
      final c2 = Cancellable();

      queue.add('val1', c1);
      queue.add('val2', c2);
      expect(queue.length, equals(2));

      // 取消第一个元素
      c1.cancel();
      // 等待异步微任务队列处理完成
      await pumpEventQueue();

      // 验证队列中仅剩第二个元素
      expect(queue.length, equals(1));
      expect(queue.firstValue, equals('val2'));
      expect(queue.lastValue, equals('val2'));
      expect(queue.isAvailable, isTrue);
    });

    // 测试 cancelAll 方法会取消 managerCancellable 并清空队列
    test('cancelling all items cancels manager cancellable and clears queue', () async {
      final queue = CancellableQueue<String>();
      final c1 = Cancellable();
      final c2 = Cancellable();

      queue.add('val1', c1);
      queue.add('val2', c2);

      // 调用 cancelAll 取消所有
      queue.cancelAll('Reason: user test');
      await pumpEventQueue();

      // 验证队列和内部 cancellables 均已取消
      expect(c1.isUnavailable, isTrue);
      expect(c2.isUnavailable, isTrue);
      expect(queue.isEmpty, isTrue);
      expect(queue.isUnavailable, isTrue);
    });

    // 测试当队列中所有元素各自单独取消后，管理者 managerCancellable 会自动取消
    test('when all queued items are cancelled individually, manager cancels', () async {
      final queue = CancellableQueue<String>();
      final c1 = Cancellable();
      final c2 = Cancellable();

      queue.add('val1', c1);
      queue.add('val2', c2);

      // 取消第一个，队列仍可用
      c1.cancel();
      await pumpEventQueue();
      expect(queue.isAvailable, isTrue);

      // 取消第二个，队列变为空且整体自动取消
      c2.cancel();
      await pumpEventQueue();
      expect(queue.isEmpty, isTrue);
      expect(queue.isUnavailable, isTrue);
    });

    // 测试 whenCancel 和 onCancel getter 能正常监听取消事件
    test('whenCancel and onCancel getters return manager cancellable futures', () async {
      final queue = CancellableQueue<String>();
      final c = Cancellable();
      queue.add('val', c);

      bool cancelHandled = false;
      queue.onCancel.then((_) {
        cancelHandled = true;
      });

      queue.cancelAll();
      await pumpEventQueue();

      expect(cancelHandled, isTrue);
      expect(queue.isUnavailable, isTrue);
    });
  });
}
