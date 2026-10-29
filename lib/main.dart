// Debatos — версія 0.7. Весь застосунок в одному файлі.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===================== налаштування =====================

/// Адреса AI-сервера. Поки порожня — працює демо-режим.
/// Коли налаштуємо сервер, сюди вставимо його адресу.
const String aiServerUrl = 'https://debatos-ai.ahmadsolomko.workers.dev';

const int debateRounds = 3;

// ===================== main =====================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();
  runApp(const DebatesApp());
}

/// Палітра давньогрецької вази: чорний лак, теракота, глина, олива.
class AppColors {
  static const Color background = Color(0xFF17100B); // чорний лак
  static const Color surface = Color(0xFF261A12); // обпалена глина
  static const Color surfaceHigh = Color(0xFF36261A);
  static const Color accent = Color(0xFFD9733B); // теракота
  static const Color gold = Color(0xFFD4A64A); // лаври, бронза
  static const Color pro = Color(0xFF9DB36A); // олива
  static const Color con = Color(0xFFD9624A); // червона фігура
  static const Color text = Color(0xFFF3E6D2); // слонова кістка
  static const Color textMuted = Color(0xFFB9A58C);
}

/// Шрифт «як на колоні» для заголовків (є кирилиця).
TextStyle classic({
  double fontSize = 22,
  Color color = AppColors.text,
  FontWeight fontWeight = FontWeight.w700,
  double letterSpacing = 0.6,
  double? height,
}) =>
    GoogleFonts.getFont(
      'Cormorant SC',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );

/// Грецький меандр — орнамент-розділювач.
class Meander extends StatelessWidget {
  final Color color;
  final double height;

  const Meander({super.key, this.color = AppColors.accent, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _MeanderPainter(color)),
    );
  }
}

class _MeanderPainter extends CustomPainter {
  final Color color;
  _MeanderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final u = h / 4; // крок сітки
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, u * 0.45)
      ..strokeCap = StrokeCap.square;
    final path = Path();
    final w = u * 4; // ширина одного «ключа»
    final count = (size.width / w).floor();
    final start = (size.width - count * w) / 2;
    path.moveTo(start, h);
    for (var i = 0; i < count; i++) {
      final x = start + i * w;
      path
        ..lineTo(x, 0)
        ..lineTo(x + u * 3, 0)
        ..lineTo(x + u * 3, u * 3)
        ..lineTo(x + u, u * 3)
        ..lineTo(x + u, u)
        ..lineTo(x + u * 2, u)
        ..lineTo(x + u * 2, u * 2)
        ..moveTo(x + u * 3, h)
        ..lineTo(x, h)
        ..moveTo(x + u * 3, h)
        ..lineTo(x + w, h);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MeanderPainter old) => old.color != color;
}

/// Лавровий вінок переможця.
class LaurelWreath extends StatelessWidget {
  final double size;
  final Color color;

  const LaurelWreath({super.key, this.size = 72, this.color = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LaurelPainter(color)),
    );
  }
}

class _LaurelPainter extends CustomPainter {
  final Color color;
  _LaurelPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.38;
    final stem = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = color;
    final leafLen = size.width * 0.17;
    final leafW = size.width * 0.075;
    for (final dir in const [-1.0, 1.0]) {
      // гілка: від низу (90°) вгору по колу, не змикаючись зверху
      const from = pi / 2 + 0.25;
      const sweep = pi - 0.75;
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(rect, dir < 0 ? from : pi - from - sweep, sweep, false, stem);
      for (var i = 0; i < 7; i++) {
        final a = dir < 0 ? from + sweep * (i + 0.5) / 7 : pi / 2 - 0.25 - sweep * (i + 0.5) / 7;
        final p = c + Offset(cos(a), sin(a)) * r;
        for (final side in const [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(p.dx, p.dy);
          // листок дивиться вздовж гілки до верху, трохи назовні/всередину
          final tangent = a + (dir < 0 ? pi / 2 : -pi / 2);
          canvas.rotate(tangent + side * 0.55);
          canvas.drawOval(
              Rect.fromLTWH(0, -leafW / 2, leafLen, leafW), leaf);
          canvas.restore();
        }
      }
    }
    // стрічка внизу
    canvas.drawCircle(c + Offset(0, r), size.width * 0.04, leaf);
  }

  @override
  bool shouldRepaint(_LaurelPainter old) => old.color != color;
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
      onPrimary: AppColors.background,
      secondary: AppColors.gold,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      outline: AppColors.textMuted,
    );
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final textTheme = GoogleFonts.getTextTheme('Alegreya', base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) => MaterialApp(
        key: ValueKey(lang),
        title: tr('appTitle'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          textTheme: textTheme,
          scaffoldBackgroundColor: AppColors.background,
          dividerColor: AppColors.surfaceHigh,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: classic(fontSize: 24),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.surfaceHigh,
            contentTextStyle: textTheme.bodyMedium,
          ),
        ),
        home: Session.hasProfile || aiServerUrl.isEmpty
            ? const HomeScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}

// ===================== мови =====================

/// Мова інтерфейсу і дебатів.
final ValueNotifier<String> appLang = ValueNotifier<String>('en');

/// Чи увімкнений автопереклад суперника (для дебатів з людьми).
final ValueNotifier<bool> autoTranslate = ValueNotifier<bool>(true);

const Map<String, String> languageNames = {
  'en': 'English',
  'uk': 'Українська',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'ru': 'Русский',
};

/// Мова телефону, якщо вона в нас є; інакше англійська.
String deviceLanguage() {
  try {
    for (final l in WidgetsBinding.instance.platformDispatcher.locales) {
      if (languageNames.containsKey(l.languageCode)) return l.languageCode;
    }
  } catch (_) {}
  return 'en';
}

String tr(String key, [Map<String, String> vars = const {}]) {
  var text = _strings[appLang.value]?[key] ?? _strings['en']![key] ?? key;
  vars.forEach((k, v) => text = text.replaceAll('{$k}', v));
  return text;
}

