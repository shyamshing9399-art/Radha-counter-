import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const NamJapApp());
}

class NamJapApp extends StatelessWidget {
  const NamJapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'नाम जप काउंटर',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[50],
      ),
      home: const CounterHomeScreen(),
    );
  }
}

class CounterHomeScreen extends StatefulWidget {
  const CounterHomeScreen({super.key});

  @override
  State<CounterHomeScreen> createState() => _CounterHomeScreenState();
}

class _CounterHomeScreenState extends State<CounterHomeScreen> {
  String selectedName = "राधा";
  final List<String> namesList = ["राधा", "कृष्ण", "राधा कृष्ण", "राम", "ॐ नमः शिवाय"];
  
  int totalCount = 0;
  String currentDisplayMessage = "";
  
  // History storage map: Date (yyyy-MM-dd) -> Count
  Map<String, int> dailyHistory = {};
  
  // Simulated wallpaper background option
  String currentWallpaper = "assets/default_bg.png"; // Placeholder for image logic

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load saved data locally
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCount = prefs.getInt('total_count') ?? 0;
      selectedName = prefs.getString('selected_name') ?? "राधा";
    });
  }

  // Save count and history
  Future<void> _incrementCount() async {
    HapticFeedback.mediumImpact(); // Gentle vibration on tap
    
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    setState(() {
      totalCount++;
      currentDisplayMessage = "$selectedName जप जारी है...";
      dailyHistory[todayDate] = (dailyHistory[todayDate] ?? 0) + 1;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_count', totalCount);
    await prefs.setString('selected_name', selectedName);
  }

  @override
  Widget build(BuildContext context) {
    String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int todayCount = dailyHistory[todayKey] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 नाम जप काउंटर 🌸', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.deepOrange.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            
            // 1. Upar Name Selection Section
            const Text(
              "पवित्र नाम चुनें:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.brown),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: namesList.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedName == namesList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(namesList[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      selected: isSelected,
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedName = namesList[index];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 10),

            // 2. Main Bada Tap Area & Counter Display
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: _incrementCount,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.deepOrange.shade300, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedName,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$totalCount",
                          style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.w900,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentDisplayMessage.isEmpty ? "Tap karke jaap shuru karein" : currentDisplayMessage,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 3. Niche Daily History / Stats Section
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        const Text(
                          "📅 दैनिक इतिहास (Daily History)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        Text(
                          "Aaj: $todayCount",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: dailyHistory.isEmpty
                          chno: const Center(child: Text("Abhi tak koi data nahi hai."))
                          : ListView(
                              children: dailyHistory.entries.map((entry) {
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.calendar_today, color: Colors.deepOrange, size: 18),
                                  title: Text("Tarik: ${entry.key}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                  trailing: Text("${entry.value} Baar", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
