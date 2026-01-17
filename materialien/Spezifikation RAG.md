# Spezifikation RAG - Funktionellmedizinisches Assistenzsystem

**Projekt:** Protoknox RAG-Prototyp
**Erstellt:** 2026-01-17
**Zweck:** Technische Dokumentation und Wissensbasis für die Entwicklung eines funktionellmedizinischen KI-Assistenzsystems

---

## Zusammenspiel von Ontologie, Knowledge Graph und LLM

### 1. Einleitung: Warum Ontologien und Knowledge Graphs bei medizinischen RAG-Systemen?

Ein reines LLM-basiertes RAG-System (Retrieval-Augmented Generation) durchsucht Dokumente und gibt relevante Text-Passagen an ein Large Language Model weiter. **Für ein funktionellmedizinisches Assistenzsystem reicht das nicht aus.**

**Warum nicht?**

1. **Medizinisches Wissen ist hochstrukturiert**: Symptome haben kausale Beziehungen zu Pathophysiologien, Laborwerte haben Referenzbereiche und Interpretationskontexte, Therapien haben Kontraindikationen.
2. **Evidenz-Hierarchie ist wichtig**: Eine Meta-Analyse (Oxford Level 1a) hat mehr Gewicht als eine Expertenmeinung (Level 5).
3. **Zeitliche Validität**: Medizinisches Wissen veraltet schnell. Eine Empfehlung von 2020 kann 2026 überholt sein.
4. **Komplexe Beziehungen**: "Vitamin D beeinflusst mitochondriale Funktion über COX-Enzyme" ist eine mehrschichtige Beziehung, die nur als Text schwer zu verarbeiten ist.
5. **Personalisierung**: Therapieempfehlungen müssen kontextabhängig sein (Alter, Vorerkrankungen, Medikation, Genetik).

**Die Lösung: Kombination von LLM, Ontologien und Knowledge Graphs**

Diese drei Komponenten ergänzen sich:
- **Ontologie** definiert die Begriffe und ihre Beziehungen (das "Vokabular")
- **Knowledge Graph** speichert konkrete Fakten in dieser Struktur (die "Wissensdatenbank")
- **LLM** versteht natürliche Sprache, generiert Antworten und interpretiert Kontext (die "Intelligenz")

---

## 2. Grundbegriffe präzise erklärt

### 2.1 Was ist eine Ontologie?

**Definition (präzise):**
Eine **Ontologie** ist ein formales, explizites Modell eines Wissensbereichs, das Konzepte (Klassen), ihre Eigenschaften (Attribute) und ihre Beziehungen zueinander definiert. Sie legt fest, **welche Arten von Dingen existieren** und **wie sie miteinander in Beziehung stehen**.

**Verständliche Erklärung:**
Stell Dir eine Ontologie wie ein **detailliertes Regelwerk** vor, das festlegt:
- Welche Begriffe es in einem Fachgebiet gibt
- Was diese Begriffe bedeuten (exakte Definitionen)
- Welche Beziehungen zwischen ihnen erlaubt sind
- Welche logischen Regeln gelten

**Medizinisches Beispiel:**

Eine funktionellmedizinische Ontologie könnte definieren:

```
Klasse: Symptom
  - Eigenschaften: name, severity, duration, onset_pattern
  - Beziehungen:
    - indicates_dysfunction (verweist auf → Systemdysfunktion)
    - measured_by (gemessen durch → Diagnostikparameter)

Klasse: Systemdysfunktion
  - Unterklassen: EntzündungsSystemik, MitochondrialeDysfunktion, HormonAchsenstörung, ...
  - Eigenschaften: pathophysiology, affected_organ_systems
  - Beziehungen:
    - causes (verursacht → Symptom)
    - detectable_via (nachweisbar durch → Laborparameter)
    - treated_by (behandelbar durch → Intervention)

Klasse: Laborparameter
  - Eigenschaften: name, unit, reference_range, optimal_range, clinical_significance
  - Beziehungen:
    - indicates (zeigt an → Systemdysfunktion)
    - influenced_by (beeinflusst durch → Supplement, Medikation, Lifestyle)

Klasse: Intervention
  - Unterklassen: Supplement, Ernährungsintervention, LifestyleIntervention, Phytotherapie
  - Eigenschaften: name, dosage, mechanism_of_action, evidence_level
  - Beziehungen:
    - targets (zielt auf → Systemdysfunktion)
    - contraindicated_with (kontraindiziert bei → Medikation, Vorerkrankung)
    - interacts_with (interagiert mit → Supplement, Medikation)
```

**Konkrete Ontologie-Regel:**
```
WENN ein Patient "chronische Müdigkeit" + "Brain Fog" + "Muskelschmerzen" hat
UND CRP erhöht IST
UND Vitamin D < 30 ng/ml IST
DANN besteht eine mögliche EntzündungsSystemik
UND MitochondrialeDysfunktion ist differentialdiagnostisch zu prüfen
```

**Bestehende medizinische Ontologien:**
- **SNOMED CT** (Systematized Nomenclature of Medicine – Clinical Terms): Weltweiter Standard für medizinische Begriffe
- **ICD-10/11** (International Classification of Diseases): Diagnoseklassifikation
- **MeSH** (Medical Subject Headings): NLM-Thesaurus für Literatursuche
- **GO** (Gene Ontology): Beschreibt Genfunktionen
- **HPO** (Human Phenotype Ontology): Beschreibt phänotypische Abnormalitäten

Für das funktionellmedizinische System würde man eine **eigene Ontologie** entwickeln, die diese Standards erweitert und funktionellmedizinische Konzepte (IFM-Matrix, Functional Medicine Timeline, optimal ranges) integriert.

---

### 2.2 Was ist ein Knowledge Graph?

**Definition (präzise):**
Ein **Knowledge Graph** (Wissensgraph) ist eine strukturierte Darstellung von Wissen in Form eines Graphen, bei dem **Entitäten** (Knoten) durch **Beziehungen** (Kanten) miteinander verbunden sind. Jede Beziehung wird durch ein Tripel repräsentiert: `(Subjekt) - [Prädikat] -> (Objekt)`.

**Verständliche Erklärung:**
Ein Knowledge Graph ist wie ein **riesiges Netzwerk von Fakten**, bei dem jeder Fakt eine Verbindung zwischen zwei Dingen darstellt.

**Unterschied zur Ontologie:**
- **Ontologie** = Die **Regeln** (Schema, Meta-Ebene): "Was KANN existieren und wie"
- **Knowledge Graph** = Die **Fakten** (Instanzen, Daten-Ebene): "Was TATSÄCHLICH existiert"

**Medizinisches Beispiel:**

