
/// Class chứa dữ liệu cho cuộc đua
class RaceData {
  final int totalMoney;
  final List<int> bets;
  final List<String> racerNames;
  final List<String> carImages; // Đường dẫn tới hình ảnh của 3 xe

  RaceData({
    required this.totalMoney,
    required this.bets,
    this.racerNames = const ['Red Car', 'Blue Car', 'Yellow Car'], // Lưu ý: Nếu thay đổi Actor thì thay đổi tên luôn.
    this.carImages = const [
      'assets/images/car_red.png',
      'assets/images/car_blue.png',
      'assets/images/car_yellow.png',
    ],
  });

  // Tính tổng tiền cược
  int get totalBets => bets.reduce((a, b) => a + b);

  RaceData copyWith({int? totalMoney, List<int>? bets}) {
    return RaceData(
      totalMoney: totalMoney ?? this.totalMoney,
      bets: bets ?? this.bets,
      racerNames: racerNames,
      carImages: carImages,
    );
  }
}
