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
