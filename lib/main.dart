import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          primary: const Color(0xFF1B4D3E),
          surface: const Color(0xFFF9FBF9),
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class ActionItem {
  final String id;
  final String title;
  final int points;
  final IconData icon;
  final String category;
  final String? remedy;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.title,
    required this.points,
    required this.icon,
    required this.category,
    this.remedy,
    this.isCompleted = false,
  });
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // الرصيد التراكمي المحفوظ على مدار الزمن
  int _totalGoodPoints = 0;
  int _totalBadPoints = 0;

  int get _lifetimeNetScore => _totalGoodPoints - _totalBadPoints;

  final List<ActionItem> _allActions = [
    // 1. اليومي والأسبوعي
    ActionItem(id: 'd1', title: 'صلاة الفجر في وقتها', points: 15, icon: Icons.alarm, category: 'daily'),
    ActionItem(id: 'd2', title: 'الصلوات المفروضة جماعة وفي وقتها', points: 40, icon: Icons.mosque, category: 'daily'),
    ActionItem(id: 'd3', title: 'السنن الرواتب والشفع والوتر', points: 15, icon: Icons.spa, category: 'daily'),
    ActionItem(id: 'd4', title: 'صلاة الضحى', points: 8, icon: Icons.wb_sunny_outlined, category: 'daily'),
    ActionItem(id: 'd5', title: 'ورد القرآن اليومي (حزب أو جزء)', points: 15, icon: Icons.menu_book, category: 'daily'),
    ActionItem(id: 'd6', title: 'أذكار الصباح والمساء', points: 12, icon: Icons.wb_twilight, category: 'daily'),
    ActionItem(id: 'd7', title: 'الاستغفار والصلاة على النبي (100 مرة)', points: 10, icon: Icons.repeat, category: 'daily'),
    ActionItem(id: 'd8', title: 'بر الوالدين والإحسان لهما', points: 25, icon: Icons.favorite, category: 'daily'),
    ActionItem(id: 'd9', title: 'صدقة مالية أو إطعام محتاج', points: 15, icon: Icons.volunteer_activism, category: 'daily'),
    ActionItem(id: 'd10', title: 'إتقان العمل والوظيفة بأمانة', points: 15, icon: Icons.work_outline, category: 'daily'),
    ActionItem(id: 'd11', title: 'كظم الغيظ وحفظ اللسان وغض البصر', points: 15, icon: Icons.visibility_off_outlined, category: 'daily'),
    ActionItem(id: 'd12', title: 'التبكير لصلاة الجمعة وسورة الكهف', points: 30, icon: Icons.auto_awesome, category: 'daily'),

    // 2. المواسم والنفحات
    ActionItem(id: 's1', title: 'صيام يوم من رمضان', points: 60, icon: Icons.nights_stay, category: 'seasons'),
    ActionItem(id: 's2', title: 'إحياء ليلة القدر / العشر الأواخر', points: 250, icon: Icons.star_border_purple500, category: 'seasons'),
    ActionItem(id: 's3', title: 'صيام يوم عرفة', points: 120, icon: Icons.cloud_done_outlined, category: 'seasons'),
    ActionItem(id: 's4', title: 'صيام يوم عاشوراء', points: 80, icon: Icons.shield, category: 'seasons'),
    ActionItem(id: 's5', title: 'أداء فريضة الحج (حج مبرور)', points: 400, icon: Icons.apartment, category: 'seasons'),
    ActionItem(id: 's6', title: 'أداء مناسك العمرة', points: 120, icon: Icons.temple_buddhist, category: 'seasons'),
    ActionItem(id: 's7', title: 'ذبح الأضحية وتوزيعها في العيد', points: 100, icon: Icons.card_giftcard, category: 'seasons'),
    ActionItem(id: 's8', title: 'إخراج زكاة الفطر', points: 30, icon: Icons.redeem, category: 'seasons'),

    // 3. أمهات القربات
    ActionItem(id: 'mg1', title: 'الرباط والجهاد بالمال والنفس', points: 500, icon: Icons.security, category: 'major_good'),
    ActionItem(id: 'mg2', title: 'ملازمة الوالدين عند الكبر والمرض', points: 200, icon: Icons.elderly, category: 'major_good'),
    ActionItem(id: 'mg3', title: 'كفالة يتيم ورعايته', points: 150, icon: Icons.child_care, category: 'major_good'),
    ActionItem(id: 'mg4', title: 'إصلاح ذات البين وإنهاء خصومة', points: 150, icon: Icons.handshake, category: 'major_good'),
    ActionItem(id: 'mg5', title: 'تفريج كربة معسرة كبرى / صدقة جارية', points: 150, icon: Icons.all_inclusive, category: 'major_good'),
    ActionItem(id: 'mg6', title: 'العفو والصفح عند المقدرة التامة', points: 120, icon: Icons.sentiment_very_satisfied, category: 'major_good'),

    // 4. المحاسبة والزلات
    ActionItem(id: 'sin1', title: 'تأخير صلاة عن وقتها عمداً', points: -20, icon: Icons.error_outline, category: 'sins', remedy: 'صلِّ الفريضة قضاءً الآن فوراً + استغفار 30 مرة'),
    ActionItem(id: 'sin2', title: 'ترك صلاة فريضة حتى خروج وقتها', points: -40, icon: Icons.cancel_outlined, category: 'sins', remedy: 'قضاء فوراً + ركعتا توبة نصوح'),
    ActionItem(id: 'sin3', title: 'غيبة وتتبع عورات المسلمين', points: -25, icon: Icons.record_voice_over_outlined, category: 'sins', remedy: 'ادعُ للمغتاب بظهر الغيب + تصدق بنية التكفير'),
    ActionItem(id: 'sin4', title: 'نميمة ونقل كلام للإفساد', points: -30, icon: Icons.hearing_disabled, category: 'sins', remedy: 'إصلاح ما أفسدته بالاعتذار وتكذيب الإشاعة'),
    ActionItem(id: 'sin5', title: 'كذب أو إخلاف عهد', points: -20, icon: Icons.gavel, category: 'sins', remedy: 'قول الصدق وإصلاح الأثر فوراً'),
    ActionItem(id: 'sin6', title: 'إطلاق البصر في محرم', points: -15, icon: Icons.visibility_off, category: 'sins', remedy: 'وضوء وركعتا توبة و100 استغفار بالسبحة'),
    ActionItem(id: 'sin7', title: 'غضب وإهانة وجرح إنسان', points: -18, icon: Icons.mood_bad, category: 'sins', remedy: 'اعتذار مباشر وجبر خاطر الشخص'),
    ActionItem(id: 'sin8', title: 'إضاعة ساعات في لهو فارغ', points: -10, icon: Icons.hourglass_disabled, category: 'sins', remedy: 'قراءة 5 صفحات قرآن استدراكاً للوقت'),

    // 5. الكبائر والموبقات
    ActionItem(id: 'ms1', title: 'الشرك بالله أو الرياء المطبق', points: -500, icon: Icons.dangerous, category: 'major_sins', remedy: 'تجديد الشهادتين وتوبة نصوح من القلب'),
    ActionItem(id: 'ms2', title: 'أكل الحرام (رشوة، سرقة، ربا)', points: -200, icon: Icons.money_off, category: 'major_sins', remedy: 'إرجاع المال لأهله فوراً أو التصدق به إن تعذر'),
    ActionItem(id: 'ms3', title: 'عقوق الوالدين الصارخ أو إيذاؤهما', points: -250, icon: Icons.priority_high, category: 'major_sins', remedy: 'طلب الرضا على الركب وتقبيل أيديهما ورأسهما'),
    ActionItem(id: 'ms4', title: 'شهادة الزور واليمين الغموس', points: -200, icon: Icons.warning, category: 'major_sins', remedy: 'الرجوع عن الشهادة فوراً وتبرئة المظلوم'),
    ActionItem(id: 'ms5', title: 'أكل مال اليتيم أو استغلال ضعفه', points: -250, icon: Icons.block, category: 'major_sins', remedy: 'رد كامل الحقوق لليتيم والتحلل منه'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadLifetimeScores();
  }

  // تحميل الرصيد المحفوظ من ذاكرة الهاتف
  Future<void> _loadLifetimeScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalGoodPoints = prefs.getInt('total_good_points') ?? 0;
      _totalBadPoints = prefs.getInt('total_bad_points') ?? 0;
    });
  }

  // حفظ الرصيد في ذاكرة الهاتف
  Future<void> _saveLifetimeScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_good_points', _totalGoodPoints);
    await prefs.setInt('total_bad_points', _totalBadPoints);
  }

  void _onToggleAction(ActionItem item, bool? val) {
    final bool isChecked = val ?? false;
    setState(() {
      item.isCompleted = isChecked;
      if (item.points > 0) {
        if (isChecked) {
          _totalGoodPoints += item.points;
        } else {
          _totalGoodPoints -= item.points;
        }
      } else {
        if (isChecked) {
          _totalBadPoints += item.points.abs();
        } else {
          _totalBadPoints -= item.points.abs();
        }
      }
    });

    _saveLifetimeScores();

    if (item.points < 0 && item.isCompleted && item.remedy != null) {
      _showRemedyDialog(item);
    }
  }

  void _showRemedyDialog(ActionItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 50, color: Colors.orange),
              const SizedBox(height: 10),
              const Text('﴿إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ﴾', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E))),
              const SizedBox(height: 8),
              Text('سُجلت: (${item.title})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.remedy!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    item.isCompleted = false;
                    _totalBadPoints -= item.points.abs();
                    if (_totalBadPoints < 0) _totalBadPoints = 0;
                  });
                  _saveLifetimeScores();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4D3E), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(45)),
                child: const Text('أتممتُ العمل المكفِّر ومحوتُ الأثر بفضل الله'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ميزان الأعمال الشامل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF1B4D3E),
            indicatorColor: const Color(0xFF1B4D3E),
            tabs: const [
              Tab(text: 'اليومي والأسبوعي'),
              Tab(text: 'المواسم والنفحات'),
              Tab(text: 'أفضل القربات'),
              Tab(text: 'المحاسبة والزلات'),
              Tab(text: 'الكبائر والموبقات'),
            ],
          ),
        ),
        body: Column(
          children: [
            // بطاقة الرصيد التراكمي الشامل (Total Score)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1B4D3E), Color(0xFF2C7A5E)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1B4D3E).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
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
                          const Text('رصيدك التراكمي الشامل', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            _lifetimeNetScore >= 0 ? 'ميزانك العام رابح ✨' : 'راجع حساباتك واستغفر ⚠️',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${_lifetimeNetScore > 0 ? "+" : ""}$_lifetimeNetScore',
                        style: TextStyle(
                          color: _lifetimeNetScore >= 0 ? Colors.white : Colors.redAccent.shade100,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Color(0xFF68D391), size: 18),
                          const SizedBox(width: 4),
                          Text('إجمالي الحسنات: +$_totalGoodPoints', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(width: 1, height: 16, color: Colors.white24),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, color: Color(0xFFFC8181), size: 18),
                          const SizedBox(width: 4),
                          Text('إجمالي الزلات: -$_totalBadPoints', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList('daily', Colors.green.shade50),
                  _buildList('seasons', Colors.amber.shade50),
                  _buildList('major_good', Colors.teal.shade50),
                  _buildList('sins', Colors.orange.shade50),
                  _buildList('major_sins', Colors.red.shade50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String category, Color bgColor) {
    final list = _allActions.where((a) => a.category == category).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final item = list[i];
        final isNegative = item.points < 0;
        return Card(
          elevation: 0,
          color: item.isCompleted ? bgColor : Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: item.isCompleted ? (isNegative ? Colors.red : const Color(0xFF1B4D3E)) : Colors.grey.shade200),
          ),
          child: ListTile(
            leading: Icon(item.icon, color: isNegative ? Colors.redAccent : const Color(0xFF1B4D3E)),
            title: Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, decoration: item.isCompleted && !isNegative ? TextDecoration.lineThrough : null)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.points > 0 ? "+" : ""}${item.points}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isNegative ? Colors.red : const Color(0xFF1B4D3E), fontSize: 14),
                ),
                Checkbox(
                  value: item.isCompleted,
                  activeColor: isNegative ? Colors.red : const Color(0xFF1B4D3E),
                  onChanged: (val) => _onToggleAction(item, val),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
