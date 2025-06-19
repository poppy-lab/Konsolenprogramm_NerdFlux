// NerdFlux – Filmzitate-Quiz mit ASCII-Intro, Ladeanimation, Fragen aus JSON und Highscore-System

import 'dart:convert'; // Für JSON-Verarbeitung
import 'dart:io'; // Für Dateioperationen & Terminal I/O
import 'dart:math'; // Für Random-Funktionen und Zufallsauswahl

// Löscht den Terminalbildschirm
void clearScreen() {
  stdout.write('\u001b[1J');
}

// Gibt Text mit Tipp-Effekt aus, simuliert einen Terminal-Stil
Future<void> zeigeMitTyping(String text, {int speed = 35}) async {
  for (var rune in text.runes) {
    stdout.write(String.fromCharCode(rune));
    await Future.delayed(Duration(milliseconds: speed));
  }
  stdout.writeln();
}

// Zeigt eine einfache Ladeanimation (rotierende Symbole)
Future<void> ladeAnimation({String text = "Lade"}) async {
  const frames = ['|', '/', '-', '\\'];
  final barLength = text.length + 2;
  for (int i = 0; i < 12; i++) {
    final frame = frames[i % frames.length];
    stdout.write('\r$text $frame');
    await Future.delayed(Duration(milliseconds: 100));
  }
  stdout.write('\r' + ' ' * (barLength + 4) + '\r');
}

// Zeigt das NerdFlux-Boot-Intro mit ASCII-Logo, Rahmen und Ladebalken
Future<void> zeigeBootIntro() async {
  clearScreen();
  await zeigeMitTyping("\u{1F47E} Booting NERDFLUX SYSTEM...", speed: 40);
  await Future.delayed(Duration(milliseconds: 400));
  print(" "); // Noch eine leere Zeile

  // ASCII-Logo
  final logo = [" █   █   █ ", " █   █   █ ", "     █   █ ", "     █   █ "];

// Textzeilen rechts neben dem Logo
  final text = [
    "BATCH 10 Aufgabe",
    "Projekt 6 – 3.4.6 Erstes Konsolenprogramm"
  ];

// Kombinierte Ausgabe
  for (int i = 0; i < logo.length; i++) {
    final logoLine = logo[i];
    final textLine = i < text.length ? "  ${text[i]}" : "";
    print(logoLine + textLine);
    await Future.delayed(Duration(milliseconds: 100));
  }

  print(" "); // Noch eine leere Zeile
  // Begrüßungsrahmen mit Fortschrittsbalken
  final rahmenOben = "╔═════════════════════════════════╗";
  final rahmenUnten = "╚═════════════════════════════════╝";
  final inhalt = [
    "║  \"Welcome to the Quizverse\"     ║",
    "║     Loading poppy.exe...        ║"
  ];

  print(rahmenOben);
  print("║   NERDFLUX SYSTEM ONLINE ✅     ║");
  for (final zeile in inhalt) {
    print(zeile);
    await Future.delayed(Duration(milliseconds: 150));
  }

  // Fortschrittsbalken animiert
  const barLength = 20;
  for (int i = 0; i <= barLength; i++) {
    final filled = "█" * i;
    final empty = "▒" * (barLength - i);
    stdout.write("\r║     $filled$empty        ║");
    await Future.delayed(Duration(milliseconds: 80));
  }

  print("");
  await Future.delayed(Duration(milliseconds: 300));
  print("║     Press ENTER to continue     ║");
  print(rahmenUnten);
  stdin.readLineSync(); // Warten auf Benutzereingabe
}

