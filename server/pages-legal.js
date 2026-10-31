// Публічні сторінки для Google Play: політика конфіденційності, умови, видалення акаунта.
// Мови: en (основна), uk, de. Для інших — англійська.
// Орієнтир: GDPR (ст. 13), Digital Services Act (ст. 11, 12, 14, 16, 17), AI Act (ст. 50), BGB §§ 305 ff.

const UPDATED = "31.10.2026";
const OWNER = "Ahmed Yassine Zitouni Solomko";

function contactLine(lang, email) {
  if (email) return `<a href="mailto:${email}">${email}</a>`;
  return {
    en: "the developer e-mail address shown on the Debatos page in Google Play",
    uk: "адреса електронної пошти розробника, вказана на сторінці Debatos у Google Play",
    de: "die auf der Debatos-Seite bei Google Play angegebene E-Mail-Adresse des Entwicklers",
  }[lang];
}

function page(lang, title, body) {
  const other = ["en", "uk", "de"].map((l) =>
    l === lang ? `<b>${l.toUpperCase()}</b>` : `<a href="?lang=${l}">${l.toUpperCase()}</a>`).join(" · ");
  return `<!doctype html><html lang="${lang}"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>${title} — Debatos</title>
<style>
body{margin:0;background:#F7F4EE;color:#2B2620;font:17px/1.6 Georgia,"Times New Roman",serif}
main{max-width:720px;margin:0 auto;padding:28px 18px 60px}
h1{font-variant:small-caps;letter-spacing:.04em;color:#2E5E8C;margin:.2em 0}
h2{font-variant:small-caps;letter-spacing:.03em;color:#8C6A1F;margin-top:1.6em}
a{color:#2E5E8C}.muted{color:#7A6F60;font-size:14px}
hr{border:0;border-top:2px solid #C9A961;margin:20px 0}
</style></head><body><main>
<p class="muted">${other}</p><h1>${title}</h1><p class="muted">Debatos · ${UPDATED}</p><hr>
${body}
</main></body></html>`;
}

const pick = (lang) => (["en", "uk", "de"].includes(lang) ? lang : "en");

