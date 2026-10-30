import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

enum ProviderKind { demo, openai, claude, gemini }

extension on ProviderKind {
  String get label => switch (this) {
        ProviderKind.demo => 'Demo (no key)',
        ProviderKind.openai => 'OpenAI',
        ProviderKind.claude => 'Claude',
        ProviderKind.gemini => 'Gemini',
      };

  String get defaultModel => switch (this) {
        ProviderKind.demo => 'demo',
        ProviderKind.openai => 'gpt-4o-mini',
        ProviderKind.claude => 'claude-3-5-sonnet-latest',
        ProviderKind.gemini => 'gemini-1.5-flash',
      };

  LlmProvider build() => switch (this) {
        ProviderKind.demo => const DemoProvider(),
        ProviderKind.openai => const OpenAIProvider(),
        ProviderKind.claude => const ClaudeProvider(),
        ProviderKind.gemini => const GeminiProvider(),
      };
}

const _brandTeal = Color(0xFF0EA5A5);
const _brandDeep = Color(0xFF0F766E);

AiChatTheme buildChatTheme(BuildContext context, bool customized) {
  final base = AiChatTheme.fromTheme(Theme.of(context));
  if (!customized) return base;
  return base.copyWith(
    accentColor: _brandTeal,
    userBubbleColor: _brandTeal,
    linkColor: _brandTeal,
    headerColor: _brandDeep,
    headerTextColor: Colors.white,
    launcherColor: _brandTeal,
    userBubbleRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(4),
    ),
    assistantBubbleRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(18),
    ),
    userBubblePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    assistantBubblePadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    inputRadius: const BorderRadius.all(Radius.circular(16)),
    sendButtonSize: 46,
    maxBubbleWidthFraction: 0.82,
    showTimestamps: true,
    assistantTextStyle: const TextStyle(height: 1.45),
  );
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  bool _customized = true;

  ProviderKind _kind = ProviderKind.demo;
  final _modelCtl = TextEditingController(text: ProviderKind.demo.defaultModel);
  final _keyCtl = TextEditingController();
  final _proxyCtl = TextEditingController();
  final _sysCtl =
      TextEditingController(text: 'You are a concise, friendly assistant.');

  late final ChatController _chat = ChatController(
    provider: _kind.build(),
    config: _buildConfig(),
  );

  LlmConfig _buildConfig() => LlmConfig(
        model: _modelCtl.text.trim().isEmpty
            ? _kind.defaultModel
            : _modelCtl.text.trim(),
        apiKey: _keyCtl.text.trim().isEmpty ? null : _keyCtl.text.trim(),
        baseUrl: _proxyCtl.text.trim().isEmpty ? null : _proxyCtl.text.trim(),
        systemPrompt: _sysCtl.text.trim().isEmpty ? null : _sysCtl.text.trim(),
        temperature: 0.7,
      );

  void _apply() {
    setState(() {
      _chat.provider = _kind.build();
      _chat.config = _buildConfig();
    });
  }

  @override
  void dispose() {
    _modelCtl.dispose();
    _keyCtl.dispose();
    _proxyCtl.dispose();
    _sysCtl.dispose();
    _chat.dispose();
    super.dispose();
  }

  AiChatIcons get _chatIcons => _customized
      ? const AiChatIcons(
          launcher: Icon(Icons.support_agent_rounded, color: Colors.white),
          avatar: CircleAvatar(
            backgroundColor: Colors.white,
            child:
                Icon(Icons.support_agent_rounded, color: _brandDeep, size: 18),
          ),
          send: Icon(Icons.send_rounded, color: Colors.white, size: 20),
          stop: Icon(Icons.stop_circle_rounded, color: Colors.white, size: 24),
          copy: Icon(Icons.content_copy_rounded, size: 15),
          regenerate: Icon(Icons.restart_alt_rounded, size: 16),
          scrollToBottom: Icon(Icons.arrow_downward_rounded, size: 20),
          close: Icon(Icons.keyboard_arrow_down_rounded),
        )
      : const AiChatIcons();

  AiChatBuilders get _chatBuilders => _customized
      ? AiChatBuilders(
          assistantAvatar: (context, message, theme) => const CircleAvatar(
            radius: 14,
            backgroundColor: _brandDeep,
            child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
          ),
          typingIndicator: (context, theme) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('typing',
                  style: TextStyle(color: theme.mutedColor, fontSize: 12.5)),
              const SizedBox(width: 6),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.mutedColor,
                ),
              ),
            ],
          ),
          timestamp: (context, message, theme) {
            final t = message.timestamp;
            final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
            final m = t.minute.toString().padLeft(2, '0');
            final ap = t.hour < 12 ? 'AM' : 'PM';
            return Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                '$h:$m $ap',
                style: TextStyle(
                    color: theme.mutedColor.withValues(alpha: 0.8),
                    fontSize: 10.5),
              ),
            );
          },
        )
      : const AiChatBuilders();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai_chat_stream example',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: _brandTeal,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: _brandTeal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          AiChatBubble(
            controller: _chat,
            title: 'AI Assistant',
            subtitle: 'Online, replies instantly',
            draggable: true,
            theme: buildChatTheme(context, _customized),
            icons: _chatIcons,
            builders: _chatBuilders,
          ),
        ],
      ),
      home: HomeScreen(
        chat: _chat,
        kind: _kind,
        themeMode: _themeMode,
        customized: _customized,
        chatIcons: _chatIcons,
        chatBuilders: _chatBuilders,
        onToggleTheme: () => setState(() {
          _themeMode =
              _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
        onToggleCustom: () => setState(() => _customized = !_customized),
        onOpenSettings: _openSettings,
      ),
    );
  }

  Future<void> _openSettings(BuildContext sheetContext) async {
    await showModalBottomSheet<void>(
      context: sheetContext,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provider',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ProviderKind.values.map((k) {
                      return ChoiceChip(
                        label: Text(k.label),
                        selected: _kind == k,
                        onSelected: (_) => setSheet(() {
                          _kind = k;
                          _modelCtl.text = k.defaultModel;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelCtl,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyCtl,
                    obscureText: true,
                    enabled: _kind != ProviderKind.demo,
                    decoration: InputDecoration(
                      labelText: 'API key',
                      helperText: _kind == ProviderKind.demo
                          ? 'Not needed for the demo provider'
                          : 'Stored only in memory for this session',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _proxyCtl,
                    enabled: _kind != ProviderKind.demo,
                    decoration: const InputDecoration(
                      labelText: 'Proxy base URL (optional)',
                      hintText: 'https://your-backend.example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sysCtl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'System prompt',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _apply();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.chat,
    required this.kind,
    required this.themeMode,
    required this.customized,
    required this.chatIcons,
    required this.chatBuilders,
    required this.onToggleTheme,
    required this.onToggleCustom,
    required this.onOpenSettings,
  });

  final ChatController chat;
  final ProviderKind kind;
  final ThemeMode themeMode;
  final bool customized;
  final AiChatIcons chatIcons;
  final AiChatBuilders chatBuilders;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleCustom;
  final ValueChanged<BuildContext> onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ai_chat_stream'),
        actions: [
          IconButton(
            tooltip: customized ? 'Custom UI: on' : 'Custom UI: off',
            onPressed: onToggleCustom,
            icon: Icon(
                customized ? Icons.palette_rounded : Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: onToggleTheme,
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
          ),
          IconButton(
            tooltip: 'Clear chat',
            onPressed: chat.clear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => onOpenSettings(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: AiChatView(
        controller: chat,
        theme: buildChatTheme(context, customized),
        icons: chatIcons,
        builders: chatBuilders,
        emptyState: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('Say hello 👋',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Streaming with the ${kind.label} provider.\n'
                'Tap the palette icon to toggle the custom UI, or the '
                'floating bubble to chat from anywhere.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