const Map<String, Map<String, String>> _strings = {
  'uk': {
    'appTitle': 'Debatos',
    'tagline': 'Сперечайся будь-якою мовою.\nТри AI-судді вирішать, хто переміг.',
    'modeAiTitle': 'Дебати з AI',
    'modeAiSub': '3 раунди проти штучного інтелекту',
    'mode3dTitle': 'Дебати «3 дні»',
    'mode3dSub': 'З людиною, відповідаєш коли зручно',
    'liveTitle': 'Живі дебати',
    'liveSub': '5 · 10 · 15 · 30 хвилин',
    'badgeSoon': 'Скоро',
    'badgeV2': 'Версія 2',
    'soonMsg': 'Зʼявиться в одній з наступних версій',
    'language': 'Мова',
    'languageRow': 'Мова застосунку й дебатів',
    'translateTitle': 'AI-переклад суперника',
    'translateSub': 'Суперник пише своєю мовою — ти читаєш своєю',
    'chooseTopic': 'Обери тему',
    'moderationNote': 'Гарячі теми модеруються: образи та мова ворожнечі '
        'блокуються, а порушників можна поскаржити.',
    'chooseSide': 'Обери свою позицію. AI займе протилежну.',
    'pro': 'ЗА',
    'con': 'ПРОТИ',
    'roundOf': 'Раунд {n} з {m}',
    'finished': 'Дебати завершено',
    'r1': 'Вступ',
    'r2': 'Контраргументи',
    'r3': 'Фінальне слово',
    'hint': '{round} — твій аргумент…',
    'tooShort': 'Аргумент закороткий — напиши хоча б одне речення',
    'you': 'Ти',
    'youColon': 'Ти: ',
    'aiOpponent': 'AI-суперник',
    'aiThinking': 'AI думає…',
    'demoMode': 'ДЕМО-РЕЖИМ',
    'judgesTitle': 'Судді ще в розробці',
    'judgesBody': 'Ми визначаємо чесні критерії оцінювання. Скоро три '
        'AI-судді оцінюватимуть логіку, докази й риторику.',
    'newDebate': 'Нові дебати',
    'aiOffline': 'AI-сервер недоступний — відповідає демо',
    'cat_hot': 'Гарячі теми',
    'cat_politics': 'Політика і суспільство',
    'cat_tech': 'Технології',
    'cat_light': 'Легкі теми',
    'onboardTitle': 'Ласкаво просимо до Debatos',
    'onboardSub': 'Сперечайся з людьми з усього світу — кожен пише своєю мовою, AI перекладає.',
    'rulesTitle': 'Правила',
    'rule1': 'Критикуй аргументи, а не людину: без образ і переходу на особистості.',
    'rule2': 'Без мови ворожнечі, погроз і непристойного вмісту.',
    'rule3': 'Не ділися контактами (телефон, соцмережі, адреса) і не проси їх.',
    'rule4': 'На порушників можна поскаржитися.',
    'ageCheck': 'Мені є 16 років, і я приймаю правила',
    'nickLabel': 'Твій нікнейм',
    'start': 'Почати',
    'nickError': 'Нікнейм має містити від 2 до 20 символів',
    'nickRejected': 'Такий нікнейм не можна використати. Спробуй інший.',
    'registerError': 'Не вдалося створити акаунт. Перевір інтернет і спробуй ще раз.',
    'rouletteTitle': 'Чат-рулетка',
    'rouletteSub': 'Випадковий суперник — просто зараз',
    'myDebates': 'Мої дебати',
    'noDebates': 'Поки порожньо. Почни дебати з людиною!',
    'waitingFor': 'Шукаємо суперника',
    'yourTurn': 'Твій хід',
    'theirTurn': 'Хід суперника',
    'finishedShort': 'Завершено',
    'searching': 'Шукаємо співрозмовника…',
    'randomTopic': 'Випадкова тема',
    'randomTopicSubAi': 'Тему вибере кубик, сторону — ти',
    'randomTopicSubHuman': 'Будь-яка тема й сторона — суперник знайдеться найшвидше',
    'orPickTopic': 'Або вибери тему сам:',
    'anySide': 'БУДЬ-ЯКА',
    'anySideHint': '«Будь-яка» — суперника знайдемо швидше',
    'anyTopic': 'Будь-яка тема',
    'anySideShort': 'будь-яка сторона',
    'searchTopic': 'Тема: {topic}',
    'searchSide': 'Твоя сторона: {side}',
    'searchingHint': 'Зазвичай це займає до хвилини.',
    'cancel': 'Скасувати',
    'nobody': 'Зараз ніхто не шукає суперника. Спробуй пізніше або зіграй з AI.',
    'playAi': 'Зіграти з AI',
    'waitingAsync': 'Шукаємо людину з протилежною позицією. Дебати зʼявляться в «Мої дебати».',
    'chooseSideHuman': 'Обери свою позицію. Шукатимемо людину з протилежною.',
    'vs': 'проти',
    'hoursLeft': 'ще {h} год',
    'waitOpponent': 'Чекаємо на відповідь суперника…',
    'showOriginal': 'Перекладено · показати оригінал',
    'showTranslation': 'Оригінал · показати переклад',
    'report': 'Поскаржитися',
    'block': 'Заблокувати',
    'surrender': 'Здатися',
    'reportTitle': 'Що сталося?',
    'r_insult': 'Образи',
    'r_hate': 'Мова ворожнечі',
    'r_sexual': 'Непристойний вміст',
    'r_contact': 'Просить контакти або спам',
    'r_other': 'Інше',
    'reported': 'Дякуємо! Скаргу надіслано, користувача заблоковано.',
    'blocked': 'Користувача заблоковано.',
    'modBlocked': 'Повідомлення не надіслано: {reason}',
    'mod_insult': 'образа або перехід на особистості',
    'mod_hate': 'мова ворожнечі',
    'mod_sexual': 'непристойний вміст',
    'mod_threat': 'погрози',
    'mod_contact': 'контакти й посилання заборонені',
    'mod_other': 'порушення правил',
    'forfeitWin': 'Суперник не відповів вчасно — перемога твоя!',
    'forfeitLose': 'Ти не відповів вчасно — поразка.',
    'oppSurrendered': 'Суперник здався або покинув дебати — перемога твоя!',
    'youSurrendered': 'Ти завершив дебати достроково.',
    'surrenderConfirm': 'Здатися? Перемога дістанеться суперникові.',
    'yes': 'Так',
    'no': 'Ні',
    'networkError': 'Немає звʼязку із сервером. Спробуй ще раз.',
    'banned': 'Акаунт заблоковано за порушення правил.',
    'loseHuman': 'Переміг суперник',
    'youVs': 'ти  ·  {name}',
    'opponentNoteTitle': 'Про суперника',
    'tooShortHuman': 'Закоротко — напиши хоча б 10 символів',
    'turnChanged': 'Хід уже змінився — оновлюю дебати.',
    'backHome': 'На головну',
    'needServer': 'Для дебатів з людьми потрібен інтернет і акаунт.',
    'nickPrefix': 'Ти граєш як',
    'toJudges': 'До суддів',
    'judgesThinking': 'Судді радяться…',
    'verdict': 'Вердикт суддів',
    'win': 'Перемога твоя!',
    'lose': 'Переміг AI',
    'draw': 'Нічия',
    'youVsAi': 'ти  ·  AI',
    'judge_logic': 'Суддя логіки',
    'judge_evidence': 'Суддя обґрунтованості',
    'judge_rhetoric': 'Суддя риторики',
    'crit_logic': 'Звʼязність, відповіді на аргументи суперника',
    'crit_evidence': 'Приклади, причини, правдоподібність',
    'crit_rhetoric': 'Ясність, структура, переконливість',
    'tipTitle': 'Порада для тебе',
    'aiNoteTitle': 'Про AI',
    'judgesError': 'Судді зараз недоступні. Спробуй ще раз трохи пізніше.',
    'retry': 'Спробувати ще',
    'judgeDisclaimer': 'Оцінює AI, і він може помилятися. Судді оцінюють якість '
        'аргументів, а не позицію.',
  },
  'de': {
    'appTitle': 'Debatos',
    'tagline': 'Debattiere in jeder Sprache.\nDrei KI-Richter entscheiden, wer gewinnt.',
    'modeAiTitle': 'Debatte gegen KI',
    'modeAiSub': '3 Runden gegen künstliche Intelligenz',
    'mode3dTitle': '3-Tage-Debatte',
    'mode3dSub': 'Gegen Menschen, antworte, wann es dir passt',
    'liveTitle': 'Live-Debatte',
    'liveSub': '5 · 10 · 15 · 30 Minuten',
    'badgeSoon': 'Bald',
    'badgeV2': 'Version 2',
    'soonMsg': 'Kommt in einer der nächsten Versionen',
    'language': 'Sprache',
    'languageRow': 'Sprache der App und Debatten',
    'translateTitle': 'KI-Übersetzung des Gegners',
    'translateSub': 'Dein Gegner schreibt in seiner Sprache, du liest in deiner',
    'chooseTopic': 'Wähle ein Thema',
    'moderationNote': 'Heiße Themen werden moderiert: Beleidigungen und '
        'Hassrede werden blockiert, Verstöße können gemeldet werden.',
    'chooseSide': 'Wähle deine Position. Die KI nimmt die Gegenposition ein.',
    'pro': 'DAFÜR',
    'con': 'DAGEGEN',
    'roundOf': 'Runde {n} von {m}',
    'finished': 'Debatte beendet',
    'r1': 'Eröffnung',
    'r2': 'Gegenargumente',
    'r3': 'Schlusswort',
    'hint': '{round} – dein Argument…',
    'tooShort': 'Zu kurz – schreib mindestens einen Satz',
    'you': 'Du',
    'youColon': 'Du: ',
    'aiOpponent': 'KI-Gegner',
    'aiThinking': 'KI denkt nach…',
    'demoMode': 'DEMO-MODUS',
    'judgesTitle': 'Richter in Entwicklung',
    'judgesBody': 'Wir legen gerade faire Bewertungskriterien fest. Bald '
        'bewerten drei KI-Richter Logik, Belege und Rhetorik.',
    'newDebate': 'Neue Debatte',
    'aiOffline': 'KI-Server nicht erreichbar – die Demo antwortet',
    'cat_hot': 'Heiße Themen',
    'cat_politics': 'Politik & Gesellschaft',
    'cat_tech': 'Technologie',
    'cat_light': 'Leichte Themen',
    'onboardTitle': 'Willkommen bei Debatos',
    'onboardSub': 'Debattiere mit Menschen aus aller Welt – jeder schreibt in seiner Sprache, die KI übersetzt.',
    'rulesTitle': 'Regeln',
    'rule1': 'Kritisiere Argumente, nicht Menschen: keine Beleidigungen, keine persönlichen Angriffe.',
    'rule2': 'Keine Hassrede, keine Drohungen, keine anstößigen Inhalte.',
    'rule3': 'Teile keine Kontaktdaten (Telefon, Social Media, Adresse) und frag nicht danach.',
    'rule4': 'Verstöße können gemeldet werden.',
    'ageCheck': 'Ich bin mindestens 16 Jahre alt und akzeptiere die Regeln',
    'nickLabel': 'Dein Nickname',
    'start': 'Starten',
    'nickError': 'Der Nickname muss 2 bis 20 Zeichen lang sein',
    'nickRejected': 'Dieser Nickname ist nicht erlaubt. Versuch einen anderen.',
    'registerError': 'Konto konnte nicht erstellt werden. Prüfe deine Internetverbindung und versuch es erneut.',
    'rouletteTitle': 'Chat-Roulette',
    'rouletteSub': 'Zufälliger Gegner – sofort',
    'myDebates': 'Meine Debatten',
    'noDebates': 'Noch leer. Starte eine Debatte mit einem Menschen!',
    'waitingFor': 'Gegner wird gesucht',
    'yourTurn': 'Du bist dran',
    'theirTurn': 'Gegner ist dran',
    'finishedShort': 'Beendet',
    'searching': 'Gesprächspartner wird gesucht…',
    'randomTopic': 'Zufälliges Thema',
    'randomTopicSubAi': 'Der Würfel wählt das Thema, du die Seite',
    'randomTopicSubHuman': 'Beliebiges Thema und Seite — so findest du am schnellsten jemanden',
    'orPickTopic': 'Oder wähle selbst ein Thema:',
    'anySide': 'EGAL',
    'anySideHint': '„Egal“ — so finden wir schneller jemanden',
    'anyTopic': 'Beliebiges Thema',
    'anySideShort': 'beliebige Seite',
    'searchTopic': 'Thema: {topic}',
    'searchSide': 'Deine Seite: {side}',
    'searchingHint': 'Das dauert meist bis zu einer Minute.',
    'cancel': 'Abbrechen',
    'nobody': 'Gerade sucht niemand einen Gegner. Versuch es später oder spiel gegen die KI.',
    'playAi': 'Gegen die KI spielen',
    'waitingAsync': 'Wir suchen jemanden mit der Gegenposition. Die Debatte erscheint unter „Meine Debatten“.',
    'chooseSideHuman': 'Wähle deine Position. Wir suchen jemanden mit der Gegenposition.',
    'vs': 'gegen',
    'hoursLeft': 'noch {h} Std.',
    'waitOpponent': 'Warten auf die Antwort des Gegners…',
    'showOriginal': 'Übersetzt · Original anzeigen',
    'showTranslation': 'Original · Übersetzung anzeigen',
    'report': 'Melden',
    'block': 'Blockieren',
    'surrender': 'Aufgeben',
    'reportTitle': 'Was ist passiert?',
    'r_insult': 'Beleidigungen',
    'r_hate': 'Hassrede',
    'r_sexual': 'Anstößige Inhalte',
    'r_contact': 'Fragt nach Kontakten oder Spam',
    'r_other': 'Sonstiges',
    'reported': 'Danke! Die Meldung wurde gesendet und der Nutzer blockiert.',
    'blocked': 'Nutzer blockiert.',
    'modBlocked': 'Nachricht nicht gesendet: {reason}',
    'mod_insult': 'Beleidigung oder persönlicher Angriff',
    'mod_hate': 'Hassrede',
    'mod_sexual': 'anstößiger Inhalt',
    'mod_threat': 'Drohungen',
    'mod_contact': 'Kontaktdaten und Links sind nicht erlaubt',
    'mod_other': 'Regelverstoß',
    'forfeitWin': 'Dein Gegner hat nicht rechtzeitig geantwortet – du hast gewonnen!',
    'forfeitLose': 'Du hast nicht rechtzeitig geantwortet – verloren.',
    'oppSurrendered': 'Dein Gegner hat aufgegeben oder die Debatte verlassen – du hast gewonnen!',
    'youSurrendered': 'Du hast die Debatte vorzeitig beendet.',
    'surrenderConfirm': 'Aufgeben? Der Sieg geht an deinen Gegner.',
    'yes': 'Ja',
    'no': 'Nein',
    'networkError': 'Keine Verbindung zum Server. Versuch es erneut.',
    'banned': 'Dein Konto wurde wegen Regelverstößen gesperrt.',
    'loseHuman': 'Dein Gegner hat gewonnen',
    'youVs': 'du  ·  {name}',
    'opponentNoteTitle': 'Über den Gegner',
    'tooShortHuman': 'Zu kurz – schreib mindestens 10 Zeichen',
    'turnChanged': 'Der Zug hat sich schon geändert – Debatte wird aktualisiert.',
    'backHome': 'Zur Startseite',
    'needServer': 'Für Debatten mit Menschen brauchst du Internet und ein Konto.',
    'nickPrefix': 'Du spielst als',
    'toJudges': 'Zu den Richtern',
    'judgesThinking': 'Die Richter beraten…',
    'verdict': 'Urteil der Richter',
    'win': 'Du hast gewonnen!',
    'lose': 'Die KI hat gewonnen',
    'draw': 'Unentschieden',
    'youVsAi': 'du  ·  KI',
    'judge_logic': 'Logik-Richter',
    'judge_evidence': 'Begründungs-Richter',
    'judge_rhetoric': 'Rhetorik-Richter',
    'crit_logic': 'Zusammenhang, Antworten auf Gegenargumente',
    'crit_evidence': 'Beispiele, Gründe, Plausibilität',
    'crit_rhetoric': 'Klarheit, Struktur, Überzeugungskraft',
    'tipTitle': 'Tipp für dich',
    'aiNoteTitle': 'Über die KI',
    'judgesError': 'Die Richter sind gerade nicht erreichbar. Versuch es '
        'später noch einmal.',
    'retry': 'Erneut versuchen',
    'judgeDisclaimer': 'Die Bewertung macht eine KI und kann Fehler enthalten. '
        'Bewertet wird die Qualität der Argumente, nicht die Position.',
  },
  'en': {
    'appTitle': 'Debatos',
    'tagline': 'Debate in any language.\nThree AI judges decide who wins.',
    'modeAiTitle': 'Debate vs AI',
    'modeAiSub': '3 rounds against artificial intelligence',
    'mode3dTitle': '3-day debate',
    'mode3dSub': 'Against a human, reply whenever it suits you',
    'liveTitle': 'Live debate',
    'liveSub': '5 · 10 · 15 · 30 minutes',
    'badgeSoon': 'Soon',
    'badgeV2': 'Version 2',
    'soonMsg': 'Coming in a future version',
    'language': 'Language',
    'languageRow': 'App and debate language',
    'translateTitle': 'AI translation of opponent',
    'translateSub': 'Your opponent writes in their language, you read in yours',
    'chooseTopic': 'Choose a topic',
    'moderationNote': 'Hot topics are moderated: insults and hate speech '
        'are blocked, and violators can be reported.',
    'chooseSide': 'Pick your side. The AI takes the opposite one.',
    'pro': 'FOR',
    'con': 'AGAINST',
    'roundOf': 'Round {n} of {m}',
    'finished': 'Debate finished',
    'r1': 'Opening',
    'r2': 'Rebuttal',
    'r3': 'Closing',
    'hint': '{round} — your argument…',
    'tooShort': 'Too short — write at least one sentence',
    'you': 'You',
    'youColon': 'You: ',
    'aiOpponent': 'AI opponent',
    'aiThinking': 'AI is thinking…',
    'demoMode': 'DEMO MODE',
    'judgesTitle': 'Judges in development',
    'judgesBody': 'We are defining fair scoring criteria. Soon three AI '
        'judges will score logic, evidence and rhetoric.',
    'newDebate': 'New debate',
    'aiOffline': 'AI server unavailable — the demo is replying',
    'cat_hot': 'Hot topics',
    'cat_politics': 'Politics & society',
    'cat_tech': 'Technology',
    'cat_light': 'Light topics',
    'onboardTitle': 'Welcome to Debatos',
    'onboardSub': 'Debate people from all over the world – everyone writes in their own language, AI translates.',
    'rulesTitle': 'Rules',
    'rule1': 'Criticize arguments, not people: no insults, no personal attacks.',
    'rule2': 'No hate speech, no threats, no explicit content.',
    'rule3': 'Do not share contact details (phone, social media, address) or ask for them.',
    'rule4': 'Rule breakers can be reported.',
    'ageCheck': 'I am at least 16 years old and accept the rules',
    'nickLabel': 'Your nickname',
    'start': 'Start',
    'nickError': 'Nickname must be 2 to 20 characters long',
    'nickRejected': 'This nickname is not allowed. Try another one.',
    'registerError': 'Could not create an account. Check your internet connection and try again.',
    'rouletteTitle': 'Chat roulette',
    'rouletteSub': 'Random opponent – right now',
    'myDebates': 'My debates',
    'noDebates': 'Nothing here yet. Start a debate with a human!',
    'waitingFor': 'Looking for an opponent',
    'yourTurn': 'Your turn',
    'theirTurn': 'Opponent’s turn',
    'finishedShort': 'Finished',
    'searching': 'Looking for someone to debate…',
    'randomTopic': 'Random topic',
    'randomTopicSubAi': 'The dice picks the topic, you pick the side',
    'randomTopicSubHuman': 'Any topic, any side — the fastest way to find an opponent',
    'orPickTopic': 'Or pick a topic yourself:',
    'anySide': 'ANY',
    'anySideHint': '“Any” — we’ll find an opponent faster',
    'anyTopic': 'Any topic',
    'anySideShort': 'any side',
    'searchTopic': 'Topic: {topic}',
    'searchSide': 'Your side: {side}',
    'searchingHint': 'It usually takes up to a minute.',
    'cancel': 'Cancel',
    'nobody': 'Nobody is looking for an opponent right now. Try later or play against the AI.',
    'playAi': 'Play against AI',
    'waitingAsync': 'Looking for someone with the opposite view. The debate will appear in “My debates”.',
    'chooseSideHuman': 'Pick your side. We will look for someone with the opposite view.',
    'vs': 'vs',
    'hoursLeft': '{h} h left',
    'waitOpponent': 'Waiting for your opponent’s reply…',
    'showOriginal': 'Translated · show original',
    'showTranslation': 'Original · show translation',
    'report': 'Report',
    'block': 'Block',
    'surrender': 'Give up',
    'reportTitle': 'What happened?',
    'r_insult': 'Insults',
    'r_hate': 'Hate speech',
    'r_sexual': 'Explicit content',
    'r_contact': 'Asks for contacts or spam',
    'r_other': 'Other',
    'reported': 'Thank you! The report was sent and the user has been blocked.',
    'blocked': 'User blocked.',
    'modBlocked': 'Message not sent: {reason}',
    'mod_insult': 'insult or personal attack',
    'mod_hate': 'hate speech',
    'mod_sexual': 'explicit content',
    'mod_threat': 'threats',
    'mod_contact': 'contacts and links are not allowed',
    'mod_other': 'rule violation',
    'forfeitWin': 'Your opponent did not reply in time – you win!',
    'forfeitLose': 'You did not reply in time – you lose.',
    'oppSurrendered': 'Your opponent gave up or left the debate – you win!',
    'youSurrendered': 'You ended the debate early.',
    'surrenderConfirm': 'Give up? The win goes to your opponent.',
    'yes': 'Yes',
    'no': 'No',
    'networkError': 'No connection to the server. Please try again.',
    'banned': 'Your account was blocked for breaking the rules.',
    'loseHuman': 'Your opponent wins',
    'youVs': 'you  ·  {name}',
    'opponentNoteTitle': 'About your opponent',
    'tooShortHuman': 'Too short – write at least 10 characters',
    'turnChanged': 'The turn has already changed – refreshing the debate.',
    'backHome': 'Home',
    'needServer': 'Debates with people need internet and an account.',
    'nickPrefix': 'You play as',
    'toJudges': 'To the judges',
    'judgesThinking': 'The judges are deliberating…',
    'verdict': 'Verdict',
    'win': 'You win!',
    'lose': 'AI wins',
    'draw': 'Draw',
    'youVsAi': 'you  ·  AI',
    'judge_logic': 'Logic judge',
    'judge_evidence': 'Evidence judge',
    'judge_rhetoric': 'Rhetoric judge',
    'crit_logic': 'Coherence, answering the opponent',
    'crit_evidence': 'Examples, reasons, plausibility',
    'crit_rhetoric': 'Clarity, structure, persuasiveness',
    'tipTitle': 'Tip for you',
    'aiNoteTitle': 'About the AI',
    'judgesError': 'The judges are unavailable right now. Please try again '
        'later.',
    'retry': 'Try again',
    'judgeDisclaimer': 'Scoring is done by AI and can be wrong. Judges rate '
        'the quality of arguments, not the position.',
  },
  'es': {
    'appTitle': 'Debatos',
    'tagline': 'Debate en cualquier idioma.\nTres jueces de IA deciden quién gana.',
    'modeAiTitle': 'Debate contra la IA',
    'modeAiSub': '3 rondas contra la inteligencia artificial',
    'mode3dTitle': 'Debate de 3 días',
    'mode3dSub': 'Contra una persona, responde cuando quieras',
    'liveTitle': 'Debate en vivo',
    'liveSub': '5 · 10 · 15 · 30 minutos',
    'badgeSoon': 'Pronto',
    'badgeV2': 'Versión 2',
    'soonMsg': 'Llegará en una próxima versión',
    'language': 'Idioma',
    'languageRow': 'Idioma de la app y los debates',
    'translateTitle': 'Traducción IA del oponente',
    'translateSub': 'Tu oponente escribe en su idioma, tú lees en el tuyo',
    'chooseTopic': 'Elige un tema',
    'moderationNote': 'Los temas candentes se moderan: los insultos y el '
        'discurso de odio se bloquean y se puede denunciar a los infractores.',
    'chooseSide': 'Elige tu postura. La IA tomará la contraria.',
    'pro': 'A FAVOR',
    'con': 'EN CONTRA',
    'roundOf': 'Ronda {n} de {m}',
    'finished': 'Debate terminado',
    'r1': 'Apertura',
    'r2': 'Réplica',
    'r3': 'Cierre',
    'hint': '{round}: tu argumento…',
    'tooShort': 'Demasiado corto: escribe al menos una frase',
    'you': 'Tú',
    'youColon': 'Tú: ',
    'aiOpponent': 'Oponente IA',
    'aiThinking': 'La IA está pensando…',
    'demoMode': 'MODO DEMO',
    'judgesTitle': 'Jueces en desarrollo',
    'judgesBody': 'Estamos definiendo criterios de evaluación justos. '
        'Pronto, tres jueces de IA evaluarán la lógica, las pruebas y la '
        'retórica.',
    'newDebate': 'Nuevo debate',
    'aiOffline': 'Servidor de IA no disponible: responde la demo',
    'cat_hot': 'Temas candentes',
    'cat_politics': 'Política y sociedad',
    'cat_tech': 'Tecnología',
    'cat_light': 'Temas ligeros',
    'onboardTitle': 'Bienvenido a Debatos',
    'onboardSub': 'Debate con gente de todo el mundo: cada uno escribe en su idioma y la IA traduce.',
    'rulesTitle': 'Normas',
    'rule1': 'Critica los argumentos, no a las personas: sin insultos ni ataques personales.',
    'rule2': 'Sin discurso de odio, amenazas ni contenido inapropiado.',
    'rule3': 'No compartas datos de contacto (teléfono, redes sociales, dirección) ni los pidas.',
    'rule4': 'Se puede denunciar a quien incumpla las normas.',
    'ageCheck': 'Tengo al menos 16 años y acepto las normas',
    'nickLabel': 'Tu apodo',
    'start': 'Empezar',
    'nickError': 'El apodo debe tener entre 2 y 20 caracteres',
    'nickRejected': 'Ese apodo no está permitido. Prueba con otro.',
    'registerError': 'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.',
    'rouletteTitle': 'Chat ruleta',
    'rouletteSub': 'Rival al azar, ahora mismo',
    'myDebates': 'Mis debates',
    'noDebates': 'Aún no hay nada. ¡Empieza un debate con una persona!',
    'waitingFor': 'Buscando rival',
    'yourTurn': 'Tu turno',
    'theirTurn': 'Turno del rival',
    'finishedShort': 'Terminado',
    'searching': 'Buscando a alguien para debatir…',
    'randomTopic': 'Tema aleatorio',
    'randomTopicSubAi': 'El dado elige el tema, tú la postura',
    'randomTopicSubHuman': 'Cualquier tema y postura: la forma más rápida de encontrar rival',
    'orPickTopic': 'O elige tú el tema:',
    'anySide': 'CUALQUIERA',
    'anySideHint': '«Cualquiera»: encontraremos rival más rápido',
    'anyTopic': 'Cualquier tema',
    'anySideShort': 'cualquier postura',
    'searchTopic': 'Tema: {topic}',
    'searchSide': 'Tu postura: {side}',
    'searchingHint': 'Suele tardar hasta un minuto.',
    'cancel': 'Cancelar',
    'nobody': 'Ahora mismo nadie busca rival. Inténtalo más tarde o juega contra la IA.',
    'playAi': 'Jugar contra la IA',
    'waitingAsync': 'Buscamos a alguien con la postura contraria. El debate aparecerá en «Mis debates».',
    'chooseSideHuman': 'Elige tu postura. Buscaremos a alguien con la contraria.',
    'vs': 'contra',
    'hoursLeft': 'quedan {h} h',
    'waitOpponent': 'Esperando la respuesta del rival…',
    'showOriginal': 'Traducido · ver original',
    'showTranslation': 'Original · ver traducción',
    'report': 'Denunciar',
    'block': 'Bloquear',
    'surrender': 'Rendirse',
    'reportTitle': '¿Qué ha pasado?',
    'r_insult': 'Insultos',
    'r_hate': 'Discurso de odio',
    'r_sexual': 'Contenido inapropiado',
    'r_contact': 'Pide contactos o spam',
    'r_other': 'Otro',
    'reported': '¡Gracias! La denuncia se ha enviado y el usuario ha sido bloqueado.',
    'blocked': 'Usuario bloqueado.',
    'modBlocked': 'Mensaje no enviado: {reason}',
    'mod_insult': 'insulto o ataque personal',
    'mod_hate': 'discurso de odio',
    'mod_sexual': 'contenido inapropiado',
    'mod_threat': 'amenazas',
    'mod_contact': 'no se permiten contactos ni enlaces',
    'mod_other': 'infracción de las normas',
    'forfeitWin': 'Tu rival no respondió a tiempo: ¡has ganado!',
    'forfeitLose': 'No respondiste a tiempo: has perdido.',
    'oppSurrendered': 'Tu rival se rindió o abandonó el debate: ¡has ganado!',
    'youSurrendered': 'Terminaste el debate antes de tiempo.',
    'surrenderConfirm': '¿Rendirte? La victoria será para tu rival.',
    'yes': 'Sí',
    'no': 'No',
    'networkError': 'Sin conexión con el servidor. Inténtalo de nuevo.',
    'banned': 'Tu cuenta ha sido bloqueada por incumplir las normas.',
    'loseHuman': 'Ha ganado tu rival',
    'youVs': 'tú  ·  {name}',
    'opponentNoteTitle': 'Sobre tu rival',
    'tooShortHuman': 'Demasiado corto: escribe al menos 10 caracteres',
    'turnChanged': 'El turno ya ha cambiado: actualizando el debate.',
    'backHome': 'Inicio',
    'needServer': 'Para debatir con personas necesitas internet y una cuenta.',
    'nickPrefix': 'Juegas como',
    'toJudges': 'A los jueces',
    'judgesThinking': 'Los jueces deliberan…',
    'verdict': 'Veredicto de los jueces',
    'win': '¡Has ganado!',
    'lose': 'Ha ganado la IA',
    'draw': 'Empate',
    'youVsAi': 'tú  ·  IA',
    'judge_logic': 'Juez de lógica',
    'judge_evidence': 'Juez de fundamentación',
    'judge_rhetoric': 'Juez de retórica',
    'crit_logic': 'Coherencia, respuesta al oponente',
    'crit_evidence': 'Ejemplos, razones, verosimilitud',
    'crit_rhetoric': 'Claridad, estructura, persuasión',
    'tipTitle': 'Consejo para ti',
    'aiNoteTitle': 'Sobre la IA',
    'judgesError': 'Los jueces no están disponibles ahora. Inténtalo más '
        'tarde.',
    'retry': 'Reintentar',
    'judgeDisclaimer': 'La evaluación la hace una IA y puede equivocarse. Se '
        'valora la calidad de los argumentos, no la postura.',
  },
  'fr': {
    'appTitle': 'Debatos',
    'tagline': 'Débats dans n’importe quelle langue.\nTrois juges IA désignent le gagnant.',
    'modeAiTitle': 'Débat contre l’IA',
    'modeAiSub': '3 manches contre l’intelligence artificielle',
    'mode3dTitle': 'Débat sur 3 jours',
    'mode3dSub': 'Contre un humain, réponds quand tu veux',
    'liveTitle': 'Débat en direct',
    'liveSub': '5 · 10 · 15 · 30 minutes',
    'badgeSoon': 'Bientôt',
    'badgeV2': 'Version 2',
    'soonMsg': 'Disponible dans une prochaine version',
    'language': 'Langue',
    'languageRow': 'Langue de l’appli et des débats',
    'translateTitle': 'Traduction IA de l’adversaire',
    'translateSub': 'Ton adversaire écrit dans sa langue, tu lis dans la tienne',
    'chooseTopic': 'Choisis un sujet',
    'moderationNote': 'Les sujets sensibles sont modérés : insultes et discours haineux sont bloqués, et les fautifs peuvent être signalés.',
    'chooseSide': 'Choisis ton camp. L’IA prendra le camp opposé.',
    'pro': 'POUR',
    'con': 'CONTRE',
    'roundOf': 'Manche {n} sur {m}',
    'finished': 'Débat terminé',
    'r1': 'Ouverture',
    'r2': 'Réfutation',
    'r3': 'Conclusion',
    'hint': '{round} — ton argument…',
    'tooShort': 'Trop court — écris au moins une phrase',
    'you': 'Toi',
    'youColon': 'Toi : ',
    'aiOpponent': 'Adversaire IA',
    'aiThinking': 'L’IA réfléchit…',
    'demoMode': 'MODE DÉMO',
    'judgesTitle': 'Juges en développement',
    'judgesBody': 'Nous définissons des critères d’évaluation équitables. Bientôt, trois juges IA noteront la logique, les preuves et la rhétorique.',
    'newDebate': 'Nouveau débat',
    'aiOffline': 'Serveur IA indisponible — la démo répond',
    'cat_hot': 'Sujets brûlants',
    'cat_politics': 'Politique et société',
    'cat_tech': 'Technologie',
    'cat_light': 'Sujets légers',
    'onboardTitle': 'Bienvenue sur Debatos',
    'onboardSub': 'Débats avec des gens du monde entier — chacun écrit dans sa langue, l’IA traduit.',
    'rulesTitle': 'Règles',
    'rule1': 'Critique les arguments, pas les personnes : pas d’insultes ni d’attaques personnelles.',
    'rule2': 'Pas de discours haineux, de menaces ni de contenu explicite.',
    'rule3': 'Ne partage pas tes coordonnées (téléphone, réseaux sociaux, adresse) et ne les demande pas.',
    'rule4': 'Les fautifs peuvent être signalés.',
    'ageCheck': 'J’ai au moins 16 ans et j’accepte les règles',
    'nickLabel': 'Ton pseudo',
    'start': 'Commencer',
    'nickError': 'Le pseudo doit contenir de 2 à 20 caractères',
    'nickRejected': 'Ce pseudo n’est pas autorisé. Essaie-en un autre.',
    'registerError': 'Impossible de créer le compte. Vérifie ta connexion et réessaie.',
    'rouletteTitle': 'Chat-roulette',
    'rouletteSub': 'Un adversaire au hasard — tout de suite',
    'myDebates': 'Mes débats',
    'noDebates': 'Rien pour l’instant. Lance un débat avec un humain !',
    'waitingFor': 'Recherche d’un adversaire',
    'yourTurn': 'À toi',
    'theirTurn': 'Au tour de l’adversaire',
    'finishedShort': 'Terminé',
    'searching': 'Recherche d’un adversaire…',
    'randomTopic': 'Sujet au hasard',
    'randomTopicSubAi': 'Le dé choisit le sujet, toi le camp',
    'randomTopicSubHuman': 'N’importe quel sujet et camp — le plus rapide pour trouver un adversaire',
    'orPickTopic': 'Ou choisis un sujet toi-même :',
    'anySide': 'PEU IMPORTE',
    'anySideHint': '« Peu importe » — on trouvera un adversaire plus vite',
    'anyTopic': 'N’importe quel sujet',
    'anySideShort': 'n’importe quel camp',
    'searchTopic': 'Sujet : {topic}',
    'searchSide': 'Ton camp : {side}',
    'searchingHint': 'Cela prend généralement moins d’une minute.',
    'cancel': 'Annuler',
    'nobody': 'Personne ne cherche d’adversaire pour l’instant. Réessaie plus tard ou joue contre l’IA.',
    'playAi': 'Jouer contre l’IA',
    'waitingAsync': 'On cherche quelqu’un d’un avis opposé. Le débat apparaîtra dans « Mes débats ».',
    'chooseSideHuman': 'Choisis ton camp. On cherchera quelqu’un d’un avis opposé.',
    'vs': 'contre',
    'hoursLeft': 'Encore {h} h',
    'waitOpponent': 'En attente de la réponse de l’adversaire…',
    'showOriginal': 'Traduit · voir l’original',
    'showTranslation': 'Original · voir la traduction',
    'report': 'Signaler',
    'block': 'Bloquer',
    'surrender': 'Abandonner',
    'reportTitle': 'Que s’est-il passé ?',
    'r_insult': 'Insultes',
    'r_hate': 'Discours haineux',
    'r_sexual': 'Contenu explicite',
    'r_contact': 'Demande des coordonnées ou spam',
    'r_other': 'Autre',
    'reported': 'Merci ! Le signalement est envoyé et l’utilisateur a été bloqué.',
    'blocked': 'Utilisateur bloqué.',
    'modBlocked': 'Message non envoyé : {reason}',
    'mod_insult': 'insulte ou attaque personnelle',
    'mod_hate': 'discours haineux',
    'mod_sexual': 'contenu explicite',
    'mod_threat': 'menaces',
    'mod_contact': 'les coordonnées et les liens sont interdits',
    'mod_other': 'violation des règles',
    'forfeitWin': 'Ton adversaire n’a pas répondu à temps — tu gagnes !',
    'forfeitLose': 'Tu n’as pas répondu à temps — défaite.',
    'oppSurrendered': 'Ton adversaire a abandonné ou quitté le débat — tu gagnes !',
    'youSurrendered': 'Tu as terminé le débat avant la fin.',
    'surrenderConfirm': 'Abandonner ? La victoire ira à ton adversaire.',
    'yes': 'Oui',
    'no': 'Non',
    'networkError': 'Pas de connexion au serveur. Réessaie.',
    'banned': 'Ton compte a été bloqué pour non-respect des règles.',
    'loseHuman': 'Ton adversaire gagne',
    'youVs': 'toi  ·  {name}',
    'opponentNoteTitle': 'Sur ton adversaire',
    'tooShortHuman': 'Trop court — écris au moins 10 caractères',
    'turnChanged': 'Le tour a déjà changé — actualisation du débat.',
    'backHome': 'Accueil',
    'needServer': 'Les débats avec des humains nécessitent Internet et un compte.',
    'nickPrefix': 'Tu joues en tant que',
    'toJudges': 'Aux juges',
    'judgesThinking': 'Les juges délibèrent…',
    'verdict': 'Verdict',
    'win': 'Tu gagnes !',
    'lose': 'L’IA gagne',
    'draw': 'Égalité',
    'youVsAi': 'toi  ·  IA',
    'judge_logic': 'Juge de la logique',
    'judge_evidence': 'Juge des preuves',
    'judge_rhetoric': 'Juge de la rhétorique',
    'crit_logic': 'Cohérence, réponses à l’adversaire',
    'crit_evidence': 'Exemples, raisons, vraisemblance',
    'crit_rhetoric': 'Clarté, structure, force de conviction',
    'tipTitle': 'Conseil pour toi',
    'aiNoteTitle': 'Sur l’IA',
    'judgesError': 'Les juges sont indisponibles pour le moment. Réessaie plus tard.',
    'retry': 'Réessayer',
    'judgeDisclaimer': 'La notation est faite par une IA et peut se tromper. Les juges évaluent la qualité des arguments, pas la position.',
  },
  'ru': {
    'appTitle': 'Debatos',
    'tagline': 'Спорь на любом языке.\nТри AI-судьи решат, кто победил.',
    'modeAiTitle': 'Дебаты с AI',
    'modeAiSub': '3 раунда против искусственного интеллекта',
    'mode3dTitle': 'Дебаты на 3 дня',
    'mode3dSub': 'С человеком, отвечай когда удобно',
    'liveTitle': 'Живые дебаты',
    'liveSub': '5 · 10 · 15 · 30 минут',
    'badgeSoon': 'Скоро',
    'badgeV2': 'Версия 2',
    'soonMsg': 'Появится в следующей версии',
    'language': 'Язык',
    'languageRow': 'Язык приложения и дебатов',
    'translateTitle': 'AI-перевод соперника',
    'translateSub': 'Соперник пишет на своём языке, ты читаешь на своём',
    'chooseTopic': 'Выбери тему',
    'moderationNote': 'Острые темы модерируются: оскорбления и язык вражды блокируются, на нарушителей можно пожаловаться.',
    'chooseSide': 'Выбери свою сторону. AI займёт противоположную.',
    'pro': 'ЗА',
    'con': 'ПРОТИВ',
    'roundOf': 'Раунд {n} из {m}',
    'finished': 'Дебаты завершены',
    'r1': 'Вступление',
    'r2': 'Опровержение',
    'r3': 'Заключение',
    'hint': '{round} — твой аргумент…',
    'tooShort': 'Слишком коротко — напиши хотя бы одно предложение',
    'you': 'Ты',
    'youColon': 'Ты: ',
    'aiOpponent': 'AI-соперник',
    'aiThinking': 'AI думает…',
    'demoMode': 'ДЕМО-РЕЖИМ',
    'judgesTitle': 'Судьи в разработке',
    'judgesBody': 'Мы определяем честные критерии оценки. Скоро три AI-судьи будут оценивать логику, доказательства и риторику.',
    'newDebate': 'Новые дебаты',
    'aiOffline': 'AI-сервер недоступен — отвечает демо',
    'cat_hot': 'Острые темы',
    'cat_politics': 'Политика и общество',
    'cat_tech': 'Технологии',
    'cat_light': 'Лёгкие темы',
    'onboardTitle': 'Добро пожаловать в Debatos',
    'onboardSub': 'Спорь с людьми со всего мира — каждый пишет на своём языке, AI переводит.',
    'rulesTitle': 'Правила',
    'rule1': 'Критикуй аргументы, а не людей: без оскорблений и перехода на личности.',
    'rule2': 'Без языка вражды, угроз и откровенного контента.',
    'rule3': 'Не делись контактами (телефон, соцсети, адрес) и не проси их.',
    'rule4': 'На нарушителей можно пожаловаться.',
    'ageCheck': 'Мне есть 16 лет, и я принимаю правила',
    'nickLabel': 'Твой ник',
    'start': 'Начать',
    'nickError': 'Ник должен быть от 2 до 20 символов',
    'nickRejected': 'Такой ник нельзя использовать. Попробуй другой.',
    'registerError': 'Не удалось создать аккаунт. Проверь интернет и попробуй ещё раз.',
    'rouletteTitle': 'Чат-рулетка',
    'rouletteSub': 'Случайный соперник — прямо сейчас',
    'myDebates': 'Мои дебаты',
    'noDebates': 'Пока пусто. Начни дебаты с человеком!',
    'waitingFor': 'Ищем соперника',
    'yourTurn': 'Твой ход',
    'theirTurn': 'Ход соперника',
    'finishedShort': 'Завершено',
    'searching': 'Ищем, с кем поспорить…',
    'randomTopic': 'Случайная тема',
    'randomTopicSubAi': 'Тему выберет кубик, сторону — ты',
    'randomTopicSubHuman': 'Любая тема и сторона — соперник найдётся быстрее всего',
    'orPickTopic': 'Или выбери тему сам:',
    'anySide': 'ЛЮБАЯ',
    'anySideHint': '«Любая» — найдём соперника быстрее',
    'anyTopic': 'Любая тема',
    'anySideShort': 'любая сторона',
    'searchTopic': 'Тема: {topic}',
    'searchSide': 'Твоя сторона: {side}',
    'searchingHint': 'Обычно это занимает до минуты.',
    'cancel': 'Отмена',
    'nobody': 'Сейчас никто не ищет соперника. Попробуй позже или сыграй с AI.',
    'playAi': 'Играть с AI',
    'waitingAsync': 'Ищем человека с противоположной позицией. Дебаты появятся в «Моих дебатах».',
    'chooseSideHuman': 'Выбери сторону. Мы найдём человека с противоположной позицией.',
    'vs': 'против',
    'hoursLeft': 'Осталось {h} ч',
    'waitOpponent': 'Ждём ответа соперника…',
    'showOriginal': 'Переведено · показать оригинал',
    'showTranslation': 'Оригинал · показать перевод',
    'report': 'Пожаловаться',
    'block': 'Заблокировать',
    'surrender': 'Сдаться',
    'reportTitle': 'Что случилось?',
    'r_insult': 'Оскорбления',
    'r_hate': 'Язык вражды',
    'r_sexual': 'Откровенный контент',
    'r_contact': 'Просит контакты или спам',
    'r_other': 'Другое',
    'reported': 'Спасибо! Жалоба отправлена, пользователь заблокирован.',
    'blocked': 'Пользователь заблокирован.',
    'modBlocked': 'Сообщение не отправлено: {reason}',
    'mod_insult': 'оскорбление или переход на личности',
    'mod_hate': 'язык вражды',
    'mod_sexual': 'откровенный контент',
    'mod_threat': 'угрозы',
    'mod_contact': 'контакты и ссылки запрещены',
    'mod_other': 'нарушение правил',
    'forfeitWin': 'Соперник не ответил вовремя — ты победил!',
    'forfeitLose': 'Ты не ответил вовремя — поражение.',
    'oppSurrendered': 'Соперник сдался или вышел из дебатов — ты победил!',
    'youSurrendered': 'Ты завершил дебаты досрочно.',
    'surrenderConfirm': 'Сдаться? Победа достанется сопернику.',
    'yes': 'Да',
    'no': 'Нет',
    'networkError': 'Нет связи с сервером. Попробуй ещё раз.',
    'banned': 'Твой аккаунт заблокирован за нарушение правил.',
    'loseHuman': 'Победил соперник',
    'youVs': 'ты  ·  {name}',
    'opponentNoteTitle': 'О сопернике',
    'tooShortHuman': 'Слишком коротко — напиши хотя бы 10 символов',
    'turnChanged': 'Ход уже сменился — обновляем дебаты.',
    'backHome': 'На главную',
    'needServer': 'Для дебатов с людьми нужен интернет и аккаунт.',
    'nickPrefix': 'Ты играешь как',
    'toJudges': 'К судьям',
    'judgesThinking': 'Судьи совещаются…',
    'verdict': 'Вердикт',
    'win': 'Ты победил!',
    'lose': 'Победил AI',
    'draw': 'Ничья',
    'youVsAi': 'ты  ·  AI',
    'judge_logic': 'Судья логики',
    'judge_evidence': 'Судья доказательств',
    'judge_rhetoric': 'Судья риторики',
    'crit_logic': 'Последовательность, ответы сопернику',
    'crit_evidence': 'Примеры, причины, правдоподобие',
    'crit_rhetoric': 'Ясность, структура, убедительность',
    'tipTitle': 'Совет тебе',
    'aiNoteTitle': 'Об AI',
    'judgesError': 'Судьи сейчас недоступны. Попробуй позже.',
    'retry': 'Попробовать ещё раз',
    'judgeDisclaimer': 'Оценку ставит AI, он может ошибаться. Судьи оценивают качество аргументов, а не позицию.',
  },
};

