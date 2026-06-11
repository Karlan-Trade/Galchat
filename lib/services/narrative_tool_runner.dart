import '../providers/ai_provider.dart';
import 'narrative_service.dart';

/// Executes read/write tool calls for narrative files.
class NarrativeToolRunner implements ToolRunner {
  final NarrativeService _ns;

  NarrativeToolRunner(this._ns);

  @override
  Future<String> run(String name, Map<String, dynamic> args) async {
    switch (name) {
      case 'read_file':
        return await _readFiles(args);
      case 'write_file':
        final filename = args['filename'] as String? ?? '';
        final content = args['content'] as String? ?? '';
        await _ns.writeFile(filename, content);
        return '已成功写入 $filename';
      default:
        return '未知工具: $name';
    }
  }

  /// Read one or more narrative files, returning concatenated content.
  ///
  /// Supports both:
  /// - `filename` (String) — single file
  /// - `filenames` (List<String>) — multiple files at once
  Future<String> _readFiles(Map<String, dynamic> args) async {
    final filenames = <String>[];

    // Single filename
    final single = args['filename'] as String?;
    if (single != null && single.isNotEmpty) {
      filenames.add(single);
    }

    // Array of filenames
    final multi = args['filenames'] as List<dynamic>?;
    if (multi != null) {
      for (final f in multi) {
        if (f is String && f.isNotEmpty && !filenames.contains(f)) {
          filenames.add(f);
        }
      }
    }

    if (filenames.isEmpty) return '(未指定文件名)';

    if (filenames.length == 1) {
      final content = await _ns.readFile(filenames.first);
      return content.isNotEmpty ? content : '(文件为空)';
    }

    // Multiple files: concatenate with clear headers
    final buf = StringBuffer();
    for (final name in filenames) {
      final content = await _ns.readFile(name);
      buf.writeln('=== $name ===');
      buf.writeln(content.isNotEmpty ? content : '(文件为空)');
      buf.writeln();
    }
    return buf.toString();
  }
}
