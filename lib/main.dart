import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          surface: const Color(0xFFF8FAF9),
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
  final String? hadithProof;
  final String? remedy;
  bool isCompleted;

  ActionItem({
    required this.id,
    required this.title,
    required this.points,
    required this.icon,
    required this.category,
    this.hadithProof,
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

  int _totalGoodPoints = 0;
  int _totalBadPoints = 0;

  int get _lifetimeNetScore => _totalGoodPoints - _totalBadPoints;

  final List<ActionItem> _allActions = [
    // 1. الفرائض واليوميات الأساسية
    ActionItem(
      id: 'd_fajr',
      title: 'صلاة الفجر في وقتها',
      points: 80,
      icon: Icons.wb_twilight,
      category: 'daily',
      hadithProof: '«من صلى الصبح فهو في ذمة الله» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'd_cong_prayers',
      title: 'أداء الصلوات الخمس في جماعة المسجد',
      points: 135,
      icon: Icons.mosque,
      category: 'daily',
      hadithProof: '«صلاة الجماعة تفضل صلاة الفذ بسبع وعشرين درجة» (متفق عليه)',
    ),
    ActionItem(
      id: 'd_solo_prayers',
      title: 'الصلوات المفروضة منفردة في وقتها',
      points: 50,
      icon: Icons.check_circle_outline,
      category: 'daily',
      hadithProof: '«أحب الأعمال إلى الله الصلاة لوقتها» (متفق عليه)',
    ),
    ActionItem(
      id: 'd_sunan',
      title: 'السنن الرواتب (12 ركعة يومياً)',
      points: 30,
      icon: Icons.nature_people,
      category: 'daily',
      hadithProof: '«بُنِيَ له بيت في الجنة» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'd_night_prayer',
      title: 'قيام الليل والشفع والوتر',
      points: 60,
      icon: Icons.nights_stay,
      category: 'daily',
      hadithProof: '«أفضل الصلاة بعد الفريضة صلاة الليل» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'd_quran',
      title: 'ورد تلاوة القرآن بتدبر (جزء أو حزب)',
      points: 40,
      icon: Icons.menu_book,
      category: 'daily',
      hadithProof: '«من قرأ حرفاً فله به حسنة والحسنة بعشر أمثالها» (صحيح الترمذي)',
    ),
    ActionItem(
      id: 'd_parents',
      title: 'بر الوالدين وخدمتهما وإدخال السرور عليهما',
      points: 70,
      icon: Icons.favorite,
      category: 'daily',
      hadithProof: '«رضا الرب في رضا الوالد» (صحيح الترمذي)',
    ),
    ActionItem(
      id: 'd_charity',
      title: 'صدقة يومية أو إطعام محتاج أو سقي ماء',
      points: 40,
      icon: Icons.volunteer_activism,
      category: 'daily',
      hadithProof: '«والصدقة تطفئ الخطيئة كما يطفئ الماء النار» (صحيح الترمذي)',
    ),
    ActionItem(
      id: 'd_work_honesty',
      title: 'إتقان العمل الوظيفي والصدق التام بالأمانة',
      points: 35,
      icon: Icons.work_outline,
      category: 'daily',
      hadithProof: '«إن الله يحب إذا عمل أحدكم عملاً أن يتقنه» (صحيح الجامع)',
    ),
    ActionItem(
      id: 'd_gaze_lowering',
      title: 'غض البصر عن المحرمات بمجاهدة نفس',
      points: 30,
      icon: Icons.visibility_off,
      category: 'daily',
      hadithProof: '«اصرف بصرك» (صحيح مسلم)',
    ),

    // 2. كنز الأذكار والأدعية الثقيلة في الميزان
    ActionItem(
      id: 'dh_1',
      title: 'سبحان الله وبحمده (100 مرة)',
      points: 100,
      icon: Icons.auto_awesome,
      category: 'dhikr',
      hadithProof: '«حُطّت خطاياه وإن كانت مثل زبد البحر» (متفق عليه)',
    ),
    ActionItem(
      id: 'dh_2',
      title: 'سبحان الله وبحمده، سبحان الله العظيم (100 مرة)',
      points: 100,
      icon: Icons.balance,
      category: 'dhikr',
      hadithProof: '«كلمتان حبيبتان إلى الرحمن خفيفتان على اللسان ثقيلتان في الميزان» (متفق عليه)',
    ),
    ActionItem(
      id: 'dh_3',
      title: 'سيد الاستغفار مع اليقين به (صباحاً ومساءً)',
      points: 120,
      icon: Icons.shield,
      category: 'dhikr',
      hadithProof: '«من قالها موقناً بها فمات من يومه أو ليلته دخل الجنة» (صحيح البخاري)',
    ),
    ActionItem(
      id: 'dh_4',
      title: 'لا إله إلا الله وحده لا شريك له.. (100 مرة)',
      points: 150,
      icon: Icons.stars,
      category: 'dhikr',
      hadithProof: '«كانت له عدل عشر رقاب وكُتبت له 100 حسنة ومُحيت عنه 100 سيئة» (متفق عليه)',
    ),
    ActionItem(
      id: 'dh_5',
      title: 'الصلاة على النبي ﷺ (100 مرة فأكثر)',
      points: 80,
      icon: Icons.favorite_border,
      category: 'dhikr',
      hadithProof: '«من صلى علي صلاة صلى الله عليه بها عشراً وحط عنه عشر خطيئات» (صحيح النسائي)',
    ),
    ActionItem(
      id: 'dh_6',
      title: 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر (100 مرة)',
      points: 90,
      icon: Icons.all_inclusive,
      category: 'dhikr',
      hadithProof: '«أحب الكلام إلى الله أربع..» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'dh_7',
      title: 'دعاء كفارة المجلس عقب أي لقاء',
      points: 40,
      icon: Icons.cleaning_services,
      category: 'dhikr',
      hadithProof: '«سبحانك اللهم وبحمدك.. غُفر له ما كان في مجلسه ذلك» (صحيح الترمذي)',
    ),

    // 3. الزلات والذنوب اليومية والواقعية
    ActionItem(
      id: 'sin_miss_prayer',
      title: 'تضييع صلاة فريضة حتى خروج وقتها عمداً',
      points: -300,
      icon: Icons.cancel,
      category: 'habits_sins',
      remedy: 'قضاؤها فوراً مع ركعتي توبة وندم وعزم على عدم العود',
    ),
    ActionItem(
      id: 'sin_delay_prayer',
      title: 'تأخير الصلاة عن وقتها الفاضل تكاسلاً',
      points: -60,
      icon: Icons.alarm_off,
      category: 'habits_sins',
      remedy: 'الوضوء وصلاة ركعتين نافلة فوراً',
    ),
    ActionItem(
      id: 'sin_porn',
      title: 'مشاهدة المحرمات أو الأفلام الإباحية',
      points: -200,
      icon: Icons.no_adult_content,
      category: 'habits_sins',
      remedy: 'اغتسال فوراً + صلاة ركعتي توبة + صدقة تطفئ غضب الرب',
    ),
    ActionItem(
      id: 'sin_gaze',
      title: 'إطلاق البصر المتعمد في العورات والمحرمات',
      points: -50,
      icon: Icons.visibility,
      category: 'habits_sins',
      remedy: 'الاستغفار 70 مرة وقراءة وجه من القرآن',
    ),
    ActionItem(
      id: 'sin_smoking',
      title: 'تناول السجائر / الشيشة / التدخين',
      points: -40,
      icon: Icons.smoking_rooms,
      category: 'habits_sins',
      remedy: 'إخراج قيمة علبة السجائر صدقة للفقراء وإمساك النفس',
    ),
    ActionItem(
      id: 'sin_lying',
      title: 'الكذب أو خيانة الوعد وتلفيق الأعذار',
      points: -80,
      icon: Icons.gavel,
      category: 'habits_sins',
      remedy: 'قول الصدق والاعتراف لمن كذبت عليه وإصلاح الأثر',
    ),
    ActionItem(
      id: 'sin_cheat_work',
      title: 'الغش في العمل أو التهرب من الدوام وأخذ أجر باطل',
      points: -120,
      icon: Icons.work_history_outlined,
      category: 'habits_sins',
      remedy: 'تعويض ساعات العمل أو التصدق بما يقابلها من الراتب',
    ),
    ActionItem(
      id: 'sin_gheeba',
      title: 'الغيبة والحديث في أعراض الناس بالسوء',
      points: -100,
      icon: Icons.record_voice_over,
      category: 'habits_sins',
      remedy: 'الاستغفار للشخص بظهر الغيب ومدحه في نفس المجلس',
    ),
    ActionItem(
      id: 'sin_anger',
      title: 'السب والشتم والبذاءة وكسر خواطر الناس بغضب',
      points: -70,
      icon: Icons.mood_bad,
      category: 'habits_sins',
      remedy: 'الاعتذار المباشر وتطييب خاطر من أسأت إليه',
    ),
    ActionItem(
      id: 'sin_time_waste',
      title: 'هدر الساعات الطويلة في الألعاب واللهو البطال',
      points: -35,
      icon: Icons.hourglass_disabled,
      category: 'habits_sins',
      remedy: 'جلسة تدبر واستغفار لمدة ربع ساعة تعويضاً عن العمر',
    ),

    // 4. الكبائر والموبقات العظام
    ActionItem(
      id: 'maj_shirk',
      title: 'الشرك، السحر، التنجيم، أو صرف العبادة لغير الله',
      points: -1000,
      icon: Icons.dangerous,
      category: 'major',
      remedy: 'تجديد التوحيد بنطق الشهادتين وخلع الباطل من أصله',
    ),
    ActionItem(
      id: 'maj_zina',
      title: 'الزنا وفواحش الفروج',
      points: -800,
      icon: Icons.block,
      category: 'major',
      remedy: 'توبة نصوح مفصلية، قطع كل وسيلة، وصيام متتابع وصدقة',
    ),
    ActionItem(
      id: 'maj_theft_bribery',
      title: 'السرقة، الرشوة، أكل الربا، أو أكل مال اليتيم',
      points: -600,
      icon: Icons.money_off,
      category: 'major',
      remedy: 'لا تُقبل التوبة إلا برد كل قرش لصاحبه أو ورثته فوراً',
    ),
    ActionItem(
      id: 'maj_parents_abuse',
      title: 'عقوق الوالدين الصارخ (الشتم، النهر، قطيعة تامة)',
      points: -700,
      icon: Icons.priority_high,
      category: 'major',
      remedy: 'تقبيل أقدامهم وطلب المسامحة الصريحة قبل فوات الأوان',
    ),
    ActionItem(
      id: 'maj_false_testimony',
      title: 'شهادة الزور أو اليمين الغموس المقتطعة لحق مسلم',
      points: -500,
      icon: Icons.warning_amber,
      category: 'major',
      remedy: 'التراجع العلني أمام القضاء أو الناس وتبرئة المظلوم',
    ),
    ActionItem(
      id: 'maj_alcohol',
      title: 'شرب المسكرات أو تعاطي المخدرات',
      points: -400,
      icon: Icons.local_bar,
      category: 'major',
      remedy: 'الإقلاع الفوري ودخول مصحة أو برنامج تعافٍ وتوبة نصوح',
    ),

    // 5. المواسم والنفحات والقربات العظمى
    ActionItem(
      id: 'seas_ramadan',
      title: 'صيام يوم من رمضان إيماناً واحتساباً',
      points: 150,
      icon: Icons.brightness_3,
      category: 'seasons',
      hadithProof: '«غفر له ما تقدم من ذنبه» (متفق عليه)',
    ),
    ActionItem(
      id: 'seas_qadr',
      title: 'قيام ليلة القدر إيماناً واحتساباً',
      points: 1000,
      icon: Icons.auto_awesome,
      category: 'seasons',
      hadithProof: '«ليلة القدر خير من ألف شهر»',
    ),
    ActionItem(
      id: 'seas_arafah',
      title: 'صيام يوم عرفة لغير الحاج',
      points: 400,
      icon: Icons.landscape,
      category: 'seasons',
      hadithProof: '«يكفر السنة الماضية والسنة القابلة» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'seas_ashura',
      title: 'صيام يوم عاشوراء',
      points: 200,
      icon: Icons.shield_outlined,
      category: 'seasons',
      hadithProof: '«أحتسب على الله أن يكفر السنة التي قبله» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'seas_hajj',
      title: 'الحج المبرور الخالص لوجه الله',
      points: 1200,
      icon: Icons.apartment,
      category: 'seasons',
      hadithProof: '«رجع كيوم ولدته أمه» (متفق عليه)',
    ),
    ActionItem(
      id: 'seas_ribat',
      title: 'الرباط وحراسة الثغور في سبيل الله',
      points: 1000,
      icon: Icons.security,
      category: 'seasons',
      hadithProof: '«رباط يوم وليلة خير من صيام شهر وقيامه» (صحيح مسلم)',
    ),
    ActionItem(
      id: 'seas_orphan',
      title: 'كفالة يتيم والقيام على احتياجاته',
      points: 500,
      icon: Icons.child_care,
      category: 'seasons',
      hadithProof: '«أنا وكافل اليتيم في الجنة هكذا» (صحيح البخاري)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkDailyResetAndLoadScores(); // التحقق التلقائي من اليوم الجديد
  }

  // التصفير التلقائي اليومي مع بقاء الرصيد التراكمي
  Future<void> _checkDailyResetAndLoadScores() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _totalGoodPoints = prefs.getInt('total_good_points') ?? 0;
      _totalBadPoints = prefs.getInt('total_bad_points') ?? 0;
    });

    final String todayDate = DateTime.now().toIso8601String().split('T').first;
    final String? lastSavedDate = prefs.getString('last_active_date');

    // إذا بدأ يوم جديد بعد منتصف الليل، تصفر الاختيارات اليومية فقط
    if (lastSavedDate != null && lastSavedDate != todayDate) {
      setState(() {
        for (var a in _allActions) {
          a.isCompleted = false;
        }
      });
    }

    await prefs.setString('last_active_date', todayDate);
  }

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
        _totalGoodPoints += isChecked ? item.points : -item.points;
        if (_totalGoodPoints < 0) _totalGoodPoints = 0;
      } else {
        _totalBadPoints += isChecked ? item.points.abs() : -item.points.abs();
        if (_totalBadPoints < 0) _totalBadPoints = 0;
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 45, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 14),
              const Icon(Icons.shield_outlined, size: 55, color: Colors.orange),
              const SizedBox(height: 10),
              const Text(
                '﴿إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ﴾',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
              ),
              const SizedBox(height: 8),
              Text('سُجلت الزلة: (${item.title})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.amber, size: 28),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.remedy!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('أتممتُ الاستدراك والتوبة ومحوتُ الأثر بفضل الله'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDialog() {
    const String myIban = "PS00PALS000000000000000000000";
    const String palpayNumber = "059xxxxxxx";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              const Icon(Icons.volunteer_activism, size: 50, color: Color(0xFF1B4D3E)),
              const SizedBox(height: 12),
              const Text(
                'دعم وتطوير ميزان الأعمال',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
              ),
              const SizedBox(height: 8),
              Text(
                'التطبيق مجاني ومتاح لوجه الله تعالى. دعمكم يساهم في تطوير ميزات جديدة مستمرة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F9F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1B4D3E).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance, color: Color(0xFF1B4D3E), size: 20),
                        SizedBox(width: 8),
                        Text('بنك فلسطين (Bank of Palestine)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('رقم الآيبان (IBAN):', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            myIban,
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF1B4D3E)),
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: myIban));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ رقم الـ IBAN بنجاح!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, color: Colors.amber, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تحويل عبر تطبيق بنكي / PalPay:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('رقم الهاتف: $palpayNumber', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _manualResetDaily() {
    setState(() {
      for (var a in _allActions) {
        a.isCompleted = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تصفير اليوميات لبدء يوم جديد، ورصيدك التاريخي العام محفوظ!'),
        backgroundColor: Color(0xFF1B4D3E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ميزان الأعمال الحقيقي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'دعم التطبيق (بنك فلسطين)',
              icon: const Icon(Icons.volunteer_activism, color: Color(0xFF1B4D3E)),
              onPressed: _showSupportDialog,
            ),
            IconButton(
              tooltip: 'تصفير اليومية يدوياً',
              icon: const Icon(Icons.refresh, color: Color(0xFF1B4D3E)),
              onPressed: _manualResetDaily,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF1B4D3E),
            indicatorColor: const Color(0xFF1B4D3E),
            tabs: const [
              Tab(text: 'الفرائض واليوميات'),
              Tab(text: 'كنز الأذكار والأدعية'),
              Tab(text: 'الزلات والعادات'),
              Tab(text: 'الكبائر والموبقات'),
              Tab(text: 'المواسم والقربات العظمى'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4D3E), Color(0xFF2C7A5E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1B4D3E).withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 5)),
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
                          const Text('رصيدك الشامل منذ بدء التطبيق', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            _lifetimeNetScore >= 500
                                ? 'كفة راجحة بفضل الله 🌟'
                                : (_lifetimeNetScore >= 0 ? 'ميزان متماسك ⚖️' : 'ناقوس خطر: استدرك بالتوبة ⚠️'),
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
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Color(0xFF68D391), size: 18),
                          const SizedBox(width: 4),
                          Text('إجمالي الحسنات: +$_totalGoodPoints', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(width: 1, height: 16, color: Colors.white24),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, color: Color(0xFFFC8181), size: 18),
                          const SizedBox(width: 4),
                          Text('إجمالي السيئات: -$_totalBadPoints', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList('daily', Colors.green.shade50),
                  _buildList('dhikr', Colors.teal.shade50),
                  _buildList('habits_sins', Colors.orange.shade50),
                  _buildList('major', Colors.red.shade50),
                  _buildList('seasons', Colors.amber.shade50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String category, Color completedBgColor) {
    final list = _allActions.where((a) => a.category == category).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final item = list[i];
        final isNegative = item.points < 0;
        return Card(
          elevation: 0,
          color: item.isCompleted ? completedBgColor : Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: item.isCompleted
                  ? (isNegative ? Colors.red.shade300 : const Color(0xFF1B4D3E))
                  : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isNegative ? Colors.red.shade50 : const Color(0xFFE8F5E9),
              foregroundColor: isNegative ? Colors.redAccent : const Color(0xFF1B4D3E),
              child: Icon(item.icon, size: 20),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: item.isCompleted && !isNegative ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: item.hadithProof != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(item.hadithProof!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.points > 0 ? "+" : ""}${item.points}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isNegative ? Colors.red : const Color(0xFF1B4D3E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Checkbox(
                  value: item.isCompleted,
                  activeColor: isNegative ? Colors.red : const Color(0xFF1B4D3E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
