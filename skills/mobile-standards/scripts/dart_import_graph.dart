// Read-only import-graph analyser for Dart and Flutter projects.
//
// Parses `import`, `export`, and `part` directives under lib/, test/, and
// integration_test/, resolves `package:<self>/` and relative URIs, and reports
// cycles, cross-feature imports, forbidden dependency directions, fan-in and
// fan-out hubs, unresolved internal imports, external package use, and the
// reverse-dependency impact of chosen files. It writes nothing except --out.
//
// Usage:
//   dart run dart_import_graph.dart --root <project> [--format md|json]
//     [--out <file>] [--features-dir lib/features] [--top 10]
//     [--forbid lib/domain:lib/data]... [--impact lib/a.dart]...
//     [--fail-on-cycles]

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _scanDirs = ['lib', 'test', 'integration_test'];
const _generatedSuffixes = [
  '.g.dart',
  '.freezed.dart',
  '.gr.dart',
  '.mocks.dart',
  '.config.dart',
];

const _usage = '''
Read-only Dart import-graph analyser.

  --root <dir>            Project root containing pubspec.yaml (default: current directory)
  --format md|json        Output format (default: md)
  --out <file>            Write the report to a file instead of stdout
  --features-dir <path>   Folder whose subfolders are features (default: lib/features)
  --top <n>               Rows in the fan-in and fan-out tables (default: 10)
  --forbid <from>:<to>    Report imports from paths under <from> to paths under <to> (repeatable)
  --impact <file>         Report files and tests that depend on <file> (repeatable)
  --fail-on-cycles        Exit with code 1 when a cycle exists
  -h, --help              Show this help
''';

class Options {
  String root = Directory.current.path;
  String format = 'md';
  String? out;
  String featuresDir = 'lib/features';
  int top = 10;
  final List<ForbidRule> forbid = [];
  final List<String> impact = [];
  bool failOnCycles = false;
}

class ForbidRule {
  ForbidRule(this.from, this.to);

  final String from;
  final String to;

  @override
  String toString() => '$from:$to';
}

class Edge {
  Edge(this.from, this.to, this.kind, this.line, {this.conditional = false});

  final String from;
  final String to;
  final String kind;
  final int line;
  final bool conditional;

  Map<String, Object> toJson() => {
    'from': from,
    'to': to,
    'kind': kind,
    'line': line,
    'conditional': conditional,
  };
}

class Unresolved {
  Unresolved(this.from, this.line, this.uri, this.target);

  final String from;
  final int line;
  final String uri;
  final String target;

  bool get generated => _generatedSuffixes.any(target.endsWith);

  Map<String, Object> toJson() => {
    'from': from,
    'line': line,
    'uri': uri,
    'target': target,
    'generated': generated,
  };
}

class Directive {
  Directive(this.kind, this.uri, this.line, {this.conditional = false});

  final String kind;
  final String uri;
  final int line;
  final bool conditional;
}

void main(List<String> args) {
  final Options options;
  try {
    final parsed = _parseArgs(args);
    if (parsed == null) {
      stdout.write(_usage);
      return;
    }
    options = parsed;
  } on FormatException catch (e) {
    stderr.writeln('error: ${e.message}\n\n$_usage');
    exitCode = 2;
    return;
  }

  final root = Directory(options.root);
  if (!root.existsSync()) {
    stderr.writeln('error: root not found: ${options.root}');
    exitCode = 2;
    return;
  }

  final analysis = _analyse(root, options);
  final text = options.format == 'json'
      ? const JsonEncoder.withIndent('  ').convert(analysis.toJson(options))
      : analysis.toMarkdown(options);

  if (options.out != null) {
    File(options.out!).writeAsStringSync('$text\n');
  } else {
    stdout.writeln(text);
  }
  if (options.failOnCycles && analysis.cycles.isNotEmpty) exitCode = 1;
}

