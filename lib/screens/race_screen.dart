import 'package:flutter/material.dart';
import 'package:prm232_mini_final_project/models/race_data.dart';

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

  // Vị trí xe (0.0 -> 1.0)
  List<double> positions = [0.0, 0.0, 0.0];

  // Màu xe và ảnh xe
  final carColors = [Colors.red, Colors.blue, Colors.amber];

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
                    color: Colors.amber.withValues(alpha: 0.5),
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
                color: Colors.black.withValues(alpha: 0.6),
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
        color: Colors.grey.shade800.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Row(
          children: [
            // Phần lanes
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    Expanded(child: _buildLane(i)),
                    if (i < 2) _buildLaneDivider(),
                  ],
                ],
              ),
            ),
            // Vạch đích
            _buildFinishLine(),
          ],
        ),
      ),
    );
  }

  // Viền vàng giữa các lane
  Widget _buildLaneDivider() {
    return Container(height: 3, color: Colors.yellow.shade700);
  }

  // Vạch đích sọc đen trắng kiểu bàn cờ (checkered)
  Widget _buildFinishLine() {
    return SizedBox(
      width: 30,
      child: Column(
        children: [
          for (int i = 0; i < 20; i++)
            Expanded(
              child: Row(
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
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLane(int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade700, Colors.grey.shade800],
        ),
      ),
      child: Stack(
        children: [
          // Vạch kẻ đường nét đứt ở giữa
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 8; i++)
                  Container(
                    width: 25,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),

          // Xe đua (dùng LayoutBuilder để tính vị trí theo progress)
          LayoutBuilder(
            builder: (context, constraints) {
              double trackWidth = constraints.maxWidth - 100;
              double carPosition = positions[index] * trackWidth;

              return Positioned(
                left: 10 + carPosition,
                top: 0,
                bottom: 0,
                child: _buildCar(index),
              );
            },
          ),

          // Trophy cho người thắng
          if (raceFinished && winnerIndex == index)
            const Positioned(
              right: 45,
              top: 0,
              bottom: 0,
              child: Center(child: Text('🏆', style: TextStyle(fontSize: 28))),
            ),
        ],
      ),
    );
  }

  // Widget xe đua tách riêng
  Widget _buildCar(int index) {
    return Center(
      child: Container(
        width: 70,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: carColors[index].withValues(alpha: 0.4),
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
            errorBuilder: (_, __, ___) {
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
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
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
                    // Icon xe + tiền cược + phần trăm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          widget.raceData.carImages[i],
                          width: 30,
                          height: 20,
                          errorBuilder: (_, __, ___) => Icon(
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
                        const SizedBox(width: 8),
                        Text(
                          '${(positions[i] * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: positions[i],
                          backgroundColor: Colors.grey.shade700,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            carColors[i],
                          ),
                        ),
                      ),
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
