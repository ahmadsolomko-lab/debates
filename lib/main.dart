// Дебати — версія 0.1 (демо). Весь застосунок в одному файлі.
import 'dart:math';

import 'package:flutter/material.dart';

// ===================== main =====================
void main() {
  runApp(const DebatesApp());
}

const String appTitle = 'Дебати';

class AppColors {
  static const Color background = Color(0xFF0E1116);
  static const Color surface = Color(0xFF171B22);
  static const Color surfaceHigh = Color(0xFF212733);
  static const Color accent = Color(0xFFFF6B35);
  static const Color pro = Color(0xFF3DDC97);
  static const Color con = Color(0xFFFF5470);
  static const Color textMuted = Color(0xFF9AA4B2);
}

class DebatesApp extends StatelessWidget {
  const DebatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      surface: AppColors.surface,
    );

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ===================== models =====================
enum Side { pro, con }

enum Speaker { user, ai }

extension SideLabel on Side {
  String get label => this == Side.pro ? 'ЗА' : 'ПРОТИ';
  Side get opposite => this == Side.pro ? Side.con : Side.pro;
}

class Topic {
  final String id;
  final String title;
  final String category;
  final bool hot;

  const Topic({
    required this.id,
    required this.title,
    required this.category,
    this.hot = false,
  });
}

class DebateMessage {
  final Speaker speaker;
  final String text;
  final int round;

  const DebateMessage({
    required this.speaker,
    required this.text,
    required this.round,
  });
}

class JudgeScore {
  final String judge;
  final String criterion;
  final int user;
  final int ai;
  final String comment;

  const JudgeScore({
    required this.judge,
    required this.criterion,
    required this.user,
    required this.ai,
    required this.comment,
  });
}

class Verdict {
  final List<JudgeScore> scores;

  const Verdict(this.scores);

  int get userTotal => scores.fold(0, (sum, s) => sum + s.user);
  int get aiTotal => scores.fold(0, (sum, s) => sum + s.ai);
  bool get isDraw => userTotal == aiTotal;
  bool get userWins => userTotal > aiTotal;
}

// ===================== settings =====================
const List<String> debateLanguages = [
  'Українська',
  'Deutsch',
  'English',
  'Español',
];

final ValueNotifier<String> debateLanguage =
    ValueNotifier<String>(debateLanguages.first);

final ValueNotifier<bool> autoTranslate = ValueNotifier<bool>(true);

const int debateRounds = 3;

// ===================== topics =====================
const List<String> categories = [
  'Гарячі теми',
  'Політика і суспільство',
  'Технології',
  'Легкі теми',
];

const List<Topic> topics = [
  Topic(
    id: 'same-sex-marriage',
    title: 'Одностатеві шлюби мають бути легальними в усіх країнах ЄС',
    category: 'Гарячі теми',
    hot: true,
  ),
  Topic(
    id: 'euthanasia',
    title: 'Евтаназія має бути легальною для дорослих за їхнім бажанням',
    category: 'Гарячі теми',
    hot: true,
  ),
  Topic(
    id: 'abortion',
    title: 'Аборт має бути легальним на вимогу жінки до 12-го тижня',
    category: 'Гарячі теми',
    hot: true,
  ),
  Topic(
    id: 'guns',
    title: 'Громадяни мають право вільно носити зброю',
    category: 'Гарячі теми',
    hot: true,
  ),
  Topic(
    id: 'gaza',
    title: 'Європейські країни мають визнати державу Палестина',
    category: 'Гарячі теми',
    hot: true,
  ),
  Topic(
    id: 'death-penalty',
    title: 'Смертна кара має бути дозволена за найтяжчі злочини',
    category: 'Гарячі теми',
    hot: true,
  ),

  Topic(
    id: 'conscription',
    title: 'Обовʼязкова військова служба має бути в кожній країні ЄС',
    category: 'Політика і суспільство',
  ),
  Topic(
    id: 'ubi',
    title: 'Безумовний базовий дохід — краще рішення, ніж соцдопомога',
    category: 'Політика і суспільство',
  ),
  Topic(
    id: 'four-day-week',
    title: 'Робочий тиждень має бути чотириденним',
    category: 'Політика і суспільство',
  ),
  Topic(
    id: 'voting-16',
    title: 'Голосувати на виборах можна з 16 років',
    category: 'Політика і суспільство',
  ),

  Topic(
    id: 'social-media-16',
    title: 'Соцмережі треба заборонити дітям до 16 років',
    category: 'Технології',
  ),
  Topic(
    id: 'ai-jobs',
    title: 'AI за 20 років забере більшість професій',
    category: 'Технології',
  ),
  Topic(
    id: 'nuclear',
    title: 'Атомна енергетика — найкращий шлях до кліматичних цілей',
    category: 'Технології',
  ),

  Topic(
    id: 'pineapple-pizza',
    title: 'Піца з ананасом — це нормально',
    category: 'Легкі теми',
  ),
  Topic(
    id: 'cats-dogs',
    title: 'Коти кращі за собак',
    category: 'Легкі теми',
  ),
  Topic(
    id: 'remote-school',
    title: 'Школа має бути онлайн хоча б двічі на тиждень',
    category: 'Легкі теми',
  ),
];