Options? _parseArgs(List<String> args) {
  final o = Options();
  var i = 0;
  String value(String flag) {
    if (i + 1 >= args.length) throw FormatException('missing value for $flag');
    i += 1;
    return args[i];
  }

  while (i < args.length) {
    final arg = args[i];
    switch (arg) {
      case '-h' || '--help':
        return null;
      case '--root':
        o.root = value(arg);
      case '--format':
        o.format = value(arg);
        if (o.format != 'md' && o.format != 'json') {
          throw FormatException('--format must be md or json');
        }
      case '--out':
        o.out = value(arg);
      case '--features-dir':
        o.featuresDir = _normalize(value(arg)) ?? 'lib/features';
      case '--top':
        o.top =
            int.tryParse(value(arg)) ??
            (throw FormatException('--top needs a number'));
      case '--forbid':
        final rule = value(arg);
        final sep = rule.indexOf(':');
        if (sep <= 0 || sep == rule.length - 1) {
          throw FormatException('--forbid needs <from>:<to>, got "$rule"');
        }
        o.forbid.add(
          ForbidRule(
            _normalize(rule.substring(0, sep)) ?? rule.substring(0, sep),
            _normalize(rule.substring(sep + 1)) ?? rule.substring(sep + 1),
          ),
        );
      case '--impact':
        final path = value(arg);
        o.impact.add(_normalize(path) ?? path);
      case '--fail-on-cycles':
        o.failOnCycles = true;
      default:
        throw FormatException('unknown argument: $arg');
    }
    i += 1;
  }
  return o;
}

class Analysis {
  String? package;
  final Map<String, int> fileCounts = {};
  final Set<String> files = SplayTreeSet();
  final List<Edge> edges = [];
  final List<Unresolved> unresolved = [];
  final Map<String, Set<String>> externalUsers = SplayTreeMap();
  final List<String> warnings = [];
  List<Map<String, Object>> cycles = [];

  Map<String, Set<String>> get adjacency {
    final adj = <String, Set<String>>{for (final f in files) f: SplayTreeSet()};
    for (final e in edges) {
      adj[e.from]!.add(e.to);
    }
    return adj;
  }

  Map<String, Object?> toJson(Options o) {
    final libEdges = _libEdges();
    return {
      'package': package,
      'root': o.root,
      'files': fileCounts,
      'edgeCount': edges.length,
      'edges': edges.map((e) => e.toJson()).toList(),
      'cycles': cycles,
      'crossFeature': _crossFeature(o).map((e) => e.toJson()).toList(),
      'forbidden': [
        for (final v in _forbidden(o)) {...v.$1.toJson(), 'rule': '${v.$2}'},
      ],
      'unresolved': unresolved.map((u) => u.toJson()).toList(),
      'fanIn': _hubs(libEdges, byFanIn: true, top: o.top),
      'fanOut': _hubs(libEdges, byFanIn: false, top: o.top),
      'externalPackages': {
        for (final entry in externalUsers.entries)
          entry.key: entry.value.length,
      },
      'impact': {for (final f in o.impact) f: _impact(f)},
      'warnings': warnings,
    };
  }

