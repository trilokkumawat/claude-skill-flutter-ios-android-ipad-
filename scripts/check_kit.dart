// Structural self-check for the flutter-mobile-kit plugin.
//
// Validates the plugin and marketplace manifests, skill and agent frontmatter,
// relative links and ${CLAUDE_SKILL_DIR} paths, SKILL.md length, and scans
// every text file for secrets, personal data, local paths, and project-specific
// names that must not ship in this public repository. Finally it runs the Dart
// import-graph analyser on its fixture and compares the result with
// tests/fixtures/sample_app/expected.json.
//
// Usage: dart run scripts/check_kit.dart [--root <kit>]
// Exit code: 0 when there are no errors, 1 otherwise.

import 'dart:convert';
import 'dart:io';

const _skillKeys = {
  'name', 'description', 'when_to_use', 'argument-hint', 'arguments', //
  'disable-model-invocation', 'user-invocable', 'allowed-tools',
  'disallowed-tools', 'model', 'effort', 'context', 'agent', 'background',
  'hooks', 'paths', 'shell', 'metadata', 'license', 'compatibility',
};

const _agentKeys = {
  'name', 'description', 'tools', 'disallowedTools', 'model', //
  'permissionMode', 'maxTurns', 'autoCompactWindow', 'skills', 'mcpServers',
  'hooks', 'memory', 'background', 'omitClaudeMd', 'effort', 'isolation',
  'color', 'initialPrompt', 'experimental',
};

// Plugin subagents ignore these keys, so shipping them would mislead readers.
const _pluginIgnoredAgentKeys = {
  'permissionMode', 'hooks', 'mcpServers', 'initialPrompt', //
};

const _knownTools = {
  'Read', 'Grep', 'Glob', 'Edit', 'Write', 'Bash', 'WebFetch', 'WebSearch', //
  'Agent', 'NotebookEdit', 'Skill', 'TodoWrite',
};

const _agentColors = {
  'red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'cyan', //
};

const _reservedPluginPrefixes = [
  'claude-',
  'anthropic-',
  'anthropics-',
  'cc-plugin-',
];

const _maxSkillLines = 500;
const _maxDescription = 1024;

final _errors = <String>[];
final _warnings = <String>[];

void _error(String message) => _errors.add(message);
void _warn(String message) => _warnings.add(message);

void main(List<String> args) {
  var root = File.fromUri(Platform.script).parent.parent.path;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--root' && i + 1 < args.length) root = args[++i];
  }
  root = Directory(root).absolute.path;

  final pluginName = _checkManifests(root);
  final skills = _checkSkills(root);
  _checkAgents(root, skills, pluginName);
  _checkLinks(root);
  _scanContent(root);
  _checkImportGraphFixture(root);

  for (final w in _warnings) {
    stdout.writeln('WARN  $w');
  }
  for (final e in _errors) {
    stdout.writeln('ERROR $e');
  }
  stdout.writeln(
    '${_errors.isEmpty ? 'PASS' : 'FAIL'}: '
    '${_errors.length} error(s), ${_warnings.length} warning(s), '
    '${skills.length} skill(s) checked.',
  );
  exitCode = _errors.isEmpty ? 0 : 1;
}

String? _checkManifests(String root) {
  final plugin = _readJson('$root/.claude-plugin/plugin.json');
  final marketplace = _readJson('$root/.claude-plugin/marketplace.json');
  if (plugin == null) return null;

  final name = plugin['name'];
  if (name is! String || !RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(name)) {
    _error('plugin.json: name must be kebab-case, got "$name"');
    return null;
  }
  if (_reservedPluginPrefixes.any(name.startsWith) ||
      name == 'claude' ||
      name == 'anthropic') {
    _error('plugin.json: name "$name" uses a reserved prefix');
  }

  if (marketplace != null) {
    for (final key in ['name', 'owner', 'plugins']) {
      if (!marketplace.containsKey(key))
        _error('marketplace.json: missing "$key"');
    }
    final plugins = marketplace['plugins'];
    if (plugins is List) {
      final entry = plugins.whereType<Map>().where((p) => p['name'] == name);
      if (entry.isEmpty) {
        _error('marketplace.json: no plugin entry named "$name"');
      } else {
        final source = entry.first['source'];
        if (source is String && !Directory('$root/$source').existsSync()) {
          _error('marketplace.json: source "$source" does not exist');
        }
      }
    }
  }
  return name;
}