List<Topic> topicsIn(String category) =>
    topics.where((t) => t.category == category).toList();

// ===================== demo_ai =====================
class DemoAi {
  final Random _random = Random();

  Future<String> reply({
    required Topic topic,
    required Side aiSide,
    required int round,
    required String lastUserMessage,
  }) async {
    await Future.delayed(Duration(milliseconds: 900 + _random.nextInt(900)));

    final stance = aiSide == Side.pro ? 'підтримую' : 'не підтримую';
    final quote = _shortQuote(lastUserMessage);

    if (round == 1) {
      return _pick([
        'Я $stance тезу «${topic.title}». Головна причина — наслідки для '
            'звичайних людей: будь-яке рішення тут треба оцінювати за тим, '
            'кому воно реально допоможе, а кому зашкодить. І за цим '
            'критерієм ваша позиція слабша.',
        'Почну з принципу: держава має втручатися лише тоді, коли без '
            'цього страждають інші. Саме тому я $stance тезу «${topic.title}». '
            'Ваш аргумент «$quote» звучить переконливо, але він описує '
            'окремий випадок, а не правило.',
      ]);
    }

    if (round == 2) {
      return _pick([
        'Ви кажете: «$quote». Але це твердження без доказів. Які дані '
            'показують, що так буде на практиці? Без цифр це лише думка, '
            'а не аргумент.',
        'Зверніть увагу: «$quote» — це наслідок, а не причина. Якщо '
            'прибрати емоції, то залишається питання ціни: хто за це '
            'платить і чи готове суспільство до цього?',
      ]);
    }

    return _pick([
      'Підсумую. Протягом дебатів ви не відповіли на головне питання — '
          'як ваша позиція працює в реальному житті, а не в теорії. Тому я '
          'й надалі $stance тезу «${topic.title}».',
      'На завершення: сильні емоції не замінюють сильних доказів. '
          'Моя позиція спирається на принцип і наслідки, і саме тому вона '
          'стійкіша за вашу.',
    ]);
  }

  Verdict judge(List<DebateMessage> messages) {
    final userText = messages
        .where((m) => m.speaker == Speaker.user)
        .map((m) => m.text)
        .join(' ');
    final aiText = messages
        .where((m) => m.speaker == Speaker.ai)
        .map((m) => m.text)
        .join(' ');

    final userLogic = _logic(userText);
    final aiLogic = _logic(aiText);
    final userEvidence = _evidence(userText);
    final aiEvidence = _evidence(aiText);
    final userRhetoric = _rhetoric(userText);
    final aiRhetoric = _rhetoric(aiText);

    return Verdict([
      JudgeScore(
        judge: 'Суддя логіки',
        criterion: 'Логіка',
        user: userLogic,
        ai: aiLogic,
        comment: userLogic >= 7
            ? 'Аргументи повʼязані між собою, видно причину і наслідок.'
            : 'Додай звʼязки: «тому що», «отже», «якщо… то». Зараз '
                'думки стоять окремо одна від одної.',
      ),
      JudgeScore(
        judge: 'Суддя обґрунтованості',
        criterion: 'Факти й докази',
        user: userEvidence,
        ai: aiEvidence,
        comment: userEvidence >= 7
            ? 'Є цифри та приклади — це посилює позицію.'
            : 'Бракує конкретики: цифр, прикладів, досліджень. '
                'Без них аргумент — лише думка.',
      ),
      JudgeScore(
        judge: 'Суддя риторики',
        criterion: 'Риторика',
        user: userRhetoric,
        ai: aiRhetoric,
        comment: userRhetoric >= 7
            ? 'Яскраво, різноманітно і зрозуміло.'
            : 'Пиши різноманітніше: менше повторів, більше чітких '
                'коротких речень і риторичних запитань.',
      ),
    ]);
  }

  static const _logicWords = [
    'тому що', 'оскільки', 'отже', 'тому', 'бо ', 'якщо', 'то ', 'адже',
    'через це', 'по-перше', 'по-друге', 'наслідок', 'причина',
    'because', 'therefore', 'if ', 'weil', 'deshalb', 'wenn', 'porque',
  ];

  static const _evidenceWords = [
    'дослідж', 'дані', 'статистик', 'наприклад', 'джерел', 'відсот',
    'згідно', 'приклад', 'study', 'data', 'example', 'studie', 'beispiel',
    'ejemplo',
  ];