// ===================== моделі =====================
enum Side { pro, con }

enum Speaker { user, ai }

extension SideX on Side {
  String get label => tr(this == Side.pro ? 'pro' : 'con');
  String labelIn(String lang) =>
      _strings[lang]?[this == Side.pro ? 'pro' : 'con'] ?? label;
  Side get opposite => this == Side.pro ? Side.con : Side.pro;
}

class Topic {
  final String id;
  final String category;
  final Map<String, String> titles;

  const Topic({required this.id, required this.category, required this.titles});

  String titleIn(String lang) => titles[lang] ?? titles['en']!;
  String get title => titleIn(appLang.value);
}

class JudgeScore {
  final String key;
  final int user;
  final int ai;
  final String note;
  final String aiNote;

  const JudgeScore({
    required this.key,
    required this.user,
    required this.ai,
    required this.note,
    required this.aiNote,
  });
}

class Verdict {
  final List<JudgeScore> scores;
  final String tip;

  const Verdict(this.scores, this.tip);

  int get userTotal => scores.fold(0, (sum, s) => sum + s.user);
  int get aiTotal => scores.fold(0, (sum, s) => sum + s.ai);
  bool get isDraw => userTotal == aiTotal;
  bool get userWins => userTotal > aiTotal;
}

class DebateMessage {
  final Speaker speaker;
  final String text;

