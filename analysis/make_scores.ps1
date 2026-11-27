# M2 scoring: regenerates analysis\scores.csv from the saved model outputs.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File analysis\make_scores.ps1
# Inputs:  raw_outputs\<id>.json             (Claude's saved replies)
#          analysis\authors_reference.csv     (bug type, refactoring, tool and the authors' Claude verdict,
#                                              extracted from data.xlsx by analysis\extract_reference.py)
#          analysis\run_metadata.csv          (who ran each case, when, with which settings)
# Ground truth is the dataset's bug type (CE/BC). Verdicts are read leniently (see raw_json column):
# four saved replies (2, 3, 14, 50) are not valid JSON because of copy errors, not model errors. BC is scored on the verdict only here;
# the generated tests are executed in event_b\run_bc_tests.ps1.

function Get-JsonState($path) {
  # Replies were copied by hand; record whether each saved file is valid JSON as saved.
  $t = Get-Content $path -Raw -Encoding UTF8
  try { $null = $t | ConvertFrom-Json -ErrorAction Stop; return 'valid' } catch {}
  $f = $t.Replace([string][char]0x201C, '"').Replace([string][char]0x201D, '"')
  try { $null = $f | ConvertFrom-Json -ErrorAction Stop; return 'repaired (curly quotes)' } catch {}
  return 'lenient (fields read directly)'
}

function Get-Verdict($path) {
  if (-not (Test-Path $path)) { return $null }
  $t = Get-Content $path -Raw -Encoding UTF8
  # accept straight or curly quotes (outputs 2 and 3 were copied with curly quotes)
  $q = '["\u201C\u201D]'
  if ($t -match ($q + 'verdict' + $q + '\s*:\s*' + $q + '([^"\u201C\u201D]+)')) { return $matches[1].Trim() }
  return 'UNREADABLE'
}

$ref  = Import-Csv analysis\authors_reference.csv
$meta = @{}; Import-Csv analysis\run_metadata.csv | ForEach-Object { $meta[$_.id] = $_ }

$rows = foreach ($r in $ref) {
  if ($r.bug_type -eq 'CE') { $expected = 'NO - COMPILATION ERROR' } else { $expected = 'NO - BEHAVIOR CHANGE' }
  $v = Get-Verdict "raw_outputs\$($r.id).json"
  $js = ''
  if ($null -eq $v) { $correct = 'not run'; $agree = ''; $v = '' }
  else {
    if ($v -eq $expected) { $correct = 'yes' } else { $correct = 'no' }
    if ($v -eq $r.authors_verdict) { $agree = 'yes' } else { $agree = 'no' }
    $js = Get-JsonState "raw_outputs\$($r.id).json"
  }
  $m = $meta[$r.id]
  [pscustomobject]@{
    id = $r.id; bug_type = $r.bug_type; refactoring = $r.refactoring; tool = $r.tool
    raw_json = $js; expected_verdict = $expected; model_verdict = $v; correct = $correct
    authors_verdict = $r.authors_verdict; authors_correct = $r.authors_correct; agrees_with_authors = $agree
    model_version = $m.model_version; run_date = $m.run_date; run_by = $m.run_by; note = $m.note
  }
}
$rows | Export-Csv analysis\scores.csv -NoTypeInformation -Encoding UTF8

$run = @($rows | Where-Object { $_.correct -ne 'not run' })
function Count($set, $col) { @($set | Where-Object { $_.$col -eq 'yes' }).Count }
"Ours:    " + (Count $run 'correct') + " / " + $run.Count + " run   (" + ($rows.Count - $run.Count) + " not run)"
"  CE:    " + (Count ($run | Where-Object { $_.bug_type -eq 'CE' }) 'correct') + " / " + @($run | Where-Object { $_.bug_type -eq 'CE' }).Count
"  BC:    " + (Count ($run | Where-Object { $_.bug_type -eq 'BC' }) 'correct') + " / " + @($run | Where-Object { $_.bug_type -eq 'BC' }).Count
"Authors: " + (Count $run 'authors_correct') + " / " + $run.Count + " on the same cases"
"Agree:   " + (Count $run 'agrees_with_authors') + " / " + $run.Count
"Strict:  " + @($run | Where-Object { $_.correct -eq 'yes' -and $_.raw_json -eq 'valid' }).Count + " / " + $run.Count + " if replies that are not valid JSON as saved counted as wrong"
"Errors:  " + ((@($run | Where-Object { $_.correct -eq 'no' }) | ForEach-Object { $_.id }) -join ', ')
