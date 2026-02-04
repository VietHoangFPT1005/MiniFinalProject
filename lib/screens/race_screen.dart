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

  List<double> positions = [0.0, 0.0, 0.0];

  List<double> displayPositions = [0.0, 0.0, 0.0];

  final carColors = [Colors.red, Colors.blue, Colors.amber];

  Timer? _raceTimer;
  final Random _random = Random();

  late AnimationController _roadController;

  @override
  void initState() {
    super.initState();

    AudioService().stopBackgroundMusic();
    AudioService().playEngineSound();

    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRaceSequence();
    });
  }

  @override
  void dispose() {
    _raceTimer?.cancel();
    _roadController.dispose();

    AudioService().stopEngineSound();

    super.dispose();
  }

  void _startRaceSequence() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      isRacing = true;
    });

    _roadController.repeat();

    _raceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int i = 0; i < 3; i++) {
          if (raceFinished) {
            if (winnerIndex == i) {
              positions[i] += 0.04;
            } else {
              positions[i] += 0.01;
            }
            continue;
          }

          double moveStep = 0.015 + _random.nextDouble() * 0.02;
          positions[i] += moveStep;
          displayPositions[i] = positions[i].clamp(0.0, 1.0);

          if (positions[i] >= 1.0) {
            setState(() {
              raceFinished = true;
              winnerIndex = i;
              displayPositions = positions
                  .map((p) => p.clamp(0.0, 1.0))
                  .toList();
            });

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
    _roadController.stop();
    if (!mounted) return;

    setState(() {
      isRacing = false;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackGround(),
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
            _buildFinishLine(),
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
        double trackHeight = constraints.maxHeight;
        double carPosition = positions[index] * trackHeight;

        double jitterX = 0;
        if (isRacing) {
          jitterX = (_random.nextDouble() - 0.5) * 2.0;
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
                Clip.none,
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: _roadController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _roadController.value * 50),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
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

              Positioned(
                bottom: 10 + carPosition,
                left: jitterX,
                right: jitterX,
                child: _buildCar(index),
              ),

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