Map<String, dynamic>? _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    _error('missing ${_rel(path)}');
    return null;
  }
  try {
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } on FormatException catch (e) {
    _error('${_rel(path)}: invalid JSON (${e.message})');
    return null;
  }
}

/// Returns skill name → whether it may be preloaded into a subagent.
Map<String, bool> _checkSkills(String root) {
  final result = <String, bool>{};
  final dir = Directory('$root/skills');
  if (!dir.existsSync()) {
    _error('missing skills/');
    return result;
  }
  for (final entity in dir.listSync()) {
    if (entity is! Directory) continue;
    final folder = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final file = File('${entity.path}/SKILL.md');
    if (!file.existsSync()) {
      _error('skills/$folder: missing SKILL.md');
      continue;
    }
    final lines = file.readAsLinesSync();
    final fm = _frontmatter(lines, 'skills/$folder/SKILL.md');
    if (fm == null) continue;

    for (final key in fm.keys) {
      if (!_skillKeys.contains(key)) {
        _error('skills/$folder/SKILL.md: unknown frontmatter key "$key"');
      }
    }
    final name = fm['name'] ?? folder;
    if (name != folder) {
      _error('skills/$folder/SKILL.md: name "$name" does not match folder');
    }
    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(name)) {
      _error('skills/$folder/SKILL.md: name must be kebab-case');
    }
    _checkDescription(fm['description'], 'skills/$folder/SKILL.md');
    if (lines.length >= _maxSkillLines) {
      _error(
        'skills/$folder/SKILL.md: ${lines.length} lines (keep under $_maxSkillLines)',
      );
    }
    _checkSkillDirPaths(entity.path, lines, 'skills/$folder/SKILL.md');
    result[name] = fm['disable-model-invocation'] != 'true';
  }
  return result;
}

void _checkAgents(String root, Map<String, bool> skills, String? pluginName) {
  final dir = Directory('$root/agents');
  if (!dir.existsSync()) {
    _error('missing agents/');
    return;
  }
  final names = <String>{};
  for (final entity in dir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;
    final base = entity.uri.pathSegments.last.replaceAll('.md', '');
    final where = 'agents/$base.md';
    final fm = _frontmatter(entity.readAsLinesSync(), where);
    if (fm == null) continue;

    for (final key in fm.keys) {
      if (!_agentKeys.contains(key))
        _error('$where: unknown frontmatter key "$key"');
      if (_pluginIgnoredAgentKeys.contains(key)) {
        _error('$where: "$key" is ignored for plugin subagents — remove it');
      }
    }
    final name = fm['name'];
    if (name == null) {
      _error('$where: missing name');
    } else {
      if (name != base) _error('$where: name "$name" does not match file name');
      if (name.contains(':')) _error('$where: name must not contain ":"');
      if (!names.add(name)) _error('$where: duplicate agent name "$name"');
    }
    _checkDescription(fm['description'], where);

    final tools = fm['tools'];
    if (tools != null) {
      for (final tool
          in tools.split(RegExp(r'[,\s]+')).where((t) => t.isNotEmpty)) {
        if (!_knownTools.contains(tool))
          _warn('$where: unrecognised tool "$tool"');
      }
    }
    final color = fm['color'];
    if (color != null && !_agentColors.contains(color)) {
      _error('$where: color "$color" is not one of $_agentColors');
    }
    final preload = fm['skills'];
    if (preload != null) {
      for (final raw
          in preload
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)) {
        final skill = pluginName != null && raw.startsWith('$pluginName:')
            ? raw.substring(pluginName.length + 1)
            : raw;
        if (!skills.containsKey(skill)) {
          _error('$where: preloads unknown skill "$raw"');
        } else if (skills[skill] == false) {
          _error(
            '$where: "$raw" sets disable-model-invocation and cannot be preloaded',
          );
        }
      }
    }
  }
}

void _checkDescription(String? description, String where) {
  if (description == null || description.trim().isEmpty) {
    _error('$where: missing description');
  } else if (description.length > _maxDescription) {
    _error(
      '$where: description is ${description.length} chars (max $_maxDescription)',
    );
  }
}

