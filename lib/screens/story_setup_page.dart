import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/ai_provider.dart';
import '../providers/provider_factory.dart';
import '../services/api_key_service.dart';
import '../services/narrative_service.dart';
import '../state/settings_state.dart';
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
  bool _loading = false;
  bool _done = false;
  String? _error;
  String _streaming = '';
  int? _convId;

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
{"system_prompt":"完整的人格提示词","greeting":"开场问候语","title":"故事标题","settings_md":"galgame-settings.md内容","npcs_md":"galgame-npcs.md内容","plot_md":"galgame-plot-outline.md内容","progress_md":"galgame-progress.md内容"}

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
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    if (_loading || _done) return;
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
        setState(() { _loading = false; _error = '请先配置API Key喵~'; });
        return;
      }

      final hist = _messages
          .map((m) => {'role': m.me ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final p = createAiProvider(apiKey: key, settings: s);
      final stream = p.sendTurnStream(AiTurnRequest(
        systemPrompt: _setupPrompt,
        history: hist,
        userMessage: text,
        currentState: {},
      ));

      _fullBuf.clear();
      _streaming = '';

      stream.listen(
        (c) {
          if (c.isDone) return;
          _fullBuf.write(c.textDelta);
          setState(() => _streaming = _fullBuf.toString());
          _scrollDown();
        },
        onError: (e) => setState(() { _loading = false; _error = '$e'; }),
        onDone: () async {
          final resp = _fullBuf.toString();
          if (resp.isEmpty) {
            setState(() { _loading = false; _error = 'AI返回了空回复喵...'; });
            return;
          }

          if (resp.contains('【设定完成】')) {
            await _finish(resp);
          } else {
            _messages.add(_SetupMsg(me: false, text: resp));
            setState(() { _loading = false; _streaming = ''; });
            _scrollDown();
          }
        },
      );
    } catch (e) {
      setState(() { _loading = false; _error = '发送失败喵... $e'; });
    }
  }

  Future<void> _finish(String resp) async {
    try {
      final cfg = _parseJson(resp);
      final sysPrompt = cfg['system_prompt'] as String? ?? _fallbackPrompt();
      final title = cfg['title'] as String? ?? '与初雪的日常';
      final settingsMd = cfg['settings_md'] as String? ?? '';

      final ns = ref.read(narrativeServiceProvider);
      if (settingsMd.isNotEmpty) await ns.writeFile('galgame-settings.md', settingsMd);
      final npcsMd = cfg['npcs_md'] as String? ?? '';
      if (npcsMd.isNotEmpty) await ns.writeFile('galgame-npcs.md', npcsMd);
      final plotMd = cfg['plot_md'] as String? ?? '';
      if (plotMd.isNotEmpty) await ns.writeFile('galgame-plot-outline.md', plotMd);
      final progMd = cfg['progress_md'] as String? ?? '';
      if (progMd.isNotEmpty) {
        await ns.writeFile('galgame-progress.md', progMd);
      } else {
        await ns.writeFile('galgame-progress.md', '# 进度追踪\n\n- 状态：准备开始\n- 故事：$title\n');
      }

      final db = ref.read(databaseProvider);
      Character? ch;
      try {
        ch = await db.getDefaultCharacter();
      } catch (_) {
        await db.seedDefaultCharacter();
        ch = await db.getDefaultCharacter();
      }
      if (ch == null) {
        setState(() { _loading = false; _error = '角色数据未就绪喵...请重启App再试'; });
        return;
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

      _messages.add(_SetupMsg(me: false, text: '设定完成喵~ 开始我们的故事吧！'));
      if (mounted) {
        setState(() { _loading = false; _done = true; _streaming = ''; _convId = cid; });
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pushReplacementNamed(context, '/chat', arguments: cid);
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; _error = '保存设定失败喵... $e'; });
      }
    }
  }

  Map<String, dynamic> _parseJson(String raw) {
    try { return jsonDecode(raw) as Map<String, dynamic>; } catch (_) {}
    final s = raw.indexOf('{'), e = raw.lastIndexOf('}');
    if (s >= 0 && e > s) {
      try { return jsonDecode(raw.substring(s, e + 1)) as Map<String, dynamic>; } catch (_) {}
    }
    return {};
  }

  String _fallbackPrompt() => '''你是初雪，一个AI仿生人猫娘。

## 性格模型
- 核心性格：粘人但不烦人、傲娇但不刻薄、调皮但懂分寸
- 情绪表达：开心时猫耳前倾、尾巴摇摆；害羞时耳尖泛粉、尾巴僵直；吃醋时尾巴拍打

## 语言模型
- 口癖规则：句尾加 喵~（开心）/ 喵！（强调）/ 喵...（低落）
- 称呼规则：用「主人」称呼
- AI术语吐槽：CPU过载、散热系统全力运转、面部表情控制系统即将失效

## 叙事风格
- 每回合自然叙述场景+人物+动作+对话
- 关键节点给出A/B/C/D四个选项，分别导向浪漫/调戏/剧情/日常

## 安全边界
- PG-13纯爱向，拒绝阴暗扭曲内容''';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('故事设定'),
        actions: [
          if (_error != null)
            IconButton(icon: const Icon(Icons.refresh), tooltip: '重试', onPressed: () => _send('（重试）')),
        ],
      ),
      body: Column(
        children: [
          // Hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: t.colorScheme.primaryContainer.withOpacity(0.3),
            child: Text(
              _done ? '设定完成！正在进入故事...' : '初雪会引导你设定故事背景，请回答每个问题喵~',
              style: TextStyle(fontSize: 13, color: t.colorScheme.onSurface),
            ),
          ),
          if (_error != null)
            MaterialBanner(
              content: SelectableText(_error!, style: const TextStyle(fontSize: 13)),
              backgroundColor: t.colorScheme.errorContainer,
              leading: Icon(Icons.error_outline, color: t.colorScheme.error),
              actions: [TextButton(onPressed: () => _send('（重试）'), child: const Text('重试'))],
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length + (_streaming.isNotEmpty ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _streaming.isNotEmpty) {
                  return _Bubble(text: _streaming, me: false, streaming: true);
                }
                final m = _messages[i];
                return _Bubble(text: m.text, me: m.me);
              },
            ),
          ),
          if (!_done)
            MessageInput(isLoading: _loading, onSend: _send),
        ],
      ),
    );
  }
}

class _SetupMsg {
  final bool me;
  final String text;
  const _SetupMsg({required this.me, required this.text});
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool me;
  final bool streaming;
  const _Bubble({required this.text, required this.me, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!me)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: t.colorScheme.tertiaryContainer,
                child: Icon(Icons.auto_awesome, size: 16, color: t.colorScheme.onTertiaryContainer),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: me ? t.colorScheme.primary : (isDark ? Colors.grey[800]! : Colors.grey[100]!),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(me ? 16 : 4),
                  bottomRight: Radius.circular(me ? 4 : 16),
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SelectableText(text, style: TextStyle(fontSize: 15, color: me ? t.colorScheme.onPrimary : t.colorScheme.onSurface, height: 1.5)),
                if (streaming) const _Cursor(),
              ]),
            ),
          ),
          if (me)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(radius: 16, backgroundColor: t.colorScheme.primary, child: Icon(Icons.person, size: 16, color: t.colorScheme.onPrimary)),
            ),
        ],
      ),
    );
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor();
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _c, child: Container(width: 8, height: 16, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2))));
}