  String toMarkdown(Options o) {
    final b = StringBuffer();
    final libEdges = _libEdges();
    final cross = _crossFeature(o);
    final forbidden = _forbidden(o);

    b.writeln('# Dart import graph — ${package ?? '(unknown package)'}');
    b.writeln();
    b.writeln(
      'Root: `${o.root}` · Files: ${files.length} '
      '(${_scanDirs.map((d) => '$d ${fileCounts[d] ?? 0}').join(', ')}) · '
      'Internal edges: ${edges.length} · External packages: ${externalUsers.length}',
    );
    b.writeln();
    b.writeln(
      'Evidence: **Verified** — parsed from import / export / part directives '
      '(`file:line`). An import shows a static dependency, not runtime behaviour.',
    );
    for (final w in warnings) {
      b.writeln();
      b.writeln('> Warning: $w');
    }

    b.writeln();
    b.writeln('## Cycles (${cycles.length})');
    if (cycles.isEmpty) b.writeln('\nNone.');
    for (var i = 0; i < cycles.length; i++) {
      final c = cycles[i];
      final path = (c['path'] as List).cast<String>();
      b.writeln();
      b.writeln(
        '${i + 1}. **${c['kind']}** — ${path.join(' → ')} '
        '(strongly connected set of ${(c['members'] as List).length} files)',
      );
      for (final e in (c['edges'] as List).cast<Map<String, Object>>()) {
        b.writeln('   - `${e['from']}:${e['line']}` imports `${e['to']}`');
      }
    }

    b.writeln();
    b.writeln('## Cross-feature imports (${cross.length})');
    if (!Directory('${o.root}/${o.featuresDir}').existsSync()) {
      b.writeln('\n`${o.featuresDir}` not found — pass `--features-dir`.');
    } else if (cross.isEmpty) {
      b.writeln('\nNone.');
    } else {
      b.writeln();
    }
    for (final e in cross) {
      b.writeln(
        '- `${e.from}:${e.line}` → `${e.to}` '
        '(${_featureOf(e.from, o)} → ${_featureOf(e.to, o)})',
      );
    }

    b.writeln();
    b.writeln('## Forbidden-direction imports (${forbidden.length})');
    if (o.forbid.isEmpty) {
      b.writeln('\nNo rules given — pass `--forbid <from>:<to>`.');
    } else if (forbidden.isEmpty) {
      b.writeln('\nNone for rules: ${o.forbid.join(', ')}.');
    } else {
      b.writeln();
    }
    for (final v in forbidden) {
      b.writeln(
        '- `${v.$1.from}:${v.$1.line}` → `${v.$1.to}` (rule `${v.$2}`)',
      );
    }

    b.writeln();
    b.writeln('## Highest fan-in (lib → lib)');
    _hubTable(b, _hubs(libEdges, byFanIn: true, top: o.top));
    b.writeln();
    b.writeln('## Highest fan-out (lib → lib)');
    _hubTable(b, _hubs(libEdges, byFanIn: false, top: o.top));

    b.writeln();
    b.writeln('## Unresolved internal imports (${unresolved.length})');
    b.writeln(unresolved.isEmpty ? '\nNone.' : '');
    for (final u in unresolved) {
      final note = u.generated ? ' — generated file, run the generator' : '';
      b.writeln('- `${u.from}:${u.line}` → `${u.target}`$note');
    }

    b.writeln();
    b.writeln('## Most-used external packages');
    final packages = externalUsers.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    if (packages.isEmpty) b.writeln('\nNone.');
    if (packages.isNotEmpty) {
      b.writeln();
      b.writeln('| Package | Files importing it |');
      b.writeln('|---|---|');
      for (final p in packages.take(o.top)) {
        b.writeln('| `${p.key}` | ${p.value.length} |');
      }
    }

    for (final target in o.impact) {
      final result = _impact(target);
      b.writeln();
      b.writeln('## Impact of `$target`');
      if (result['found'] != true) {
        b.writeln('\nNot found among scanned files.');
        continue;
      }
      final lib = (result['lib'] as List).cast<String>();
      final tests = (result['tests'] as List).cast<String>();
      b.writeln('\nDependent lib files (${lib.length}):');
      for (final f in lib) {
        b.writeln('- `$f`');
      }
      b.writeln('\nTests to run (${tests.length}):');
      for (final f in tests) {
        b.writeln('- `$f`');
      }
    }
    return b.toString();
  }

  List<Edge> _libEdges() => edges
      .where(
        (e) =>
            e.kind != 'part' &&
            e.from.startsWith('lib/') &&
            e.to.startsWith('lib/'),
      )
      .toList();

  List<Edge> _crossFeature(Options o) {
    if (!Directory('${o.root}/${o.featuresDir}').existsSync()) return const [];
    return edges.where((e) {
      final from = _featureOf(e.from, o);
      final to = _featureOf(e.to, o);
      return from != null && to != null && from != to;
    }).toList();
  }

  List<(Edge, ForbidRule)> _forbidden(Options o) => [
    for (final e in edges)
      for (final rule in o.forbid)
        if (_under(e.from, rule.from) && _under(e.to, rule.to)) (e, rule),
  ];

