import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prm232_mini_final_project/models/race_data.dart';
import 'package:prm232_mini_final_project/screens/result_screen.dart';
import '../services/audio_service.dart';

class RaceScreen extends StatefulWidget {
  final RaceData raceData;
  const RaceScreen({super.key, required this.raceData});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> with TickerProviderStateMixin {
  bool isRacing = false;
  bool raceFinished = false;
  int? winnerIndex;

  // Vị trí xe (0.0 -> 1.0) - dùng cho animation
  List<double> positions = [0.0, 0.0, 0.0];

  // Vị trí hiển thị cho status bar (freeze khi race kết thúc)
  List<double> displayPositions = [0.0, 0.0, 0.0];

  // Màu xe và ảnh xe
  final carColors = [Colors.red, Colors.blue, Colors.amber];

  Timer? _raceTimer;
  final Random _random = Random();

  // Animation controller cho hiệu ứng đường chạy (scrolling road)
  late AnimationController _roadController;

  @override
  void initState() {
    super.initState();

    // Dừng background music và bật engine sound
    AudioService().stopBackgroundMusic();
    AudioService().playEngineSound();

    // Controller cho animation đường chạy
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ), // Tăng tốc độ đường chạy (0.2s/chu kỳ)
    );

    // Tự động bắt đầu đua sau khi màn hình được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRaceSequence();
    });
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    _roadController.dispose();

    // Dừng engine sound và bật lại background music
    AudioService().stopEngineSound();
    AudioService().playBackgroundMusic();

    super.dispose();
  }

  void _startRaceSequence() async {
    // Phase 1: Chờ 1 giây ở trạng thái "Get Ready"
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      isRacing = true;
    });

    // Bắt đầu animation đường chạy
    _roadController.repeat();

    // Phase 2: Bắt đầu đua
    // Cập nhật vị trí mỗi 50ms
    _raceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int i = 0; i < 3; i++) {
          // Nếu đã có người thắng
          if (raceFinished) {
            // Xe thắng chạy vút qua (victory run)
            if (winnerIndex == i) {
              positions[i] += 0.04; // Chạy nhanh qua đích
            } else {
              // Các xe thua vẫn trôi nhẹ (quán tính) chứ không đừng khựng lại
              positions[i] += 0.01;
            }
            continue;
          }

          // Tốc độ ngẫu nhiên: cơ bản + biến thiên
          // Đảm bảo đua nhanh hơn (khoảng 2-3 giây)
          double moveStep = 0.015 + _random.nextDouble() * 0.02;
          positions[i] += moveStep;
          // Cập nhật display (chỉ khi chưa kết thúc)
          displayPositions[i] = positions[i].clamp(0.0, 1.0);

          // Kiểm tra về đích
          if (positions[i] >= 1.0) {
            // Xác nhận người thắng và FREEZE displayPositions
            setState(() {
              raceFinished = true;
              winnerIndex = i;
              // Freeze vị trí hiển thị tại thời điểm kết thúc
              displayPositions = positions
                  .map((p) => p.clamp(0.0, 1.0))
                  .toList();
            });

            // Cho phép chạy tiếp 2 giây mới dừng hẳn
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _stopRaceCompletely();
            });
            break;
          }
        }
      });
    });
  }

  void _stopRaceCompletely() {
    _raceTimer?.cancel();
    _roadController.stop(); // Dừng đường chạy
    if (!mounted) return;

    setState(() {
      isRacing = false;
    });

    // Tạo kết quả và chuyển màn hình
    final result = RaceResult(
      winnerIndex: winnerIndex!,
      bets: widget.raceData.bets,
      racerNames: widget.raceData.racerNames,
      carImages: widget.raceData.carImages,
      previousMoney: widget.raceData.totalMoney,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: result),
      ),
    );
  }

  // Hàm cũ _finishRace không dùng nữa, thay bằng _stopRaceCompletely
  /* void _finishRace(int winner) { ... } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image - phủ toàn màn hình
          _buildBackGround(),
          // Nội dung chính nằm trên background
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(flex: 5, child: _buildRaceTrack()),
                const SizedBox(height: 15),
                _buildStatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (raceFinished && winnerIndex != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    '${widget.raceData.racerNames[winnerIndex!]} WINS!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isRacing ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Text(
                isRacing ? '🏁 RACING...' : '🚦 GET READY...',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackGround() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRaceTrack() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            // Vạch đích (Finish Line)
            _buildFinishLine(),

            // Phần lanes (đường đua dọc)
            Expanded(
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(child: _buildLane(i)),
                    if (i < 2) _buildLaneDivider(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaneDivider() {
    return Container(width: 3, color: Colors.yellow.shade700);
  }

  Widget _buildFinishLine() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (int i = 0; i < 10; i++)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: i % 2 == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: i % 2 == 0 ? Colors.black : Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: i % 2 == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLane(int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính toán vị trí xe
        double trackHeight = constraints.maxHeight;
        double carPosition = positions[index] * trackHeight;

        // Rung lắc nhẹ khi đang đua (Vibration)
        double jitterX = 0;
        if (isRacing) {
          jitterX = (_random.nextDouble() - 0.5) * 2.0; // +/- 1.0 pixel
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.grey.shade700, Colors.grey.shade800],
            ),
          ),
          child: Stack(
            clipBehavior:
                Clip.none, // Cho phép xe chạy lố lên vạch đích (overflow)
            children: [
              // Vạch kẻ đường (Road Markings) - Animated Scrolling - CENTER trong lane
              Center(
                child: AnimatedBuilder(
                  animation: _roadController,
                  builder: (context, child) {
                    // Di chuyển từ -40 đến 0
                    return Transform.translate(
                      offset: Offset(0, _roadController.value * 50),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      // Vẽ dư ra một chút ở trên để khi scroll xuống không bị hở
                      for (int i = -1; i < 15; i++)
                        Container(
                          width: 3,
                          height: 30,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Xe đua (Car) - Positioned giờ là con trực tiếp của Stack
              Positioned(
                bottom: 10 + carPosition,
                left: jitterX,
                right: jitterX,
                child: _buildCar(index),
              ),

              // Trophy
              if (raceFinished && winnerIndex == index)
                const Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text('🏆', style: TextStyle(fontSize: 28)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCar(int index) {
    return Center(
      child: RotatedBox(
        quarterTurns: 3,
        child: Container(
          width: 70,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: carColors[index].withOpacity(0.4),
                blurRadius: isRacing ? 12 : 5,
                spreadRadius: isRacing ? 2 : 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.raceData.carImages[index],
              width: 70,
              height: 45,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 45,
                  decoration: BoxDecoration(
                    color: carColors[index],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon xe + tiền cược
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          widget.raceData.carImages[i],
                          width: 30,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.directions_car,
                            color: carColors[i],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge tiền cược
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: carColors[i],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '\$${widget.raceData.bets[i]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar + percentage
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: displayPositions[i],
                                backgroundColor: Colors.grey.shade700,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  carColors[i],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(displayPositions[i] * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
