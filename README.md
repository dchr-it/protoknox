# Protoknox - RAG-Prototyp

Ein **Retrieval-Augmented Generation (RAG)** System-Prototyp für intelligente Dokumentensuche und -analyse.

---

## 📋 Projektübersicht

Dieses Projekt implementiert ein RAG-System, das es ermöglicht:
- Dokumente zu laden und zu verarbeiten
- Embeddings zu erstellen und in einer Vector-Datenbank zu speichern
- Semantische Suche über Dokumente durchzuführen
- Kontextbasierte Antworten mit einem Large Language Model zu generieren

**Status:** 🚧 In Entwicklung (Prototyp-Phase)

---

## 🏗️ Projektstruktur

```
protoknox/
├── src/               # Quellcode
│   ├── ingestion/     # Dokument-Laden & Chunking
│   ├── embedding/     # Embedding-Generierung
│   ├── storage/       # Vector-DB Integration
│   ├── retrieval/     # Similarity Search
│   ├── generation/    # LLM-Integration
│   └── utils/         # Hilfsfunktionen
├── tests/             # Unit- und Integration-Tests
├── data/              # Daten
│   ├── raw/           # Rohdaten (nicht im Git)
│   └── processed/     # Verarbeitete Daten (nicht im Git)
├── docs/              # Zusätzliche Dokumentation
├── session_logs/      # Entwicklungs-Session-Logs
├── docker/            # Docker-Konfigurationen
├── claude.md          # Arbeitsrichtlinien für KI-Assistenz
├── RAG_PLANUNG.md     # Detaillierte Projektplanung
└── README.md          # Diese Datei
```

---

## 🚀 Setup & Installation

### Voraussetzungen
- Python 3.10+
- Docker & Docker Compose
- Git

### Installation (Coming Soon)

```bash
# Repository klonen
git clone <repository-url>
cd protoknox

# Docker Container starten
docker-compose up -d

# Dependencies installieren (falls lokal entwickelt wird)
pip install -r requirements.txt
```

---

## 📚 Dokumentation

- **[RAG_PLANUNG.md](./RAG_PLANUNG.md)** - Detaillierte Projektplanung, Anforderungen & Architektur-Entscheidungen
- **[claude.md](./claude.md)** - Arbeitsrichtlinien für die KI-gestützte Entwicklung
- **[session_logs/](./session_logs/)** - Protokolle der Entwicklungssessions

---

## 🛠️ Technologie-Stack (Geplant)

### Kern-Komponenten
- **Embedding-Modell:** TBD (OpenAI, Sentence-Transformers, etc.)
- **Vector-Datenbank:** TBD (Chroma, Qdrant, FAISS, etc.)
- **LLM:** TBD (OpenAI GPT-4, Claude, lokale Modelle)
- **Framework:** TBD (LangChain, LlamaIndex, custom)

### Development
- **Sprache:** Python 3.10+
- **Testing:** pytest
- **Code Quality:** Black, Pylint/Ruff
- **Containerization:** Docker & Docker Compose

---

## 🔒 Sicherheit

- **Secrets:** API-Keys und Credentials werden NIEMALS ins Repository committed
- **Environment Variables:** Verwendung von `.env` Dateien (siehe `.env.example`)
- **Data Privacy:** Rohdaten werden nicht ins Git committed

---

## 📝 Entwicklungs-Workflow

Dieses Projekt folgt einem strukturierten Entwicklungsprozess:

1. **Planung:** Anforderungen in `RAG_PLANUNG.md` dokumentieren
2. **Implementierung:** Modularer Code in `/src`
3. **Testing:** Tests in `/tests`
4. **Dokumentation:** Session Logs & Code-Kommentare
5. **Git:** Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)

Details siehe [claude.md](./claude.md).

---

## 🎯 Roadmap

- [ ] Anforderungen & Architektur finalisieren
- [ ] Docker-Setup erstellen
- [ ] Ingestion-Pipeline implementieren
- [ ] Embedding-System aufsetzen
- [ ] Vector-DB Integration
- [ ] Retrieval-System implementieren
- [ ] LLM-Integration
- [ ] Evaluation-Framework
- [ ] User Interface (CLI/Web)

---

## 👤 Entwicklung

**Entwickler:** dchrm
**Startdatum:** 2026-01-17
**KI-Assistenz:** Claude Code (Anthropic)

---

## 📄 Lizenz

TBD

---

**Hinweis:** Dieses README wird während der Entwicklung kontinuierlich aktualisiert.
