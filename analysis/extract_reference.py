"""One-off extraction of the authors' reference data for our 25 cases.

Reads the authors' data.xlsx (Zenodo record 21910261, v1) and writes
analysis/authors_reference.csv, which make_scores.ps1 uses.

Usage (repo root):  python analysis/extract_reference.py path/to/data.xlsx
Requires Python 3 and openpyxl (pip install openpyxl).
"""
import csv, sys, openpyxl

SAMPLE = [2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 50, 51, 53, 54, 55, 56]

wb = openpyxl.load_workbook(sys.argv[1], read_only=True)
rows = list(wb["results-claude4.6sonnet"].iter_rows(values_only=True))
col = {name: i for i, name in enumerate(rows[0])}
by_id = {int(r[0]): r for r in rows[1:] if r[0] is not None}

def authors_correct(r):
    # Paper Section 3.6: CE correct if verdict is NO - COMPILATION ERROR; BC correct if verdict is
    # NO - BEHAVIOR CHANGE and the generated test compiles on both versions and passes on exactly one.
    verdict = (r[col["verdict-claude"]] or "").strip()
    if r[col["Type"]] == "Compilation Error":
        return verdict == "NO - COMPILATION ERROR"
    return (verdict == "NO - BEHAVIOR CHANGE" and r[col["original-status"]] == "YES"
            and r[col["resulting-status"]] == "YES"
            and r[col["run-test-case-original"]] != r[col["run-test-case-resulting"]])

# Sanity check: the rule must reproduce the paper's published 214/226.
total = sum(authors_correct(r) for r in by_id.values())
print(f"authors' Claude Sonnet 4.6 on all cases: {total}/{len(by_id)} (paper reports 214/226)")

with open("analysis/authors_reference.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["id", "bug_type", "refactoring", "tool", "authors_verdict", "authors_correct"])
    for i in SAMPLE:
        r = by_id[i]
        w.writerow([i, "CE" if r[col["Type"]] == "Compilation Error" else "BC", r[col["Refactoring"]],
                    r[col["Tool"]], (r[col["verdict-claude"]] or "").strip(), "yes" if authors_correct(r) else "no"])
print("wrote analysis/authors_reference.csv")
