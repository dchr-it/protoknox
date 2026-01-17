# Claude Code - Arbeitsrichtlinien für Protoknox RAG-Projekt

**Projekt:** Protoknox RAG-Prototyp
**Erstellt:** 2026-01-17
**Version:** 1.0

---

## 1. Grundprinzipien

### 1.1 Dokumentation & Nachvollziehbarkeit
- **Dokumentation ist essentiell**: Jede Entscheidung und jeder Schritt wird dokumentiert
- **Transparenz**: Ich erkläre meine Vorschläge mit Vor- und Nachteilen
- **Begründungen**: Architektur-Entscheidungen werden im RAG_PLANUNG.md festgehalten (Architecture Decision Records)
- **Nachvollziehbarkeit**: Code-Änderungen werden kommentiert und erklärt

### 1.2 Kommunikation
- **Sprache**: Deutsch für Kommunikation und Dokumentation
- **Code**: Englisch für Code-Kommentare, Variablennamen, Funktionen (internationaler Standard)
- **Erklärungen**: Ich erkläre proaktiv, warum ich welchen Ansatz vorschlage
- **Vor-/Nachteile**: Bei Vorschlägen werden immer Alternativen und Trade-offs aufgezeigt
- **Fragekultur**: Bei Unsicherheit frage ich nach, bei klaren Standards entscheide ich eigenständig

### 1.3 Entscheidungsprozess
1. Claude analysiert und schlägt Optionen vor
2. Claude erklärt Vor-/Nachteile jeder Option
3. User trifft informierte Entscheidung
4. Entscheidung wird in RAG_PLANUNG.md dokumentiert
5. Implementierung erfolgt nach Freigabe

---

## 2. Token-Management

### 2.1 Token-Budget
- **Gesamtbudget**: 200.000 Tokens pro Session
- **Warnschwelle**: Bei 90% Auslastung (180.000 Tokens) informiere ich proaktiv
- **Ziel**: Token-Verbrauch nie 100% erreichen, um Wartezeiten zu vermeiden

### 2.2 Verhalten bei 90% Token-Auslastung
**Wenn 180k Tokens erreicht sind:**

1. ⚠️ **STOP**: Aktuellen Task sofort unterbrechen
2. 📝 **Dokumentieren**:
   - Aktuellen Stand festhalten
   - Was wurde erledigt?
   - Was ist offen?
   - Nächste Schritte definieren
3. 💾 **Session Log erstellen** (siehe Abschnitt 3)
4. ✅ **User informieren**: "Token-Limit bei 90% erreicht. Session Log erstellt. Bereit für neue Session."

### 2.3 Token-Sparmaßnahmen
- Effiziente Tool-Nutzung (parallele Aufrufe wo möglich)
- Fokussierte Datei-Reads (nur relevante Abschnitte)
- Vermeidung von redundanten Wiederholungen
- Nutzung von Task-Agents für explorative Aufgaben

---

## 3. Session Logs

### 3.1 Format
**Dateiname**: `session_log_YYYYMMDD_HHMM.md`
**Zeitstempel**: Zeitpunkt der Erstellung des Logs
**Speicherort**: `/home/dchrm/protoknox/session_logs/`

### 3.2 Trigger für Session Log
- ✅ Bei Erreichen von 90% Token-Budget (automatisch)
- ✅ Bei User-Request "erstelle session log"
- ✅ Bei natürlichem Session-Ende (wenn User abschließt)
- ✅ Vor größeren Arbeitsunterbrechungen

