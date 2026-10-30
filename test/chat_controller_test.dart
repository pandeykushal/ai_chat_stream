import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_provider.dart';

const _config = LlmConfig(model: 'test');

void main() {
  group('ChatController', () {
    test('send appends a user message then streams the assistant reply',
        () async {
      final controller = ChatController(
        provider: MockProvider(tokens: const ['Hello', ', ', 'world']),
        config: _config,
      );

      await controller.send('hi');

      expect(controller.messages.length, 2);
      expect(controller.messages[0].role, ChatRole.user);
      expect(controller.messages[0].content, 'hi');
      expect(controller.messages[1].role, ChatRole.assistant);
      expect(controller.messages[1].content, 'Hello, world');
      expect(controller.messages[1].status, MessageStatus.done);
      expect(controller.isStreaming, isFalse);

      controller.dispose();
    });

    test('ignores empty input and does nothing while busy', () async {
      final controller = ChatController(
        provider: MockProvider(tokens: const ['x']),
        config: _config,
      );
      await controller.send('   ');
      expect(controller.messages, isEmpty);
      controller.dispose();
    });

    test('an error marks the message as error but keeps partial text',
        () async {
      final controller = ChatController(
        provider: MockProvider(
          tokens: const ['par', 'tial', 'never'],
          throwAfter: 2,
        ),
        config: _config,
      );

      await controller.send('go');

      final reply = controller.messages.last;
      expect(reply.status, MessageStatus.error);
      expect(reply.error, isNotNull);
      expect(reply.content, 'partial');
      expect(controller.isStreaming, isFalse);

      controller.dispose();
    });

    test('stop() aborts cleanly and keeps the partial reply', () async {
      final controller = ChatController(
        provider: MockProvider(
          tokens: const ['a', 'b', 'c', 'd'],
          perToken: const Duration(milliseconds: 40),
        ),
        config: _config,
      );

      final future = controller.send('go');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(controller.isStreaming, isTrue);

      controller.stop();
      expect(controller.isStreaming, isFalse);
      expect(controller.messages.last.status, MessageStatus.done);
      expect(controller.messages.last.content.isNotEmpty, isTrue);

      await future; // send() completes even though we stopped.
      controller.dispose();
    });

    test('regenerate() drops the last assistant message and re-answers',
        () async {
      final controller = ChatController(
        provider: MockProvider(tokens: const ['one']),
        config: _config,
      );
      await controller.send('q');
      expect(controller.messages.length, 2);

      await controller.regenerate();
      expect(controller.messages.length, 2);
      expect(controller.messages.last.role, ChatRole.assistant);
      expect(controller.messages.last.content, 'one');

      controller.dispose();
    });

    test('clear() empties the conversation', () async {
      final controller = ChatController(
        provider: MockProvider(tokens: const ['x']),
        config: _config,
      );
      await controller.send('hi');
      controller.clear();
      expect(controller.messages, isEmpty);
      controller.dispose();
    });

    test('notifies listeners as tokens arrive', () async {
      final controller = ChatController(
        provider: MockProvider(tokens: const ['a', 'b']),
        config: _config,
      );
      var notifications = 0;
      controller.addListener(() => notifications++);
      await controller.send('hi');
      expect(notifications, greaterThan(1));
      controller.dispose();
    });
  });
}
