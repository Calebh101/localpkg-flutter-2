import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> arguments) async {
  ArgParser parser = ArgParser()
    ..addOption("directory", abbr: "d", help: "Working directory of Flutter project.", defaultsTo: Directory.current.path)
    ..addOption("commit", abbr: "c", help: "Commit to use for localpkg.");

  ArgResults args = parser.parse(arguments);
  Directory directory = Directory(args["directory"]);
  File pubspec = File(p.joinAll([directory.path, "pubspec.yaml"]));

  if (!directory.existsSync()) {
    print("Directory ${directory.path} does not exist.");
    exit(1);
  }

  if (!pubspec.existsSync()) {
    print("File ${pubspec.path} does not exist.");
    exit(1);
  }

  YamlEditor editor = YamlEditor(pubspec.readAsStringSync());
  var loaded = editor.parseAt([]);
  var data = yamlToMap(loaded);
  Map<String, dynamic>? localpkg = data["dependencies"]?["localpkg"];

  if (localpkg == null) {
    print("Data for localpkg does not exist.");
    exit(1);
  }

  String? initialCommitSetting = localpkg["git"]?["ref"];
  if (initialCommitSetting == "main") initialCommitSetting = null;

  print("Fetching latest commit...");
  http.Response response = await http.get(Uri.parse("https://api.github.com/repos/Calebh101/localpkg-flutter-2/commits/main"));

  if (response.statusCode < 200 || response.statusCode > 300) {
    print("Received bad request for API call: code ${response.statusCode}.");
    print(response.body);
    exit(-1);
  }

  Map body = jsonDecode(response.body);
  String sha = body["sha"];
  print("Found commit ID of $sha: ${body["commit"]?["message"] ?? "Unknown"}");

  if (sha == initialCommitSetting) {
    print("Package localpkg is up to date.");
    exit(0);
  }


  print("Updating packages...");
  editor.update(["dependencies", "localpkg", "git", "ref"], sha);
  pubspec.writeAsStringSync(editor.toString());

  var process = await Process.start("flutter", ["pub", "get"], runInShell: true, workingDirectory: directory.path);
  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);

  int exitCode = await process.exitCode;
  print("Job done!");
}

dynamic yamlToMap(dynamic yaml) {
  if (yaml is YamlMap) {
    return Map<String, dynamic>.fromEntries(
      yaml.entries.map((e) => MapEntry(e.key, yamlToMap(e.value))),
    );
  } else if (yaml is YamlList) {
    return yaml.map((e) => yamlToMap(e)).toList();
  } else {
    return yaml;
  }
}