  const DebateMessage({required this.speaker, required this.text});
}

// ===================== теми =====================
const List<String> categories = ['hot', 'politics', 'tech', 'light'];

const List<Topic> topics = [
  Topic(id: 'same-sex-marriage', category: 'hot', titles: {
    'uk': 'Одностатеві шлюби мають бути легальними в усіх країнах ЄС',
    'de': 'Die gleichgeschlechtliche Ehe sollte in allen EU-Ländern legal sein',
    'en': 'Same-sex marriage should be legal in every EU country',
    'es': 'El matrimonio entre personas del mismo sexo debería ser legal en '
        'todos los países de la UE',
    'fr': 'Le mariage homosexuel devrait être légal dans tous les pays de l’UE',
    'ru': 'Однополые браки должны быть легальны во всех странах ЕС',
  }),
  Topic(id: 'euthanasia', category: 'hot', titles: {
    'uk': 'Евтаназія має бути легальною для дорослих за їхнім бажанням',
    'de': 'Sterbehilfe sollte für Erwachsene auf eigenen Wunsch legal sein',
    'en': 'Euthanasia should be legal for adults who request it',
    'es': 'La eutanasia debería ser legal para los adultos que la soliciten',
    'fr': 'L’euthanasie devrait être légale pour les adultes qui la demandent',
    'ru': 'Эвтаназия должна быть легальной для взрослых по их желанию',
  }),
  Topic(id: 'abortion', category: 'hot', titles: {
    'uk': 'Аборт має бути легальним на вимогу жінки до 12-го тижня',
    'de': 'Abtreibung sollte bis zur 12. Woche auf Wunsch der Frau legal sein',
    'en': 'Abortion should be legal on request up to the 12th week',
    'es': 'El aborto debería ser legal a petición de la mujer hasta la '
        'semana 12',
    'fr': 'L’avortement devrait être légal sur demande jusqu’à la 12e semaine',
    'ru': 'Аборт должен быть легальным по желанию женщины до 12-й недели',
  }),
  Topic(id: 'guns', category: 'hot', titles: {
    'uk': 'Громадяни мають право вільно носити зброю',
    'de': 'Bürger sollten das Recht haben, frei Waffen zu tragen',
    'en': 'Citizens should have the right to carry guns freely',
    'es': 'Los ciudadanos deberían tener derecho a portar armas libremente',
    'fr': 'Les citoyens devraient avoir le droit de porter librement une arme',
    'ru': 'Граждане должны иметь право свободно носить оружие',
  }),
  Topic(id: 'palestine', category: 'hot', titles: {
    'uk': 'Європейські країни мають визнати державу Палестина',
    'de': 'Europäische Staaten sollten den Staat Palästina anerkennen',
    'en': 'European countries should recognise the State of Palestine',
    'es': 'Los países europeos deberían reconocer el Estado de Palestina',
    'fr': 'Les pays européens devraient reconnaître l’État de Palestine',
    'ru': 'Европейские страны должны признать государство Палестина',
  }),
  Topic(id: 'death-penalty', category: 'hot', titles: {
    'uk': 'Смертна кара має бути дозволена за найтяжчі злочини',
    'de': 'Die Todesstrafe sollte für die schwersten Verbrechen erlaubt sein',
    'en': 'The death penalty should be allowed for the most serious crimes',
    'es': 'La pena de muerte debería permitirse para los delitos más graves',
    'fr': 'La peine de mort devrait être autorisée pour les crimes les plus graves',
    'ru': 'Смертная казнь должна быть разрешена за самые тяжкие преступления',
  }),
  Topic(id: 'conscription', category: 'politics', titles: {
    'uk': 'Обовʼязкова військова служба має бути в кожній країні ЄС',
    'de': 'Jedes EU-Land sollte eine Wehrpflicht haben',
    'en': 'Every EU country should have mandatory military service',
    'es': 'Todos los países de la UE deberían tener servicio militar '
        'obligatorio',
    'fr': 'Chaque pays de l’UE devrait avoir un service militaire obligatoire',
    'ru': 'Обязательная военная служба должна быть в каждой стране ЕС',
  }),
  Topic(id: 'ubi', category: 'politics', titles: {
    'uk': 'Безумовний базовий дохід — краще рішення, ніж соцдопомога',
    'de': 'Ein bedingungsloses Grundeinkommen ist besser als Sozialhilfe',
    'en': 'Universal basic income is better than welfare benefits',
    'es': 'La renta básica universal es mejor que las ayudas sociales',
    'fr': 'Le revenu universel est meilleur que les aides sociales',
    'ru': 'Безусловный базовый доход — лучшее решение, чем соцпомощь',
  }),
  Topic(id: 'four-day-week', category: 'politics', titles: {
    'uk': 'Робочий тиждень має бути чотириденним',
    'de': 'Die Arbeitswoche sollte vier Tage haben',
    'en': 'The working week should be four days long',
    'es': 'La semana laboral debería ser de cuatro días',
    'fr': 'La semaine de travail devrait durer quatre jours',
    'ru': 'Рабочая неделя должна быть четырёхдневной',
  }),
  Topic(id: 'voting-16', category: 'politics', titles: {
    'uk': 'Голосувати на виборах можна з 16 років',
    'de': 'Wählen sollte ab 16 Jahren erlaubt sein',
    'en': 'People should be able to vote from age 16',
    'es': 'Se debería poder votar desde los 16 años',
    'fr': 'On devrait pouvoir voter dès 16 ans',
    'ru': 'Голосовать на выборах можно с 16 лет',
  }),
  Topic(id: 'social-media-16', category: 'tech', titles: {
    'uk': 'Соцмережі треба заборонити дітям до 16 років',
    'de': 'Soziale Medien sollten für Kinder unter 16 verboten werden',
    'en': 'Social media should be banned for children under 16',
    'es': 'Las redes sociales deberían prohibirse a los menores de 16 años',
    'fr': 'Les réseaux sociaux devraient être interdits aux moins de 16 ans',
    'ru': 'Соцсети нужно запретить детям до 16 лет',
  }),
  Topic(id: 'ai-jobs', category: 'tech', titles: {
    'uk': 'AI за 20 років забере більшість професій',
    'de': 'KI wird in 20 Jahren die meisten Berufe ersetzen',
    'en': 'AI will replace most jobs within 20 years',
    'es': 'La IA sustituirá la mayoría de los empleos en 20 años',
    'fr': 'L’IA remplacera la plupart des métiers d’ici 20 ans',
    'ru': 'AI за 20 лет заменит большинство профессий',
  }),
  Topic(id: 'nuclear', category: 'tech', titles: {
    'uk': 'Атомна енергетика — найкращий шлях до кліматичних цілей',
    'de': 'Atomkraft ist der beste Weg zu den Klimazielen',
    'en': 'Nuclear power is the best path to climate goals',
    'es': 'La energía nuclear es el mejor camino hacia los objetivos '
        'climáticos',
    'fr': 'Le nucléaire est la meilleure voie vers les objectifs climatiques',
    'ru': 'Атомная энергетика — лучший путь к климатическим целям',
  }),
  Topic(id: 'pineapple-pizza', category: 'light', titles: {
    'uk': 'Піца з ананасом — це нормально',
    'de': 'Pizza mit Ananas ist völlig in Ordnung',
    'en': 'Pineapple on pizza is perfectly fine',
    'es': 'La pizza con piña está perfectamente bien',
    'fr': 'La pizza à l’ananas, c’est tout à fait acceptable',
    'ru': 'Пицца с ананасом — это нормально',
  }),
  Topic(id: 'cats-dogs', category: 'light', titles: {
    'uk': 'Коти кращі за собак',
    'de': 'Katzen sind besser als Hunde',
    'en': 'Cats are better than dogs',
    'es': 'Los gatos son mejores que los perros',
    'fr': 'Les chats sont meilleurs que les chiens',
    'ru': 'Кошки лучше собак',
  }),
  Topic(id: 'remote-school', category: 'light', titles: {
    'uk': 'Школа має бути онлайн хоча б двічі на тиждень',
    'de': 'Schule sollte mindestens zweimal pro Woche online sein',
    'en': 'School should be online at least twice a week',
    'es': 'La escuela debería ser en línea al menos dos veces por semana',
    'fr': 'L’école devrait se faire en ligne au moins deux fois par semaine',
    'ru': 'Школа должна быть онлайн хотя бы два раза в неделю',
  }),
];