/// Parses simple YAML frontmatter: `key: value` lines and `- item` lists.
/// List values are joined with commas.
Map<String, String>? _frontmatter(List<String> lines, String where) {
  if (lines.isEmpty || lines.first.trim() != '---') {
    _error('$where: frontmatter must start on line 1 with ---');
    return null;
  }
  final end = lines.indexWhere((l) => l.trim() == '---', 1);
  if (end < 0) {
    _error('$where: frontmatter is not closed with ---');
    return null;
  }
  final result = <String, String>{};
  String? currentKey;
  for (final line in lines.sublist(1, end)) {
    final keyMatch = RegExp(r'^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$')
        .firstMatch(line);
    if (keyMatch != null) {
      currentKey = keyMatch.group(1)!;
      final raw = keyMatch.group(2)!.trim();
      if (!_isQuoted(raw) &&
          (raw.contains(': ') ||
              raw.contains(' #') ||
              RegExp(r'^[\[{*&!|>@`%]').hasMatch(raw))) {
        _error(
          '$where: value of "$currentKey" is not a valid plain YAML scalar — quote it',
        );
      }
      result[currentKey] = _unquote(raw);
    } else if (currentKey != null && RegExp(r'^\s+-\s+').hasMatch(line)) {
      final item = _unquote(line.replaceFirst(RegExp(r'^\s+-\s+'), '').trim());
      final existing = result[currentKey]!;
      result[currentKey] = existing.isEmpty ? item : '$existing,$item';
    }
  }
  return result;
}

bool _isQuoted(String value) =>
    value.length >= 2 &&
    ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'")));

String _unquote(String value) =>
    _isQuoted(value) ? value.substring(1, value.length - 1) : value;

void _checkSkillDirPaths(String skillDir, List<String> lines, String where) {
  final pattern = RegExp(r'\$\{CLAUDE_SKILL_DIR\}/([A-Za-z0-9_./-]+)');
  for (final line in lines) {
    for (final m in pattern.allMatches(line)) {
      final path = m.group(1)!.replaceAll(RegExp(r'[.]$'), '');
      final full = '$skillDir/$path';
      if (!File(full).existsSync() && !Directory(full).existsSync()) {
        _error('$where: \${CLAUDE_SKILL_DIR}/$path does not exist');
      }
    }
  }
}

void _checkLinks(String root) {
  final link = RegExp(r'\[[^\]]*\]\(([^)\s]+)\)');
  for (final file in _textFiles(root).where((f) => f.path.endsWith('.md'))) {
    final where = _rel(file.path, root);
    if (where.startsWith('tests/')) continue;
    var inFence = false;
    for (final line in file.readAsLinesSync()) {
      if (line.trimLeft().startsWith('```')) inFence = !inFence;
      if (inFence) continue;
      for (final m in link.allMatches(line)) {
        var target = m.group(1)!;
        if (RegExp(r'^(https?|mailto):').hasMatch(target) ||
            target.startsWith('#') ||
            target.contains(r'${') ||
            target.contains('<')) {
          continue;
        }
        target = target.split('#').first;
        final resolved = File.fromUri(file.parent.uri.resolve(target));
        if (!resolved.existsSync() && !Directory(resolved.path).existsSync()) {
          _error('$where: broken link "$target"');
        }
      }
    }
  }
}

void _scanContent(String root) {
  // Built from parts so this file does not flag itself.
  final projectNames = RegExp(
    [
      'focus'
          'better',
      'life'
          r'\s+'
          'os dashboard',
    ].join('|'),
    caseSensitive: false,
  );
  final checks = <String, RegExp>{
    'private key': RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----'),
    'AWS access key': RegExp(r'AKIA[0-9A-Z]{16}'),
    'Google API key': RegExp(r'AIza[0-9A-Za-z_\-]{35}'),
    'GitHub token': RegExp(r'gh[pousr]_[0-9A-Za-z]{36}'),
    'Slack token': RegExp(r'xox[baprs]-[0-9A-Za-z-]{10,}'),
    'Stripe live key': RegExp(r'sk_live_[0-9A-Za-z]{16,}'),
    'email address': RegExp(
      r'[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}',
    ),
    'local user path': RegExp(r'(/Users/|/home/)[A-Za-z0-9._-]+/|C:\\Users\\'),
    'project-specific name': projectNames,
  };
  const allowedEmailDomains = ['example.com', 'example.org'];

  for (final file in _textFiles(root)) {
    final where = _rel(file.path, root);
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      for (final entry in checks.entries) {
        for (final m in entry.value.allMatches(lines[i])) {
          if (entry.key == 'email address' &&
              allowedEmailDomains.any((d) => m.group(0)!.endsWith('@$d'))) {
            continue;
          }
          _error('$where:${i + 1}: possible ${entry.key}');
        }
      }
    }
  }
}