  int _logic(String text) {
    final t = text.toLowerCase();
    var hits = 0;
    for (final w in _logicWords) {
      hits += _count(t, w);
    }
    final words = _words(t).length;
    final score = 3 + hits * 1.2 + min(words / 40, 2.5);
    return _clamp(score.round());
  }

  int _evidence(String text) {
    final t = text.toLowerCase();
    var hits = RegExp(r'\d').hasMatch(t) ? 2 : 0;
    hits += _count(t, '%');
    for (final w in _evidenceWords) {
      hits += _count(t, w);
    }
    final score = 2 + hits * 1.3;
    return _clamp(score.round());
  }

  int _rhetoric(String text) {
    final words = _words(text.toLowerCase());
    if (words.isEmpty) return 1;
    final variety = words.toSet().length / words.length;
    final questions = _count(text, '?');
    final lengthBonus = min(words.length / 60, 2.0);
    final score = 2 + variety * 5 + min(questions, 2) + lengthBonus;
    return _clamp(score.round());
  }

  int _clamp(int v) => max(1, min(10, v));

  List<String> _words(String text) => text
      .split(RegExp(r'[\s,.!?;:«»"()—-]+'))
      .where((w) => w.isNotEmpty)
      .toList();

  int _count(String text, String pattern) {
    var count = 0;
    var index = text.indexOf(pattern);
    while (index != -1) {
      count++;
      index = text.indexOf(pattern, index + pattern.length);
    }
    return count;
  }

  String _shortQuote(String text) {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return '…';
    final words = clean.split(' ');
    if (words.length <= 8) return clean;
    return '${words.take(8).join(' ')}…';
  }

  String _pick(List<String> options) =>
      options[_random.nextInt(options.length)];
}

