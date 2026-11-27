# Event B: seeded behaviour-change bug

## The seeded case (`cases/seed1`)

| | |
|---|---|
| Refactoring | Inline Variable (Fowler: Inline Temp) on `Counter.doubleNext()` |
| Ground truth | Behaviour change (BC): expected verdict `NO - BEHAVIOR CHANGE` |
| Seeded fault | The temp `n` holds the result of `next()`, which has a side effect (`count++`). Inlining it as `next() + next()` calls `next()` twice. |

Effect of the fault: on a new `Counter`, `doubleNext()` returns **2** on the original and **3** on the resulting program. `count` ends at 1 on the original and 2 on the resulting program.

## Why it meets the Event B requirements

- **Compiles:** both versions compile with javac (JDK 21), so the Week 9 compile check passes it straight to the model.
- **Passes the original visible tests:** `visible_tests/CounterVisibleTest.java` passes on both versions. It only checks `next()`/`getCount()` and that `doubleNext()` is positive.
- **Subtle:** the change is one line, and both versions return a positive number. Inlining a temp is normally a safe refactoring, and it breaks here only because `next()` has a side effect.
- **Detectable:** `reference_test/CounterReferenceTest.java` passes on the original and fails on the resulting program (`expected:<2> but was:<3>`).

The reference test is our ground truth. **Never send it to the model.**

## Files

| Path | Contents |
|---|---|
| `cases/seed1/original/Counter.java` | Program before the refactoring |
| `cases/seed1/resulting/Counter.java` | Program after the refactoring, with the seeded bug |
| `visible_tests/CounterVisibleTest.java` | "Original visible tests": pass on both versions |
| `reference_test/CounterReferenceTest.java` | Ground-truth detecting test (not given to the model) |
| `prompts/seed1.txt` | The authors' prompt template (from data.xlsx, case 2) with the seeded code inserted |
| `raw_outputs/`, `tests/`, `logs/` | Empty folders for the model's output, its generated test, and the run logs |

## How to use it

1. **Pre-Event-B pipeline (frozen Week 9):**
   - Run the compile check. Expect the program to compile.
   - Send `prompts/seed1.txt` to Claude Sonnet 4.6 with the M2 settings, and save the response as `raw_outputs/seed1.json`.
   - The verdict is accepted as given, because verdict-only scoring does not check it.
2. **Post-response pipeline (Event B response):**
   - Run the same steps.
   - Also run Claude's `junit_test` against the original and the resulting program.
   - Accept `NO - BEHAVIOR CHANGE` only if the test passes on the original and fails on the resulting program.
3. **Record:**
   - Claude's verdict, and whether its test compiled.
   - Whether the test passes on the original and fails on the resulting program.
   - Whether each pipeline caught the bug.

## Verification run when built (13 Nov 2026, JDK 21, JUnit 4 via the console-standalone jar)

| Test | Original | Resulting |
|---|---|---|
| CounterVisibleTest (2 tests) | PASS | PASS |
| CounterReferenceTest (1 test) | PASS | FAIL (expected 2, was 3) |

## Results (13 Nov 2026)

### seed1
- **Claude's verdict:** `NO - BEHAVIOR CHANGE` (`raw_outputs/seed1.json`).
- **Claude's test:** `tests/seed1/CounterTest.java` (renamed from `Countertest.java` so the file name matches the class). It passes on the original (`OK (1 test)`) and fails on the resulting program (`expected:<2> but was:<3>`), so the case is **confirmed**.
- **Logs:** `logs/seed1_original.txt` and `logs/seed1_resulting.txt`, run locally in PowerShell.

### The 13 BC cases from M2
Each case's saved `junit_test` (from `raw_outputs/<id>.json`) is in `tests/<id>/`, and was run against `cases/<id>/original` and `cases/<id>/resulting`. Logs are in `logs/<id>_<version>.txt`, and the summary is in `comparison.csv`.

| Outcome | Cases |
|---|---|
| Confirmed: passes on original, fails on resulting | 2, 4, 6, 8, 10, 12, 14, 18, 20, 50, 53, 54 (12) |
| Test does not compile | 16 |

Case 16's saved output contains `import static org.junit.Assert.;`, with the `*` missing. With the `*` restored, the test confirms the change, but the saved output is what counts.

**Before and after:** BC was 13/13 verdict-only; with tests executed it is 12/13. seed1 goes from accepted-unverified to confirmed.

### How the results are produced
Run this from the repository root:
```powershell
powershell -ExecutionPolicy Bypass -File event_b\run_bc_tests.ps1
```
For each of the 13 BC cases and seed1, the script:
1. reads Claude's reply (`raw_outputs/<id>.json`, or `raw_outputs/seed1.json` here);
2. writes the `junit_test` to `tests/<id>/`;
3. compiles and runs it against `original` and `resulting`;
4. writes `logs/<id>_<version>.txt` and `comparison.csv`.

It works in Windows PowerShell 5.1 and PowerShell 7, and needs JDK 21.

Replies 2, 14 and 50 are not strictly valid JSON as saved, because of copy errors. The `raw_json` column in `comparison.csv` records how each reply was read. Under a strict rule (invalid JSON counts as wrong), cases 14 and 50 would have no usable test, giving 10/13.

These results were first produced by an AI-written Python script on Linux. That script was replaced by `run_bc_tests.ps1`, which reproduces every outcome and every extracted test.
