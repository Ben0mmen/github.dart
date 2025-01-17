part of github.common;

/// Model class for a file on GitHub.
class GitHubFile {
  /// Type of File
  String type;

  /// File Encoding
  String encoding;

  /// File Size
  int size;

  /// File Name
  String name;

  /// File Path
  String path;

  /// File Content
  String content;

  /// SHA
  String sha;

  /// Url to file
  @JsonKey(name: "html_url")
  String htmlUrl;

  /// Git Url
  @JsonKey(name: "git_url")
  String gitUrl;

  /// Links
  @JsonKey(name: "_links")
  Links links;

  /// Text Content
  String get text {
    if (_text == null) {
      _text = utf8.decode(base64Decode(content));
    }
    return _text;
  }

  String _text;

  /// Source Repository
  RepositorySlug sourceRepository;

  static GitHubFile fromJSON(Map<String, dynamic> input,
      [RepositorySlug slug]) {
    if (input == null) return null;

    return GitHubFile()
      ..type = input['type']
      ..encoding = input['encoding']
      ..size = input['size']
      ..name = input['name']
      ..path = input['path']
      ..content = input['content'] == null
          ? null
          : LineSplitter.split(input['content']).join()
      ..sha = input['sha']
      ..gitUrl = input['git_url']
      ..htmlUrl = input['html_url']
      ..links = Links.fromJson(input['_links'] as Map<String, dynamic>)
      ..sourceRepository = slug;
  }
}

@JsonSerializable()
class Links {
  final Uri self;
  final Uri git;
  final Uri html;

  Links({this.git, this.self, this.html});

  factory Links.fromJson(Map<String, dynamic> input) {
    if (input == null) return null;

    return _$LinksFromJson(input);
  }

  Map<String, dynamic> toJson() => _$LinksToJson(this);
}

/// Model class for a file or directory.
class RepositoryContents {
  GitHubFile file;
  List<GitHubFile> tree;

  bool get isFile => file != null;
  bool get isDirectory => tree != null;
}

/// Model class for a new file to be created.
class CreateFile {
  final String path;
  final String message;
  final String content;

  String branch;
  CommitUser committer;

  CreateFile(this.path, this.content, this.message);

  String toJSON() {
    final map = <String, dynamic>{};
    putValue("path", path, map);
    putValue("message", message, map);
    putValue("content", content, map);
    putValue("branch", branch, map);
    putValue("committer", committer != null ? committer.toMap() : null, map);
    return jsonEncode(map);
  }
}

/// Model class for a committer of a commit.
class CommitUser {
  final String name;
  final String email;

  CommitUser(this.name, this.email);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    putValue('name', name, map);
    putValue('email', email, map);

    return map;
  }
}

/// Model class for the response of a content creation.
class ContentCreation {
  final RepositoryCommit commit;
  final GitHubFile content;

  ContentCreation(this.commit, this.content);

  static ContentCreation fromJSON(Map<String, dynamic> input) {
    if (input == null) return null;

    return ContentCreation(
        RepositoryCommit.fromJSON(input['commit'] as Map<String, dynamic>),
        GitHubFile.fromJSON(input['content'] as Map<String, dynamic>));
  }
}