List<Topic> topicsIn(String category) =>
    topics.where((t) => t.category == category).toList();

// ===================== AI =====================

class AiReply {
  final String text;
  final bool fellBack;

  const AiReply(this.text, {this.fellBack = false});
}

class AiClient {
  final DemoAi _demo = DemoAi();

  bool get isDemo => aiServerUrl.isEmpty;

  Future<AiReply> reply({
    required String lang,
    required Topic topic,
    required Side aiSide,
    required int round,
    required List<DebateMessage> history,
  }) async {
    if (!isDemo) {
      try {
        final data = await _post({
          'lang': lang,
          'topic': topic.titleIn(lang),
          'aiSide': aiSide == Side.pro ? 'pro' : 'con',
          'round': round,
          'rounds': debateRounds,
          'history': _history(history),
        }, const Duration(seconds: 45));
        final text = data is Map ? (data['reply'] ?? '').toString().trim() : '';
        if (text.isEmpty) throw Exception('empty reply');
        return AiReply(text);
      } catch (_) {
        final text = await _demo.reply(
            lang: lang, aiSide: aiSide, round: round, history: history);
        return AiReply(text, fellBack: true);
      }
    }
    final text = await _demo.reply(
        lang: lang, aiSide: aiSide, round: round, history: history);
    return AiReply(text);
  }