```
[Chronische Müdigkeit] --ist-ein--> [Symptom]
[Chronische Müdigkeit] --indiziert--> [Mitochondriale Dysfunktion]
[Chronische Müdigkeit] --indiziert--> [Hypothyreose]
[Chronische Müdigkeit] --indiziert--> [Chronische Entzündung]

[Mitochondriale Dysfunktion] --detektierbar-via--> [CoQ10-Spiegel]
[Mitochondriale Dysfunktion] --detektierbar-via--> [Laktat/Pyruvat-Ratio]
[Mitochondriale Dysfunktion] --behandelbar-durch--> [CoQ10-Supplementation]
[Mitochondriale Dysfunktion] --behandelbar-durch--> [PQQ-Supplementation]

[CoQ10-Supplementation] --dosierung--> [100-300 mg/Tag]
[CoQ10-Supplementation] --evidenz-level--> [Oxford Level 2b]
[CoQ10-Supplementation] --referenz--> [DOI:10.1016/j.phrs.2018.03.011]
[CoQ10-Supplementation] --interagiert-mit--> [Statine]
[CoQ10-Supplementation] --kontraindiziert-bei--> [Schwangerschaft (unzureichende Datenlage)]

[CoQ10-Spiegel] --referenzbereich--> [0.5-1.5 μg/mL]
[CoQ10-Spiegel] --optimal-range--> [>1.0 μg/mL]
[CoQ10-Spiegel] --beeinflusst-durch--> [Statine, negativ]
[CoQ10-Spiegel] --beeinflusst-durch--> [Alter, negativ]
```

**Wichtig für das funktionellmedizinische System:**

Jede Kante (Beziehung) im Graph hat **Metadaten**:
- **Evidenz-Level** (Oxford-Pyramide, GRADE)
- **Quellen-Referenz** (PubMed-ID, DOI)
- **Validierungs-Datum** (wann wurde die Verbindung zuletzt überprüft?)
- **Confidence-Score** (wie sicher ist diese Aussage?)

**Beispiel mit Metadaten:**
```
[Vitamin D Mangel] --erhöht-risiko-für--> [Autoimmunerkrankungen]
  Evidenz: Meta-Analyse (Oxford Level 1a)
  Quelle: PMID:34567890 (DOI:10.1016/j.autoimm.2024.102345)
  Validiert: 2025-11-12
  Confidence: 0.89 (hoch)
```

**Bekannte medizinische Knowledge Graphs:**
- **Unified Medical Language System (UMLS)**: Integriert 200+ medizinische Vokabulare
- **Hetionet**: Biomedizinischer KG mit Krankheiten, Genen, Medikamenten, etc.
- **DisGeNET**: Krankheits-Gen-Assoziationen
- **KEGG** (Kyoto Encyclopedia of Genes and Genomes): Stoffwechselwege
- **DrugBank**: Medikamente, Wirkmechanismen, Interaktionen

---

## 3. Wie spielen LLM, Knowledge Graph und Ontologie zusammen bei RAG?

### 3.1 Traditionelles RAG (nur LLM + Vektordatenbank)

**Workflow:**
1. Dokumente (PDFs, Papers, Leitlinien) werden in Text-Chunks aufgeteilt
2. Text-Chunks werden in Embeddings (Vektoren) umgewandelt
3. Embeddings werden in einer Vektordatenbank gespeichert (z.B. ChromaDB)
4. Bei einer Frage: Ähnlichkeitssuche findet relevante Chunks
5. LLM erhält die Chunks als Kontext und generiert eine Antwort

**Probleme für medizinische Anwendung:**
- ❌ Keine strukturierte Repräsentation von Beziehungen
- ❌ Evidenz-Hierarchie wird ignoriert (alle Texte sind gleichwertig)
- ❌ Keine explizite Validierung von kausalen Zusammenhängen
- ❌ Schwierig, widersprüchliche Informationen zu erkennen
- ❌ Keine maschinenlesbare Logik (nur Text)

### 3.2 Hybrid-RAG mit Ontologie + Knowledge Graph + LLM

**Workflow:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    Eingabe: Arzt-Anamnese                        │
│  "Patient: 45J, m, chronische Müdigkeit, Brain Fog, Vitamin D   │
│   <20 ng/mL, CRP 8 mg/L, TSH 3.2 mU/L"                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 1: NLP-Extraktion (LLM)        │
        │  → Extrahiere strukturierte Daten       │
        │    - Symptome: [Müdigkeit, Brain Fog]   │
        │    - Labor: [Vit D: 18, CRP: 8, TSH:3.2]│
        │    - Demografie: [Alter: 45, Gender: m] │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 2: Ontologie-Mapping           │
        │  → Mappe auf Ontologie-Klassen          │
        │    Müdigkeit → Symptom::ChronischeMüdigkeit │
        │    Vit D 18 → Laborparameter::VitaminD_Mangel_Schwer │
        │    CRP 8 → Laborparameter::CRP_Erhöht    │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 3: Knowledge Graph Query       │
        │  → Finde alle Verbindungen im KG        │
        │    QUERY:                               │
        │    MATCH (s:Symptom {name: "Chronische Müdigkeit"}) │
        │          -[:INDIZIERT]->(d:Dysfunktion) │
        │    WHERE d.supported_by_lab IN [...]    │
        │    RETURN d, evidence_level, references │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 4: Reasoning Engine            │
        │  → Logische Inferenzen über Ontologie   │
        │    REGEL: IF Vit D < 20 AND CRP > 5     │
        │           THEN EntzündungsSystemik=wahrscheinlich │
        │    REGEL: IF TSH > 2.5 AND Müdigkeit    │
        │           THEN Hypothyreose_check_fT3_fT4 │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 5: Vektordatenbank-RAG         │
        │  → Finde relevante Literatur/Guidelines │
        │    zu den identifizierten Dysfunktionen │
        │    Embedding-Suche nach:                │
        │    - "Vitamin D Entzündung Müdigkeit"   │
        │    - "Mitochondriale Dysfunktion CoQ10" │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 6: LLM Synthesis               │
        │  → Generiere Diagnostik-Empfehlungen    │
        │    Kontext: KG-Fakten + Papers + Regeln │
        │    Output:                              │
        │    "Differentialdiagnosen:              │
        │     1. Mitochondriale Dysfunktion (hoch)│
        │     2. Subklinische Hypothyreose (mittel)│
        │     3. Chronisches Entzündungssyndrom   │
        │                                         │
        │     Empfohlene Diagnostik:              │
        │     - fT3, fT4 (DD Hypothyreose)        │
        │     - CoQ10, Laktat/Pyruvat (DD Mito)   │
        │     - Ferritin, Zink, Selen (Cofaktoren)│
        │                                         │
        │     Evidenz: [PubMed-Links...]"         │
        └─────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────┐
        │  SCHRITT 7: Confidence & Traceability   │
        │  → Jede Aussage hat:                    │
        │    - Confidence-Score (0-1)             │
        │    - Quellen-IDs aus KG                 │
        │    - Reasoning-Path (welche Regeln)     │
        └─────────────────────────────────────────┘
