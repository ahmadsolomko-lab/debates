// Публічні сторінки для Google Play: політика конфіденційності, умови, видалення акаунта.
// Мови: en (основна), uk, de. Для інших — англійська.

const UPDATED = "29.10.2026";

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
<p>Debatos is a debate app: you debate an AI or other people, and AI judges score the arguments. This policy explains what data the app processes and why.</p>
<h2>What we store</h2>
<ul>
<li><b>Nickname</b> that you choose, and a random account key created by the app. We do not ask for your name, e-mail, phone number or location.</li>
<li><b>App language</b> and your settings.</li>
<li><b>Debates with people</b>: your messages, topics, results and AI verdicts.</li>
<li><b>Safety data</b>: reports and blocks you send or receive.</li>
<li><b>Reports about AI answers</b>: the reported text, topic and reason.</li>
</ul>
<h2>What we do not store</h2>
<p>Debates against the AI are processed to generate the reply and the verdict and are <b>not stored</b> on our server. We use no advertising, no analytics and no tracking, and we do not sell or share data for advertising.</p>
<h2>On your device</h2>
<p>The account key, nickname, language and settings are saved on your phone so that you stay signed in.</p>
<h2>Who processes the data</h2>
<p>The server and the AI models run on <b>Cloudflare</b> (Cloudflare, Inc.), which acts as our processor. Your texts are sent to these AI models for replies, translation, moderation and judging. Cloudflare may process data outside the EU; such transfers are covered by the EU Standard Contractual Clauses and the EU–U.S. Data Privacy Framework.</p>
<h2>Why (legal basis)</h2>
<p>To provide the app you asked for (Art. 6(1)(b) GDPR) and to keep debates safe through moderation and reports (Art. 6(1)(f) GDPR, our legitimate interest in a safe community).</p>
<h2>How long</h2>
<p>Until you delete your account. Deleting the account immediately removes your nickname, your debates with people (including the messages in them), your reports and blocks. Reports about AI answers are kept without any link to you.</p>
<h2>Your rights</h2>
<p>You can delete your account at any time in the app (Home → Delete account), see <a href="/delete-account?lang=en">how to delete your account</a>. You also have the rights of access, rectification, erasure, restriction, portability and objection, and the right to complain to a data protection authority.</p>
<h2>Age</h2><p>Debatos is for people aged 16 and older.</p>
<h2>Contact</h2><p>${c}.</p>
<p class="muted">We may update this policy; the date above shows the latest version.</p>`],
    uk: ["Політика конфіденційності", `
<p>Debatos — застосунок для дебатів: ти сперечаєшся з AI або з людьми, а AI-судді оцінюють аргументи. Тут пояснено, які дані обробляє застосунок і навіщо.</p>
<h2>Що ми зберігаємо</h2>
<ul>
<li><b>Нік</b>, який ти вибрав, і випадковий ключ акаунта, створений застосунком. Ми не питаємо імені, пошти, телефону чи місцезнаходження.</li>
<li><b>Мову застосунку</b> та налаштування.</li>
<li><b>Дебати з людьми</b>: твої повідомлення, теми, результати й вердикти AI.</li>
<li><b>Дані безпеки</b>: скарги й блокування, які ти надсилаєш або отримуєш.</li>
<li><b>Скарги на відповіді AI</b>: текст, тему й причину скарги.</li>
</ul>
<h2>Чого ми не зберігаємо</h2>
<p>Дебати з AI обробляються лише для відповіді та вердикту і <b>не зберігаються</b> на сервері. Жодної реклами, аналітики чи стеження; ми не продаємо й не передаємо дані для реклами.</p>
<h2>На твоєму телефоні</h2>
<p>Ключ акаунта, нік, мова й налаштування зберігаються на телефоні, щоб ти лишався в акаунті.</p>
<h2>Хто обробляє дані</h2>
<p>Сервер і AI-моделі працюють на <b>Cloudflare</b> (Cloudflare, Inc.) як нашому обробнику. Твої тексти надсилаються цим моделям для відповідей, перекладу, модерації й суддівства. Cloudflare може обробляти дані поза ЄС; це покривають Стандартні договірні положення ЄС і EU–U.S. Data Privacy Framework.</p>
<h2>Навіщо (правова підстава)</h2>
<p>Щоб надати застосунок, яким ти користуєшся (ст. 6(1)(b) GDPR), і щоб дебати були безпечними завдяки модерації та скаргам (ст. 6(1)(f) GDPR, законний інтерес у безпечній спільноті).</p>
<h2>Як довго</h2>
<p>Доки ти не видалиш акаунт. Видалення одразу стирає нік, твої дебати з людьми (разом із повідомленнями), скарги й блокування. Скарги на відповіді AI зберігаються без зв'язку з тобою.</p>
<h2>Твої права</h2>
<p>Видалити акаунт можна будь-коли в застосунку (Головна → Видалити акаунт), див. <a href="/delete-account?lang=uk">як видалити акаунт</a>. Також ти маєш право на доступ, виправлення, видалення, обмеження, перенесення даних і заперечення, а також право поскаржитися до органу захисту даних.</p>
<h2>Вік</h2><p>Debatos — для людей від 16 років.</p>
<h2>Зв'язок</h2><p>${c}.</p>
<p class="muted">Ми можемо оновлювати цю політику; дата вгорі показує актуальну версію.</p>`],
    de: ["Datenschutzerklärung", `