  /// Оцінка трьох AI-суддів. null — судді недоступні.
  Future<Verdict?> judge({
    required String lang,
    required Topic topic,
    required Side userSide,
    required List<DebateMessage> history,
  }) async {
    if (isDemo) return null;
    try {
      final data = await _post({
        'mode': 'judge',
        'lang': lang,
        'topic': topic.titleIn(lang),
        'userSide': userSide == Side.pro ? 'pro' : 'con',
        'history': _history(history),
      }, const Duration(seconds: 75));
      return parseVerdict(data);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, String>> _history(List<DebateMessage> history) => [
        for (final m in history)
          {
            'speaker': m.speaker == Speaker.user ? 'user' : 'ai',
            'text': m.text,
          },
      ];

  Future<Object?> _post(Map<String, Object?> payload, Duration timeout) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(aiServerUrl));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return jsonDecode(body);
    } finally {
      client.close();
    }
  }
}

/// Розбір відповіді суддів (однаковий для AI і для людей).
Verdict? parseVerdict(Object? data) {
  if (data is! Map) return null;
  int toScore(Object? v) {
    final int n = v is num ? v.round() : (int.tryParse('$v') ?? 0);
    return max(0, min(10, n));
  }

  final scores = <JudgeScore>[];
  for (final key in const ['logic', 'evidence', 'rhetoric']) {
    final c = data[key];
    if (c is! Map) return null;
    scores.add(JudgeScore(
      key: key,
      user: toScore(c['user']),
      ai: toScore(c['ai']),
      note: (c['note'] ?? '').toString().trim(),
      aiNote: (c['aiNote'] ?? '').toString().trim(),
    ));
  }
  return Verdict(scores, (data['tip'] ?? '').toString().trim());
}

/// ДЕМО: шаблонні відповіді без справжнього AI.
class DemoAi {
  final Random _random = Random();

  static const Map<String, List<List<String>>> _templates = {
    'uk': [
      [
        "Моя позиція — {side}. Головне тут — наслідки для звичайних людей: "
            "кому це рішення реально допоможе, а кому зашкодить? За цим "
            "критерієм ваша позиція слабша.",
        "Почну з принципу: держава має втручатися лише тоді, коли без цього "
            "страждають інші. Тому моя позиція — {side}. Ваш аргумент "
            "«{quote}» описує окремий випадок, а не правило.",
      ],
      [
        "Ви кажете: «{quote}». Але де докази? Без даних це лише думка, "
            "а не аргумент.",
        "«{quote}» — це наслідок, а не причина. Головне питання — ціна: "
            "хто за це платить і чи готове суспільство?",
      ],
      [
        "Підсумую: ви так і не показали, як ваша позиція працює на "
            "практиці, а не в теорії. Тому моя позиція й надалі — {side}.",
        "На завершення: сильні емоції не замінюють сильних доказів. Моя "
            "позиція спирається на принцип і наслідки — тому вона стійкіша.",
      ],
    ],
    'de': [
      [
        "Meine Position: {side}. Entscheidend sind die Folgen für ganz "
            "normale Menschen: Wem hilft diese Entscheidung wirklich, und wem "
            "schadet sie? Nach diesem Maßstab ist Ihre Position schwächer.",
        "Ich beginne mit einem Prinzip: Der Staat sollte nur eingreifen, "
            "wenn sonst andere leiden. Deshalb ist meine Position: {side}. "
            "Ihr Argument „{quote}“ beschreibt einen Einzelfall, keine Regel.",
      ],
      [
        "Sie sagen: „{quote}“. Aber wo sind die Belege? Ohne Daten ist das "
            "nur eine Meinung, kein Argument.",
        "„{quote}“ ist eine Folge, keine Ursache. Die eigentliche Frage ist "
            "der Preis: Wer zahlt dafür, und ist die Gesellschaft bereit?",
      ],
      [
        "Zusammengefasst: Sie haben nicht gezeigt, wie Ihre Position in der "
            "Praxis funktioniert. Deshalb bleibt meine Position: {side}.",
        "Zum Schluss: Starke Gefühle ersetzen keine starken Belege. Meine "
            "Position stützt sich auf Prinzipien und Folgen – deshalb ist sie "
            "stabiler.",
      ],
    ],
    'en': [
      [
        "My position: {side}. What matters most are the consequences for "
            "ordinary people: who does this decision actually help, and who "
            "does it hurt? By that standard, your position is weaker.",
        "Let me start with a principle: the state should step in only when "
            "others would otherwise suffer. That's why my position is {side}. "
            "Your argument “{quote}” describes a single case, not a rule.",
      ],
      [
        "You say: “{quote}”. But where is the evidence? Without data, "
            "that's an opinion, not an argument.",
        "“{quote}” is a consequence, not a cause. The real question is the "
            "cost: who pays for it, and is society ready?",
      ],
      [
        "To sum up: you never showed how your position works in practice "
            "rather than in theory. So my position remains: {side}.",
        "In closing: strong emotions are no substitute for strong evidence. "
            "My position rests on principles and consequences — that's why "
            "it holds up better.",
      ],
    ],
    'es': [
      [
        "Mi postura: {side}. Lo decisivo son las consecuencias para la "
            "gente común: ¿a quién ayuda realmente esta decisión y a quién "
            "perjudica? Con ese criterio, su postura es más débil.",
        "Empiezo con un principio: el Estado solo debe intervenir cuando, "
            "de lo contrario, otros sufren. Por eso mi postura es: {side}. "
            "Su argumento «{quote}» describe un caso aislado, no una regla.",
      ],
      [
        "Usted dice: «{quote}». Pero ¿dónde están las pruebas? Sin datos, "
            "es solo una opinión, no un argumento.",
        "«{quote}» es una consecuencia, no una causa. La verdadera pregunta "
            "es el precio: ¿quién lo paga y está preparada la sociedad?",
      ],
      [
        "En resumen: no ha demostrado cómo funciona su postura en la "
            "práctica y no solo en teoría. Por eso mi postura sigue siendo: "
            "{side}.",
        "Para terminar: las emociones fuertes no sustituyen a las pruebas "
            "sólidas. Mi postura se basa en principios y consecuencias; por "
            "eso es más sólida.",
      ],
    ],
  };

  Future<String> reply({
    required String lang,
    required Side aiSide,
    required int round,
    required List<DebateMessage> history,
  }) async {
    await Future.delayed(Duration(milliseconds: 900 + _random.nextInt(900)));

    final lastUser = history.lastWhere(
      (m) => m.speaker == Speaker.user,
      orElse: () => const DebateMessage(speaker: Speaker.user, text: ''),
    );
    final set = _templates[lang] ?? _templates['en']!;
    final roundIndex = max(0, min(round, set.length) - 1);
    final options = set[roundIndex];
    final template = options[_random.nextInt(options.length)];

    return template
        .replaceAll('{side}', aiSide.labelIn(lang))
        .replaceAll('{quote}', _shortQuote(lastUser.text));
  }

  String _shortQuote(String text) {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return '…';
    final words = clean.split(' ');
    if (words.length <= 8) return clean;
    return '${words.take(8).join(' ')}…';
  }
}

