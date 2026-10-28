// Дебати — версія 0.2. Весь застосунок в одному файлі.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

// ===================== налаштування =====================

/// Адреса AI-сервера. Поки порожня — працює демо-режим.
/// Коли налаштуємо сервер, сюди вставимо його адресу.
const String aiServerUrl = 'https://debatos-ai.ahmadsolomko.workers.dev';

const int debateRounds = 3;

// ===================== main =====================
void main() {
  runApp(const DebatesApp());
}

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

    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) => MaterialApp(
        key: ValueKey(lang),
        title: tr('appTitle'),
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
      ),
    );
  }
}

// ===================== мови =====================

/// Мова інтерфейсу і дебатів.
final ValueNotifier<String> appLang = ValueNotifier<String>('uk');

/// Чи увімкнений автопереклад суперника (для дебатів з людьми).
final ValueNotifier<bool> autoTranslate = ValueNotifier<bool>(true);

const Map<String, String> languageNames = {
  'uk': 'Українська',
  'de': 'Deutsch',
  'en': 'English',
  'es': 'Español',
};

String tr(String key, [Map<String, String> vars = const {}]) {
  var text = _strings[appLang.value]?[key] ?? _strings['uk']![key] ?? key;
  vars.forEach((k, v) => text = text.replaceAll('{$k}', v));
  return text;
}

