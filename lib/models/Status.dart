class Status {
  final String commitHash;
  final String startTime;

  Status({required this.commitHash, required this.startTime});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(commitHash: json["commitHash"], startTime: json["startTime"]);
  }
}