void _checkImportGraphFixture(String root) {
  final expectedFile = File('$root/tests/fixtures/sample_app/expected.json');
  final script = '$root/skills/mobile-standards/scripts/dart_import_graph.dart';
  if (!expectedFile.existsSync() || !File(script).existsSync()) {
    _error('import-graph fixture or script missing');
    return;
  }
  final expected =
      jsonDecode(expectedFile.readAsStringSync()) as Map<String, dynamic>;
  final args = (expected['args'] as List).cast<String>();
  final run = Process.runSync(Platform.resolvedExecutable, [
    'run',
    script,
    '--root',
    'tests/fixtures/sample_app',
    '--format',
    'json',
    ...args,
  ], workingDirectory: root);
  if (run.exitCode != 0) {
    _error(
      'import-graph fixture: analyser exited ${run.exitCode}: ${run.stderr}',
    );
    return;
  }
  final out = run.stdout as String;
  final actual =
      jsonDecode(out.substring(out.indexOf('{'))) as Map<String, dynamic>;

  String edge(Map e) => '${e['from']}:${e['line']} -> ${e['to']}';
  void same(String what, Object expectedValue, Object actualValue) {
    final a = jsonEncode(expectedValue);
    final b = jsonEncode(actualValue);
    if (a != b)
      _error('import-graph fixture: $what\n  expected $a\n  actual   $b');
  }

  final files = (actual['files'] as Map).cast<String, dynamic>();
  same('file counts', expected['files'], {
    for (final k in (expected['files'] as Map).keys) k: files[k],
  });
  same('cycles', expected['cycles'], [
    for (final c in (actual['cycles'] as List).cast<Map>())
      {'members': c['members'], 'kind': c['kind']},
  ]);
  same('cross-feature imports', expected['crossFeature'], [
    for (final e in (actual['crossFeature'] as List).cast<Map>()) edge(e),
  ]);
  same('forbidden imports', expected['forbidden'], [
    for (final e in (actual['forbidden'] as List).cast<Map>()) edge(e),
  ]);
  same('unresolved imports', expected['unresolved'], [
    for (final u in (actual['unresolved'] as List).cast<Map>())
      '${u['from']}:${u['line']} -> ${u['target']}${u['generated'] == true ? ' (generated)' : ''}',
  ]);
  same(
    'external packages',
    expected['externalPackages'],
    actual['externalPackages']!,
  );
  same('conditional edges', expected['conditionalEdges'], [
    for (final e in (actual['edges'] as List).cast<Map>())
      if (e['conditional'] == true) edge(e),
  ]);
  final impact = (actual['impact'] as Map).cast<String, dynamic>();
  same('impact', expected['impact'], {
    for (final entry in impact.entries)
      entry.key: {
        'lib': (entry.value['lib'] as List).length,
        'tests': entry.value['tests'],
      },
  });
  same(
    'top fan-in',
    expected['topFanIn'],
    (actual['fanIn'] as List).first['file'],
  );
}

Iterable<File> _textFiles(String root) sync* {
  const extensions = ['.md', '.dart', '.json', '.yaml', '.yml', '.txt', ''];
  for (final entity in Directory(
    root,
  ).listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final rel = _rel(entity.path, root);
    if (rel
        .split('/')
        .any((s) => s == '.git' || s == '.dart_tool' || s == 'build'))
      continue;
    final name = rel.split('/').last;
    if (name == '.DS_Store') continue;
    final dot = name.lastIndexOf('.');
    final ext = dot <= 0 ? '' : name.substring(dot);
    if (extensions.contains(ext) || name.startsWith('.git')) yield entity;
  }
}

String _rel(String path, [String? root]) {
  final base = root ?? Directory.current.path;
  final prefix = base.endsWith('/') ? base : '$base/';
  return path.startsWith(prefix) ? path.substring(prefix.length) : path;
}
