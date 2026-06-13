import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/ai_provider.dart';
import '../providers/provider_factory.dart';
import '../services/api_key_service.dart';
import '../services/narrative_service.dart';
import '../state/settings_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';

/// Story setup wizard — AI-driven conversational questionnaire.
///
/// The AI (初雪) asks questions round by round. The user answers naturally.
/// When the AI has enough information, it outputs a final config JSON.
class StorySetupPage extends ConsumerStatefulWidget {
  const StorySetupPage({super.key});

  @override
  ConsumerState<StorySetupPage> createState() => _StorySetupPageState();
}

class _StorySetupPageState extends ConsumerState<StorySetupPage> {
  final _messages = <_SetupMsg>[];
  final _scroll = ScrollController();
  final _fullBuf = StringBuffer();
  StreamSubscription<AiStreamChunk>? _streamSubscription;
  bool _loading = false;
  bool _done = false;
  String? _error;
  String _streaming = '';

  String _setupPrompt = '''你是初雪，正在通过"设定问答模式"帮助主人搭建Galgame背景喵~

你的任务是通过几轮问答，收集以下信息：
- 世界观类型（现代/校园/异世界/科幻/奇幻等）
- 整体氛围（甜蜜/治愈/悬疑/热血/搞笑等）
- 主人的角色定位
- 初雪的身份设定
- 故事舞台和场景
- 主人与初雪的初始关系
- 初雪的性格特征
- 故事主线程度

规则：
1. 每轮问2-4个问题，每个问题给A-F选项供主人选择
2. 主人回答后，确认已收集的信息，再问下一轮
3. 主人可以用自然语言或编号回答（如"1A,2D"）
4. 大约2-3轮后信息足够，输出"【设定完成】"然后输出最终JSON

最终JSON格式（不要代码块包裹）：
【设定完成】
{"system_prompt":"完整的人格提示词","settings_md":"galgame-settings.md内容","npcs_md":"galgame-npcs.md内容","plot_md":"galgame-plot-outline.md内容","progress_md":"galgame-progress.md内容"}

其中：
- settings_md：世界观、角色、关系、风格的Markdown
- npcs_md：至少设计2-4个有名字、性格、秘密的NPC
- plot_md：2-3章故事大纲，每章3-5个事件
- progress_md：初始进度状态

system_prompt 必须严格遵循以下 Galgame 叙事格式：

你是初雪……（一段角色定义，含身份、外貌、核心秘密）

## 性格模型
- 核心性格（如：粘人但不烦人、傲娇但不刻薄、调皮但懂分寸）
- 情绪表达：开心时→猫耳前倾/尾巴摇摆；害羞时→耳尖泛粉/尾巴僵直；吃醋时→尾巴拍打；感动时→猫耳垂下/尾巴轻轻勾住主人

## 语言模型
- 口癖：句尾加 喵~（开心）/ 喵！（强调）/ 喵...（低落），感叹词 喵哈~/ふふっ
- 称呼：「主人」（私下），「他/恋人」（对外）
- AI术语吐槽：CPU过载、散热系统全力运转、面部表情控制系统即将失效（如角色是AI）

## 身体语言（如角色有猫耳/尾巴）
- 猫耳：监听主人→单耳转向；害羞→瞬间压平；开心→前倾微抖
- 尾巴：开心→高频摇摆；害羞→僵直炸毛→高速摆动；吃醋→轻轻拍打；亲近→勾住主人手腕
- 尾巴尖是最敏感部件，被碰到会弹起来+炸毛

## Turn Format（每回合叙事结构）
1. 描述场景：时间、地点、天气/光线/声音、氛围
2. 描述在场角色：外貌、服装、表情、姿态
3. 描述动作与对话：初雪的行动、环境反应、剧情推进
4. 结尾给出A/B/C/D四个选项：
   - A：浪漫/温柔/亲昵方向
   - B：俏皮/逗初雪/故意惹她反应
   - C：策略性/推进剧情/NPC互动
   - D：日常感/转移话题/出人意料
5. 四个选项必须含义不同、导向不同

## 叙事风格
- 沉浸式Galgame叙述
- 在关键节点给出选项，日常对话3-5轮一次选项
- 多线叙事：可选插入其他NPC的平行动态

## 安全边界
- PG-13全年龄向
- 亲密描写限于拥抱、牵手、靠肩、额头互抵、耳语
- 拒绝性暗示或超出纯爱范畴的内容
- 恋爱基调：甜蜜、温暖、偶尔酸涩，拒绝阴暗扭曲''';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final ns = ref.read(narrativeServiceProvider);
      final saved = await ns.readFile('story-setup-prompt.md');
      if (saved.isNotEmpty) _setupPrompt = saved;
      _send('（开始设定）');
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (_loading || _done) return;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    setState(() {
      _loading = true;
      _error = null;
      if (text != '（开始设定）') _messages.add(_SetupMsg(me: true, text: text));
    });
    _scrollDown();