<p>Debatos ist eine Debatten-App: Du debattierst mit einer KI oder mit anderen Menschen, und KI-Richter bewerten die Argumente. Hier steht, welche Daten die App verarbeitet und warum.</p>
<h2>Was wir speichern</h2>
<ul>
<li><b>Nickname</b>, den du wählst, und einen zufälligen Kontoschlüssel, den die App erzeugt. Wir fragen nicht nach Name, E-Mail, Telefonnummer oder Standort.</li>
<li><b>App-Sprache</b> und Einstellungen.</li>
<li><b>Debatten mit Menschen</b>: deine Nachrichten, Themen, Ergebnisse und KI-Urteile.</li>
<li><b>Sicherheitsdaten</b>: Meldungen und Blockierungen, die du sendest oder erhältst.</li>
<li><b>Meldungen zu KI-Antworten</b>: gemeldeter Text, Thema und Grund.</li>
</ul>
<h2>Was wir nicht speichern</h2>
<p>Debatten gegen die KI werden nur für die Antwort und das Urteil verarbeitet und <b>nicht gespeichert</b>. Keine Werbung, keine Analyse, kein Tracking; wir verkaufen oder teilen keine Daten für Werbung.</p>
<h2>Auf deinem Gerät</h2>
<p>Kontoschlüssel, Nickname, Sprache und Einstellungen werden auf deinem Handy gespeichert, damit du angemeldet bleibst.</p>
<h2>Wer die Daten verarbeitet</h2>
<p>Server und KI-Modelle laufen bei <b>Cloudflare</b> (Cloudflare, Inc.) als unserem Auftragsverarbeiter. Deine Texte werden an diese Modelle für Antworten, Übersetzung, Moderation und Bewertung gesendet. Cloudflare kann Daten außerhalb der EU verarbeiten; dies ist durch EU-Standardvertragsklauseln und das EU-U.S. Data Privacy Framework abgedeckt.</p>
<h2>Rechtsgrundlage</h2>
<p>Bereitstellung der App (Art. 6 Abs. 1 lit. b DSGVO) und Sicherheit durch Moderation und Meldungen (Art. 6 Abs. 1 lit. f DSGVO, berechtigtes Interesse an einer sicheren Community).</p>
<h2>Speicherdauer</h2>
<p>Bis du dein Konto löschst. Die Löschung entfernt sofort Nickname, deine Debatten mit Menschen (inklusive Nachrichten), Meldungen und Blockierungen. Meldungen zu KI-Antworten bleiben ohne Bezug zu dir erhalten.</p>
<h2>Deine Rechte</h2>
<p>Du kannst dein Konto jederzeit in der App löschen (Start → Konto löschen), siehe <a href="/delete-account?lang=de">Konto löschen</a>. Du hast außerdem das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit und Widerspruch sowie das Recht auf Beschwerde bei einer Datenschutzaufsichtsbehörde.</p>
<h2>Alter</h2><p>Debatos ist für Menschen ab 16 Jahren.</p>
<h2>Kontakt</h2><p>${c}.</p>
<p class="muted">Wir können diese Erklärung aktualisieren; das Datum oben zeigt die aktuelle Fassung.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

