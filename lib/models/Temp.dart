class Temp {
  final int fan2;
  final int systin;
  final double cputin;
  final int gpu;
  final Map<String, int> disks;

  Temp(
      {required this.fan2,
      required this.systin,
      required this.cputin,
      required this.gpu,
      required this.disks});

  factory Temp.fromJson(Map<String, dynamic> json) {
    return Temp(
        fan2: json["fan2"],
        systin: 3, //json["SYSTIN"],
        cputin: 3.14, //json["CPUTIN"],
        gpu: 8, //json["GPU"],
        disks: Map<String, int>() //Map<String, int>.from(json["disks"]),
        );
  }
}