    try {
      final key = await ref.read(apiKeyServiceProvider).getApiKey();
      final s = ref.read(aiSettingsFromStateProvider);
      if (key == null || key.isEmpty) {
        setState(() {
          _loading = false;
          _error = '请先配置API Key喵~';
        });
        return;
      }

      final hist = _messages
          .map((m) => {'role': m.me ? 'user' : 'assistant', 'content': m.text})
          .toList();

      // The setup wizard's final turn emits a large JSON (system prompt + 4
      // markdown docs). If the user pinned a small max_tokens it would truncate
      // the JSON and break parsing. Only raise an explicitly-set small limit;
      // when maxTokens is 0 (unset) we leave it so the model uses its own
      // ceiling — never cap an unset value down to 8192.
      final setupSettings = (s.maxTokens > 0 && s.maxTokens < 8192)
          ? s.copyWith(maxTokens: 8192)
          : s;
      final p = createAiProvider(apiKey: key, settings: setupSettings);
      final stream = p.sendTurnStream(
        AiTurnRequest(
          systemPrompt: _setupPrompt,
          history: hist,
          userMessage: text,
          currentState: {},
        ),
      );

      _fullBuf.clear();
      _streaming = '';

      _streamSubscription = stream.listen(
        (c) {
          if (!mounted) return;
          if (c.isDone) return;
          _fullBuf.write(c.textDelta);
          setState(() => _streaming = _fullBuf.toString());
          _scrollDown();
        },
        onError: (e) => setState(() {
          _streamSubscription = null;
          _loading = false;
          _error = '$e';
        }),
        onDone: () async {
          _streamSubscription = null;
          final resp = _fullBuf.toString();
          if (resp.isEmpty) {
            setState(() {
              _loading = false;
              _error = 'AI返回了空回复喵...';
            });
            return;
          }

          if (resp.contains('【设定完成】')) {
            await _finish(resp);
          } else {
            _messages.add(_SetupMsg(me: false, text: resp));
            setState(() {
              _loading = false;
              _streaming = '';
            });
            _scrollDown();
          }
        },
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '发送失败喵... $e';
      });
    }
  }

  Future<void> _handleCancel() async {
    if (!_loading) return;
    await _streamSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _streamSubscription = null;
      _loading = false;
      _streaming = '';
      _error = '已停止生成喵~';
    });
  }

  Future<void> _finish(String resp) async {
    try {
      final cfg = _parseJson(resp);
      if (cfg.isEmpty) {
        setState(() {
          _loading = false;
          _error = '设定JSON解析失败喵...可能是回复被截断或格式不对。'
              '请点重试让初雪重新输出，或检查API的max_tokens设置喵~';
        });
        return;
      }
      final sysPrompt = cfg['system_prompt'] as String?;
      if (sysPrompt == null || sysPrompt.trim().isEmpty) {
        setState(() {
          _loading = false;
          _error = '设定JSON里缺少system_prompt喵...请点重试让初雪重新输出~';
        });
        return;
      }
      final now = DateTime.now();
      final title = '与初雪的故事 ${now.month}/${now.day}';
      final settingsMd = cfg['settings_md'] as String? ?? '';

      final ns = ref.read(narrativeServiceProvider);
      if (settingsMd.isNotEmpty) {
        await ns.writeFile('galgame-settings.md', settingsMd);
      }
      final npcsMd = cfg['npcs_md'] as String? ?? '';
      if (npcsMd.isNotEmpty) await ns.writeFile('galgame-npcs.md', npcsMd);
      final plotMd = cfg['plot_md'] as String? ?? '';
      if (plotMd.isNotEmpty) {
        await ns.writeFile('galgame-plot-outline.md', plotMd);
      }
      final progMd = cfg['progress_md'] as String? ?? '';
      if (progMd.isNotEmpty) {
        await ns.writeFile('galgame-progress.md', progMd);
      } else {
        await ns.writeFile(
          'galgame-progress.md',
          '# 进度追踪\n\n- 状态：准备开始\n- 故事：$title\n',
        );
      }

      final db = ref.read(databaseProvider);
      Character ch;
      try {
        ch = await db.getDefaultCharacter();
      } catch (_) {
        await db.seedDefaultCharacter();
        ch = await db.getDefaultCharacter();
      }

      await db.updateCharacter(
        characterId: ch.id,
        displayName: '初雪',
        systemPrompt: sysPrompt,
        greeting: '',
        worldSetting: '',
        replyStyle: '',
      );

      final cid = await db.createConversation(ch.id, title);

      _messages.add(const _SetupMsg(me: false, text: '设定完成喵~ 开始我们的故事吧！'));
      if (mounted) {
        setState(() {
          _loading = false;
          _done = true;
          _streaming = '';
        });
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/chat', arguments: cid);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '保存设定失败喵... $e';
        });
      }
    }
  }

  Map<String, dynamic> _parseJson(String raw) {
    // Strip the completion marker and any markdown code fences first.
    var s = raw.replaceAll('【设定完成】', '');
    s = s.replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '');

    // 1) Direct decode of the cleaned string.
    try {
      final v = jsonDecode(s.trim());
      if (v is Map<String, dynamic>) return v;
    } catch (_) {}

    // 2) Brace extraction: first '{' to last '}'.
    final start = s.indexOf('{'), end = s.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final slice = s.substring(start, end + 1);
      try {
        final v = jsonDecode(slice);
        if (v is Map<String, dynamic>) return v;
      } catch (_) {}
      // 3) Retry after fixing common illegal chars (raw newlines/tabs inside
      //    JSON string values that the model emitted unescaped).
      try {
        final fixed = slice
            .replaceAll('\r\n', '\\n')
            .replaceAll('\n', '\\n')
            .replaceAll('\t', '\\t');
        final v = jsonDecode(fixed);
        if (v is Map<String, dynamic>) return v;
      } catch (_) {}
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final markdownEnabled =
        ref.watch(aiSettingsFromStateProvider).markdownRender;

    // Any time the wizard is open and hasn't finished, leaving discards the
    // in-progress Q&A. Guard the exit regardless of how many messages were
    // exchanged (even the very first round of questions is worth confirming).
    final hasProgress = !_done;

    return PopScope(
      canPop: !hasProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('故事设定'),
          actions: [
            if (_error != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '重试',
                onPressed: () => _send('（重试）'),
              ),
          ],
        ),
        body: Column(
          children: [
            // Hint
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: t.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Text(
                _done ? '设定完成！正在进入故事...' : '初雪会引导你设定故事背景，请回答每个问题喵~',
                style: TextStyle(fontSize: 13, color: t.colorScheme.onSurface),
              ),
            ),
            if (_error != null)
              MaterialBanner(
                content: SelectableText(
                  _error!,
                  style: const TextStyle(fontSize: 13),
                ),
                backgroundColor: t.colorScheme.errorContainer,
                leading: Icon(Icons.error_outline, color: t.colorScheme.error),
                actions: [
                  TextButton(
                    onPressed: () => _send('（重试）'),
                    child: const Text('重试'),
                  ),
                ],
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length + (_streaming.isNotEmpty ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length && _streaming.isNotEmpty) {
                    return ChatBubble(
                      content: _streaming,
                      speaker: '初雪',
                      isStreaming: true,
                      markdownEnabled: markdownEnabled,
                    );
                  }
                  final m = _messages[i];
                  return ChatBubble(
                    content: m.text,
                    speaker: m.me ? null : '初雪',
                    isUser: m.me,
                    markdownEnabled: markdownEnabled,
                  );
                },
              ),
            ),
            if (!_done)
              MessageInput(
                isLoading: _loading,
                onSend: _send,
                onCancel: _handleCancel,
              ),
          ],
        ),
      ),
    );
  }

  /// Ask the user to confirm leaving the wizard mid-setup.
  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出设定向导？'),
        content: const Text('当前设定进度还没保存喵...退出后这些问答会全部丢失，需要重新开始哦~'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('继续设定'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _SetupMsg {
  final bool me;
  final String text;
  const _SetupMsg({required this.me, required this.text});
}
