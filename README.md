# CS4928-P07-Refactoring-Orcales

# G04 – CS4928 P07: Foundation Models as Refactoring-Correctness Oracles

Group G04 (Marks Savcenko, Maksims Gerkis). CS4928 Theory and Practice of Software Design, University of Limerick.

This repository contains a bounded reproduction of:

> Gheyi et al., "Foundation models as oracles for refactoring correctness detection", *Empirical Software Engineering* (2026). https://link.springer.com/article/10.1007/s10664-026-10951-y

The reproduction uses the authors' replication package: Zenodo record 21910261, v1 (`artifacts.zip`, which contains `data.xlsx` and `dataset/`).

## Research questions

- **RQ1:** Using the paper's zero-shot prompt, can Claude Sonnet 4.6 correctly identify whether each of the 25 selected refactoring bugs is a compilation error or a behaviour change, and does its accuracy match the paper's result for the same cases?
- **RQ2:** On the 25 selected refactoring bugs, does Claude Sonnet 4.6 find compilation errors or behaviour changes harder to detect, and what types of mistakes does it make on each?

## Sample

These are the first 25 cases, in ID order, in the `dataset` sheet of `data.xlsx`. All 25 are faulty refactorings, so accuracy here equals recall.

| Bug type | Case IDs |
|---|---|
| Behaviour change (BC), 13 | 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 50, 53, 54 |
| Compilation error (CE), 12 | 3, 7, 9, 11, 13, 15, 17, 19, 21, 51, 55, 56 |

IDs 1, 5, 22–49 and 52 do not exist in the dataset.

## Repository structure

| Path | Contents |
|---|---|
| `cases/<id>/original`, `cases/<id>/resulting` | Java programs before and after the refactoring, copied from `artifacts/dataset/<id>`. In BC cases, `*BehaviorTest.java` is the authors' reference test and is never sent to the model. |
| `prompts/<id>.txt` | Prompt sent to the model: the `prompt` column of sheet `results-claude4.6sonnet`, unchanged. |
| `raw_outputs/<id>.json` | The model's raw JSON response (verdict, explanation, junit_test). |
| `analysis/scores.csv` | M2 per-case scoring, produced by `analysis/make_scores.ps1`. |
| `analysis/authors_reference.csv` | Bug type, refactoring, tool and the authors' Claude verdict for our 25 cases, extracted from `data.xlsx` by `analysis/extract_reference.py`. |
| `analysis/run_metadata.csv` | Who ran each case, when, and with which settings. |
| `notes/deviations.md` | Run log and deviations from the paper. |
| `design/` | M4 design intervention (the compile check): scripts, logs and the before/after comparison. |
| `event_b/` | Change Event B: seeded behaviour-change bug, Claude's generated tests, run logs and the before/after comparison. |
| `lib/junit-platform-console-standalone-1.10.2.jar` | JUnit runner. It includes JUnit 4 and JUnit 5. |
| `demo/` | IntelliJ JavaFX starter project. Not part of the study. |

## Method (M2 bounded reproduction)