```

### 3.3 Vorteile des Hybrid-Ansatzes

| Aspekt | Nur LLM-RAG | Hybrid (LLM + KG + Ontologie) |
|--------|-------------|-------------------------------|
| **Strukturierte Beziehungen** | ❌ Nur Text | ✅ Explizite Relationen im KG |
| **Logische Inferenzen** | ❌ Limitiert | ✅ Reasoning über Ontologie-Regeln |
| **Evidenz-Gewichtung** | ❌ Schwierig | ✅ Metadaten im KG (Evidence-Level) |
| **Traceability** | ⚠️ Nur wenn LLM zitiert | ✅ Jeder Fakt hat Quellen-ID |
| **Widersprüche erkennen** | ❌ LLM muss halluzinieren | ✅ KG-Konsistenzprüfung |
| **Update-Mechanismus** | ⚠️ Nur durch Re-Embedding | ✅ KG-Knoten/Kanten-Update |
| **Personalisierung** | ⚠️ Nur via Prompt-Engineering | ✅ Patientenprofil als KG-Entität |
| **Interpretierbarkeit** | ❌ Black Box | ✅ Reasoning-Path ist nachvollziehbar |

---

## 4. Agenten in RAG-Systemen: Wann, Warum und Was?

### 4.1 Was sind Agenten?

**Definition:**
Ein **Agent** ist ein autonomes Software-Modul, das **zielgerichtet handelt**, um eine spezifische Aufgabe zu erfüllen. Agenten können:
- Entscheidungen treffen (basierend auf Regeln oder ML-Modellen)
- Mit anderen Agenten kommunizieren
- Werkzeuge (Tools) nutzen (z.B. Datenbanken, APIs, Code-Execution)
- Ihren internen Zustand anpassen (lernen, erinnern)

**Im Kontext von LLM-Systemen:**
Ein Agent ist ein LLM, das nicht nur Fragen beantwortet, sondern **aktiv Aufgaben ausführt** durch:
- **Tool-Use**: Aufrufen von APIs, Datenbank-Queries, Code-Execution
- **Planung**: Mehrstufige Workflows orchestrieren
- **Selbstreflexion**: Eigene Outputs validieren
- **Kollaboration**: Mit anderen Agenten zusammenarbeiten (Multi-Agent-System)

### 4.2 Wann kommen Agenten zum Einsatz?

Agenten sind sinnvoll, wenn:

1. **Komplexe, mehrstufige Workflows** erforderlich sind
   → Beispiel: "Erstelle Diagnostikplan → Warte auf Labordaten → Interpretiere → Erstelle Therapieplan"

2. **Spezialisiertes Wissen** in verschiedenen Domänen benötigt wird
   → Beispiel: Ein Agent für Laborinterpretation, ein anderer für Pharmakologie, ein dritter für Ernährungsmedizin

3. **Externe Tools** eingebunden werden müssen
   → Beispiel: PubMed-API, Datenbank-Queries, Interaktions-Checker

4. **Validierung und Quality Assurance** kritisch sind
   → Beispiel: Ein Agent generiert Therapievorschlag, ein zweiter Agent prüft auf Kontraindikationen

5. **Iterative Verfeinerung** erforderlich ist
   → Beispiel: Agent fragt nach fehlenden Informationen, bis Diagnose gesichert ist

### 4.3 Aufgaben von Agenten im funktionellmedizinischen RAG-System

#### Agent 1: **Anamnese-Agent** (Data Extraction & Structuring)

**Aufgabe:**
Strukturiert die Arzteingabe in maschinenlesbare Entitäten.

**Workflow:**
```
Input: "Patient klagt über Brain Fog seit 6 Monaten, nimmt Metformin wegen Prädiabetes"
↓
[Agent nutzt NER-Modell + Ontologie-Mapping]
↓
Output:
{
  "symptoms": [{"name": "Brain Fog", "duration": "6 months", "severity": "nicht spezifiziert"}],
  "medications": [{"name": "Metformin", "indication": "Prädiabetes"}],
  "diagnoses": [{"name": "Prädiabetes", "status": "aktiv"}]
}
```

**Tools:**
- NER (Named Entity Recognition) für medizinische Begriffe
- Ontologie-Mapping-Engine
- Rückfrage-Generator bei Unklarheiten

---

#### Agent 2: **Diagnostik-Planer** (Diagnostic Reasoning)

**Aufgabe:**
Generiert priorisierte, evidenzbasierte Diagnostikempfehlungen.

**Workflow:**
```
Input: Strukturierte Anamnese
↓
1. Query Knowledge Graph nach relevanten Dysfunktionen
2. Hole Leitlinien-Empfehlungen aus Vektordatenbank
3. Priorisiere nach:
   - Klinische Wahrscheinlichkeit (Bayesianisch)
   - Evidenz-Level
   - Kosten-Nutzen
↓
Output: Diagnostik-Liste mit Begründungen + Quellen
```

**Tools:**
- KG-Query-Engine (z.B. Neo4j Cypher, SPARQL)
- Bayesianisches Reasoning
- Literatur-Retrieval (PubMed API)

---

#### Agent 3: **Labor-Interpretations-Agent** (Lab Analysis)

**Aufgabe:**
Interpretiert Laborwerte im funktionellmedizinischen Kontext.

**Workflow:**
```
Input: Laborwerte (HL7/FHIR-Format)
↓
1. Validiere Werte (Plausibilität, Einheiten)
2. Vergleiche mit Referenzbereichen UND optimal ranges (aus KG)
3. Erkenne Muster:
   - Entzündungsmarker-Cluster (CRP, IL-6, TNF-α)
   - Mitochondrien-Marker (CoQ10, Laktat/Pyruvat, Citrullin)
   - Hormon-Achsen (Cortisol, DHEA, fT3/fT4-Ratio)
4. Mappe auf IFM-Matrix (Assimilation, Defense, Energy, etc.)
↓
Output:
  - Pathophysiologische Cluster
  - Funktionellmedizinische Einordnung
  - Differentialdiagnosen
  - Quellen für jede Interpretation
```

**Tools:**
- HL7/FHIR-Parser
- KG-Pattern-Matching
- IFM-Matrix-Engine
- Referenzbereiche-Datenbank (alters- und geschlechtsspezifisch)

---

#### Agent 4: **Therapie-Planer** (Treatment Recommendation)

**Aufgabe:**
Erstellt personalisierten, evidenzbasierten Therapieplan.

**Workflow:**
```
Input:
  - Diagnose-Cluster
  - Laborwerte
  - Patientenprofil (Alter, Geschlecht, Medikation, Allergien)