// ===================== головний екран =====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _waiting = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!Session.online) return;
    setState(() => _loading = true);
    try {
      final r = await Api.call('me', {});
      if (!mounted) return;
      setState(() {
        _matches = List<Map<String, dynamic>>.from(
            (r['matches'] as List?) ?? const <Map<String, dynamic>>[]);
        _waiting = List<Map<String, dynamic>>.from(
            (r['waiting'] as List?) ?? const <Map<String, dynamic>>[]);
        _error = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = Api.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _refresh();
  }

  void _needOnline(VoidCallback action) {
    if (Session.online) {
      action();
    } else {
      showSnack(context, tr('needServer'));
    }
  }

  Future<void> _cancelWaiting(Map<String, dynamic> w) async {
    try {
      await Api.call('cancel', {'mode': 'async', 'topicId': w['topicId']});
    } on ApiException catch (e) {
      if (mounted) showSnack(context, Api.errorText(e));
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('appTitle'),
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        actions: [
          if (Session.online)
            IconButton(
              onPressed: _loading ? null : _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Text(
                tr('tagline'),
                style: classic(fontSize: 24, height: 1.2),
              ),
              const SizedBox(height: 12),
              const Meander(),
              if (Session.nick != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${tr('nickPrefix')} ${Session.nick}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 20),
              _ModeCard(
                icon: Icons.smart_toy_outlined,
                title: tr('modeAiTitle'),
                subtitle: tr('modeAiSub'),
                highlighted: true,
                onTap: () => _open(const TopicsScreen()),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                icon: Icons.casino_rounded,
                title: tr('rouletteTitle'),
                subtitle: tr('rouletteSub'),
                onTap: () => _needOnline(() => _open(const TopicsScreen(mode: 'live'))),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                icon: Icons.hourglass_bottom_rounded,
                title: tr('mode3dTitle'),
                subtitle: tr('mode3dSub'),
                onTap: () =>
                    _needOnline(() => _open(const TopicsScreen(mode: 'async'))),
              ),
              if (Session.online) ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      tr('myDebates'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    if (_loading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: AppColors.con))
                else if (_matches.isEmpty && _waiting.isEmpty && !_loading)
                  Text(tr('noDebates'),
                      style: const TextStyle(color: AppColors.textMuted)),
                for (final w in _waiting)
                  _DebateTile(
                    icon: Icons.hourglass_empty_rounded,
                    title: w['topicAny'] == true
                        ? tr('anyTopic')
                        : topicTitleFor((w['topicId'] ?? '').toString(),
                            (w['topicTitle'] ?? '').toString()),
                    subtitle: '${tr('waitingFor')} · ${w['side'] == 'con' ? tr('con') : (w['side'] == 'pro' ? tr('pro') : tr('anySideShort'))}',
                    trailing: IconButton(
                      onPressed: () => _cancelWaiting(w),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: tr('cancel'),
                    ),
                  ),
                for (final m in _matches)
                  _DebateTile(
                    icon: m['mode'] == 'live'
                        ? Icons.casino_rounded
                        : Icons.hourglass_bottom_rounded,
                    title: topicTitleFor(
                        (m['topicId'] ?? '').toString(), (m['topicTitle'] ?? '').toString()),
                    subtitle: '${tr('vs')} ${m['opponentNick'] ?? '?'} · '
                        '${m['status'] != 'active' ? tr('finishedShort') : (m['yourTurn'] == true ? tr('yourTurn') : tr('theirTurn'))}',
                    highlight: m['status'] == 'active' && m['yourTurn'] == true,
                    onTap: () =>
                        _open(HumanMatchScreen(matchId: m['id'].toString())),
                  ),
              ],
              const SizedBox(height: 28),
              Text(
                tr('language'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const _LanguagePanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebateTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlight;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _DebateTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlight = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                Icon(icon,
                    color: highlight ? AppColors.accent : AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, height: 1.3)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: highlight ? AppColors.accent : AppColors.textMuted,
                          fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted),
                    ),
              ],
            ),
          ),
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
    final fg = highlighted ? AppColors.background : AppColors.text;
    final sub = highlighted ? AppColors.background.withAlpha(220) : AppColors.textMuted;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: highlighted ? AppColors.gold : AppColors.accent.withAlpha(90),
          width: highlighted ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
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
                      style: classic(color: fg, fontSize: 22),
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
              Expanded(child: Text(tr('languageRow'))),
              DropdownButton<String>(
                value: appLang.value,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(12),
                items: [
                  for (final entry in languageNames.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (v) {
                  if (v != null) appLang.value = v;
                },
              ),
            ],
          ),
          const Divider(height: 1),
          ValueListenableBuilder<bool>(
            valueListenable: autoTranslate,
            builder: (context, value, _) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr('translateTitle')),
              subtitle: Text(
                tr('translateSub'),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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

// ===================== вибір теми =====================
class TopicsScreen extends StatelessWidget {
  /// 'ai' — проти AI, 'async' — «3 дні» з людиною, 'live' — чат-рулетка.
  final String mode;

  const TopicsScreen({super.key, this.mode = 'ai'});

  bool get human => mode != 'ai';

  /// Повертає 'pro', 'con' або (лише з людьми) 'any'.
  Future<String?> _pickSide(BuildContext context, Topic topic) {
    return showModalBottomSheet<String>(
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
              Text(
                tr(human ? 'chooseSideHuman' : 'chooseSide'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SideButton(
                      label: Side.pro.label,
                      color: AppColors.pro,
                      onTap: () => Navigator.pop(sheetContext, 'pro'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SideButton(
                      label: Side.con.label,
                      color: AppColors.con,
                      onTap: () => Navigator.pop(sheetContext, 'con'),
                    ),
                  ),
                ],
              ),
              if (human) ...[
                const SizedBox(height: 12),
                _SideButton(
                  label: tr('anySide'),
                  color: AppColors.surfaceHigh,
                  textColor: AppColors.text,
                  height: 52,
                  onTap: () => Navigator.pop(sheetContext, 'any'),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('anySideHint'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Topic _randomTopic() => topics[Random().nextInt(topics.length)];

  /// Користувач вибрав конкретну тему.
  Future<void> _onTopic(BuildContext context, Topic topic) async {
    final side = await _pickSide(context, topic);
    if (side == null || !context.mounted) return;
    await _start(context, topic, side, anyTopic: false);
  }

  /// «Випадкова тема».
  Future<void> _onRandom(BuildContext context) async {
    final topic = _randomTopic();
    if (!human) {
      // проти AI тема випадкова, а сторону все одно обираєш сам
      await _onTopic(context, topic);
      return;
    }
    await _start(context, topic, 'any', anyTopic: true);
  }

  Future<void> _start(BuildContext context, Topic topic, String side,
      {required bool anyTopic}) async {
    if (mode == 'ai') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DebateScreen(
            topic: topic,
            userSide: side == 'con' ? Side.con : Side.pro,
          ),
        ),
      );
      return;
    }
    if (mode == 'live') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RouletteScreen(
            topic: anyTopic ? null : topic,
            side: side,
          ),
        ),
      );
      return;
    }
    try {
      final r = await Api.call('find', {
        'mode': 'async',
        'topicId': topic.id,
        'topicTitle': topic.title,
        'topicAny': anyTopic,
        'side': side,
      });
      if (!context.mounted) return;
      if (r['status'] == 'matched') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HumanMatchScreen(matchId: r['matchId'].toString()),
          ),
        );
      } else {
        showSnack(context, tr('waitingAsync'));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, Api.errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = mode == 'live'
        ? tr('rouletteTitle')
        : (mode == 'async' ? tr('mode3dTitle') : tr('chooseTopic'));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _onRandom(context),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.casino_rounded, color: Colors.black, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('randomTopic'),
                            style: classic(
                                color: AppColors.background, fontSize: 22),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr(human ? 'randomTopicSubHuman' : 'randomTopicSubAi'),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              tr('orPickTopic'),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  if (category == 'hot') ...[
                    const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    tr('cat_$category'),
                    style: classic(fontSize: 20, color: AppColors.gold),
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
                    onTap: () => _onTopic(context, topic),
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
          Text(
            tr('moderationNote'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final double height;
  final VoidCallback onTap;

  const _SideButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.black,
    this.height = 64,
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
          height: height,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
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

// ===================== дебати =====================
class DebateScreen extends StatefulWidget {
  final Topic topic;
  final Side userSide;

  const DebateScreen({super.key, required this.topic, required this.userSide});

  @override
  State<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  final AiClient _ai = AiClient();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<DebateMessage> _messages = [];
  final String _lang = appLang.value;

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
        SnackBar(content: Text(tr('tooShort'))),
      );
      return;
    }

    setState(() {
      _messages.add(DebateMessage(speaker: Speaker.user, text: text));
      _input.clear();
      _aiThinking = true;
    });
    _scrollToEnd();

    final reply = await _ai.reply(
      lang: _lang,
      topic: widget.topic,
      aiSide: widget.userSide.opposite,
      round: _round,
      history: List.unmodifiable(_messages),
    );
    if (!mounted) return;

    if (reply.fellBack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('aiOffline'))),
      );
    }

    setState(() {
      _messages.add(DebateMessage(speaker: Speaker.ai, text: reply.text));
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => VerdictScreen(
          topic: widget.topic,
          userSide: widget.userSide,
          lang: _lang,
          messages: List.unmodifiable(_messages),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userColor =
        widget.userSide == Side.pro ? AppColors.pro : AppColors.con;
    final aiColor = widget.userSide == Side.pro ? AppColors.con : AppColors.pro;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _finished
              ? tr('finished')
              : tr('roundOf', {'n': '$_round', 'm': '$debateRounds'}),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopicHeader(
              topic: widget.topic,
              userSide: widget.userSide,
              userColor: userColor,
              demo: _ai.isDemo,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length + (_aiThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _Bubble(
                      text: tr('aiThinking'),
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
                    label: Text(
                      tr('toJudges'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              )
            else
              _InputBar(
                controller: _input,
                hint: tr('hint', {'round': tr('r$_round')}),
                enabled: !_aiThinking,
                onSend: _send,
              ),
          ],
        ),
      ),
    );
  }
}

// ===================== акаунт і сервер =====================

/// Нікнейм і токен зберігаються на телефоні.
class Session {
  static String? token;
  static String? nick;
  static SharedPreferences? _prefs;

  static bool get hasProfile => token != null && nick != null;
  static bool get online => aiServerUrl.isNotEmpty && hasProfile;

  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _prefs = p;
      token = p.getString('token');
      nick = p.getString('nick');
      final lang = p.getString('lang');
      appLang.value = lang != null && languageNames.containsKey(lang)
          ? lang
          : deviceLanguage();
      autoTranslate.value = p.getBool('autoTranslate') ?? true;
    } catch (_) {
      // без збереження застосунок усе одно працює
    }
    appLang.addListener(() => _prefs?.setString('lang', appLang.value));
    autoTranslate
        .addListener(() => _prefs?.setBool('autoTranslate', autoTranslate.value));
  }

  static Future<void> save(String newToken, String newNick) async {
    token = newToken;
    nick = newNick;
    await _prefs?.setString('token', newToken);
    await _prefs?.setString('nick', newNick);
  }
}

class ApiException implements Exception {
  final String code;
  final int status;

  ApiException(this.code, this.status);

  @override
  String toString() => 'ApiException($code, $status)';
}

class Api {
  static Future<Map<String, dynamic>> call(
    String route,
    Map<String, Object?> body, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse('$aiServerUrl/api/$route'));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode({
        ...body,
        'token': Session.token,
        'lang': appLang.value,
      })));
      final response = await request.close().timeout(timeout);
      final text = await response.transform(utf8.decoder).join();
      Object? data;
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = null;
      }
      final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
      if (response.statusCode != 200) {
        throw ApiException((map['error'] ?? 'http').toString(), response.statusCode);
      }
      return map;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('network', 0);
    } finally {
      client.close();
    }
  }

  static String errorText(ApiException e) =>
      e.code == 'banned' ? tr('banned') : tr('networkError');
}

Topic? topicById(String id) {
  for (final t in topics) {
    if (t.id == id) return t;
  }
  return null;
}

String topicTitleFor(String id, String fallback) =>
    topicById(id)?.title ?? fallback;

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

