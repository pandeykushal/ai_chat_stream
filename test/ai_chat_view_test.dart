import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AiChatView sends a message and shows the reply bubble',
      (tester) async {
    final controller = ChatController(
      provider: const DemoProvider(tokenDelay: Duration.zero),
      config: const LlmConfig(model: 'demo'),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AiChatView(controller: controller))),
    );

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump(); // process send + add placeholder

    expect(controller.messages.first.content, 'hello');
    expect(controller.messages.length, 2);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(controller.messages.last.role, ChatRole.assistant);
    expect(controller.isStreaming, isFalse);

    controller.dispose();
  });

  testWidgets('AiChatBubble shows a launcher and opens a panel',
      (tester) async {
    final controller = ChatController(
      provider: const DemoProvider(tokenDelay: Duration.zero),
      config: const LlmConfig(model: 'demo'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: SizedBox.expand()),
        builder: (context, child) => Stack(
          children: [
            if (child != null) child,
            AiChatBubble(controller: controller, title: 'Helper'),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    expect(find.text('Helper'), findsNothing);

    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Helper'), findsOneWidget);

    controller.dispose();
  });
}