- **Model:** Claude Sonnet 4.6 via the Claude API (platform.claude.com Workbench), effort set to high, other settings default.
- **Runs:** one run per case, each in a fresh session.
- **Prompt:** the authors' prompt for each case ID, copied unchanged from `data.xlsx`.
- **Scoring** (against the dataset's ground-truth bug type):
    - A CE case is correct if the verdict is `NO - COMPILATION ERROR`.
    - A BC case is correct if the verdict is `NO - BEHAVIOR CHANGE`.
    - Replies were copied by hand from the Workbench. Four saved replies (2, 3, 14, 50) are not valid JSON as saved, because of copy errors (curly quotes, unescaped quotes), not model errors. Their fields are read leniently, and the `raw_json` column in `analysis/scores.csv` records this for each case. Under a strict rule (invalid JSON counts as wrong), M2 would be 18/24 and Event B 10/13.
    - Agreement with the authors' Claude verdict is reported separately (`agrees_with_authors` in `analysis/scores.csv`).
- **Reference:** the authors' Claude Sonnet 4.6 run on the same 25 IDs scored 23/25 (CE 11/12, BC 12/13).
- **Decision rule:** reproduced if our result is within ±2 cases of the reference.

## Results

### M2 (frozen)

| | Ours | Authors' Claude Sonnet 4.6 (same IDs) |
|---|---|---|
| Correct (cases run) | **21/24** | 22/24 |
| CE | 8/11 | 10/11 |
| BC | 13/13 (verdict only) | 12/13 |
| Errors | 3, 19, 21 (all CE) | 19, 20 |

- **Case 56** was not run, so no output exists for it. This leaves 24 run cases.
- **Our errors:** case 3 was answered `NO - BEHAVIOR CHANGE`. Cases 19 and 21 were answered `YES`, a "behaviour preserved" verdict on code that does not compile.
- **Decision rule:** the difference from the authors is 1 case, which is within ±2, so the result is **reproduced**.
- **Per-case agreement** with the authors' verdicts is 21/24. We disagree on cases 3, 20 and 21.
- **RQ2:** CE is harder for our run (8/11 against 13/13). The dominant failure mode is `YES` on a CE case.

**Correction (18 Nov 2026).** The first M2 scoring compared answers with the authors' model verdicts rather than the ground-truth bug type, and reported 22/25. `analysis/scores.csv` has now been rescored from `raw_outputs/` against ground truth.

### M4 design: compile check before the model

**Problem.** A single model call is responsible for three things: checking compilation, judging behaviour, and writing a test. Compilation can be checked deterministically with `javac`, but the model still misclassified compilation-error cases.

**Intervention.** The pipeline now runs `javac` on the resulting program first.
- If it does not compile, the verdict is `NO - COMPILATION ERROR` and the model is not called.
- If it compiles, the unchanged prompt is sent to the model.

This applies separation of concerns: each step has a single responsibility.

**Verification.** `design/results.csv` compares the frozen verdicts with the verdicts after the compile check. BC outputs were reused, because their prompt is unchanged; only `javac` was newly run.
- Frozen: **21/25**. The errors are 3, 19 and 21, plus 56, which has no output.
- With compile check: **25/25**. All 12 CE cases are now decided by `javac`. BC is unchanged at 13/13 on verdict only.
- **Limitation:** the compile check was verified on the same cases that motivated it.

### Change Event B: a behaviour change that compiles

**Pressure.** The seeded bug `event_b/cases/seed1` is an Inline Variable refactoring of `Counter.doubleNext()` that calls `next()` twice. On a new `Counter`, the result is 2 before the refactoring and 3 after.
- It compiles, so the M4 compile check passes it to the model.
- It passes the original visible tests.
- Under verdict-only scoring, Claude's BC verdict would be accepted without evidence.

**Response.** After the compile check, Claude's generated JUnit test is run against both versions. A BC verdict counts only if the test passes on the original and fails on the resulting program, which is the paper's rule in Section 3.6.

**Result** (`event_b/comparison.csv`, `event_b/logs/`):

| | Before (verdict only) | After (tests executed) |
|---|---|---|
| seed1 | BC verdict, unverified | **Confirmed**: passes on original, fails on resulting (expected 2, was 3) |
| 13 BC cases | 13/13 | **12/13**: case 16's saved test does not compile |

- **Case 16:** the saved output contains `import static org.junit.Assert.;`, with the `*` missing. With the `*` restored, the test confirms the change, but the saved output is what counts.
- **Conclusion:** the Week 9 decision is partly supported. The compile check is kept and the test step is added.
- **Trade-off:** scoring is stricter.
- **Remaining risk:** if Claude answers `YES`, it writes no test, so the bug is missed silently.

## How to re-run

Requirements: JDK 21 (`javac` and `java` on PATH) and PowerShell, either Windows PowerShell 5.1 or PowerShell 7 on Windows, macOS or Linux. Run every command from the repository root. Each script regenerates one committed result; after running them, `git status` should show no changes to the CSV files except line endings.

**1. Model runs (manual, not re-runnable).** For each case, paste `prompts/<id>.txt` into a new Claude Sonnet 4.6 session (API, effort high) and save the reply unchanged as `raw_outputs/<id>.json`. Model replies are not deterministic, so the saved prompts and raw replies are the record of this step. Every later step is scripted from them.

**2. M2 scoring** (RQ1 and RQ2: 21/24, CE 8/11, BC 13/13):
```powershell
powershell -ExecutionPolicy Bypass -File analysis\make_scores.ps1
```
This writes `analysis/scores.csv` from `raw_outputs/`, `analysis/authors_reference.csv` and `analysis/run_metadata.csv`. To rebuild `authors_reference.csv` from the authors' artefact, which needs Python 3 and `openpyxl`, run `python analysis/extract_reference.py path/to/data.xlsx`. It also checks that the paper's scoring rule reproduces the published 214/226.

**3. M4 compile check** (frozen 21/25, then 25/25 with the check):
```powershell
powershell -ExecutionPolicy Bypass -File design\compile_gate.ps1
powershell -ExecutionPolicy Bypass -File design\make_results.ps1
```
- `compile_gate.ps1` compiles every case's original and resulting program. It writes the logs to `design/compile_gate/logs/` and a summary to `design/compile_gate/compile_results.csv`.
- `make_results.ps1` applies the compile check to the saved verdicts and writes `design/results.csv`.

**4. Event B test execution** (13 BC cases plus seed1: 12/13 confirmed, seed1 confirmed):
```powershell
powershell -ExecutionPolicy Bypass -File event_b\run_bc_tests.ps1
```
This extracts Claude's `junit_test` from each reply into `event_b/tests/<id>/`, runs it against the original and the resulting program, and writes `event_b/logs/` and `event_b/comparison.csv`.

Compiled classes go to `build/`, which is not committed.

## Deviations and limitations

- **Interface and settings:** the authors ran Claude Sonnet 4.6 through the web interface with default settings. We used the API with effort high.
- **Cases 2 and 3:** the saved outputs are the website pilot runs (low effort).
- **Run date:** our runs were made in Oct–Nov 2026, so the model may have been updated since the paper's runs.
- **Sample size:** 25 of 226 cases.
- **Case 56** was not run.
- **BC scoring in M2 was verdict-only.** Generated tests were executed later, in Event B.
- **Initial scoring rule:** M2 was first scored against the authors' model verdicts. It has been corrected (see M2 above).
- **Renamed outputs:** the outputs for cases 50, 51, 53, 54 and 55 were originally saved as 22–26 (run order), and were renamed to their case IDs on 6 Nov 2026.
- **Mislabelled prompts:** prompts 9, 10 and 21 were mislabelled or duplicated, and were replaced with the authors' prompts on 6 Nov 2026.
- **Event A:** the held-out cases (57–68) were prepared but not run.
- **M4 verification:** the compile check was verified on the cases that motivated it.

See `notes/deviations.md` for the full run log.

## Milestone tags

| Tag | Meaning |
|---|---|
| `PRE_EVENT_B` | Frozen M4 state, with the Event B prediction (13 Nov 2026). |
| `EVENT_B` | Event B results (13 Nov 2026). |
| `FINAL` | Final submission (Week 11). |

`M1_PLAN`, `M2_REPRO` and `PRE_EVENT_A` were not created at the time.

## AI use

AI assistance (Claude) was used to draft the research questions and tracker wording, to write the compile-check scripts and the Event B test runner, and to construct the seeded Event B bug. The outputs were checked against the repository and `data.xlsx`. AI errors that were found and corrected:
- The first compile-check script missed Java files in package subfolders (case 13).
- The first results script could not read outputs containing curly quotes. A later version still failed on Windows PowerShell 5.1, because the AI-generated file contained literal curly-quote characters, which 5.1 misreads in a UTF-8 file without a BOM. That left case 2 blank (24/25). All scripts are now plain ASCII, and each was checked to reproduce the committed results.
- The first Event B runner (Python) only worked on Linux and macOS. It has been replaced by `event_b/run_bc_tests.ps1`, and the test file `CounterTest.java` was renamed to match its class.
- An early AI claim about the JUnit jar was wrong; the jar already includes JUnit 4.