// ===================== перший запуск =====================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nick = TextEditingController();
  bool _agree = false;
  bool _busy = false;

  @override
  void dispose() {
    _nick.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final nick = _nick.text.trim();
    if (nick.length < 2 || nick.length > 20) {
      showSnack(context, tr('nickError'));
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await Api.call('register', {'nick': nick});
      await Session.save(r['token'].toString(), (r['nick'] ?? nick).toString());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(
        context,
        e.code == 'nick' || e.code == 'nick_moderation'
            ? tr('nickRejected')
            : tr('registerError'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.forum_rounded, color: AppColors.accent, size: 32),
                const Spacer(),
                DropdownButton<String>(
                  value: appLang.value,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    for (final entry in languageNames.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                  ],
                  onChanged: (v) {
                    if (v != null) appLang.value = v;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tr('onboardTitle'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              tr('onboardSub'),
              style: const TextStyle(color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('rulesTitle'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  for (final k in const ['rule1', 'rule2', 'rule3', 'rule4'])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.pro),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(tr(k),
                                style: const TextStyle(height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nick,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: tr('nickLabel'),
                border: const OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              title: Text(tr('ageCheck')),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _agree && !_busy ? _start : null,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        tr('start'),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== чат-рулетка =====================
class RouletteScreen extends StatefulWidget {
  /// null — будь-яка тема
  final Topic? topic;

  /// 'pro', 'con' або 'any'
  final String side;

  const RouletteScreen({super.key, this.topic, this.side = 'any'});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  static const int _maxSeconds = 120;
  // запасна тема, якщо обидва вибрали «будь-яку»
  late final Topic _topic = widget.topic ?? topics[Random().nextInt(topics.length)];
  Timer? _timer;
  int _seconds = 0;
  bool _busy = false;
  bool _done = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() {
    _seconds = 0;
    _done = false;
    _message = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_done) {
      Api.call('cancel', {'mode': 'live'}).catchError((_) => <String, dynamic>{});
    }
    super.dispose();
  }

  void _stop(String message) {
    _timer?.cancel();
    _done = true;
    Api.call('cancel', {'mode': 'live'}).catchError((_) => <String, dynamic>{});
    if (mounted) setState(() => _message = message);
  }

  Future<void> _tick() async {
    if (_busy || _done) return;
    _busy = true;
    try {
      _seconds += 2;
      if (_seconds > _maxSeconds) {
        _stop(tr('nobody'));
        return;
      }
      final r = await Api.call('find', {
        'mode': 'live',
        'topicId': _topic.id,
        'topicTitle': _topic.title,
        'topicAny': widget.topic == null,
        'side': widget.side,
      });
      if (!mounted || _done) return;
      if (r['status'] == 'matched') {
        _done = true;
        _timer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HumanMatchScreen(matchId: r['matchId'].toString()),
          ),
        );
      }
    } on ApiException catch (e) {
      if (e.code == 'banned') _stop(tr('banned'));
      // мережеві збої — просто пробуємо ще раз на наступному кроці
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    return Scaffold(
      appBar: AppBar(title: Text(tr('rouletteTitle'))),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: message == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(strokeWidth: 5),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        tr('searching'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        tr('searchTopic', {
                          'topic': widget.topic == null
                              ? tr('anyTopic')
                              : widget.topic!.title,
                        }),
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('searchSide', {
                          'side': widget.side == 'pro'
                              ? tr('pro')
                              : (widget.side == 'con'
                                  ? tr('con')
                                  : tr('anySideShort')),
                        }),
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr('searchingHint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textMuted, height: 1.4),
                      ),
                      const SizedBox(height: 28),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(tr('cancel')),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_search_rounded,
                          size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(height: 1.4, fontSize: 16)),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => setState(_startSearch),
                        child: Text(tr('retry')),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const TopicsScreen()),
                        ),
                        child: Text(tr('playAi')),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ===================== дебати з людиною =====================
class HumanMatchScreen extends StatefulWidget {
  final String matchId;

  const HumanMatchScreen({super.key, required this.matchId});

  @override
  State<HumanMatchScreen> createState() => _HumanMatchScreenState();
}

class _HumanMatchScreenState extends State<HumanMatchScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Set<int> _showOriginal = {};
  Map<String, dynamic>? _m;
  Timer? _poll;
  Timer? _clock;
  bool _sending = false;
  bool _failed = false;
  int _msLeft = 0;
  int _lastCount = -1;

  @override
  void initState() {
    super.initState();
    _load();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_msLeft > 0 && mounted) {
        setState(() => _msLeft = max(0, _msLeft - 1000));
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _clock?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _schedule() {
    _poll?.cancel();
    final m = _m;
    if (!mounted || m == null || m['status'] != 'active') return;
    final live = m['mode'] == 'live';
    _poll = Timer(Duration(seconds: live ? 3 : 15), _load);
  }

  Future<void> _load() async {
    try {
      final r = await Api.call(
        'match',
        {'matchId': widget.matchId, 'translate': autoTranslate.value},
        timeout: const Duration(seconds: 60),
      );
      if (!mounted) return;
      final count = (r['messages'] as List?)?.length ?? 0;
      setState(() {
        _m = r;
        _msLeft = (r['msLeft'] as num?)?.toInt() ?? 0;
        _failed = false;
      });
      if (count != _lastCount) {
        _lastCount = count;
        _scrollToEnd();
      }
    } on ApiException {
      if (mounted && _m == null) setState(() => _failed = true);
    }
    _schedule();
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

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.length < 10) {
      showSnack(context, tr('tooShortHuman'));
      return;
    }
    setState(() => _sending = true);
    try {
      final r = await Api.call(
        'send',
        {'matchId': widget.matchId, 'text': text},
        timeout: const Duration(seconds: 40),
      );
      if (!mounted) return;
      if (r['ok'] == true) {
        _input.clear();
        await _load();
      } else if (r['error'] == 'moderation') {
        showSnack(context,
            tr('modBlocked', {'reason': tr('mod_${r['category'] ?? 'other'}')}));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final turnIssue = const ['not_your_turn', 'conflict', 'finished'].contains(e.code);
      showSnack(context, turnIssue ? tr('turnChanged') : Api.errorText(e));
      await _load();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _menu(String action) async {
    if (action == 'surrender') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(tr('surrenderConfirm')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('no'))),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('yes'))),
          ],
        ),
      );
      if (ok != true) return;
      try {
        await Api.call('leave', {'matchId': widget.matchId});
      } on ApiException catch (e) {
        if (mounted) showSnack(context, Api.errorText(e));
      }
      await _load();
      return;
    }
    if (action == 'block') {
      try {
        await Api.call('block', {'matchId': widget.matchId});
        if (!mounted) return;
        showSnack(context, tr('blocked'));
        Navigator.of(context).pop();
      } on ApiException catch (e) {
        if (mounted) showSnack(context, Api.errorText(e));
      }
      return;
    }
    if (action == 'report') {
      final reason = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        builder: (c) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(tr('reportTitle'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              for (final r in const ['insult', 'hate', 'sexual', 'contact', 'other'])
                ListTile(
                  title: Text(tr('r_$r')),
                  onTap: () => Navigator.pop(c, r),
                ),
            ],
          ),
        ),
      );
      if (reason == null) return;
      try {
        await Api.call('report', {'matchId': widget.matchId, 'reason': reason});
        if (!mounted) return;
        showSnack(context, tr('reported'));
        Navigator.of(context).pop();
      } on ApiException catch (e) {
        if (mounted) showSnack(context, Api.errorText(e));
      }
    }
  }

  String _timeLeft(int ms) {
    if (ms >= 3600 * 1000) {
      return tr('hoursLeft', {'h': '${(ms / 3600000).ceil()}'});
    }
    final s = (ms / 1000).ceil();
    final mm = (s ~/ 60).toString();
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final m = _m;
    if (m == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _failed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tr('networkError')),
                    TextButton(onPressed: _load, child: Text(tr('retry'))),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final mySide = m['yourSide'] == 'con' ? Side.con : Side.pro;
    final myColor = mySide == Side.pro ? AppColors.pro : AppColors.con;
    final oppColor = mySide == Side.pro ? AppColors.con : AppColors.pro;
    final opp = (m['opponentNick'] ?? '?').toString();
    final active = m['status'] == 'active';
    final yourTurn = m['yourTurn'] == true;
    final msgs = (m['messages'] as List?) ?? const [];
    final round = (m['round'] as num?)?.toInt() ?? 1;
    final title = topicTitleFor(
        (m['topicId'] ?? '').toString(), (m['topicTitle'] ?? '').toString());

    Widget bottom;
    if (active && yourTurn) {
      bottom = _InputBar(
        controller: _input,
        hint: tr('hint', {'round': tr('r$round')}),
        enabled: !_sending,
        onSend: _send,
      );
    } else if (active) {
      bottom = Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: const EdgeInsets.all(16),
        child: Text(tr('waitOpponent'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted)),
      );
    } else {
      final result = (m['result'] ?? '').toString();
      if (result == 'judge') {
        bottom = Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HumanVerdictScreen(
                    matchId: widget.matchId,
                    opponent: opp,
                    topicTitle: title,
                  ),
                ),
              ),
              icon: const Icon(Icons.gavel_rounded),
              label: Text(tr('toJudges'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        );
      } else {
        const keys = {
          'opp_timeout': 'forfeitWin',
          'you_timeout': 'forfeitLose',
          'opp_surrendered': 'oppSurrendered',
          'you_surrendered': 'youSurrendered',
        };
        final win = result.startsWith('opp_');
        bottom = Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: (win ? AppColors.pro : AppColors.con).withAlpha(120)),
          ),
          child: Text(tr(keys[result] ?? 'finished'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(active
            ? tr('roundOf', {'n': '$round', 'm': '$debateRounds'})
            : tr('finished')),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menu,
            itemBuilder: (_) => [
              PopupMenuItem(value: 'report', child: Text(tr('report'))),
              PopupMenuItem(value: 'block', child: Text(tr('block'))),
              if (active)
                PopupMenuItem(value: 'surrender', child: Text(tr('surrender'))),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(tr('youColon'),
                          style: const TextStyle(color: AppColors.textMuted)),
                      Text(mySide.label,
                          style: TextStyle(
                              color: myColor, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${tr('vs')} $opp',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  if (active) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 16,
                            color: yourTurn ? AppColors.accent : AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          '${yourTurn ? tr('yourTurn') : tr('theirTurn')} · ${_timeLeft(_msLeft)}',
                          style: TextStyle(
                            color: yourTurn ? AppColors.accent : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: msgs.length,
                itemBuilder: (context, i) {
                  final msg = msgs[i] as Map;
                  final mine = msg['mine'] == true;
                  final original = (msg['text'] ?? '').toString();
                  final translated = msg['translated']?.toString();
                  final showTr = !mine && translated != null && !_showOriginal.contains(i);
                  return Column(
                    crossAxisAlignment:
                        mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      _Bubble(
                        text: showTr ? translated : original,
                        isUser: mine,
                        color: mine ? myColor : oppColor,
                        label: mine ? tr('you') : opp,
                      ),
                      if (!mine && translated != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 4),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              if (!_showOriginal.remove(i)) _showOriginal.add(i);
                            }),
                            child: Text(
                              tr(showTr ? 'showOriginal' : 'showTranslation'),
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            bottom,
          ],
        ),
      ),
    );
  }
}

class HumanVerdictScreen extends StatefulWidget {
  final String matchId;
  final String opponent;
  final String topicTitle;

  const HumanVerdictScreen({
    super.key,
    required this.matchId,
    required this.opponent,
    required this.topicTitle,
  });

  @override
  State<HumanVerdictScreen> createState() => _HumanVerdictScreenState();
}

class _HumanVerdictScreenState extends State<HumanVerdictScreen> {
  Verdict? _verdict;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    Verdict? v;
    try {
      final r = await Api.call('verdict', {'matchId': widget.matchId},
          timeout: const Duration(seconds: 90));
      v = parseVerdict(r);
    } on ApiException {
      v = null;
    }
    if (!mounted) return;
    setState(() {
      _verdict = v;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(tr('judgesThinking'),
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    } else if (_verdict == null) {
      body = Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(tr('judgesError'),
              textAlign: TextAlign.center, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(tr('retry')),
          ),
        ],
      );
    } else {
      body = _VerdictView(
        verdict: _verdict!,
        topicTitle: widget.topicTitle,
        opponentLabel: widget.opponent,
        vsAi: false,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('verdict'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            body,
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(tr('backHome'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== вердикт =====================
class VerdictScreen extends StatefulWidget {
  final Topic topic;
  final Side userSide;
  final String lang;
  final List<DebateMessage> messages;

  const VerdictScreen({
    super.key,
    required this.topic,
    required this.userSide,
    required this.lang,
    required this.messages,
  });

  @override
  State<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends State<VerdictScreen> {
  final AiClient _ai = AiClient();
  Verdict? _verdict;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final v = await _ai.judge(
      lang: widget.lang,
      topic: widget.topic,
      userSide: widget.userSide,
      history: widget.messages,
    );
    if (!mounted) return;
    setState(() {
      _verdict = v;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_ai.isDemo) {
      body = const _JudgesLockedCard();
    } else if (_loading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(tr('judgesThinking'),
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    } else if (_verdict == null) {
      body = Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.cloud_off_rounded,
              size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(tr('judgesError'),
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(tr('retry')),
          ),
        ],
      );
    } else {
      body = _VerdictView(verdict: _verdict!, topicTitle: widget.topic.title);
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('verdict'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            body,
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  tr('newDebate'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerdictView extends StatelessWidget {
  final Verdict verdict;
  final String topicTitle;
  final String opponentLabel;
  final bool vsAi;

  const _VerdictView({
    required this.verdict,
    required this.topicTitle,
    this.opponentLabel = 'AI',
    this.vsAi = true,
  });

  @override
  Widget build(BuildContext context) {
    final String headline;
    final Color color;
    if (verdict.isDraw) {
      headline = tr('draw');
      color = AppColors.accent;
    } else if (verdict.userWins) {
      headline = tr('win');
      color = AppColors.pro;
    } else {
      headline = vsAi ? tr('lose') : tr('loseHuman');
      color = AppColors.con;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(120)),
          ),
          child: Column(
            children: [
              if (verdict.userWins && !verdict.isDraw)
                const LaurelWreath(size: 84)
              else
                const Icon(Icons.account_balance_rounded,
                    size: 44, color: AppColors.gold),
              const SizedBox(height: 8),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: classic(fontSize: 32, color: color),
              ),
              const SizedBox(height: 8),
              const Meander(height: 10),
              const SizedBox(height: 6),
              Text(
                '${verdict.userTotal} : ${verdict.aiTotal}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                  vsAi
                      ? tr('youVsAi')
                      : tr('youVs', {'name': opponentLabel}),
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Text(
                topicTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final s in verdict.scores) ...[
          _JudgeCard(
            score: s,
            opponentLabel: opponentLabel,
            noteTitle: vsAi ? tr('aiNoteTitle') : tr('opponentNoteTitle'),
          ),
          const SizedBox(height: 12),
        ],
        if (verdict.tip.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                  AppColors.accent.withAlpha(30), AppColors.surface),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('tipTitle'),
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(verdict.tip, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          tr('judgeDisclaimer'),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _JudgeCard extends StatelessWidget {
  final JudgeScore score;
  final String opponentLabel;
  final String noteTitle;

  const _JudgeCard({
    required this.score,
    required this.opponentLabel,
    required this.noteTitle,
  });

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
            tr('judge_${score.key}'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(
            tr('crit_${score.key}'),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _ScoreBar(label: tr('you'), value: score.user, color: AppColors.pro),
          const SizedBox(height: 8),
          _ScoreBar(label: opponentLabel, value: score.ai, color: AppColors.con),
          if (score.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(score.note, style: const TextStyle(height: 1.4)),
          ],
          if (score.aiNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '$noteTitle: ${score.aiNote}',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13, height: 1.4),
            ),
          ],
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
          width: 72,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          width: 40,
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

class _JudgesLockedCard extends StatelessWidget {
  const _JudgesLockedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceHigh),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_rounded,
              color: AppColors.accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('judgesTitle'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  tr('judgesBody'),
                  style: const TextStyle(
                      color: AppColors.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  final Topic topic;
  final Side userSide;
  final Color userColor;
  final bool demo;

  const _TopicHeader({
    required this.topic,
    required this.userSide,
    required this.userColor,
    required this.demo,
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
              Text(tr('youColon'),
                  style: const TextStyle(color: AppColors.textMuted)),
              Text(
                userSide.label,
                style: TextStyle(color: userColor, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              if (demo)
                Text(
                  tr('demoMode'),
                  style: const TextStyle(
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
  final String? label;

  const _Bubble({
    required this.text,
    required this.isUser,
    required this.color,
    this.muted = false,
    this.label,
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
                label ?? (isUser ? tr('you') : tr('aiOpponent')),
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
                  color: muted ? AppColors.textMuted : AppColors.text,
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