↓
1. Query KG nach Interventionen für identifizierte Dysfunktionen
2. Filtere basierend auf:
   - Kontraindikationen (Patientenprofil)
   - Interaktionen (aktuelle Medikation)
   - Evidenz-Level
3. Priorisiere nach IFM-Hierarchie:
   - Remove (Trigger entfernen: Gluten, Toxine, Stress)
   - Replace (Defizite ausgleichen: Vit D, Mg, Enzyme)
   - Reinoculate (Mikrobiom: Probiotika, Präbiotika)
   - Repair (Barriere: Glutamin, Zink, Omega-3)
   - Rebalance (Lifestyle: Schlaf, Bewegung, Stressmanagement)
↓
Output:
  - Therapieplan (strukturiert nach IFM 5R-Framework)
  - Für jede Intervention: Dosierung, Dauer, Evidenz, Quellen
  - Monitoring-Parameter (wann Kontrolllabor?)
```

**Tools:**
- KG-Query-Engine
- Interaktions-Checker (DrugBank API)
- Dosierungs-Rechner (gewichtsbasiert, altersbasiert)
- Evidenz-Ranking-Engine

---

#### Agent 5: **Quality-Assurance-Agent** (Validation & Safety)

**Aufgabe:**
Validiert Outputs der anderen Agenten auf Sicherheit und Konsistenz.

**Workflow:**
```
Input: Therapieplan von Agent 4
↓
1. Prüfe auf:
   - Red Flags (gefährliche Interaktionen, Kontraindikationen)
   - Inkonsistenzen (widersprüchliche Empfehlungen)
   - Fehlende Quellen (jede Empfehlung MUSS Referenz haben)
   - Compliance mit Guidelines (AWMF, NICE)
2. Berechne Confidence-Score für gesamten Plan
3. Markiere unsichere Bereiche für ärztliche Review
↓
Output:
  - Validierungs-Report
  - Warnungen (falls vorhanden)
  - Freigabe-Empfehlung (grün/gelb/rot)
```

**Tools:**
- Regel-Engine (Safety-Rules)
- Konsistenz-Checker (logische Prüfungen)
- Guideline-Compliance-Checker

---

#### Agent 6: **Literatur-Update-Agent** (Knowledge Maintenance)

**Aufgabe:**
Hält Knowledge Graph und Vektordatenbank aktuell.

**Workflow (läuft kontinuierlich im Hintergrund):**
```
1. Überwache PubMed für neue Publikationen
   - Suchbegriffe aus Ontologie (funktionelle Medizin, Mikronährstoffe, etc.)
2. Extrahiere Fakten aus neuen Papers:
   - Intervention X verbessert Marker Y (Evidenz-Level, Effect Size)
3. Vergleiche mit bestehendem KG:
   - Neue Verbindung → Füge hinzu (Status: "pending review")
   - Widerspruch → Markiere für manuelle Review
4. Aktualisiere Embeddings für neue Dokumente
5. Versioniere alle Änderungen
↓
Output (wöchentlicher Report):
  - X neue Fakten hinzugefügt
  - Y bestehende Fakten aktualisiert
  - Z Konflikte erkannt (Review benötigt)
```

**Tools:**
- PubMed API (E-utilities)
- Biomedical NLP (Relation Extraction)
- KG-Merge-Engine
- Versionskontrolle (Git-ähnlich für KG)

---

### 4.4 Multi-Agent-Orchestrierung

Die Agenten arbeiten **nicht isoliert**, sondern in einem **Workflow**:

```
                 ┌──────────────────┐
                 │  Arzt-Eingabe    │
                 └────────┬─────────┘
                          │
                 ┌────────▼─────────┐
                 │ Anamnese-Agent   │
                 │ (Strukturierung) │
                 └────────┬─────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼─────┐   ┌──────▼──────┐   ┌────▼─────┐
    │Diagnostik│   │Literatur-   │   │Labor-    │
    │Planer    │   │Recherche    │   │Interpret.│
    └────┬─────┘   └──────┬──────┘   └────┬─────┘
         │                │                │
         └────────────────┼────────────────┘
                          │
                 ┌────────▼─────────┐
                 │ Therapie-Planer  │
                 └────────┬─────────┘
                          │
                 ┌────────▼─────────┐
                 │ QA-Agent         │
                 │ (Validierung)    │
                 └────────┬─────────┘
                          │
                 ┌────────▼─────────┐
                 │ Ärztliche Review │
                 │ + Freigabe       │
                 └──────────────────┘