  List<Map<String, Object>> _hubs(
    List<Edge> libEdges, {
    required bool byFanIn,
    required int top,
  }) {
    final fanIn = <String, Set<String>>{};
    final fanOut = <String, Set<String>>{};
    for (final e in libEdges) {
      fanIn.putIfAbsent(e.to, SplayTreeSet.new).add(e.from);
      fanOut.putIfAbsent(e.from, SplayTreeSet.new).add(e.to);
    }
    final testedBy = <String, Set<String>>{};
    for (final e in edges) {
      if (!e.from.startsWith('lib/')) {
        testedBy.putIfAbsent(e.to, SplayTreeSet.new).add(e.from);
      }
    }
    final libFiles = files.where((f) => f.startsWith('lib/')).toList();
    final rows = [
      for (final f in libFiles)
        <String, Object>{
          'file': f,
          'fanIn': fanIn[f]?.length ?? 0,
          'fanOut': fanOut[f]?.length ?? 0,
          'testedBy': testedBy[f]?.length ?? 0,
        },
    ];
    final key = byFanIn ? 'fanIn' : 'fanOut';
    rows.sort((a, b) {
      final byKey = (b[key] as int).compareTo(a[key] as int);
      return byKey != 0
          ? byKey
          : (a['file'] as String).compareTo(b['file'] as String);
    });
    return rows.where((r) => (r[key] as int) > 0).take(top).toList();
  }

  void _hubTable(StringBuffer b, List<Map<String, Object>> rows) {
    if (rows.isEmpty) {
      b.writeln('\nNone.');
      return;
    }
    b.writeln();
    b.writeln('| File | Fan-in | Fan-out | Imported by tests |');
    b.writeln('|---|---|---|---|');
    for (final r in rows) {
      b.writeln(
        '| `${r['file']}` | ${r['fanIn']} | ${r['fanOut']} | ${r['testedBy']} |',
      );
    }
  }

  Map<String, Object> _impact(String target) {
    if (!files.contains(target))
      return {'found': false, 'lib': [], 'tests': []};
    final reverse = <String, Set<String>>{};
    for (final e in edges) {
      reverse.putIfAbsent(e.to, () => {}).add(e.from);
    }
    final seen = <String>{target};
    final queue = Queue<String>()..add(target);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      for (final dependent in reverse[current] ?? const <String>{}) {
        if (seen.add(dependent)) queue.add(dependent);
      }
    }
    seen.remove(target);
    final sorted = seen.toList()..sort();
    return {
      'found': true,
      'lib': sorted.where((f) => f.startsWith('lib/')).toList(),
      'tests': sorted.where((f) => !f.startsWith('lib/')).toList(),
    };
  }
}

