import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:json2yaml/json2yaml.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  ArgParser parser = ArgParser()
    ..addOption("directory", abbr: "d", help: "Working directory of Flutter project.", defaultsTo: Directory.current.path)
    ..addOption("commit", abbr: "c", help: "Commit to use for localpkg.");

  ArgResults args = parser.parse(arguments);
  Directory directory = Directory(args["directory"]);
  File pubspecLock = File(p.joinAll([directory.path, "pubspec.lock"]));

  if (!directory.existsSync()) {
    print("Directory ${directory.path} does not exist.");
    exit(1);
  }

  if (!pubspecLock.existsSync()) {
    print("File ${pubspecLock.path} does not exist.");
    exit(1);
  }

  var loaded = loadYaml(pubspecLock.readAsStringSync());
  var data = yamlToMap(loaded);
  Map<String, dynamic>? localpkg = data["packages"]?["localpkg"];

  if (localpkg == null) {
    print("Data for localpkg does not exist.");
    exit(1);
  }

  String initialCommitSetting = localpkg["description"]["resolved-ref"];
  print("Fetching latest commit...");
  http.Response response = await http.get(Uri.parse("https://api.github.com/repos/Calebh101/localpkg-flutter-2/commits/main"));

  if (response.statusCode < 200 || response.statusCode > 210) {
    print("Received bad request for API call: code ${response.statusCode}.");
    print(response.body);
    exit(-1);
  }

  Map body = jsonDecode(response.body);
  String sha = body["sha"];
  print("Found commit ID of $sha.");

  if (sha == initialCommitSetting) {
    print("Package localpkg is up to date.");
    exit(0);
  }

  localpkg["description"]["resolved-ref"] = sha;
  print("Updating packages...");
  pubspecLock.writeAsStringSync(json2yaml(localpkg));
  Process.runSync("flutter", ["pub", "get"], runInShell: true, workingDirectory: directory.path);
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