const Map<String, Map<String, String>> _strings = {
  'uk': {
    'appTitle': 'Дебати',
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
  },
  'de': {
    'appTitle': 'Debatten',
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
  },
  'en': {
    'appTitle': 'Debates',
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
  },
  'es': {
    'appTitle': 'Debates',
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

  String titleIn(String lang) => titles[lang] ?? titles['uk']!;
  String get title => titleIn(appLang.value);
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
  }),
  Topic(id: 'euthanasia', category: 'hot', titles: {
    'uk': 'Евтаназія має бути легальною для дорослих за їхнім бажанням',
    'de': 'Sterbehilfe sollte für Erwachsene auf eigenen Wunsch legal sein',
    'en': 'Euthanasia should be legal for adults who request it',
    'es': 'La eutanasia debería ser legal para los adultos que la soliciten',
  }),
  Topic(id: 'abortion', category: 'hot', titles: {
    'uk': 'Аборт має бути легальним на вимогу жінки до 12-го тижня',
    'de': 'Abtreibung sollte bis zur 12. Woche auf Wunsch der Frau legal sein',
    'en': 'Abortion should be legal on request up to the 12th week',
    'es': 'El aborto debería ser legal a petición de la mujer hasta la '
        'semana 12',
  }),
  Topic(id: 'guns', category: 'hot', titles: {
    'uk': 'Громадяни мають право вільно носити зброю',
    'de': 'Bürger sollten das Recht haben, frei Waffen zu tragen',
    'en': 'Citizens should have the right to carry guns freely',
    'es': 'Los ciudadanos deberían tener derecho a portar armas libremente',
  }),
  Topic(id: 'palestine', category: 'hot', titles: {
    'uk': 'Європейські країни мають визнати державу Палестина',
    'de': 'Europäische Staaten sollten den Staat Palästina anerkennen',
    'en': 'European countries should recognise the State of Palestine',
    'es': 'Los países europeos deberían reconocer el Estado de Palestina',
  }),
  Topic(id: 'death-penalty', category: 'hot', titles: {
    'uk': 'Смертна кара має бути дозволена за найтяжчі злочини',
    'de': 'Die Todesstrafe sollte für die schwersten Verbrechen erlaubt sein',
    'en': 'The death penalty should be allowed for the most serious crimes',
    'es': 'La pena de muerte debería permitirse para los delitos más graves',
  }),
  Topic(id: 'conscription', category: 'politics', titles: {
    'uk': 'Обовʼязкова військова служба має бути в кожній країні ЄС',
    'de': 'Jedes EU-Land sollte eine Wehrpflicht haben',
    'en': 'Every EU country should have mandatory military service',
    'es': 'Todos los países de la UE deberían tener servicio militar '
        'obligatorio',
  }),
  Topic(id: 'ubi', category: 'politics', titles: {
    'uk': 'Безумовний базовий дохід — краще рішення, ніж соцдопомога',
    'de': 'Ein bedingungsloses Grundeinkommen ist besser als Sozialhilfe',
    'en': 'Universal basic income is better than welfare benefits',
    'es': 'La renta básica universal es mejor que las ayudas sociales',
  }),
  Topic(id: 'four-day-week', category: 'politics', titles: {
    'uk': 'Робочий тиждень має бути чотириденним',
    'de': 'Die Arbeitswoche sollte vier Tage haben',
    'en': 'The working week should be four days long',
    'es': 'La semana laboral debería ser de cuatro días',
  }),
  Topic(id: 'voting-16', category: 'politics', titles: {
    'uk': 'Голосувати на виборах можна з 16 років',
    'de': 'Wählen sollte ab 16 Jahren erlaubt sein',
    'en': 'People should be able to vote from age 16',
    'es': 'Se debería poder votar desde los 16 años',
  }),
  Topic(id: 'social-media-16', category: 'tech', titles: {
    'uk': 'Соцмережі треба заборонити дітям до 16 років',
    'de': 'Soziale Medien sollten für Kinder unter 16 verboten werden',
    'en': 'Social media should be banned for children under 16',
    'es': 'Las redes sociales deberían prohibirse a los menores de 16 años',
  }),
  Topic(id: 'ai-jobs', category: 'tech', titles: {
    'uk': 'AI за 20 років забере більшість професій',
    'de': 'KI wird in 20 Jahren die meisten Berufe ersetzen',
    'en': 'AI will replace most jobs within 20 years',
    'es': 'La IA sustituirá la mayoría de los empleos en 20 años',
  }),
  Topic(id: 'nuclear', category: 'tech', titles: {
    'uk': 'Атомна енергетика — найкращий шлях до кліматичних цілей',
    'de': 'Atomkraft ist der beste Weg zu den Klimazielen',
    'en': 'Nuclear power is the best path to climate goals',
    'es': 'La energía nuclear es el mejor camino hacia los objetivos '
        'climáticos',
  }),
  Topic(id: 'pineapple-pizza', category: 'light', titles: {
    'uk': 'Піца з ананасом — це нормально',
    'de': 'Pizza mit Ananas ist völlig in Ordnung',
    'en': 'Pineapple on pizza is perfectly fine',
    'es': 'La pizza con piña está perfectamente bien',
  }),
  Topic(id: 'cats-dogs', category: 'light', titles: {
    'uk': 'Коти кращі за собак',
    'de': 'Katzen sind besser als Hunde',
    'en': 'Cats are better than dogs',
    'es': 'Los gatos son mejores que los perros',
  }),
  Topic(id: 'remote-school', category: 'light', titles: {
    'uk': 'Школа має бути онлайн хоча б двічі на тиждень',
    'de': 'Schule sollte mindestens zweimal pro Woche online sein',
    'en': 'School should be online at least twice a week',
    'es': 'La escuela debería ser en línea al menos dos veces por semana',
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
        final text = await _remote(
          lang: lang,
          topic: topic,
          aiSide: aiSide,
          round: round,
          history: history,
        );
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

  Future<String> _remote({
    required String lang,
    required Topic topic,
    required Side aiSide,
    required int round,
    required List<DebateMessage> history,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(aiServerUrl));
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode({
        'lang': lang,
        'topic': topic.titleIn(lang),
        'aiSide': aiSide == Side.pro ? 'pro' : 'con',
        'round': round,
        'rounds': debateRounds,
        'history': [
          for (final m in history)
            {
              'speaker': m.speaker == Speaker.user ? 'user' : 'ai',
              'text': m.text,
            },
        ],
      })));
      final response =
          await request.close().timeout(const Duration(seconds: 45));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final data = jsonDecode(body);
      final text = data is Map ? (data['reply'] ?? '').toString().trim() : '';
      if (text.isEmpty) throw Exception('empty reply');
      return text;
    } finally {
      client.close();
    }
  }
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
    final set = _templates[lang] ?? _templates['uk']!;
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('soonMsg'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('appTitle'),
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(
              tr('tagline'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            _ModeCard(
              icon: Icons.smart_toy_outlined,
              title: tr('modeAiTitle'),
              subtitle: tr('modeAiSub'),
              highlighted: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopicsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.hourglass_bottom_rounded,
              title: tr('mode3dTitle'),
              subtitle: tr('mode3dSub'),
              badge: tr('badgeSoon'),
              onTap: () => _soon(context),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.bolt_rounded,
              title: tr('liveTitle'),
              subtitle: tr('liveSub'),
              badge: tr('badgeV2'),
              onTap: () => _soon(context),
            ),
            const SizedBox(height: 28),
            Text(
              tr('language'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              Text(
                tr('chooseSide'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SideButton(
                      label: Side.pro.label,
                      color: AppColors.pro,
                      onTap: () => Navigator.pop(sheetContext, Side.pro),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SideButton(
                      label: Side.con.label,
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
      appBar: AppBar(title: Text(tr('chooseTopic'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
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
                itemCount: _messages.length + (_aiThinking || _finished ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    if (_finished) return const _JudgesLockedCard();
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      tr('newDebate'),
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
                isUser ? tr('you') : tr('aiOpponent'),
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