```

**Kommunikation zwischen Agenten:**
- **Asynchron** (Agent 6 läuft im Hintergrund)
- **Sequential** (Anamnese → Diagnostik → Therapie)
- **Parallel** (Diagnostik-Planer + Literatur-Recherche gleichzeitig)

**Koordination durch:**
- **Orchestrator-Agent** (Meta-Agent, der Workflow steuert)
- **Shared Context** (Patientenprofil als zentraler State)
- **Message Queue** (z.B. RabbitMQ für asynchrone Kommunikation)

---

## 5. Konkrete Anwendung: Funktionellmedizinisches Assistenzsystem

### 5.1 Architektur-Übersicht

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRÄSENTATIONS-SCHICHT                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│  │ Praxis-    │  │ Web-UI     │  │ API        │               │
│  │ Software   │  │ (React)    │  │ (FastAPI)  │               │
│  └────────────┘  └────────────┘  └────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                       ORCHESTRIERUNGS-SCHICHT                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Multi-Agent Orchestrator                       │  │
│  │  (LangChain / LangGraph / CrewAI)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                         AGENTEN-SCHICHT                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────┐│
│  │Anamnese  │ │Diagnostik│ │Labor-    │ │Therapie  │ │QA    ││
│  │Agent     │ │Agent     │ │Agent     │ │Agent     │ │Agent ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────┘│
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                        WISSENS-SCHICHT                           │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │ Ontologie       │  │ Knowledge Graph  │  │ Vektordatenbank│ │
│  │ (OWL/RDF)       │  │ (Neo4j)          │  │ (ChromaDB)     │ │
│  │                 │  │                  │  │                │ │
│  │ - SNOMED CT     │  │ - Symptome       │  │ - Leitlinien   │ │
│  │ - IFM-Ontologie │  │ - Dysfunktionen  │  │ - Papers       │ │
│  │ - HPO           │  │ - Interventionen │  │ - Textbooks    │ │
│  │ - Regeln        │  │ - Evidenz        │  │                │ │
│  └─────────────────┘  └──────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                        DATEN-SCHICHT                             │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │ Patientendaten  │  │ Labor-Daten      │  │ Literatur-     │ │
│  │ (PostgreSQL)    │  │ (HL7/FHIR)       │  │ Quellen        │ │
│  │                 │  │                  │  │ (PubMed API)   │ │
│  └─────────────────┘  └──────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Technologie-Stack

| Komponente | Technologie | Begründung |
|------------|-------------|------------|
| **Ontologie** | OWL 2 (Web Ontology Language) + Protégé | Standard für medizinische Ontologien, logisches Reasoning |
| **Knowledge Graph** | Neo4j (Graph Database) | Native Graph-Storage, Cypher-Query-Language, gute Performance |
| **Vektordatenbank** | ChromaDB / Qdrant | Open-Source, Python-Integration, Metadaten-Filterung |
| **LLM** | Claude 3.5 Sonnet (Anthropic API) | Medizinisches Reasoning, große Context-Window, Tool-Use |
| **Embedding-Modell** | text-embedding-3-large (OpenAI) | Hohe Qualität für medizinische Texte |
| **Agent-Framework** | LangGraph (LangChain) | State-Management, Multi-Agent-Orchestrierung, Tool-Use |
| **Backend-API** | FastAPI (Python) | Async, Type-Safety, OpenAPI-Docs |
| **Datenbank** | PostgreSQL | DSGVO-konform, strukturierte Patientendaten |
| **NLP** | spaCy + scispaCy (biomedizinische Modelle) | NER für medizinische Entitäten |

### 5.3 Konkrete Ontologie-Struktur für das System

**Top-Level-Klassen:**

```
Thing
├── ClinicalEntity
│   ├── Symptom
│   │   ├── ChronischeMüdigkeit
│   │   ├── BrainFog
│   │   ├── Muskelschmerzen
│   │   └── ...
│   ├── Diagnose
│   │   ├── ICD10Code
│   │   └── FunktionelleDiagnose
│   ├── SystemDysfunktion
│   │   ├── EntzündungsSystemik
│   │   ├── MitochondrialeDysfunktion
│   │   ├── HormonAchsenstörung
│   │   │   ├── Hypothyreose
│   │   │   ├── NebennierenDysfunktion
│   │   │   └── ...
│   │   ├── DarmBarriereStörung
│   │   ├── Detoxifikationsstörung
│   │   └── ...
│   └── Laborparameter
│       ├── VitaminD
│       ├── CRP
│       ├── TSH
│       └── ...
├── Intervention
│   ├── Supplement
│   │   ├── VitaminD3
│   │   ├── CoQ10
│   │   ├── Omega3
│   │   └── ...
│   ├── Ernährungsintervention
│   │   ├── GlutenfreieErnährung
│   │   ├── MediterraneDiät
│   │   └── ...
│   ├── LifestyleIntervention
│   │   ├── Stressmanagement
│   │   ├── Schlafhygiene
│   │   └── ...
│   └── Phytotherapie
│       ├── Kurkuma
│       ├── Ashwagandha
│       └── ...
├── Evidenz
│   ├── Studie
│   │   ├── Meta-Analyse
│   │   ├── RCT
│   │   ├── KohortStudie
│   │   └── Fallbericht
│   └── Leitlinie
│       ├── AWMF
│       ├── NICE
│       └── IFM
└── Patient
    ├── Demografie
    ├── Anamnese
    ├── Medikation
    └── Lifestyle
```

**Wichtige Relationen (Object Properties):**

```
indiziert (Symptom → SystemDysfunktion)
detektierbar_via (SystemDysfunktion → Laborparameter)
behandelbar_durch (SystemDysfunktion → Intervention)
kontraindiziert_bei (Intervention → Diagnose/Medikation)
interagiert_mit (Intervention → Intervention/Medikation)
unterstützt_durch (Aussage → Evidenz)
hat_evidenzlevel (Evidenz → EvidenzLevel [Oxford/GRADE])
beeinflusst (Intervention → Laborparameter)
hat_optimal_range (Laborparameter → NumericRange)
```

### 5.4 Beispiel-Workflow: Von Symptom zu Therapieplan

**Eingabe:**
```
Patient: 52 Jahre, weiblich
Symptome: Chronische Müdigkeit (8/10), Brain Fog, Gelenkschmerzen
Dauer: 2 Jahre, progredient
Vorerkrankungen: Hashimoto-Thyreoiditis (seit 5 Jahren)
Medikation: L-Thyroxin 75 µg
Labor (aktuell): TSH 2.8, fT3 2.1 (low), fT4 1.2, Vitamin D 22 ng/mL, Ferritin 18 ng/mL
```

**Agent-Workflow:**

**1. Anamnese-Agent:**
```json
{
  "patient_id": "P12345",
  "demographics": {"age": 52, "gender": "female"},
  "symptoms": [
    {"name": "ChronischeMüdigkeit", "severity": 8, "duration_years": 2},
    {"name": "BrainFog", "severity": "nicht quantifiziert", "duration_years": 2},
    {"name": "Gelenkschmerzen", "severity": "nicht quantifiziert", "duration_years": 2}
  ],
  "diagnoses": [{"name": "Hashimoto-Thyreoiditis", "icd10": "E06.3", "since_years": 5}],
  "medications": [{"name": "L-Thyroxin", "dose": "75 µg", "indication": "Hypothyreose"}],
  "lab_values": [
    {"parameter": "TSH", "value": 2.8, "unit": "mU/L", "reference": "0.4-4.0"},
    {"parameter": "fT3", "value": 2.1, "unit": "pg/mL", "reference": "2.3-4.2", "status": "low"},
    {"parameter": "fT4", "value": 1.2, "unit": "ng/dL", "reference": "0.8-1.8"},
    {"parameter": "VitaminD", "value": 22, "unit": "ng/mL", "reference": ">30", "status": "insufficient"},
    {"parameter": "Ferritin", "value": 18, "unit": "ng/mL", "reference": "15-150", "status": "low"}
  ]
}
```

**2. Diagnostik-Planer-Agent (KG-Query):**

```cypher
// Neo4j Cypher Query
MATCH (s:Symptom {name: "ChronischeMüdigkeit"})-[:INDIZIERT]->(d:SystemDysfunktion)
WHERE d.supported_by_lab = true
RETURN d.name, d.typical_lab_markers

// Ergebnis:
// - MitochondrialeDysfunktion (CoQ10, Laktat/Pyruvat, Carnitin)
// - HypothyreoseSubklinisch (fT3, fT4, rT3, TPO-AK)
// - EisenmangelAnämie (Ferritin, Transferrin, Hb)
// - VitaminDMangel (25-OH-D3)
```

**Diagnostik-Output:**
```
PRIORISIERTE DIAGNOSTIK-EMPFEHLUNGEN

