class Temp {
  final int? fan2;
  final double? systin;
  final double? cputin;
  final int? gpu;
  final Map<String, int?> disks;

  Temp(
      {required this.fan2,
      required this.systin,
      required this.cputin,
      required this.gpu,
      required this.disks});

  factory Temp.fromJson(Map<String, dynamic> json) {
    return Temp(
      fan2: json["fan2"],
      systin: double.parse(json["SYSTIN"].toString()),
      cputin: double.parse(json["CPUTIN"].toString()),
      gpu: json["GPU"],
      disks: Map<String, int>.from(json["disks"]),
    );
  }
}
