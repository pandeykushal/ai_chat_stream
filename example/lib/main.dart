import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Which backend the demo is pointed at.
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

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai_chat_stream example',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F6BFF),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F6BFF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // Mount the floating bubble ABOVE all routes so it overlays every screen.
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          AiChatBubble(
            controller: _chat,
            title: 'AI Assistant',
            subtitle: 'Online — replies instantly',
            draggable: true,
          ),
        ],
      ),
      home: HomeScreen(
        chat: _chat,
        kind: _kind,
        themeMode: _themeMode,
        onToggleTheme: () => setState(() {
          _themeMode =
              _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
        onOpenSettings: _openSettings,
      ),
    );
  }

  // [sheetContext] must come from below MaterialApp (e.g. the HomeScreen build
  // context) so the modal can find Navigator / Overlay / MaterialLocalizations.
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
    required this.onToggleTheme,
    required this.onOpenSettings,
  });

  final ChatController chat;
  final ProviderKind kind;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<BuildContext> onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ai_chat_stream'),
        actions: [
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
        emptyState: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'Say hello 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Streaming with the ${kind.label} provider.\n'
                'Tap the floating bubble to chat from anywhere.',
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