🔴 PRIORITÄT 1 (Basis-Abklärung):
1. Schilddrüse:
   - rT3 (reverses T3) → DD: T4→T3-Konversionsstörung
   - TPO-Antikörper, TG-Antikörper → Hashimoto-Aktivität
   Begründung: TSH im oberen Normbereich + fT3 erniedrigt trotz L-Thyroxin
   Evidenz: PMID:28123456 (Gupta et al. 2022, Thyroid Journal)

2. Eisenstatus:
   - Transferrin, Transferrinsättigung, Hämoglobin
   Begründung: Ferritin 18 ng/mL ist funktionell zu niedrig (optimal >50)
   Evidenz: AWMF-Leitlinie Eisenmangel (2021)

3. Vitamin D:
   - 1,25-OH-Vitamin D (aktive Form) optional
   Begründung: 25-OH-D 22 ng/mL = Insuffizienz, Ziel: >40 ng/mL
   Evidenz: Endocrine Society Clinical Practice Guideline (2024)

🟡 PRIORITÄT 2 (Funktionelle Diagnostik):
4. Mitochondriale Funktion:
   - CoQ10 (Serum)
   - Laktat/Pyruvat-Ratio
   - Carnitin (frei + gesamt)
   Begründung: Müdigkeit + Brain Fog → DD mitochondriale Dysfunktion
   Evidenz: PMID:34567890 (Myhill et al. 2023, functional medicine)

5. Entzündungsmarker:
   - hsCRP (high-sensitivity CRP)
   - IL-6, TNF-α (optional)
   Begründung: Autoimmun-Anamnese + Gelenkschmerzen
   Evidenz: PMID:31234567 (Inflammation in chronic fatigue)

🟢 PRIORITÄT 3 (Erweiterte Differentialdiagnostik):
6. Mikronährstoffe:
   - Zink, Selen, Magnesium (Vollblut)
   - B-Vitamine (B12, Folat, B6)
   Begründung: Cofaktoren für Schilddrüsen- und mitochondriale Funktion
   Evidenz: IFM Functional Medicine Matrix (2025)
```

**3. Labor-Interpretations-Agent (nach Eintreffen der Ergebnisse):**

Angenommen, neue Laborwerte sind:
```
rT3: 28 ng/dL (erhöht, Referenz <24)
CoQ10: 0.4 µg/mL (erniedrigt, optimal >0.7)
Carnitin gesamt: 35 µmol/L (erniedrigt, Referenz 40-60)
hsCRP: 4.2 mg/L (erhöht, Referenz <3)
```

**Interpretation:**
```
PATHOPHYSIOLOGISCHE ANALYSE

🔴 HAUPTBEFUNDE:

1. T4→T3-Konversionsstörung
   - Befund: rT3 erhöht (28 ng/dL), fT3 niedrig (2.1 pg/mL)
   - Mechanismus: Gestörte Dejodase-Aktivität (Typ 2) → T4 wird zu inaktivem rT3 statt zu aktivem T3
   - Ursachen (wahrscheinlich):
     * Chronische Entzündung (hsCRP 4.2)
     * Nährstoffmangel (Zink, Selen)
     * Stress (Cortisol-Dysregulation → nicht getestet)
   - IFM-Matrix-Zuordnung: Defense & Repair, Communication (Hormones)
   - Evidenz: PMID:29876543 (reverse T3 in chronic inflammation)

2. Mitochondriale Dysfunktion
   - Befund: CoQ10 ↓, Carnitin ↓, Müdigkeit
   - Mechanismus: Beeinträchtigte ATP-Produktion
   - Zusammenhang: T3-Mangel verschlechtert mitochondriale Funktion (T3 reguliert mtDNA-Transkription)
   - IFM-Matrix-Zuordnung: Energy (Mitochondria)
   - Evidenz: PMID:32123456 (thyroid-mitochondria axis)

3. Chronische low-grade Inflammation
   - Befund: hsCRP 4.2 mg/L
   - Kontext: Autoimmunthyreopathie + Nährstoffmängel
   - Auswirkung: Verstärkt T4→T3-Konversionsstörung, fördert mitochondriale Dysfunktion
   - IFM-Matrix-Zuordnung: Defense & Repair
   - Evidenz: PMID:30123789 (chronic inflammation in autoimmune disease)

🎯 FUNKTIONELLMEDIZINISCHE EINORDNUNG (IFM-Matrix):
┌─────────────────────────────────────────┐
│  ANTECEDENTS (Prädisposition)           │
│  - Autoimmunität (Hashimoto)            │
│  - Alter 52 (perimenopausale Phase?)    │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  TRIGGERS (Auslöser)                    │
│  - Nährstoffmängel (Fe, Vit D, CoQ10)  │
│  - Chronische Entzündung                │
│  - ? Stress, ? Darm-Permeabilität       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  MEDIATORS (Mechanismen)                │
│  - Gestörte T4→T3-Konversion            │
│  - ATP-Mangel (Mitochondrien)           │
│  - Inflammation (hsCRP, Zytokine)       │
└─────────────────────────────────────────┘
```

**4. Therapie-Planer-Agent:**

```
PERSONALISIERTER THERAPIEPLAN (nach IFM 5R-Framework)

═══════════════════════════════════════════════════════════
1. REMOVE (Trigger entfernen/reduzieren)
═══════════════════════════════════════════════════════════

1.1 Entzündungstrigger identifizieren (empfohlen):
   □ Ernährungstagebuch → glutenhaltiges Getreide probeweise eliminieren (3-4 Wochen)
      Begründung: Gluten kann bei Hashimoto Autoimmunität verstärken
      Evidenz: PMID:25599185 (gluten & Hashimoto, Level 2b)

   □ Stressmanagement evaluieren (Cortisol-Tagesprofil erwägen)
      Begründung: Chronischer Stress → Cortisol-Dysregulation → verstärkt rT3-Bildung
      Evidenz: PMID:28456123 (HPA axis & thyroid)

═══════════════════════════════════════════════════════════
2. REPLACE (Defizite ausgleichen)
═══════════════════════════════════════════════════════════

2.1 Schilddrüsen-Substitution optimieren:
   ⚠️  ÄRZTLICHE ENTSCHEIDUNG ERFORDERLICH:
   □ Option A: L-Thyroxin-Dosis erhöhen (z.B. 100 µg)
   □ Option B: Kombination T4/T3 erwägen (z.B. 75 µg T4 + 5-10 µg T3)
      Begründung: Konversionsstörung → direktes T3 könnte effektiver sein
      Evidenz: PMID:29123456 (combination therapy T4/T3, Level 1b)
      Kontraindikation: Herzrhythmusstörungen, KHK
      → TSH-Kontrolle nach 6-8 Wochen

2.2 Vitamin D:
   💊 Vitamin D3: 4000 IE/Tag (Erhaltungsdosis) für 3 Monate
      Ziel: 25-OH-D >40 ng/mL (optimal 50-70)
      Kontrolle: nach 3 Monaten
      Evidenz: Endocrine Society Guideline (Oxford Level 1a)
      Interaktionen: keine bei dieser Dosis