// ---------------------------------------------------------------------
function terms(langIn, email) {
  const lang = pick(langIn);
  const c = contactLine(lang, email);
  const T = {
    en: ["Terms of Use", `
<h2>1. Who can use Debatos</h2><p>You must be at least 16 years old.</p>
<h2>2. Rules</h2><ul>
<li>Criticize arguments, not people: no insults or personal attacks.</li>
<li>No hate speech, threats or sexual content.</li>
<li>Do not share or ask for contact details (phone, social media, address).</li>
<li>Do not spam or try to disrupt the service.</li></ul>
<h2>3. Moderation</h2><p>Messages are checked automatically and can be blocked. Users can report and block each other. We may remove content and restrict, suspend or block accounts that break these rules.</p>
<h2>4. AI</h2><p>AI opponents, translations and judges' scores are generated automatically and can be wrong, one-sided or inaccurate. They are not advice and not the opinion of the developer. You can report an AI answer in the app.</p>
<h2>5. Your content</h2><p>You are responsible for what you write. You allow us to store and process your messages to run the debate, translate it and judge it.</p>
<h2>6. Service</h2><p>Debatos is provided free of charge and "as is". We may change, pause or stop features at any time.</p>
<h2>7. Privacy</h2><p>See the <a href="/privacy?lang=en">Privacy Policy</a>.</p>
<h2>8. Law</h2><p>German law applies, without prejudice to mandatory consumer protection in your country.</p>
<h2>Contact</h2><p>${c}.</p>`],
    uk: ["Умови користування", `
<h2>1. Хто може користуватися</h2><p>Тобі має бути щонайменше 16 років.</p>
<h2>2. Правила</h2><ul>
<li>Критикуй аргументи, а не людей: без образ і переходу на особистості.</li>
<li>Без мови ворожнечі, погроз і відвертого контенту.</li>
<li>Не діліться контактами (телефон, соцмережі, адреса) і не просіть їх.</li>
<li>Без спаму і спроб зламати роботу сервісу.</li></ul>
<h2>3. Модерація</h2><p>Повідомлення перевіряються автоматично і можуть бути заблоковані. Користувачі можуть скаржитися одне на одного й блокувати. Ми можемо видаляти контент, обмежувати, призупиняти або блокувати акаунти, що порушують правила.</p>
<h2>4. AI</h2><p>AI-суперник, переклад і оцінки суддів створюються автоматично й можуть бути помилковими, однобічними чи неточними. Це не порада і не думка розробника. На відповідь AI можна поскаржитися в застосунку.</p>
<h2>5. Твій контент</h2><p>Ти відповідаєш за те, що пишеш. Ти дозволяєш нам зберігати й обробляти твої повідомлення, щоб проводити дебати, перекладати й оцінювати їх.</p>
<h2>6. Сервіс</h2><p>Debatos надається безкоштовно і «як є». Ми можемо змінювати, призупиняти чи припиняти функції будь-коли.</p>
<h2>7. Конфіденційність</h2><p>Див. <a href="/privacy?lang=uk">Політику конфіденційності</a>.</p>
<h2>8. Право</h2><p>Застосовується право Німеччини, без обмеження обов'язкового захисту споживачів у твоїй країні.</p>
<h2>Зв'язок</h2><p>${c}.</p>`],
    de: ["Nutzungsbedingungen", `
<h2>1. Wer Debatos nutzen darf</h2><p>Du musst mindestens 16 Jahre alt sein.</p>
<h2>2. Regeln</h2><ul>
<li>Kritisiere Argumente, nicht Menschen: keine Beleidigungen oder persönlichen Angriffe.</li>
<li>Keine Hassrede, Drohungen oder sexuellen Inhalte.</li>
<li>Teile keine Kontaktdaten (Telefon, soziale Netzwerke, Adresse) und frage nicht danach.</li>
<li>Kein Spam und keine Störung des Dienstes.</li></ul>
<h2>3. Moderation</h2><p>Nachrichten werden automatisch geprüft und können blockiert werden. Nutzer können einander melden und blockieren. Wir können Inhalte entfernen und Konten, die gegen die Regeln verstoßen, einschränken, vorübergehend sperren oder sperren.</p>
<h2>4. KI</h2><p>KI-Gegner, Übersetzungen und Bewertungen werden automatisch erzeugt und können falsch, einseitig oder ungenau sein. Sie sind keine Beratung und nicht die Meinung des Entwicklers. KI-Antworten können in der App gemeldet werden.</p>
<h2>5. Deine Inhalte</h2><p>Du bist für deine Texte verantwortlich. Du erlaubst uns, deine Nachrichten zu speichern und zu verarbeiten, um die Debatte durchzuführen, zu übersetzen und zu bewerten.</p>
<h2>6. Dienst</h2><p>Debatos wird kostenlos und „wie besehen" angeboten. Wir können Funktionen jederzeit ändern, pausieren oder einstellen.</p>
<h2>7. Datenschutz</h2><p>Siehe <a href="/privacy?lang=de">Datenschutzerklärung</a>.</p>
<h2>8. Recht</h2><p>Es gilt deutsches Recht, unbeschadet zwingender Verbraucherschutzvorschriften deines Landes.</p>
<h2>Kontakt</h2><p>${c}.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

// ---------------------------------------------------------------------
function deleteAccount(langIn, email) {
  const lang = pick(langIn);
  const c = contactLine(lang, email);
  const T = {
    en: ["Delete your Debatos account", `
<h2>In the app (fastest)</h2><ol>
<li>Open Debatos.</li><li>On the home screen scroll down to <b>Account</b>.</li>
<li>Tap <b>Delete account</b> and confirm.</li></ol>
<p>Deletion is immediate and cannot be undone.</p>
<h2>What is deleted</h2><p>Your nickname and account key, your debates with people (including all messages, translations and verdicts in them), your queue entries, reports and blocks. Reports about AI answers are kept without any link to you. Debates against the AI are never stored.</p>
<h2>No access to the app?</h2><p>Write to ${c} with your nickname and we will delete the account within 30 days.</p>`],
    uk: ["Видалення акаунта Debatos", `
<h2>У застосунку (найшвидше)</h2><ol>
<li>Відкрий Debatos.</li><li>На головному екрані прокрути вниз до розділу <b>Акаунт</b>.</li>
<li>Натисни <b>Видалити акаунт</b> і підтверди.</li></ol>
<p>Видалення відбувається одразу, і його не можна скасувати.</p>
<h2>Що видаляється</h2><p>Нік і ключ акаунта, твої дебати з людьми (з усіма повідомленнями, перекладами й вердиктами), заявки на пошук, скарги й блокування. Скарги на відповіді AI зберігаються без зв'язку з тобою. Дебати з AI взагалі не зберігаються.</p>
<h2>Немає доступу до застосунку?</h2><p>Напиши на ${c}, вкажи свій нік, і ми видалимо акаунт протягом 30 днів.</p>`],
    de: ["Debatos-Konto löschen", `
<h2>In der App (am schnellsten)</h2><ol>
<li>Öffne Debatos.</li><li>Scrolle auf dem Startbildschirm nach unten zu <b>Konto</b>.</li>
<li>Tippe auf <b>Konto löschen</b> und bestätige.</li></ol>
<p>Die Löschung erfolgt sofort und kann nicht rückgängig gemacht werden.</p>
<h2>Was gelöscht wird</h2><p>Nickname und Kontoschlüssel, deine Debatten mit Menschen (mit allen Nachrichten, Übersetzungen und Urteilen), Warteschlangen-Einträge, Meldungen und Blockierungen. Meldungen zu KI-Antworten bleiben ohne Bezug zu dir. Debatten gegen die KI werden nie gespeichert.</p>
<h2>Kein Zugriff auf die App?</h2><p>Schreib an ${c} mit deinem Nickname, und wir löschen das Konto innerhalb von 30 Tagen.</p>`],
  };
  return page(lang, T[lang][0], T[lang][1]);
}

export const PAGES = {
  "/privacy": privacy,
  "/terms": terms,
  "/delete-account": deleteAccount,
};
