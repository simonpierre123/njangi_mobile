import 'package:flutter/material.dart';
import 'tab_ma_tresorerie.dart';
import 'tab_contributions.dart';
import 'tab_prets.dart';

class TresorerieScreen extends StatefulWidget {
  const TresorerieScreen({super.key});

  @override
  State<TresorerieScreen> createState() => _TresorerieScreenState();
}

class _TresorerieScreenState extends State<TresorerieScreen> {
  int _activeSubTabIndex = 1; // Commencer sur "Contributions" par défaut

  final List<String> _tabs = ["Ma Trésorerie", "Contributions", "Prêts"];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5E4E);
    const textDark = Color(0xFF1C2D27);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.hub_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Famille Bamiléké", style: TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.bold)),
                Text("Cycle 8/12", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Les Sous-onglets de navigation horizontaux
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2EE),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isActive = _activeSubTabIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeSubTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isActive ? Colors.white : primaryGreen,
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // 2. Contenu Dynamique de l'onglet actif
          Expanded(
            child: IndexedStack(
              index: _activeSubTabIndex,
              children: const [
                TabMaTresorerie(),
                TabContributions(),
                TabPrets(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}