2.3 Eisen:
   💊 Eisenbisglycinat: 30-40 mg Eisen/Tag (auf nüchternen Magen, mit Vit C)
      Ziel: Ferritin >50 ng/mL (optimal 70-90)
      Kontrolle: nach 8-12 Wochen
      Evidenz: AWMF-Leitlinie Eisenmangel (Level 1a)
      Hinweis: Eisensulfat vermeiden (schlechtere Verträglichkeit)
      ⚠️  Abstand zu L-Thyroxin: mind. 4 Stunden (Interaktion!)

═══════════════════════════════════════════════════════════
3. REINOCULATE (nicht primär relevant hier, eher bei Darm-Problematik)
═══════════════════════════════════════════════════════════

   Aktuell nicht indiziert (keine GI-Symptome beschrieben)
   Falls zukünftig Darm-Diagnostik → Mikrobiom-Aufbau erwägen

═══════════════════════════════════════════════════════════
4. REPAIR (Zelluläre Reparatur & Funktion)
═══════════════════════════════════════════════════════════

4.1 Mitochondriale Unterstützung:
   💊 CoQ10 (Ubiquinol): 200-300 mg/Tag (zu Mahlzeit)
      Ziel: CoQ10-Serumspiegel >0.7 µg/mL
      Kontrolle: nach 3 Monaten
      Evidenz: PMID:30234567 (CoQ10 in fatigue, Oxford Level 2a)
      Interaktionen: Statine (CoQ10 kann Statin-Myopathie reduzieren)

   💊 L-Carnitin: 1000-2000 mg/Tag (aufgeteilt auf 2 Dosen)
      Begründung: Unterstützt mitochondriale Fettsäure-Oxidation
      Evidenz: PMID:31345678 (carnitine in chronic fatigue, Level 2b)
      Kontraindikation: Epilepsie (selten), Schilddrüsenüberfunktion (nicht hier)

   💊 Magnesium (Glycinat oder Malat): 300-400 mg/Tag
      Begründung: Cofaktor für ATP-Synthese, T4→T3-Konversion
      Evidenz: PMID:29876543 (magnesium in thyroid function, Level 2b)

4.2 Antioxidative Unterstützung:
   💊 Selen: 200 µg/Tag (als Selenmethionin)
      Begründung: Cofaktor für Dejodase (T4→T3), antioxidativ bei Hashimoto
      Evidenz: PMID:28234567 (selenium in Hashimoto, Meta-Analyse Level 1a)
      ⚠️  Maximaldauer: 6 Monate (dann Pause oder Reduktion auf 100 µg)

   💊 Zink: 15-30 mg/Tag (als Zinkbisglycinat, mit Mahlzeit)
      Begründung: Cofaktor für T4→T3-Konversion, Immunmodulation
      Evidenz: PMID:30123456 (zinc & thyroid, Level 2b)
      Hinweis: >30 mg/Tag → Kupfer-Verdrängung, daher Kupfer-Monitoring

4.3 Anti-inflammatorische Unterstützung:
   💊 Omega-3 (EPA/DHA): 2000-3000 mg/Tag (hochdosiert, Triglycerid-Form)
      Ziel: Omega-6/Omega-3-Ratio verbessern, hsCRP senken
      Evidenz: PMID:32345678 (omega-3 in chronic inflammation, Level 1a)
      Qualität: IFOS-zertifiziert (Schadstoff-geprüft)

   🌿 Kurkuma-Extrakt (Curcumin): 500-1000 mg/Tag (mit Piperin oder Phospholipid-komplex)
      Begründung: NF-κB-Inhibition, anti-inflammatorisch
      Evidenz: PMID:31234567 (curcumin in autoimmune diseases, Level 2a)
      Kontraindikation: Gallensteine, Blutverdünner (Vorsicht)

═══════════════════════════════════════════════════════════
5. REBALANCE (Lifestyle-Optimierung)
═══════════════════════════════════════════════════════════

5.1 Ernährung:
   🥗 Mediterrane Ernährung + glutenfrei (Probe 4 Wochen)
      Begründung: Anti-inflammatorisch, thyroid-supportive
      Evidenz: PMID:29876543 (Mediterranean diet & autoimmunity, Level 1b)

   🥗 Ausreichend Protein: 1.0-1.2 g/kg KG/Tag
      Begründung: Thyrosin als T3/T4-Vorstufe

   🥗 Komplexe Kohlenhydrate (niedriger GI)
      Begründung: Blutzucker-Stabilität → reduziert Cortisol-Spikes

5.2 Schlaf:
   😴 7-9 Stunden/Nacht, Schlafhygiene optimieren
      Begründung: Schlafmangel → erhöhte Inflammation, verschlechterte T4→T3-Konversion
      Evidenz: PMID:30987654 (sleep & inflammation, Level 2a)

5.3 Bewegung:
   🏃 Moderate Aktivität: 30 Min/Tag, 5x/Woche (z.B. Walking, Yoga)
      ⚠️  KEIN High-Intensity Training initial (verschlimmert Fatigue bei Mitochondrien-Dysfunktion)
      Evidenz: PMID:31123456 (exercise in chronic fatigue, Level 2b)

5.4 Stressmanagement:
   🧘 Meditation, Atemübungen, oder professionelle Begleitung
      Begründung: HPA-Achsen-Regulation
      Evidenz: PMID:29234567 (mindfulness & cortisol, Level 2a)

═══════════════════════════════════════════════════════════
MONITORING & KONTROLLEN
═══════════════════════════════════════════════════════════

📅 Nach 6-8 Wochen:
   - TSH, fT3, fT4, rT3 (Schilddrüsen-Adjustierung evaluieren)
   - Ferritin (Eisen-Repletion prüfen)

📅 Nach 12 Wochen:
   - Vitamin D (25-OH-D)
   - CoQ10, Carnitin (optional, falls Symptome persistieren)
   - hsCRP (Entzündungsverlauf)

📅 Nach 6 Monaten:
   - Komplettes Panel wiederholen
   - Symptom-Scores (z.B. Fatigue Severity Scale)
   - Therapie-Adjustierung basierend auf Response

═══════════════════════════════════════════════════════════
ERWARTETES OUTCOME
═══════════════════════════════════════════════════════════

✅ Verbesserung nach 4-6 Wochen:
   - Energie-Level steigt (durch verbesserte T3-Versorgung, Mikronährstoffe)
   - Brain Fog reduziert sich (bessere mitochondriale Funktion)

✅ Verbesserung nach 12 Wochen:
   - Gelenkschmerzen reduziert (anti-inflammatorische Interventionen)
   - Labor-Normalisierung (fT3 ansteigend, rT3 sinkend, hsCRP <3)

