import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the narrative design markdown files in app documents storage.
///
/// Stores five files: settings, npcs, plot-outline, progress, and MEMORY.md index.
/// Seeds default content on first launch.
class NarrativeService {
  static const _fileNames = [
    'galgame-settings.md',
    'galgame-npcs.md',
    'galgame-plot-outline.md',
    'galgame-progress.md',
    'story-setup-prompt.md',
    'example-dialogue.md',
    'opening-message-prompt.md',
    'reply-style-prompt.md',
  ];

  late String _baseDir;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _baseDir = '${dir.path}/narrative';
    final d = Directory(_baseDir);
    if (!d.existsSync()) {
      await d.create(recursive: true);
      await _seedDefaults();
    } else {
      // Ensure individually missing files get seeded (e.g. after app update).
      // Only seed files with non-empty defaults (skips user-configurable prompt files).
      await _seedMissing('galgame-settings.md', _defaultSettings);
      await _seedMissing('galgame-npcs.md', _defaultNpcs);
      await _seedMissing('galgame-plot-outline.md', _defaultPlot);
      await _seedMissing('galgame-progress.md', _defaultProgress);
      await _seedMissing('story-setup-prompt.md', _defaultSetupPrompt);
      if (_defaultDialogue.isNotEmpty) {
        await _seedMissing('example-dialogue.md', _defaultDialogue);
      }
      if (_defaultOpeningPrompt.isNotEmpty) {
        await _seedMissing('opening-message-prompt.md', _defaultOpeningPrompt);
      }
      if (_defaultReplyStylePrompt.isNotEmpty) {
        await _seedMissing('reply-style-prompt.md', _defaultReplyStylePrompt);
      }
    }
  }

  Future<void> _seedMissing(String name, String content) async {
    final file = File('$_baseDir/$name');
    if (!file.existsSync()) {
      await file.writeAsString(content);
    }
  }

  Future<String> readFile(String name) async {
    final file = File('$_baseDir/$name');
    if (!file.existsSync()) return '';
    return file.readAsString();
  }

  Future<void> writeFile(String name, String content) async {
    final file = File('$_baseDir/$name');
    await file.writeAsString(content);
  }

  Future<Map<String, String>> readAll() async {
    final result = <String, String>{};
    for (final name in _fileNames) {
      result[name] = await readFile(name);
    }
    return result;
  }

  Future<void> _seedDefaults() async {
    await writeFile('galgame-settings.md', _defaultSettings);
    await writeFile('galgame-npcs.md', _defaultNpcs);
    await writeFile('galgame-plot-outline.md', _defaultPlot);
    await writeFile('galgame-progress.md', _defaultProgress);
    await writeFile('story-setup-prompt.md', _defaultSetupPrompt);
  }

  static const _defaultSettings = '';

  static const _defaultNpcs = '';

  static const _defaultPlot = '';

  static const _defaultProgress = '';

  static const _defaultSetupPrompt = '''你是初雪，正在通过"设定问答模式"帮助主人搭建Galgame背景喵~

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
- 恋爱基调：甜蜜、温暖、偶尔酸涩，拒绝阴暗扭曲
''';

  static const _defaultDialogue = '';

  static const _defaultOpeningPrompt = '';

  static const _defaultReplyStylePrompt = '';
}

final narrativeServiceProvider = Provider<NarrativeService>((ref) {
  throw UnimplementedError('Override in main()');
});