Analysis _analyse(Directory root, Options o) {
  final a = Analysis();
  final rootPath = root.absolute.path;
  final pubspec = File('$rootPath/pubspec.yaml');
  if (pubspec.existsSync()) {
    final match = RegExp(
      r'^name:\s*([A-Za-z0-9_]+)',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    a.package = match?.group(1);
  }
  if (a.package == null) {
    a.warnings.add(
      'No package name in pubspec.yaml; package: imports are '
      'treated as external.',
    );
  }

  for (final dir in _scanDirs) {
    final d = Directory('$rootPath/$dir');
    if (!d.existsSync()) continue;
    for (final entity in d.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final rel = _relative(entity.path, rootPath);
      if (rel.split('/').any((s) => s.startsWith('.') || s == 'build'))
        continue;
      a.files.add(rel);
      a.fileCounts[dir] = (a.fileCounts[dir] ?? 0) + 1;
    }
  }

  for (final file in a.files) {
    final source = File('$rootPath/$file').readAsStringSync();
    for (final d in _directives(source)) {
      final uri = d.uri;
      if (uri.startsWith('dart:')) continue;
      if (uri.startsWith('package:')) {
        final rest = uri.substring('package:'.length);
        final slash = rest.indexOf('/');
        final name = slash < 0 ? rest : rest.substring(0, slash);
        if (name != a.package) {
          a.externalUsers.putIfAbsent(name, SplayTreeSet.new).add(file);
          continue;
        }
      } else if (uri.contains(':')) {
        continue;
      }
      final target = _resolve(file, uri, a.package);
      if (target == null) continue;
      if (a.files.contains(target)) {
        a.edges.add(
          Edge(file, target, d.kind, d.line, conditional: d.conditional),
        );
      } else {
        a.unresolved.add(Unresolved(file, d.line, uri, target));
      }
    }
  }
  a.cycles = _cycles(a, o);
  return a;
}

/// Extracts directives from Dart source with comments blanked out, so
/// commented-out imports are ignored and line numbers stay accurate.
List<Directive> _directives(String source) {
  final text = _stripComments(source);
  final lineStarts = <int>[0];
  for (var i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) == 10) lineStarts.add(i + 1);
  }
  int lineOf(int offset) {
    var lo = 0;
    var hi = lineStarts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (lineStarts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  final start = RegExp(
    r'''(?:^|;)[ \t]*(import|export|part)\s+(?!of\b)(?=['"])''',
    multiLine: true,
  );
  final quoted = RegExp(r'''^['"]([^'"]+)['"]''');
  final conditional = RegExp(r'''\bif\s*\([^)]*\)\s*['"]([^'"]+)['"]''');
  final result = <Directive>[];
  for (final m in start.allMatches(text)) {
    final kind = m.group(1)!;
    final keywordOffset = m.start + m.group(0)!.indexOf(kind);
    final end = text.indexOf(';', m.end);
    final statement = text.substring(m.end, end < 0 ? text.length : end);
    final line = lineOf(keywordOffset);
    final primary = quoted.firstMatch(statement);
    if (primary == null) continue;
    result.add(Directive(kind, primary.group(1)!, line));
    for (final c in conditional.allMatches(statement)) {
      result.add(Directive(kind, c.group(1)!, line, conditional: true));
    }
  }
  return result;
}

/// Replaces comments with spaces (keeping newlines). String literals are kept
/// intact, so `//` inside a string is not treated as a comment.
String _stripComments(String src) {
  final out = StringBuffer();
  final n = src.length;
  var i = 0;
  while (i < n) {
    if (src.startsWith('//', i)) {
      while (i < n && src[i] != '\n') {
        out.write(' ');
        i++;
      }
    } else if (src.startsWith('/*', i)) {
      var depth = 0;
      do {
        if (src.startsWith('/*', i)) {
          depth++;
          out.write('  ');
          i += 2;
        } else if (src.startsWith('*/', i)) {
          depth--;
          out.write('  ');
          i += 2;
        } else {
          out.write(src[i] == '\n' ? '\n' : ' ');
          i++;
        }
      } while (i < n && depth > 0);
    } else if (src[i] == "'" || src[i] == '"') {
      final quote = src[i];
      final raw = i > 0 && (src[i - 1] == 'r' || src[i - 1] == 'R');
      final delimiter = src.startsWith(quote * 3, i) ? quote * 3 : quote;
      out.write(delimiter);
      i += delimiter.length;
      while (i < n) {
        if (!raw && src[i] == r'\') {
          final stop = math.min(i + 2, n);
          out.write(src.substring(i, stop));
          i = stop;
          continue;
        }
        if (src.startsWith(delimiter, i)) {
          out.write(delimiter);
          i += delimiter.length;
          break;
        }
        if (delimiter.length == 1 && src[i] == '\n') break;
        out.write(src[i]);
        i++;
      }
    } else {
      out.write(src[i]);
      i++;
    }
  }
  return out.toString();
}

String? _resolve(String fromFile, String uri, String? package) {
  if (uri.startsWith('package:')) {
    final rest = uri.substring('package:'.length);
    final slash = rest.indexOf('/');
    if (slash < 0 || package == null) return null;
    return _normalize('lib/${rest.substring(slash + 1)}');
  }
  final dir = fromFile.contains('/')
      ? fromFile.substring(0, fromFile.lastIndexOf('/'))
      : '';
  return _normalize(dir.isEmpty ? uri : '$dir/$uri');
}

String? _normalize(String path) {
  final parts = <String>[];
  for (final segment in path.replaceAll(r'\', '/').split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (parts.isEmpty) return null;
      parts.removeLast();
    } else {
      parts.add(segment);
    }
  }
  return parts.isEmpty ? null : parts.join('/');
}

String _relative(String path, String root) {
  final p = path.replaceAll(r'\', '/');
  final r = root.replaceAll(r'\', '/');
  final prefix = r.endsWith('/') ? r : '$r/';
  return p.startsWith(prefix) ? p.substring(prefix.length) : p;
}

bool _under(String path, String prefix) =>
    path == prefix || path.startsWith('$prefix/');

String? _featureOf(String path, Options o) {
  final prefix = '${o.featuresDir}/';
  if (!path.startsWith(prefix)) return null;
  final rest = path.substring(prefix.length);
  final slash = rest.indexOf('/');
  return slash < 0 ? null : rest.substring(0, slash);
}

/// The layer a file belongs to: `<feature>/<sublayer>` inside the features
/// folder, otherwise the first folder under lib/ (or the top folder for tests).
String _layerOf(String path, Options o) {
  final feature = _featureOf(path, o);
  if (feature != null) {
    final rest = path.substring('${o.featuresDir}/$feature/'.length);
    final slash = rest.indexOf('/');
    return slash < 0 ? feature : '$feature/${rest.substring(0, slash)}';
  }
  final parts = path.split('/');
  return parts.length > 2 ? '${parts[0]}/${parts[1]}' : parts[0];
}

List<Map<String, Object>> _cycles(Analysis a, Options options) {
  final adj = a.adjacency;
  var index = 0;
  final indices = <String, int>{};
  final lowLink = <String, int>{};
  final stack = <String>[];
  final onStack = <String>{};
  final components = <List<String>>[];

  void visit(String v) {
    indices[v] = index;
    lowLink[v] = index;
    index++;
    stack.add(v);
    onStack.add(v);
    for (final w in adj[v] ?? const <String>{}) {
      if (!indices.containsKey(w)) {
        visit(w);
        lowLink[v] = math.min(lowLink[v]!, lowLink[w]!);
      } else if (onStack.contains(w)) {
        lowLink[v] = math.min(lowLink[v]!, indices[w]!);
      }
    }
    if (lowLink[v] == indices[v]) {
      final component = <String>[];
      String w;
      do {
        w = stack.removeLast();
        onStack.remove(w);
        component.add(w);
      } while (w != v);
      components.add(component..sort());
    }
  }

  for (final v in adj.keys) {
    if (!indices.containsKey(v)) visit(v);
  }

  final edgeAt = <String, Edge>{};
  for (final e in a.edges) {
    edgeAt.putIfAbsent('${e.from}|${e.to}', () => e);
  }

  final result = <Map<String, Object>>[];
  for (final component in components) {
    final members = component.toSet();
    final first = component.first;
    final selfLoop = adj[first]?.contains(first) ?? false;
    if (component.length < 2 && !selfLoop) continue;
    final path = _cycleThrough(first, members, adj);
    final features = members
        .map((f) => _featureOf(f, options))
        .whereType<String>()
        .toSet();
    final layers = members.map((f) => _layerOf(f, options)).toSet();
    final kind = features.length > 1
        ? 'cross-feature'
        : layers.length > 1
        ? 'cross-layer'
        : 'local';
    result.add({
      'members': component,
      'path': path,
      'kind': kind,
      'edges': [
        for (var i = 0; i + 1 < path.length; i++)
          {
            'from': path[i],
            'to': path[i + 1],
            'line': edgeAt['${path[i]}|${path[i + 1]}']?.line ?? 0,
          },
      ],
    });
  }
  result.sort(
    (x, y) => ((x['members'] as List).first as String).compareTo(
      (y['members'] as List).first as String,
    ),
  );
  return result;
}

/// Shortest cycle through [start] that stays inside [members].
List<String> _cycleThrough(
  String start,
  Set<String> members,
  Map<String, Set<String>> adj,
) {
  final parent = <String, String>{};
  final seen = <String>{start};
  final queue = Queue<String>()..add(start);
  while (queue.isNotEmpty) {
    final u = queue.removeFirst();
    for (final w in adj[u] ?? const <String>{}) {
      if (!members.contains(w)) continue;
      if (w == start) {
        final reversed = <String>[];
        var x = u;
        while (x != start) {
          reversed.add(x);
          x = parent[x]!;
        }
        return [start, ...reversed.reversed, start];
      }
      if (seen.add(w)) {
        parent[w] = u;
        queue.add(w);
      }
    }
  }
  return [start, start];
}