⚠️ Falls KEINE Verbesserung nach 12 Wochen:
   → Erweiterte Diagnostik:
      - Cortisol-Tagesprofil (HPA-Achsen-Dysfunktion)
      - Darm-Diagnostik (Zonulin, α1-Antitrypsin, Calprotectin)
      - Autoantikörper erweitern (ANA, ENA)
      - Schwermetall-Belastung (optional, bei V.a. Detox-Störung)
```

**5. QA-Agent-Validierung:**

```
QUALITÄTSPRÜFUNG THERAPIEPLAN

✅ VALIDIERUNG ERFOLGREICH:

1. Quellenangaben: Alle Empfehlungen haben PubMed-Referenzen ✓
2. Evidenz-Level: Dokumentiert (Oxford-Klassifikation) ✓
3. Interaktionen geprüft:
   - Eisen ↔ L-Thyroxin: Abstand 4h empfohlen ✓
   - CoQ10 ↔ Statine: keine Kontraindikation (sogar synergistisch) ✓
   - Kurkuma ↔ Blutverdünner: Warnung platziert ✓
4. Kontraindikationen geprüft:
   - T3-Supplementation: Warnung bei Herzproblemen platziert ✓
   - Selen: Maximaldauer dokumentiert ✓
5. Dosierungen: Innerhalb therapeutischer Bereiche ✓
6. Monitoring: Kontroll-Zeitpunkte definiert ✓

⚠️ HINWEISE FÜR ÄRZTLICHE REVIEW:

1. T4/T3-Kombination erfordert ärztliche Entscheidung (regulatorisch)
2. Patient-Compliance: 12+ Supplements → Priorisierung mit Patient besprechen
   Vorschlag: Essentials zuerst (Vit D, Eisen, Selen, CoQ10), Rest später
3. Kosten-Aspekt: Supplements ca. 80-120€/Monat → mit Patient kommunizieren

🟢 FREIGABE-EMPFEHLUNG: GRÜN
   → Plan ist sicher, evidenzbasiert und kann ärztlich reviewed werden
```

---

## 6. Zusammenfassung: Warum diese Architektur für funktionelle Medizin ideal ist

### 6.1 Vorteile des Hybrid-Ansatzes (Ontologie + KG + LLM)

1. **Strukturiertes medizinisches Wissen**
   → Ontologie definiert funktionellmedizinische Konzepte (IFM-Matrix, 5R-Framework)
   → KG speichert konkrete Evidenz mit Metadaten (Evidenz-Level, Quellen)

2. **Nachvollziehbarkeit & Transparenz**
   → Jede Empfehlung hat einen Reasoning-Path durch den KG
   → Ärzte können nachvollziehen: "Warum schlägt das System CoQ10 vor?"

3. **Evidenz-basierte Entscheidungen**
   → Automatische Gewichtung nach Oxford/GRADE-Level
   → Nur validierte, peer-reviewed Informationen

4. **Personalisierung**
   → Patientenprofil als Entität im KG
   → Kontraindikationen, Interaktionen werden automatisch geprüft

5. **Kontinuierliche Aktualisierung**
   → Literatur-Update-Agent hält KG aktuell
   → Neue Evidenz wird integriert, alte wird versioniert

6. **Multi-Agenten-Spezialisierung**
   → Jeder Agent hat Expertise in einer Domäne
   → Komplexe Workflows werden orchestriert

### 6.2 Herausforderungen & Lösungsansätze

| Herausforderung | Lösungsansatz |
|----------------|---------------|
| **Ontologie-Entwicklung ist aufwändig** | Schrittweise: Start mit IFM-Matrix, erweitern über Zeit; Nutzung bestehender Standards (SNOMED, HPO) |
| **KG-Aufbau erfordert viel manuelle Arbeit** | Automatisierte Extraktion aus Papers (NLP); Crowd-Sourcing via Ärzte-Feedback |
| **LLM-Halluzinationen** | Validierung durch KG-Facts; Confidence-Scores; QA-Agent als Safeguard |
| **Komplexität für Nutzer** | UI abstrahiert Komplexität; Ärzte sehen nur Outputs, nicht interne Mechanik |
| **DSGVO-Compliance** | On-Premise-Deployment; Anonymisierung; Patient-Daten getrennt von KG |
| **Kosten (API-Calls)** | Hybrid-Modelle (lokale Embeddings, Cloud-LLM nur für Reasoning); Caching |

### 6.3 Nächste Schritte für die Implementierung

**Phase 1: Prototyp (MVP)**
1. Definiere minimale Ontologie (10-15 Klassen, 20-30 Relationen)
2. Erstelle Mini-KG mit 100-200 Fakten (z.B. Vitamin D, Schilddrüse, Mitochondrien)
3. Implementiere 2-3 Agenten (Anamnese, Diagnostik, Therapie)
4. Teste mit 5-10 realen Fällen
5. Sammle Feedback von Hausarzt

**Phase 2: Expansion**
1. Erweitere Ontologie (IFM-Matrix vollständig abbilden)
2. Automatisiere KG-Aufbau (Paper-Extraktion)
3. Integriere weitere Agenten (Labor-Interpretation, QA)
4. HL7/FHIR-Schnittstelle zur Praxissoftware

**Phase 3: Produktion**
1. Multi-Tenancy (mehrere Ärzte/Praxen)
2. Feedback-Loop (Therapieerfolge tracken → KG verbessern)
3. Audit-Trail (alle Entscheidungen protokollieren)
4. Zertifizierung (Medizinprodukt-Klasse evaluieren)

---

## 7. Literaturempfehlungen für Vertiefung

**Ontologien & Knowledge Graphs:**
- "Knowledge Graphs" (Hogan et al., 2021) - Comprehensive overview
- "Semantic Web for the Working Ontologist" (Allemang & Hendler, 2011)
- SNOMED CT User Guide (IHTSDO)

**RAG & LLM-Systeme:**
- "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks" (Lewis et al., 2020, Meta AI)
- LangChain Documentation (Multi-Agent Systems)

**Medizinische KI:**
- "Artificial Intelligence in Medicine" (Ramesh et al., 2024)
- IFM Toolkit: Functional Medicine Matrix & Timeline

**Funktionelle Medizin:**
- "Textbook of Functional Medicine" (IFM, 2020)
- "The Functional Medicine Approach to COVID-19" (Pizzorno, 2024)

---

**Dieses Dokument wird fortlaufend erweitert, wenn neue Erkenntnisse oder Technologien relevant werden.**

---

**Version:** 1.0
**Letzte Aktualisierung:** 2026-01-17
**Autor:** Claude Code (mit Input von dchrm)
**Review:** Offen (ärztliche Validierung ausstehend)
