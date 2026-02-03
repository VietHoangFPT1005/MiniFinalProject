import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/race_data.dart';
import '../services/audio_service.dart';
import 'race_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialMoney;
  const HomeScreen({super.key, this.initialMoney = 100});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int totalMoney;
  List<int> bets = [0, 0, 0];
  late List<TextEditingController> controllers;

  final List<Color> carColors = [Colors.red, Colors.blue, Colors.amber];

  @override
  void initState() {
    super.initState();
    totalMoney = widget.initialMoney;
    controllers = List.generate(3, (_) => TextEditingController(text: '0'));
    
    // Phát background music khi vào Home Screen
    AudioService().playBackgroundMusic();
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    // Không cần dừng background music ở đây
    // Để race_screen tự quản lý khi vào
    super.dispose();
  }

  int get totalBets => bets.reduce((a, b) => a + b);
  bool get canStartRace => totalBets > 0 && totalBets <= totalMoney;

  int remainingMoney(int index) {
    return totalMoney - (totalBets - bets[index]);
  }

  void _updateBet(int index, int value) {
    // Phát âm thanh click
    AudioService().playClickSound();
    
    setState(() {
      bets[index] = value.clamp(0, remainingMoney(index));
      controllers[index].text = bets[index].toString();
    });
  }

  void _startRace() {
    if (!canStartRace) return;

    AudioService().playClickSound();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceScreen(
          raceData: RaceData(
            totalMoney: totalMoney,
            bets: List.from(bets),
          ),
        ),
      ),
    ).then((newMoney) {
      if (newMoney != null) {
        setState(() {
          totalMoney = newMoney;
          bets = [0, 0, 0];
          for (var c in controllers) {
            c.text = '0';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background giống RaceScreen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMoneyCard(),
                  const SizedBox(height: 25),
                  _buildBettingSection(),
                  const SizedBox(height: 25),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: const Text(
        '🚦 PLACE YOUR BETS',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMoneyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet,
              color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            '\$$totalMoney',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBettingSection() {
    return Column(
      children: List.generate(3, (i) => _buildBetRow(i)),
    );
  }

  Widget _buildBetRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: carColors[index], width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car,
              color: carColors[index], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'CAR ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _betButton(
            icon: Icons.remove,
            color: Colors.red,
            onTap: bets[index] > 0
                ? () => _updateBet(index, bets[index] - 10)
                : null,
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controllers[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (v) {
                final value = int.tryParse(v) ?? 0;
                _updateBet(index, value);
              },
            ),
          ),
          _betButton(
            icon: Icons.add,
            color: Colors.green,
            onTap: remainingMoney(index) >= 10
                ? () => _updateBet(index, bets[index] + 10)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _betButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null ? color : Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        color: canStartRace ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: canStartRace ? Colors.greenAccent : Colors.grey,
          width: 2,
        ),
      ),
      child: TextButton(
        onPressed: canStartRace ? _startRace : null,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Text(
            'START RACE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
