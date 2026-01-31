
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

// Class chứa kết quả cuộc đua
class RaceResult {
  final int winnerIndex;          // Index xe thắng (0, 1, hoặc 2)
  final List<int> bets;           // Tiền cược cho 3 xe
  final List<String> racerNames;
  final List<String> carImages;
  final int previousMoney;        // Tiền TRƯỚC khi đua

  RaceResult({
    required this.winnerIndex,
    required this.bets,
    required this.racerNames,
    required this.carImages,
    required this.previousMoney,
  });

  /*
  Luật chơi như sau:
  - Cược mà thắng -> Lấy lại tiền cược + (Tiền thắng) * 2
  - Cược mà thua -> Mất ziền thoai
   */
  int calculateNewMoney() {
    int newMoney = previousMoney;

    for (int i = 0; i < bets.length; i++) {
      if (i == winnerIndex) {
        // XE THẮNG: Cộng tiền thưởng (= tiền cược)
        // Tức là nhận lại cược + thưởng = x2
        newMoney += bets[i];
      } else {
        // XE THUA: Trừ tiền cược
        newMoney -= bets[i];
      }
    }

    return newMoney;
  }

  // Kiểm tra người chơi thắng hay thua
  // ============================================
  bool get didWin => bets[winnerIndex] > 0;

  // Tính tiền sẽ thay đổi ở trên HomeScreen
  int get moneyChange => calculateNewMoney() - previousMoney;
}