// ===================== home_screen =====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what зʼявиться в наступній версії')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          appTitle,
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const Text(
              'Сперечайся будь-якою мовою.\nТри AI-судді вирішать, хто переміг.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            _ModeCard(
              icon: Icons.smart_toy_outlined,
              title: 'Дебати з AI',
              subtitle: '3 раунди проти штучного інтелекту',
              highlighted: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopicsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.hourglass_bottom_rounded,
              title: 'Дебати «3 дні»',
              subtitle: 'З людиною, відповідаєш коли зручно',
              badge: 'Скоро',
              onTap: () => _soon(context, 'Дебати з людьми'),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.bolt_rounded,
              title: 'Живі дебати',
              subtitle: '5 · 10 · 15 · 30 хвилин',
              badge: 'Версія 2',
              onTap: () => _soon(context, 'Живі дебати'),
            ),
            const SizedBox(height: 28),
            const Text(
              'Мова',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const _LanguagePanel(),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool highlighted;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? AppColors.accent : AppColors.surface;
    final fg = highlighted ? Colors.black : Colors.white;
    final sub = highlighted ? Colors.black87 : AppColors.textMuted;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 32, color: fg),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: sub)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Icon(Icons.arrow_forward_rounded, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('Я дебатую мовою')),
              ValueListenableBuilder<String>(
                valueListenable: debateLanguage,
                builder: (context, value, _) => DropdownButton<String>(
                  value: value,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    for (final lang in debateLanguages)
                      DropdownMenuItem(value: lang, child: Text(lang)),
                  ],
                  onChanged: (v) {
                    if (v != null) debateLanguage.value = v;
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          ValueListenableBuilder<bool>(
            valueListenable: autoTranslate,
            builder: (context, value, _) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AI-переклад суперника'),
              subtitle: const Text(
                'Суперник пише своєю мовою — ти читаєш своєю',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              value: value,
              onChanged: (v) => autoTranslate.value = v,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== topics_screen =====================
class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  Future<void> _chooseSide(BuildContext context, Topic topic) async {
    final side = await showModalBottomSheet<Side>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                topic.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Обери свою позицію. AI займе протилежну.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SideButton(
                      label: 'ЗА',
                      color: AppColors.pro,
                      onTap: () => Navigator.pop(sheetContext, Side.pro),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SideButton(
                      label: 'ПРОТИ',
                      color: AppColors.con,
                      onTap: () => Navigator.pop(sheetContext, Side.con),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (side == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DebateScreen(topic: topic, userSide: side),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обери тему')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  if (category == 'Гарячі теми') ...[
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            for (final topic in topicsIn(category))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _chooseSide(context, topic),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              topic.title,
                              style: const TextStyle(height: 1.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Гарячі теми модеруються: образи та мова ворожнечі '
            'блокуються, а порушників можна поскаржити.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SideButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== debate_screen =====================
class DebateScreen extends StatefulWidget {
  final Topic topic;
  final Side userSide;

  const DebateScreen({super.key, required this.topic, required this.userSide});

  @override
  State<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  final DemoAi _ai = DemoAi();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<DebateMessage> _messages = [];

  int _round = 1;
  bool _aiThinking = false;
  bool _finished = false;

  static const int _minLength = 20;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.length < _minLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Аргумент закороткий — напиши хоча б одне речення'),
        ),
      );
      return;
    }

    setState(() {
      _messages.add(
        DebateMessage(speaker: Speaker.user, text: text, round: _round),
      );
      _input.clear();
      _aiThinking = true;
    });
    _scrollToEnd();

    final reply = await _ai.reply(
      topic: widget.topic,
      aiSide: widget.userSide.opposite,
      round: _round,
      lastUserMessage: text,
    );
    if (!mounted) return;

    setState(() {
      _messages.add(
        DebateMessage(speaker: Speaker.ai, text: reply, round: _round),
      );
      _aiThinking = false;
      if (_round >= debateRounds) {
        _finished = true;
      } else {
        _round++;
      }
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _openVerdict() {
    final verdict = _ai.judge(_messages);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VerdictScreen(
          topic: widget.topic,
          userSide: widget.userSide,
          verdict: verdict,
        ),
      ),
    );
  }

  String get _roundName {
    switch (_round) {
      case 1:
        return 'Вступ';
      case 2:
        return 'Контраргументи';
      default:
        return 'Фінальне слово';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userColor =
        widget.userSide == Side.pro ? AppColors.pro : AppColors.con;
    final aiColor = widget.userSide == Side.pro ? AppColors.con : AppColors.pro;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _finished ? 'Дебати завершено' : 'Раунд $_round з $debateRounds',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopicHeader(
              topic: widget.topic,
              userSide: widget.userSide,
              userColor: userColor,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length + (_aiThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _Bubble(
                      text: 'AI думає…',
                      isUser: false,
                      color: aiColor,
                      muted: true,
                    );
                  }
                  final m = _messages[index];
                  return _Bubble(
                    text: m.text,
                    isUser: m.speaker == Speaker.user,
                    color: m.speaker == Speaker.user ? userColor : aiColor,
                  );
                },
              ),
            ),
            if (_finished)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _openVerdict,
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text(
                      'До суддів',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              )
            else
              _InputBar(
                controller: _input,
                hint: '$_roundName — твій аргумент…',
                enabled: !_aiThinking,
                onSend: _send,
              ),
          ],
        ),
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  final Topic topic;
  final Side userSide;
  final Color userColor;

  const _TopicHeader({
    required this.topic,
    required this.userSide,
    required this.userColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Ти: ', style: TextStyle(color: AppColors.textMuted)),
              Text(
                userSide.label,
                style: TextStyle(color: userColor, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              const Text(
                'ДЕМО-РЕЖИМ',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color color;
  final bool muted;

  const _Bubble({
    required this.text,
    required this.isUser,
    required this.color,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color.alphaBlend(color.withAlpha(28), AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            border: Border.all(color: color.withAlpha(90)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'Ти' : 'AI-суперник',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  height: 1.4,
                  color: muted ? AppColors.textMuted : Colors.white,
                  fontStyle: muted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      color: AppColors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hint,
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

// ===================== verdict_screen =====================
class VerdictScreen extends StatelessWidget {
  final Topic topic;
  final Side userSide;
  final Verdict verdict;

  const VerdictScreen({
    super.key,
    required this.topic,
    required this.userSide,
    required this.verdict,
  });

  @override
  Widget build(BuildContext context) {
    final String headline;
    final Color headlineColor;
    if (verdict.isDraw) {
      headline = 'Нічия';
      headlineColor = AppColors.accent;
    } else if (verdict.userWins) {
      headline = 'Перемога твоя!';
      headlineColor = AppColors.pro;
    } else {
      headline = 'Переміг AI';
      headlineColor = AppColors.con;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Вердикт суддів')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: headlineColor.withAlpha(120)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.gavel_rounded,
                      size: 40, color: AppColors.accent),
                  const SizedBox(height: 8),
                  Text(
                    headline,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: headlineColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${verdict.userTotal} : ${verdict.aiTotal}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ти  ·  AI',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final score in verdict.scores) ...[
              _JudgeCard(score: score),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            const Text(
              'Демо-оцінка: зараз судді рахують прості ознаки тексту. '
              'Справжні AI-судді зʼявляться після підключення сервера.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Нові дебати',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JudgeCard extends StatelessWidget {
  final JudgeScore score;

  const _JudgeCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            score.judge,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            score.criterion,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _ScoreBar(label: 'Ти', value: score.user, color: AppColors.pro),
          const SizedBox(height: 8),
          _ScoreBar(label: 'AI', value: score.ai, color: AppColors.con),
          const SizedBox(height: 12),
          Text(score.comment, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 10,
              color: color,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '$value/10',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