// ---------------------------------------------------------------------
function privacy(langIn, email) {
  const lang = pick(langIn);
  const c = contactLine(lang, email);
  const T = {
    en: ["Privacy Policy", `
<h2>Who is responsible</h2>
<p>Controller within the meaning of the GDPR: <b>${OWNER}</b>, Germany. Contact: ${c}. A data protection officer is not required and has not been appointed.</p>
<p>Debatos is a debate app: you debate an AI or other people, and AI judges score the arguments. This policy explains which data the app processes, why, and for how long.</p>
<h2>What we process</h2>
<ul>
<li><b>Account:</b> the nickname you choose and a random account key created by the app. We do not ask for your name, e-mail, phone number or location.</li>
<li><b>Settings:</b> app language, chosen debate duration.</li>
<li><b>Debates with people:</b> your messages, topics (including topics you write yourself), results, AI verdicts and translations.</li>
<li><b>Safety data:</b> reports and blocks you send or receive.</li>
<li><b>Usage counters:</b> how many AI debates your account has used (needed for the free limit and Premium), and whether you activated a promo code or tapped "I want Premium".</li>
<li><b>Reports about AI answers:</b> the reported text, topic and reason.</li>
<li><b>Technical data:</b> to deliver the service, Cloudflare processes your IP address and similar connection data. We do not store IP addresses; short-lived counters in server memory protect against spam and disappear automatically.</li>
</ul>
<h2>What we do not do</h2>
<p>Debates against the AI are processed only to generate the reply and the verdict and are <b>not stored</b> on our server. There is no advertising, no analytics and no tracking, and we do not sell or share data.</p>
<h2>Purposes and legal bases</h2>
<ul>
<li>Providing the app and its features (account, debates, translation, judging, limits, Premium): Art. 6(1)(b) GDPR — performance of the contract (our Terms of Use).</li>
<li>Safety of the community (automatic moderation, reports, blocks, spam protection): Art. 6(1)(f) GDPR — our legitimate interest in a safe service free of abuse — and Art. 6(1)(c) GDPR together with the EU Digital Services Act where we must act on reports.</li>
</ul>
<p>Providing a nickname is necessary to use debates with people; without it these features cannot be offered. There is no statutory obligation to provide data.</p>
<h2>Automated processing</h2>
<p>Messages and custom topics are checked automatically by AI and simple rules for insults, hate speech, sexual content, threats and contact details; such messages are not sent. AI judges score debates automatically. Accounts that receive repeated reports from different users can be blocked automatically. These steps have no legal effect on you; you can contest any decision by writing to ${c}, and a human will review it.</p>
<h2>On your device</h2>
<p>The account key, nickname, language and settings are saved on your phone so that you stay signed in (this is strictly necessary for the service, § 25(2) TDDDG).</p>
<h2>Recipients and processors</h2>
<p>The server runs on <b>Cloudflare</b> (Cloudflare, Inc., USA). Your texts are sent to AI models for replies, translation, moderation and judging; these models run at <b>Groq</b> (Groq, Inc., USA) and, as a fallback, at Cloudflare. Both act as our processors; Groq does not store the texts by default. Data may therefore be processed in the USA; such transfers are based on the EU Standard Contractual Clauses and, where the company is certified, the EU–U.S. Data Privacy Framework (Art. 45/46 GDPR).</p>
<h2>How long</h2>
<ul>
<li>Account, debates with people, reports and blocks: until you delete your account. Deleting the account immediately removes them; debates are removed for both participants.</li>
<li>AI usage counters: up to 40 days. Spam-protection counters: minutes, in memory only.</li>
<li>Reports about AI answers: without any link to you, for up to 12 months.</li>
</ul>
<h2>Your rights</h2>
<p>You have the right of access (Art. 15), rectification (Art. 16), erasure (Art. 17), restriction (Art. 18), data portability (Art. 20) and to object to processing based on legitimate interests (Art. 21 GDPR). You can delete your account at any time in the app (Home → Delete account), see <a href="/delete-account?lang=en">how to delete your account</a>. For everything else write to ${c}. You also have the right to lodge a complaint with a data protection supervisory authority (Art. 77 GDPR), for example the one in your place of residence.</p>
<h2>Age</h2><p>Debatos is for people aged 16 and older.</p>
<p class="muted">We update this policy when the app changes; the date above shows the current version.</p>`],
    uk: ["Політика конфіденційності", `
<h2>Хто відповідає</h2>
<p>Відповідальна особа (контролер) у розумінні GDPR: <b>${OWNER}</b>, Німеччина. Зв'язок: ${c}. Уповноважений із захисту даних не потрібен і не призначений.</p>
<p>Debatos — застосунок для дебатів: ти сперечаєшся з AI або з людьми, а AI-судді оцінюють аргументи. Тут пояснено, які дані обробляє застосунок, навіщо і як довго.</p>
<h2>Що ми обробляємо</h2>
<ul>
<li><b>Акаунт:</b> нік, який ти вибрав, і випадковий ключ акаунта, створений застосунком. Ми не питаємо імені, пошти, телефону чи місцезнаходження.</li>
<li><b>Налаштування:</b> мова застосунку, вибрана тривалість дебатів.</li>
<li><b>Дебати з людьми:</b> твої повідомлення, теми (зокрема власні), результати, вердикти AI і переклади.</li>
<li><b>Дані безпеки:</b> скарги й блокування, які ти надсилаєш або отримуєш.</li>
<li><b>Лічильники:</b> скільки дебатів з AI використав твій акаунт (потрібно для безкоштовного ліміту й Преміуму), чи активовано промокод і чи натиснуто «Хочу Преміум».</li>
<li><b>Скарги на відповіді AI:</b> текст, тема й причина скарги.</li>
<li><b>Технічні дані:</b> щоб сервіс працював, Cloudflare обробляє твою IP-адресу та подібні дані з'єднання. Ми IP-адреси не зберігаємо; короткочасні лічильники в пам'яті сервера захищають від спаму і зникають самі.</li>
</ul>
<h2>Чого ми не робимо</h2>
<p>Дебати з AI обробляються лише для відповіді та вердикту і <b>не зберігаються</b> на сервері. Немає реклами, аналітики й стеження; ми не продаємо й не передаємо дані.</p>
<h2>Мета й правові підстави</h2>
<ul>
<li>Робота застосунку (акаунт, дебати, переклад, судді, ліміти, Преміум): ст. 6(1)(b) GDPR — виконання договору (наших Умов користування).</li>
<li>Безпека спільноти (автоматична модерація, скарги, блокування, захист від спаму): ст. 6(1)(f) GDPR — наш законний інтерес у безпечному сервісі без зловживань — і ст. 6(1)(c) GDPR разом із Законом ЄС про цифрові послуги (DSA), коли ми мусимо реагувати на скарги.</li>
</ul>
<p>Нік потрібен для дебатів з людьми; без нього ці функції недоступні. Законного обов'язку надавати дані немає.</p>
<h2>Автоматична обробка</h2>
<p>Повідомлення й власні теми автоматично перевіряються AI і простими правилами на образи, мову ворожнечі, сексуальний контент, погрози й контакти; такі повідомлення не надсилаються. AI-судді оцінюють дебати автоматично. Акаунти, на які неодноразово скаржаться різні користувачі, можуть бути заблоковані автоматично. Ці кроки не мають для тебе юридичних наслідків; будь-яке рішення можна оскаржити, написавши на ${c}, — його перегляне людина.</p>
<h2>На твоєму телефоні</h2>
<p>Ключ акаунта, нік, мова й налаштування зберігаються на телефоні, щоб ти лишався в акаунті (це необхідно для роботи сервісу, § 25(2) TDDDG).</p>
<h2>Отримувачі й обробники</h2>
<p>Сервер працює на <b>Cloudflare</b> (Cloudflare, Inc., США). Твої тексти надсилаються AI-моделям для відповідей, перекладу, модерації й суддівства; ці моделі працюють у <b>Groq</b> (Groq, Inc., США), а як запасний варіант — у Cloudflare. Обидві компанії — наші обробники; Groq за замовчуванням не зберігає тексти. Тому дані можуть оброблятися в США; така передача ґрунтується на Стандартних договірних положеннях ЄС і, якщо компанія сертифікована, на EU–U.S. Data Privacy Framework (ст. 45/46 GDPR).</p>
<h2>Як довго</h2>
<ul>
<li>Акаунт, дебати з людьми, скарги й блокування: доки ти не видалиш акаунт. Видалення одразу стирає їх; дебати зникають в обох учасників.</li>
<li>Лічильники дебатів з AI: до 40 днів. Лічильники захисту від спаму: хвилини, лише в пам'яті.</li>
<li>Скарги на відповіді AI: без зв'язку з тобою, до 12 місяців.</li>
</ul>
<h2>Твої права</h2>
<p>Ти маєш право на доступ (ст. 15), виправлення (ст. 16), видалення (ст. 17), обмеження обробки (ст. 18), перенесення даних (ст. 20) і заперечення проти обробки на підставі законного інтересу (ст. 21 GDPR). Акаунт можна видалити будь-коли в застосунку (Головна → Видалити акаунт), див. <a href="/delete-account?lang=uk">як видалити акаунт</a>. З усім іншим пиши на ${c}. Також ти можеш поскаржитися до органу захисту даних (ст. 77 GDPR), наприклад за місцем проживання.</p>
<h2>Вік</h2><p>Debatos — для людей від 16 років.</p>
<p class="muted">Ми оновлюємо цю політику, коли змінюється застосунок; дата вгорі показує актуальну версію.</p>`],
    de: ["Datenschutzerklärung", `
<h2>Verantwortlicher</h2>
<p>Verantwortlicher im Sinne der DSGVO: <b>${OWNER}</b>, Deutschland. Kontakt: ${c}. Ein Datenschutzbeauftragter ist nicht erforderlich und nicht benannt.</p>
<p>Debatos ist eine Debatten-App: Du debattierst mit einer KI oder mit anderen Menschen, und KI-Richter bewerten die Argumente. Hier steht, welche Daten die App verarbeitet, wozu und wie lange.</p>
<h2>Was wir verarbeiten</h2>
<ul>
<li><b>Konto:</b> der Nickname, den du wählst, und ein zufälliger Kontoschlüssel, den die App erzeugt. Wir fragen nicht nach Name, E-Mail, Telefonnummer oder Standort.</li>
<li><b>Einstellungen:</b> App-Sprache, gewählte Debattendauer.</li>
<li><b>Debatten mit Menschen:</b> deine Nachrichten, Themen (auch selbst geschriebene), Ergebnisse, KI-Urteile und Übersetzungen.</li>
<li><b>Sicherheitsdaten:</b> Meldungen und Blockierungen, die du sendest oder erhältst.</li>
<li><b>Nutzungszähler:</b> wie viele KI-Debatten dein Konto genutzt hat (für das Gratis-Kontingent und Premium) sowie ob ein Promo-Code aktiviert oder „Ich will Premium“ angetippt wurde.</li>
<li><b>Meldungen zu KI-Antworten:</b> gemeldeter Text, Thema und Grund.</li>
<li><b>Technische Daten:</b> Zur Bereitstellung verarbeitet Cloudflare deine IP-Adresse und ähnliche Verbindungsdaten. Wir speichern keine IP-Adressen; kurzlebige Zähler im Serverspeicher schützen vor Spam und verschwinden automatisch.</li>
</ul>
<h2>Was wir nicht tun</h2>
<p>Debatten gegen die KI werden nur für Antwort und Urteil verarbeitet und <b>nicht gespeichert</b>. Keine Werbung, keine Analyse, kein Tracking; wir verkaufen oder teilen keine Daten.</p>
<h2>Zwecke und Rechtsgrundlagen</h2>
<ul>
<li>Bereitstellung der App und ihrer Funktionen (Konto, Debatten, Übersetzung, Bewertung, Kontingente, Premium): Art. 6 Abs. 1 lit. b DSGVO — Vertragserfüllung (unsere Nutzungsbedingungen).</li>
<li>Sicherheit der Community (automatische Moderation, Meldungen, Blockierungen, Spamschutz): Art. 6 Abs. 1 lit. f DSGVO — unser berechtigtes Interesse an einem sicheren, missbrauchsfreien Dienst — sowie Art. 6 Abs. 1 lit. c DSGVO i. V. m. dem Digital Services Act, soweit wir auf Meldungen reagieren müssen.</li>
</ul>
<p>Ein Nickname ist für Debatten mit Menschen erforderlich; ohne ihn können diese Funktionen nicht angeboten werden. Eine gesetzliche Pflicht zur Bereitstellung besteht nicht.</p>
<h2>Automatisierte Verarbeitung</h2>
<p>Nachrichten und eigene Themen werden automatisch durch KI und einfache Regeln auf Beleidigungen, Hassrede, sexuelle Inhalte, Drohungen und Kontaktdaten geprüft; solche Nachrichten werden nicht gesendet. KI-Richter bewerten Debatten automatisch. Konten, die wiederholt von verschiedenen Nutzern gemeldet werden, können automatisch gesperrt werden. Diese Schritte entfalten dir gegenüber keine rechtliche Wirkung; du kannst jede Entscheidung über ${c} anfechten, sie wird dann von einem Menschen geprüft.</p>
<h2>Auf deinem Gerät</h2>
<p>Kontoschlüssel, Nickname, Sprache und Einstellungen werden auf deinem Handy gespeichert, damit du angemeldet bleibst (unbedingt erforderlich, § 25 Abs. 2 TDDDG).</p>
<h2>Empfänger und Auftragsverarbeiter</h2>
<p>Der Server läuft bei <b>Cloudflare</b> (Cloudflare, Inc., USA). Deine Texte werden für Antworten, Übersetzung, Moderation und Bewertung an KI-Modelle gesendet; diese laufen bei <b>Groq</b> (Groq, Inc., USA) und ersatzweise bei Cloudflare. Beide sind unsere Auftragsverarbeiter; Groq speichert die Texte standardmäßig nicht. Daten können daher in den USA verarbeitet werden; die Übermittlung stützt sich auf EU-Standardvertragsklauseln und, soweit das Unternehmen zertifiziert ist, das EU-U.S. Data Privacy Framework (Art. 45/46 DSGVO).</p>
<h2>Speicherdauer</h2>
<ul>
<li>Konto, Debatten mit Menschen, Meldungen und Blockierungen: bis du dein Konto löschst. Die Löschung entfernt sie sofort; Debatten verschwinden bei beiden Teilnehmern.</li>
<li>Zähler für KI-Debatten: bis zu 40 Tage. Spamschutz-Zähler: Minuten, nur im Arbeitsspeicher.</li>
<li>Meldungen zu KI-Antworten: ohne Bezug zu dir, bis zu 12 Monate.</li>
</ul>
<h2>Deine Rechte</h2>
<p>Du hast das Recht auf Auskunft (Art. 15), Berichtigung (Art. 16), Löschung (Art. 17), Einschränkung der Verarbeitung (Art. 18), Datenübertragbarkeit (Art. 20) und Widerspruch gegen Verarbeitungen auf Grundlage berechtigter Interessen (Art. 21 DSGVO). Dein Konto kannst du jederzeit in der App löschen (Start → Konto löschen), siehe <a href="/delete-account?lang=de">Konto löschen</a>. Für alles andere schreib an ${c}. Außerdem hast du das Recht, dich bei einer Datenschutz-Aufsichtsbehörde zu beschweren (Art. 77 DSGVO), z. B. an deinem Wohnort.</p>
<h2>Alter</h2><p>Debatos ist für Menschen ab 16 Jahren.</p>
<p class="muted">Wir aktualisieren diese Erklärung, wenn sich die App ändert; das Datum oben zeigt die aktuelle Fassung.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

// ---------------------------------------------------------------------
function terms(langIn, email) {
  const lang = pick(langIn);
  const c = contactLine(lang, email);
  const T = {
    en: ["Terms of Use", `
<h2>1. Provider</h2><p>Debatos is provided by ${OWNER}, Germany. Contact point for users and authorities (Art. 11 and 12 DSA): ${c}. We communicate in English, German and Ukrainian.</p>
<h2>2. Who can use Debatos</h2><p>You must be at least 16 years old.</p>
<h2>3. Rules</h2><ul>
<li>Criticize arguments, not people: no insults or personal attacks.</li>
<li>No hate speech, threats or sexual content, and nothing illegal.</li>
<li>Do not share or ask for contact details (phone, social media, address).</li>
<li>Do not spam or try to disrupt the service.</li></ul>
<h2>4. Moderation</h2>
<p>Messages and custom topics are checked automatically by AI and simple rules; a message that breaks the rules is not sent, and you see the reason. Every user can report and block other users in a debate. Illegal content can also be reported to ${c}. Accounts that receive repeated reports from different users can be blocked automatically. We may remove content and restrict, suspend or block accounts that break these rules or the law. You will be told about such a measure in the app; you can contest it by writing to ${c}, and a human will review your case.</p>
<h2>5. AI</h2><p>In Debatos you interact with artificial intelligence: the AI opponent, translations and judges' scores are generated automatically. They can be wrong, one-sided or inaccurate, are not advice and do not express the developer's opinion. You can report an AI answer in the app.</p>
<h2>6. Free features, limits and Premium</h2><p>Debates with people are free. A limited number of AI debates is free; the current limits are shown in the app. Premium, when available, is offered through Google Play; its price and features are shown before purchase, and Google Play's terms apply to payment and cancellation.</p>
<h2>7. Your content</h2><p>You are responsible for what you write. You allow us to store, process and translate your messages to run the debate and judge it, and to show them to your opponent. You can delete finished debates and your account at any time.</p>
<h2>8. Availability</h2><p>We work to keep Debatos available but cannot guarantee uninterrupted operation. We may change or discontinue features; we will inform you of significant changes in advance where reasonable.</p>
<h2>9. Liability</h2><p>We are liable without limitation for intent and gross negligence and for injury to life, body or health. For slight negligence we are liable only for breaches of essential obligations and limited to the typical, foreseeable damage. Liability under mandatory statutory provisions remains unaffected.</p>
<h2>10. Law</h2><p>German law applies; mandatory consumer protection rules of the country where you live remain unaffected. Privacy: see the <a href="/privacy?lang=en">Privacy Policy</a>.</p>`],
    uk: ["Умови користування", `
<h2>1. Хто надає сервіс</h2><p>Debatos надає ${OWNER}, Німеччина. Контактна точка для користувачів і органів влади (ст. 11 і 12 DSA): ${c}. Ми спілкуємося англійською, німецькою та українською.</p>
<h2>2. Хто може користуватися</h2><p>Тобі має бути щонайменше 16 років.</p>
<h2>3. Правила</h2><ul>
<li>Критикуй аргументи, а не людей: без образ і переходу на особистості.</li>
<li>Без мови ворожнечі, погроз, сексуального контенту і нічого незаконного.</li>
<li>Не діліться контактами (телефон, соцмережі, адреса) і не просіть їх.</li>
<li>Без спаму і спроб зламати роботу сервісу.</li></ul>
<h2>4. Модерація</h2>
<p>Повідомлення і власні теми автоматично перевіряються AI і простими правилами; повідомлення, що порушує правила, не надсилається, і ти бачиш причину. Кожен користувач може поскаржитися на суперника і заблокувати його. Про незаконний контент можна також повідомити на ${c}. Акаунти, на які неодноразово скаржаться різні користувачі, можуть бути заблоковані автоматично. Ми можемо видаляти контент, обмежувати, призупиняти або блокувати акаунти, що порушують ці правила чи закон. Про такий захід ти дізнаєшся в застосунку; його можна оскаржити, написавши на ${c}, — твій випадок перегляне людина.</p>
<h2>5. AI</h2><p>У Debatos ти взаємодієш зі штучним інтелектом: AI-суперник, переклад і оцінки суддів створюються автоматично. Вони можуть бути помилковими, однобічними чи неточними, не є порадою і не виражають думки розробника. На відповідь AI можна поскаржитися в застосунку.</p>
<h2>6. Безкоштовні функції, ліміти й Преміум</h2><p>Дебати з людьми безкоштовні. Обмежена кількість дебатів з AI безкоштовна; актуальні ліміти показано в застосунку. Преміум, коли з'явиться, продаватиметься через Google Play; ціну й можливості видно до покупки, а для оплати й скасування діють умови Google Play.</p>
<h2>7. Твій контент</h2><p>Ти відповідаєш за те, що пишеш. Ти дозволяєш нам зберігати, обробляти й перекладати твої повідомлення, щоб проводити й оцінювати дебати і показувати їх суперникові. Завершені дебати і свій акаунт можна видалити будь-коли.</p>
<h2>8. Доступність</h2><p>Ми стараємося, щоб Debatos працював, але не гарантуємо безперебійної роботи. Ми можемо змінювати чи припиняти функції; про суттєві зміни повідомимо заздалегідь, коли це можливо.</p>
<h2>9. Відповідальність</h2><p>Ми необмежено відповідаємо за умисел і грубу необережність, а також за шкоду життю, тілу чи здоров'ю. За легку необережність відповідаємо лише за порушення суттєвих обов'язків і в межах типової передбачуваної шкоди. Відповідальність за обов'язковими нормами закону не обмежується.</p>
<h2>10. Право</h2><p>Застосовується право Німеччини; обов'язкові норми захисту споживачів країни твого проживання не обмежуються. Конфіденційність: див. <a href="/privacy?lang=uk">Політику конфіденційності</a>.</p>`],
    de: ["Nutzungsbedingungen", `
<h2>1. Anbieter</h2><p>Debatos wird angeboten von ${OWNER}, Deutschland. Kontaktstelle für Nutzer und Behörden (Art. 11 und 12 DSA): ${c}. Wir kommunizieren auf Deutsch, Englisch und Ukrainisch.</p>
<h2>2. Wer Debatos nutzen darf</h2><p>Du musst mindestens 16 Jahre alt sein.</p>
<h2>3. Regeln</h2><ul>
<li>Kritisiere Argumente, nicht Menschen: keine Beleidigungen oder persönlichen Angriffe.</li>
<li>Keine Hassrede, Drohungen, sexuellen oder rechtswidrigen Inhalte.</li>
<li>Teile keine Kontaktdaten (Telefon, soziale Netzwerke, Adresse) und frage nicht danach.</li>
<li>Kein Spam und keine Störung des Dienstes.</li></ul>
<h2>4. Moderation</h2>
<p>Nachrichten und eigene Themen werden automatisch durch KI und einfache Regeln geprüft; eine regelwidrige Nachricht wird nicht gesendet, und du siehst den Grund. Jeder Nutzer kann Gegner in einer Debatte melden und blockieren. Rechtswidrige Inhalte können auch an ${c} gemeldet werden. Konten, die wiederholt von verschiedenen Nutzern gemeldet werden, können automatisch gesperrt werden. Wir können Inhalte entfernen und Konten, die gegen diese Regeln oder das Gesetz verstoßen, einschränken, vorübergehend sperren oder sperren. Über eine solche Maßnahme wirst du in der App informiert; du kannst sie über ${c} anfechten, dein Fall wird dann von einem Menschen geprüft.</p>
<h2>5. KI</h2><p>In Debatos interagierst du mit künstlicher Intelligenz: KI-Gegner, Übersetzungen und Bewertungen der Richter werden automatisch erzeugt. Sie können falsch, einseitig oder ungenau sein, sind keine Beratung und geben nicht die Meinung des Entwicklers wieder. KI-Antworten können in der App gemeldet werden.</p>
<h2>6. Kostenlose Funktionen, Kontingente und Premium</h2><p>Debatten mit Menschen sind kostenlos. Eine begrenzte Zahl von KI-Debatten ist kostenlos; die aktuellen Kontingente zeigt die App. Premium wird, sobald verfügbar, über Google Play angeboten; Preis und Leistungen werden vor dem Kauf angezeigt, für Zahlung und Kündigung gelten die Bedingungen von Google Play.</p>
<h2>7. Deine Inhalte</h2><p>Du bist für deine Texte verantwortlich. Du erlaubst uns, deine Nachrichten zu speichern, zu verarbeiten und zu übersetzen, um die Debatte durchzuführen und zu bewerten und sie deinem Gegner anzuzeigen. Beendete Debatten und dein Konto kannst du jederzeit löschen.</p>
<h2>8. Verfügbarkeit</h2><p>Wir bemühen uns um einen störungsfreien Betrieb, können ihn aber nicht garantieren. Wir können Funktionen ändern oder einstellen; über wesentliche Änderungen informieren wir, soweit zumutbar, vorab.</p>
<h2>9. Haftung</h2><p>Wir haften unbeschränkt bei Vorsatz und grober Fahrlässigkeit sowie bei Verletzung von Leben, Körper oder Gesundheit. Bei leichter Fahrlässigkeit haften wir nur bei Verletzung wesentlicher Vertragspflichten und begrenzt auf den typischen, vorhersehbaren Schaden. Die Haftung nach zwingenden gesetzlichen Vorschriften bleibt unberührt.</p>
<h2>10. Recht</h2><p>Es gilt deutsches Recht; zwingende Verbraucherschutzvorschriften deines Wohnsitzstaates bleiben unberührt. Datenschutz: siehe <a href="/privacy?lang=de">Datenschutzerklärung</a>.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

// ---------------------------------------------------------------------
function deleteAccount(langIn, email) {
  const lang = pick(langIn);
  const c = contactLine(lang, email);
  const T = {
    en: ["Delete your Debatos account", `
<p>Debatos by ${OWNER}.</p>
<h2>In the app (fastest)</h2><ol>
<li>Open Debatos.</li><li>On the home screen scroll down to <b>Account</b>.</li>
<li>Tap <b>Delete account</b> and confirm.</li></ol>
<p>Deletion is immediate and cannot be undone.</p>
<h2>What is deleted</h2><p>Your nickname and account key, your debates with people (including all messages, translations and verdicts in them — they disappear for your opponents too), your queue entries, usage counters, reports and blocks. Reports about AI answers are kept without any link to you for up to 12 months. Debates against the AI are never stored.</p>
<h2>No access to the app?</h2><p>Write to ${c} with your nickname and we will delete the account within 30 days.</p>`],
    uk: ["Видалення акаунта Debatos", `
<p>Debatos від ${OWNER}.</p>
<h2>У застосунку (найшвидше)</h2><ol>
<li>Відкрий Debatos.</li><li>На головному екрані прокрути вниз до розділу <b>Акаунт</b>.</li>
<li>Натисни <b>Видалити акаунт</b> і підтверди.</li></ol>
<p>Видалення відбувається одразу, і його не можна скасувати.</p>
<h2>Що видаляється</h2><p>Нік і ключ акаунта, твої дебати з людьми (з усіма повідомленнями, перекладами й вердиктами — вони зникають і в суперників), заявки на пошук, лічильники, скарги й блокування. Скарги на відповіді AI зберігаються без зв'язку з тобою до 12 місяців. Дебати з AI взагалі не зберігаються.</p>
<h2>Немає доступу до застосунку?</h2><p>Напиши на ${c}, вкажи свій нік, і ми видалимо акаунт протягом 30 днів.</p>`],
    de: ["Debatos-Konto löschen", `
<p>Debatos von ${OWNER}.</p>
<h2>In der App (am schnellsten)</h2><ol>
<li>Öffne Debatos.</li><li>Scrolle auf dem Startbildschirm nach unten zu <b>Konto</b>.</li>
<li>Tippe auf <b>Konto löschen</b> und bestätige.</li></ol>
<p>Die Löschung erfolgt sofort und kann nicht rückgängig gemacht werden.</p>
<h2>Was gelöscht wird</h2><p>Nickname und Kontoschlüssel, deine Debatten mit Menschen (mit allen Nachrichten, Übersetzungen und Urteilen — sie verschwinden auch bei deinen Gegnern), Warteschlangen-Einträge, Nutzungszähler, Meldungen und Blockierungen. Meldungen zu KI-Antworten bleiben ohne Bezug zu dir bis zu 12 Monate erhalten. Debatten gegen die KI werden nie gespeichert.</p>
<h2>Kein Zugriff auf die App?</h2><p>Schreib an ${c} mit deinem Nickname, und wir löschen das Konto innerhalb von 30 Tagen.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

export const PAGES = {
  "/privacy": privacy,
  "/terms": terms,
  "/delete-account": deleteAccount,
};
