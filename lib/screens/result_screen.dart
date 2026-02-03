import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/race_data.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final RaceResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final audioService = AudioService();
  late int newMoney;
  late bool didWin;

  final List<Color> carColors = [Colors.red, Colors.blue, Colors.amber];

  @override
  void initState() {
    super.initState();
    newMoney = widget.result.calculateNewMoney();
    didWin = widget.result.bets[widget.result.winnerIndex] > 0;

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Hiệu ứng thắng/thua
    if (didWin) {
      _confettiController.play();
      audioService.playWinSound();
    } else {
      audioService.playLoseSound();
    }

    _slideController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: didWin
                    ? [Colors.green.shade800, Colors.teal.shade900]
                    : [Colors.red.shade800, Colors.grey.shade900],
              ),
            ),
          ),

          // Nội dung chính
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildResultHeader(),
                    const SizedBox(height: 30),
                    _buildWinnerCard(),
                    const SizedBox(height: 30),
                    _buildStatsTable(),
                    const SizedBox(height: 30),
                    _buildMoneyCard(),
                    const SizedBox(height: 40),
                    _buildButtons(),
                  ],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Text(
          didWin ? '🎉 YOU WON! 🎉' : '😢 YOU LOST',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          didWin ? 'Congratulations!' : 'Better luck next time!',
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildWinnerCard() {
    int winner = widget.result.winnerIndex;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 WINNER 🏆',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 15),
          Image.asset(
            widget.result.carImages[winner],
            width: 100,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.directions_car,
              size: 60,
              color: carColors[winner],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.result.racerNames[winner],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'RACER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'BET',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'RESULT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '+/-',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          for (int i = 0; i < 3; i++) _buildStatRow(i),
        ],
      ),
    );
  }

  Widget _buildStatRow(int index) {
    bool isWinner = index == widget.result.winnerIndex;
    int bet = widget.result.bets[index];
    int profit = isWinner ? bet : -bet;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green.withOpacity(0.2) : Colors.transparent,
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Image.asset(
                  widget.result.carImages[index],
                  width: 35,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.directions_car,
                    color: carColors[index],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.result.racerNames[index],
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '\$$bet',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWinner
                    ? Colors.green
                    : (bet > 0 ? Colors.red : Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isWinner ? 'WIN' : (bet > 0 ? 'LOSE' : '-'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              bet > 0
                  ? (profit > 0 ? '+\$$profit' : '-\$${profit.abs()}')
                  : '-',
              style: TextStyle(
                color: profit > 0
                    ? Colors.green
                    : (bet > 0 ? Colors.red : Colors.grey),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard() {
    int change = newMoney - widget.result.previousMoney;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.purple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Previous:', style: TextStyle(color: Colors.white70)),
              Text(
                '\$${widget.result.previousMoney}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Change:', style: TextStyle(color: Colors.white70)),
              Text(
                change >= 0 ? '+\$$change' : '-\$${change.abs()}',
                style: TextStyle(
                  color:
                  change >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.amber,
                size: 30,
              ),
              const SizedBox(width: 15),
              Text(
                '\$$newMoney',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Nút Play Again
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: newMoney > 0
                ? () {
              audioService.playClickSound();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(initialMoney: newMoney),
                ),
                    (route) => false,
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Game Over nếu hết tiền
        if (newMoney <= 0)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Text(
                  '💸 GAME OVER 💸',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You ran out of money!',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
      ],
    );
  }
}