// Zeigt den Abspann mit ASCII-Rahmen, Logo und Credits
Future<void> zeigeAbspann() async {
  final abspann = [
    "",
    "╔══════════════════════════════════════════╗",
    "║                                          ║",
    "║        🎉 DANKE FÜRS SPIELEN! 🎉         ║",
    "║                                          ║",
    "║    NerdFlux – Das Filmzitate-Quiz        ║",
    "║     für Nerds, Filmfans und Legenden     ║",
    "║                                          ║",
    "║           © 2025 DerRiccardo             ║",
    "║         made with ❤️  and Dart            ║",
    "╚══════════════════════════════════════════╝",
  ];

  // ASCII-Logo zwischen Abspann und Footer
  final logo = [
    "              █   █   █              ",
    "              █   █   █              ",
    "                  █   █              ",
    "                  █   █              "
  ];

  // Footer mit Danksagung und Referenzen
  final footer = [
    "",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "         learn by AppAkademie ❤️              ",
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    "",
    "  Special thanks to:",
    "   • Moritz Hofmann  (AppAkademie lecturer)",
    "   • Lennart Kosova  (AppAkademie tutor)",
    "",
    "👉 Press ENTER to Nerd Again 👾",
    ""
  ];

  for (var line in abspann) {
    await zeigeMitTyping(line, speed: 15);
  }
  for (var line in logo) {
    await zeigeMitTyping(line, speed: 20);
  }
  for (var line in footer) {
    await zeigeMitTyping(line, speed: 15);
  }
  stdin.readLineSync(); // Warte auf Nutzer-Enter
}

// Datenmodell für eine Quizfrage
class Frage {
  String zitat; // Das Zitat selbst
  String kontext; // Hinweis oder Kontext zur Einordnung
  List<String> optionen; // Antwortoptionen A–C
  String richtigeAntwort; // Buchstabe der korrekten Antwort

  Frage(this.zitat, this.kontext, this.optionen, this.richtigeAntwort);

  // Erzeugt ein Frage-Objekt aus JSON
  factory Frage.fromJson(Map<String, dynamic> json) {
    return Frage(
      json['zitat'],
      json['kontext'],
      List<String>.from(json['optionen']),
      json['richtigeAntwort'],
    );
  }
}

// Liest Fragen aus einer JSON-Datei und wandelt sie in Frage-Objekte um
Future<List<Frage>> ladeFragenAusDatei(String pfad) async {
  final file = File(pfad);
  if (!await file.exists()) {
    print("❌ Datei '$pfad' nicht gefunden.");
    exit(1); // Bricht das Programm ab
  }
  final content = await file.readAsString();
  final List<dynamic> daten = jsonDecode(content);
  return daten.map((e) => Frage.fromJson(e)).toList();
}

// Zeigt gespeicherte Highscores an, sortiert nach Punktzahl
void zeigeHighscores() {
  final file = File('highscore.txt');
  if (!file.existsSync()) {
    print("Noch keine Highscores vorhanden.");
    return;
  }

  final lines = file.readAsLinesSync();
  lines.sort((a, b) {
    final punkteA =
        int.tryParse(RegExp(r"(\\d+)").firstMatch(a)?.group(1) ?? "0") ?? 0;
    final punkteB =
        int.tryParse(RegExp(r"(\\d+)").firstMatch(b)?.group(1) ?? "0") ?? 0;
    return punkteB.compareTo(punkteA);
  });

  print("\n🏅 Highscores:");
  for (var line in lines.take(10)) {
    print("🔹 $line");
  }
}

// Gibt Achievement basierend auf Erfolgsquote zurück
String getAchievement(int punkte, int runden) {
  double quote = punkte / runden;
  if (quote == 1) return "🥇 Perfektionist";
  if (quote >= 0.8) return "🏆 Meister-Nerd";
  if (quote >= 0.5) return "🎖️ Filmkenner";
  return "📚 Noch Padawan";
}

