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
| `analysis/scores.csv` | M2 per-case scoring. |
| `notes/deviations.md` | Run log and deviations from the paper. |
| `design/` | M4 design intervention (the compile check): scripts, logs and the before/after comparison. |
| `lib/junit-platform-console-standalone-1.10.2.jar` | JUnit runner. It includes JUnit 4 and JUnit 5. |
| `demo/` | IntelliJ JavaFX starter project. Not part of the study. |

## Method (M2 bounded reproduction)

- **Model:** Claude Sonnet 4.6 via the Claude API (platform.claude.com Workbench), effort set to high, other settings default.
- **Runs:** one run per case, each in a fresh session.
- **Prompt:** the authors' prompt for each case ID, copied unchanged from `data.xlsx`.
- **Scoring:**
    - A CE case is correct if the verdict is `NO - COMPILATION ERROR`.
    - A BC case is correct if the verdict is `NO - BEHAVIOR CHANGE`.
    - Invalid JSON counts as incorrect.
- **Reference:** the authors' Claude Sonnet 4.6 run on the same 25 IDs scored 23/25 (CE 11/12, BC 12/13).
- **Decision rule:** reproduced if our result is within ±2 cases of the reference.

## Results

### M2 (frozen)

[Fill in: final M2 result, CE x/y, BC x/y, the cases missed, and whether the result was reproduced under the ±2 rule. See `analysis/scores.csv`.]

### M4 design: compile check before the model

**Problem.** A single model call is responsible for three things: checking compilation, judging behaviour, and writing a test. Compilation can be checked deterministically with `javac`, but the model still misclassified compilation-error cases.

**Intervention.** The pipeline now runs `javac` on the resulting program first.
- If it does not compile, the verdict is `NO - COMPILATION ERROR` and the model is not called.
- If it compiles, the unchanged prompt is sent to the model.

This applies separation of concerns: each step has a single responsibility.

**Verification.** `design/results.csv` compares the frozen verdicts with the verdicts after the compile check. BC outputs were reused, because their prompt is unchanged; only `javac` was newly run.
- Frozen: [x]/25
- With compile check: [x]/25

## How to re-run

Requirements: JDK 21 and Windows PowerShell. Run these commands from the repository root.

**1. Model runs.** For each case, paste `prompts/<id>.txt` into a new Claude Sonnet 4.6 session (API, effort high). Save the response unchanged as `raw_outputs/<id>.json`.

**2. Compile check and comparison:**
```powershell
powershell -ExecutionPolicy Bypass -File design\compile_gate.ps1
powershell -ExecutionPolicy Bypass -File design\make_results.ps1
```
- `compile_gate.ps1` compiles every case's original and resulting program. It writes the logs to `design/compile_gate/logs/` and a summary to `design/compile_gate/compile_results.csv`.
- `make_results.ps1` applies the compile check to the saved verdicts. It writes `design/results.csv` and prints the totals.

## Deviations and limitations

- **Interface:** the authors ran Claude Sonnet 4.6 through the web interface with default settings. We used the API with effort set to high. Cases 2 and 3 were first run on the website as a pilot, and that pilot run is not counted.
- **Run date:** our runs were made in October–November 2026, after the paper's runs, so the model may have been updated in between.
- **Sample size:** 25 of the 226 cases.
- **BC scoring:** BC cases are scored on the verdict only. The model's generated JUnit tests were not executed, although the paper's correctness rule requires this.
- **Case 56:** not run with the model. The compile check decides it without the model.
- **Case 21:** the saved prompt contains the authors' prompt twice.
- **Renamed outputs:** the outputs for cases 50, 51, 53, 54 and 55 were originally saved as 22–26 (run order) and were renamed to their case IDs on 6 Nov 2026.
- **Design verification:** the compile check was tested on the same cases that motivated it.

See `notes/deviations.md` for the full run log.