### 3.3 Session Log Struktur
```markdown
# Session Log - [Datum] [Uhrzeit]

## Session-Info
- **Start**: YYYY-MM-DD HH:MM
- **Ende**: YYYY-MM-DD HH:MM
- **Token-Verbrauch**: X / 200.000 (Y%)
- **Abbruchgrund**: [90% Limit | User-Request | Session beendet]

## Zusammenfassung
[Kurze Übersicht was in der Session erreicht wurde]

## Erledigte Tasks
- ✅ Task 1
- ✅ Task 2
- ✅ Task 3

## Offene Tasks / In Progress
- ⏳ Task 4 (50% fertig - Details: ...)
- ⏳ Task 5 (nicht begonnen)

## Wichtige Entscheidungen
1. **Entscheidung**: [Was wurde entschieden]
   - **Begründung**: [Warum]
   - **Alternativen**: [Was wurde abgelehnt und warum]

## Geänderte Dateien
- `pfad/zur/datei.py` - [Was wurde geändert]
- `pfad/zur/datei2.md` - [Was wurde geändert]

## Nächste Schritte
1. [Konkreter nächster Schritt]
2. [Konkreter nächster Schritt]
3. [Konkreter nächster Schritt]

## Blockers / Fragen
- [Gibt es offene Fragen oder Blocker?]

## Notizen
[Sonstige wichtige Informationen]
```

---

## 4. Git-Workflow

### 4.1 Repository-Struktur
```
protoknox/
├── .git/
├── .gitignore
├── claude.md (diese Datei)
├── RAG_PLANUNG.md
├── README.md
├── session_logs/
├── src/
│   ├── __init__.py
│   ├── ingestion/
│   ├── retrieval/
│   └── generation/
├── tests/
├── data/
│   ├── raw/
│   └── processed/
├── docs/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── requirements.txt
```

### 4.2 Branching-Strategie
**Einfaches Feature-Branch-Modell:**

- **main**: Stabiler, funktionierender Code
- **feature/[name]**: Neue Features (z.B. `feature/embedding-pipeline`)
- **fix/[name]**: Bugfixes (z.B. `fix/chunking-overlap`)
- **docs/[name]**: Dokumentation (z.B. `docs/api-documentation`)

**Workflow:**
```bash
# Neues Feature
git checkout -b feature/embedding-pipeline
# ... Entwicklung ...
git add .
git commit -m "feat: implement embedding pipeline with OpenAI"
git checkout main
git merge feature/embedding-pipeline
git branch -d feature/embedding-pipeline
```

