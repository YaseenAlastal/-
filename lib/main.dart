import 'package:flutter/material.dart';

void main() {
  runApp(const MeezanApp());
}

class MeezanApp extends StatelessWidget {
  const MeezanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ميزان الأعمال',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.light,
          primary: const Color(0xFF1B4D3E),
          surface: const Color(0xFFF9FBF9),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class ActionItem {
  final String id;
  final String title;
  final int points;
  final IconData icon;
  final String category;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.title,
    required this.points,
    required this.icon,
    required this.category,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ActionItem> _goodDeeds = [
    ActionItem(id: '1', title: 'صلاة الفجر في وقتها', points: 15, icon: Icons.alarm, category: 'فرائض'),
    ActionItem(id: '2', title: 'الصلوات المفروضة (جماعة/في وقتها)', points: 40, icon: Icons.mosque, category: 'فرائض'),
    ActionItem(id: '3', title: 'ورد القرآن الكريم (صفحتان فأكثر)', points: 15, icon: Icons.menu_book, category: 'قرآن وذكر'),
    ActionItem(id: '4', title: 'أذكار الصباح والمساء', points: 12, icon: Icons.wb_sunny_outlined, category: 'قرآن وذكر'),
    ActionItem(id: '5', title: 'بر الوالدين وخدمتهما', points: 25, icon: Icons.favorite, category: 'معاملات'),
    ActionItem(id: '6', title: 'صدقة أو تفريج كربة', points: 20, icon: Icons.volunteer_activism, category: 'معاملات'),
    ActionItem(id: '7', title: 'السنن الرواتب والشفع والوتر', points: 15, icon: Icons.spa, category: 'سنن'),
  ];

  final List<Map<String, dynamic>> _mistakes = [
    {
      'title': 'تأخير صلاة عن وقتها',
      'points': -20,
      'remedy': 'صلِّ الفريضة قضاءً الآن فوراً + استغفر 30 مرة',
    },
    {
      'title': 'غيبة أو حديث في عرض مسلم',
      'points': -25,
      'remedy': 'ادعُ للمغتاب بظهر الغيب + تصدق بنية التكفير',
    },
    {
      'title': 'إطلاق البصر في محرم',
      'points': -15,
      'remedy': 'توضأ وصلِّ ركعتي توبة واستغفر 70 مرة بالسبحة',
    },
    {
      'title': 'غضب جارح أو خصومة',
      'points': -15,
      'remedy': 'أرسل رسالة اعتذار أو تودد للشخص الآن فوراً',
    },
    {
      'title': 'إضاعة ساعات في لهو فارغ',
      'points': -10,
      'remedy': 'اقرأ 5 صفحات قرآن تعويضاً عن الوقت الضائع',
    },
  ];

  int _mistakesPenalty = 0;
  final int _streakDays = 5;

  int get _goodPoints {
    return _goodDeeds
        .where((item) => item.isCompleted)
        .fold(0, (sum, item) => sum + item.points);
  }

  int get _netScore => _goodPoints - _mistakesPenalty;

  void _recordMistake(String title, int points, String remedy) {
    setState(() {
      _mistakesPenalty += points.abs();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.shield_outlined, size: 55, color: Colors.orange),
                const SizedBox(height: 12),
                const Text(
                  '﴿إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ﴾',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4D3E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سُجلت الزلة: ($title). لا تيأس، باب الاستدراك والمحو مفتوح فوراً!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          remedy,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mistakesPenalty -= points.abs();
                      if (_mistakesPenalty < 0) _mistakesPenalty = 0;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('أحسنت! تم محو الزلة وعودة كفة ميزانك بفضل الله.'),
                        backgroundColor: Color(0xFF1B4D3E),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('أتممتُ العمل المكفِّر ومحوتُ الزلة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D3E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMistakesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'محاسبة النفس ومكافحة الزلل',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'الاعتراف بالذنب أول خطوات المحو والاستقامة',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                ..._mistakes.map((m) => Card(
                      elevation: 0,
                      color: Colors.red.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                      child: ListTile(
                        title: Text(m['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        trailing: Text('${m['points']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _recordMistake(m['title'], m['points'], m['remedy']);
                        },
                      ),
                    )),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ميزان الأعمال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
                  const SizedBox(width: 4),
                  Text('$_streakDays أيام استمرار', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrange)),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildSeasonBanner(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('طاعاتك اليومية المقترحة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${_goodDeeds.where((d) => d.isCompleted).length} من ${_goodDeeds.length}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              ..._goodDeeds.map((deed) => _buildDeedTile(deed)),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                onPressed: _openMistakesSheet,
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                label: const Text('سجل زلة أو تقصيراً لمسحه وتداركه فوراً', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    double progress = (_netScore / 120).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4D3E), Color(0xFF2C7A5E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B4D3E).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مؤشر كفتك اليوم', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    _netScore >= 60 ? 'كفتك رابحة ومباركة ✨' : 'بادر لترجيح الميزان ⚖️',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '$_netScore+',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF68D391)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF1B4D3E), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'نفحة اليوم: صيام النافلة أو صلة رحم ترفع ميزانك اليوم +25 نقطة إضافية!',
              style: TextStyle(fontSize: 12, color: Color(0xFF1B4D3E), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeedTile(ActionItem deed) {
    return Card(
      elevation: 0,
      color: deed.isCompleted ? const Color(0xFFF4F9F6) : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: deed.isCompleted ? const Color(0xFF1B4D3E).withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: deed.isCompleted ? const Color(0xFF1B4D3E) : Colors.grey.shade100,
          foregroundColor: deed.isCompleted ? Colors.white : Colors.black87,
          child: Icon(deed.icon, size: 20),
        ),
        title: Text(
          deed.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: deed.isCompleted ? TextDecoration.lineThrough : null,
            color: deed.isCompleted ? Colors.grey[600] : Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${deed.points}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E), fontSize: 14),
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: deed.isCompleted,
              activeColor: const Color(0xFF1B4D3E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) {
                setState(() {
                  deed.isCompleted = val ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