// Hauptfunktion – Spielstart
Future<void> main() async {
  final fragen = await ladeFragenAusDatei('assets/fragen.json');
  fragen.shuffle(); // Fragenreihenfolge zufällig

  clearScreen();
  await zeigeBootIntro();

  // Benutzername abfragen
  print("🎬 Willkommen zu NerdFlux – dem Filmzitate-Quiz!");
  stdout.write("Wie heißt du? ");
  String? name = stdin.readLineSync()?.trim();
  if (name == null || name.isEmpty) {
    name = "Unbekannt";
  } else {
    name = name[0].toUpperCase() + name.substring(1);
  }

  // Rundenanzahl bestimmen (5, 10 oder 15)
  int runden = 0;
  while (![5, 10, 15].contains(runden)) {
    stdout.write("Wie viele Fragen möchtest du spielen? (5 / 10 / 15): ");
    runden = int.tryParse(stdin.readLineSync() ?? "") ?? 0;
  }

  final ausgewaehlteFragen = fragen.take(runden).toList();
  int punkte = 0;
  List<String> buchstaben = ["A", "B", "C"];

  // Fragen-Loop
  for (int i = 0; i < ausgewaehlteFragen.length; i++) {
    await Future.delayed(Duration(seconds: 1));
    await ladeAnimation(text: "Nächste Frage wird geladen");
    clearScreen();

    // Optionales Easter Egg
    if (Random().nextInt(50) == 0) {
      print("\x1B[35m🎥 GEHEIMES ZITAT 🎥\x1B[0m");
      print("✨ „Du bist nicht im Film – du *bist* der Code.“");
      print("💾 NerdFlux OS // MetaModus aktiviert.");
      await Future.delayed(Duration(seconds: 2));
      continue;
    }

    final f = ausgewaehlteFragen[i];
    stdout.writeln("Frage ${i + 1} von $runden:\n");
    await zeigeMitTyping('\x1B[36m${f.zitat}\x1B[0m');
    await zeigeMitTyping('Kontext: ${f.kontext}\n');

    // Antwortmöglichkeiten anzeigen und prüfen
    var aktuelleOptionen = List<String>.from(f.optionen);
    var aktuelleBuchstaben = List<String>.from(buchstaben);
    bool korrekt = false;

    while (!korrekt && aktuelleOptionen.length >= 2) {
      for (int j = 0; j < aktuelleOptionen.length; j++) {
        print("${aktuelleBuchstaben[j]}) ${aktuelleOptionen[j]}");
      }

      stdout.write("\nDeine Antwort (A, B oder C): ");
      String? antwort = stdin.readLineSync()?.toUpperCase();

      if (antwort == f.richtigeAntwort) {
        print("\x1B[32m✔ Richtig, $name!\x1B[0m");
        punkte++;
        korrekt = true;
      } else {
        print(
            "\x1B[31m✘ Falsch. Versuch's nochmal mit den verbleibenden Optionen!\x1B[0m");
        int index = aktuelleBuchstaben.indexOf(antwort ?? "");
        if (index >= 0 && index < aktuelleOptionen.length) {
          aktuelleOptionen.removeAt(index);
          aktuelleBuchstaben.removeAt(index);
        }
      }
    }

    // Lösung anzeigen, wenn nicht korrekt beantwortet
    if (!korrekt) {
      print(
          "\x1B[31m✘ Leider falsch. Die richtige Antwort war: ${f.richtigeAntwort}) ${f.optionen[buchstaben.indexOf(f.richtigeAntwort)]}\x1B[0m");
    }
  }

  // Ergebnisanzeige & Speicherung
  stdout.write("\nDrücke Enter für das Ergebnis...");
  stdin.readLineSync();

  await ladeAnimation(text: "Berechne Auswertung");
  clearScreen();

  print("\n🏁 $name hat $punkte von $runden Punkten erreicht!");
  print("🏆 Auszeichnung: ${getAchievement(punkte, runden)}");

  // Score speichern
  final file = File('highscore.txt');
  file.writeAsStringSync("$name: $punkte von $runden Punkten\n",
      mode: FileMode.append);

  clearScreen();
  zeigeHighscores();
  await zeigeAbspann();
}