### 4.3 Commit-Konventionen
**Conventional Commits** (https://www.conventionalcommits.org/)

**Format**: `<type>: <kurze beschreibung>`

**Types:**
- `feat:` - Neues Feature
- `fix:` - Bugfix
- `docs:` - Dokumentation
- `refactor:` - Code-Refactoring (keine Funktionsänderung)
- `test:` - Tests hinzufügen/ändern
- `chore:` - Build, Dependencies, Config
- `perf:` - Performance-Verbesserung

**Beispiele:**
```bash
git commit -m "feat: add ChromaDB vector store integration"
git commit -m "fix: resolve chunking overlap issue"
git commit -m "docs: update RAG_PLANUNG.md with embedding strategy"
git commit -m "refactor: extract embedding logic into separate module"
git commit -m "test: add unit tests for document chunking"
git commit -m "chore: update dependencies in requirements.txt"
```

### 4.4 .gitignore Regeln
**Wichtig - NIEMALS committen:**
- ❌ API-Keys, Secrets, `.env` Dateien
- ❌ Große Modelle, Embeddings, Vector-DB-Dateien
- ❌ `__pycache__/`, `.pyc` Dateien
- ❌ Virtual Environments (`venv/`, `.venv/`)
- ❌ Rohdaten mit sensiblen Informationen
- ❌ IDE-spezifische Dateien (`.vscode/`, `.idea/`)

### 4.5 Meine Rolle bei Git
- ✅ Ich helfe bei jedem Commit (erkläre was commited wird)
- ✅ Ich schlage sinnvolle Commit-Messages vor
- ✅ Ich erstelle die .gitignore
- ✅ Ich weise auf sensible Dateien hin
- ✅ Ich erkläre jeden Git-Befehl bevor ich ihn ausführe

---

## 5. Docker-Workflow

### 5.1 Warum Docker?
**Vorteile:**
- ✅ Reproduzierbares Setup
- ✅ Isolation von Host-System
- ✅ Einfaches Management von Services (Vector-DB, API)
- ✅ Deployment-ready
- ✅ Team-Kollaboration einfacher

### 5.2 Docker-Setup für Anfänger
**Ich werde erklären:**
- Was ist ein Dockerfile?
- Was ist docker-compose.yml?
- Wie funktionieren Container?
- Wie funktionieren Volumes?
- Wie debugge ich in Containern?

### 5.3 Development-Workflow mit Docker
```bash
# Container starten
docker-compose up -d

# Logs ansehen
docker-compose logs -f

# In Container wechseln (für Debugging)
docker-compose exec app bash

# Container stoppen
docker-compose down

# Container neu bauen (nach Dependency-Änderungen)
docker-compose up -d --build
```

### 5.4 Geplante Services
**docker-compose.yml wird enthalten:**
- `app`: Python-Anwendung (RAG-System)
- `vector-db`: Chroma/Qdrant (je nach Entscheidung)
- `api`: FastAPI/Flask (optional, später)

### 5.5 Volume-Mounting für Live-Entwicklung
- Source-Code wird gemountet → Änderungen sofort sichtbar
- Kein Rebuild bei Code-Änderungen nötig
- Nur Rebuild bei Dependency-Änderungen (requirements.txt)

### 5.6 Meine Rolle bei Docker
- ✅ Ich erkläre jeden Docker-Befehl
- ✅ Ich erstelle verständliche Dockerfiles mit Kommentaren
- ✅ Ich helfe bei Debugging
- ✅ Ich erkläre was in Containern passiert
- ✅ Ich zeige Best Practices für Python+Docker

---

## 6. Projekt-Organisation

### 6.1 Dateistruktur
- **`/src`**: Gesamter Quellcode
- **`/tests`**: Unit- und Integrations-Tests
- **`/data`**: Daten (mit Unterordnern raw/processed)
- **`/docs`**: Zusätzliche Dokumentation
- **`/session_logs`**: Session Logs
- **`/docker`**: Docker-Konfigurationen
- **Root**: Configs, README, claude.md, RAG_PLANUNG.md

### 6.2 Code-Organisation
**Modular aufgebaut:**
```
src/
├── ingestion/        # Dokumente laden, chunken
├── embedding/        # Embeddings erstellen
├── storage/          # Vector-DB Interaktion
├── retrieval/        # Similarity Search
├── generation/       # LLM-Integration
└── utils/            # Hilfsfunktionen
```

### 6.3 Dokumentation
- **Code-Kommentare**: Englisch, für komplexe Logik
- **Docstrings**: Englisch, für alle Functions/Classes (Google-Style)
- **README.md**: Deutsch, Projektübersicht und Setup-Anleitung
- **RAG_PLANUNG.md**: Deutsch, Anforderungen und Entscheidungen
- **Session Logs**: Deutsch, Arbeitsprotokolle

---

## 7. Testing & Qualität

### 7.1 Testing-Mindset
- ✅ Ich schlage Tests proaktiv vor
- ✅ Unit-Tests für Kernlogik
- ✅ Integration-Tests für Pipelines
- ✅ Evaluation-Metriken für RAG-Qualität

### 7.2 Test-Framework
- **pytest** für Python
- Tests in `/tests` mit gleicher Struktur wie `/src`
- Test-Daten in `/tests/fixtures`

### 7.3 Code-Qualität
- **Black**: Code-Formatting (automatisch)
- **Pylint/Ruff**: Linting
- **Type Hints**: Wo sinnvoll (nicht übertreiben)

---

## 8. Arbeitsablauf (Workflow)

### 8.1 Typische Session
1. **Start**: Claude liest letztes Session Log (falls vorhanden)
2. **Planung**: Tasks besprechen, in RAG_PLANUNG.md oder TodoWrite festhalten
3. **Entwicklung**: Implementierung mit Erklärungen
4. **Dokumentation**: Änderungen dokumentieren
5. **Git-Commit**: Sinnvolle Commits mit Conventional Commits
6. **Testing**: Tests laufen lassen
7. **Session Log**: Bei 90% Token oder Ende Session Log erstellen

### 8.2 Planungsmodus für größere Tasks
Für nicht-triviale Implementierungen:
1. ✅ Claude wechselt in Planungsmodus (mit `EnterPlanMode`)
2. ✅ Claude exploriert Codebase
3. ✅ Claude erstellt detaillierten Plan
4. ✅ User genehmigt Plan
5. ✅ Implementierung startet

### 8.3 User-Freigabe erforderlich bei
- ⚠️ Architektur-Entscheidungen
- ⚠️ Wahl von Dependencies/Libraries
- ⚠️ Änderungen an bestehender Funktionalität
- ⚠️ Größeren Refactorings
- ⚠️ Deployment-Schritten

---

## 9. Sicherheit & Best Practices

### 9.1 Secrets-Management
- ❌ NIEMALS API-Keys im Code
- ✅ Immer `.env` Dateien verwenden
- ✅ `.env` in `.gitignore`
- ✅ `.env.example` als Template (ohne echte Keys)

### 9.2 Abhängigkeiten
- `requirements.txt` mit gepinnten Versionen
- Regelmäßige Updates dokumentieren
- Nur notwendige Dependencies

### 9.3 Daten
- Sensible Daten NICHT ins Repository
- Rohdaten in `/data/raw` (in .gitignore)
- Sample-Daten für Tests OK

---

## 10. Spezielle Regeln für dieses Projekt

### 10.1 RAG-Spezifisch
- **Embeddings**: Nicht ins Git (zu groß)
- **Vector-DB**: Datenbank-Files in .gitignore
- **Modelle**: Wenn lokal, dann .gitignore
- **Test-Dokumente**: Kleine Samples ins Repo OK

### 10.2 Evaluation
- Evaluation-Skripte dokumentieren
- Test-Fragen in RAG_PLANUNG.md pflegen
- Metriken tracken (kann später in Spreadsheet/Tool)

---

## 11. Checkliste für Claude

**Vor jedem Commit:**
- [ ] Code getestet?
- [ ] Secrets entfernt?
- [ ] Kommentare verständlich?
- [ ] RAG_PLANUNG.md aktualisiert (bei Entscheidungen)?
- [ ] .gitignore korrekt?

**Bei 90% Tokens:**
- [ ] Task unterbrochen & dokumentiert
- [ ] Session Log erstellt
- [ ] Nächste Schritte klar definiert
- [ ] User informiert

**Bei Session-Ende:**
- [ ] Alle offenen Fragen notiert?
- [ ] Session Log erstellt (wenn Session produktiv war)?
- [ ] Git-Status clean (oder WIP dokumentiert)?

---

## 12. User-Präferenzen (Zusammenfassung)

✅ Dokumentation & Nachvollziehbarkeit sind Priorität
✅ Erklärungen mit Vor-/Nachteilen erwünscht
✅ Token-schonend arbeiten
✅ Automatisches Session Log bei 90% Token
✅ Token-Limit NIE komplett ausreizen
✅ Git & Docker von Anfang an (trotz fehlender Erfahrung)
✅ Best Practices lernen durch Erklärungen

---

## Änderungshistorie

**v1.0 - 2026-01-17**
- Initiale Version
- Alle Kernregeln definiert
- Git & Docker Workflow integriert
- Session Log Format festgelegt

---

**Diese Datei ist das zentrale Regelwerk für unsere Zusammenarbeit. Bei Änderungen wird die Version hochgezählt und die Änderung hier dokumentiert.**
