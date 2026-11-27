# Applies the compile check to the frozen Claude verdicts and compares the two (M4 verification).
# Run after compile_gate.ps1, from the repo root:  powershell -ExecutionPolicy Bypass -File design\make_results.ps1
# Output: design\results.csv
# Note: BC cases are scored on the verdict only here (generated JUnit tests are executed in event_b\run_bc_tests.ps1).
# This file is plain ASCII on purpose: curly quotes are written as \u201C / \u201D so that
# Windows PowerShell 5.1 (which reads UTF-8 files without a BOM as ANSI) matches them correctly.

$cr = Import-Csv (Join-Path 'design' (Join-Path 'compile_gate' 'compile_results.csv')) | Where-Object { $_.version -eq 'resulting' }

$out = foreach ($r in $cr) {
  $id = $r.case
  $compiles = ($r.compiles -eq 'True')
  if ($compiles) { $type = 'BC'; $expected = 'NO - BEHAVIOR CHANGE' } else { $type = 'CE'; $expected = 'NO - COMPILATION ERROR' }

  $f = $null
  if (Test-Path (Join-Path 'raw_outputs' "$id.json")) { $f = Join-Path 'raw_outputs' "$id.json" }
  elseif (Test-Path (Join-Path 'event_a' (Join-Path 'raw_outputs' "$id.json"))) { $f = Join-Path 'event_a' (Join-Path 'raw_outputs' "$id.json") }

  $old = ''
  if ($f) {
    $t = Get-Content $f -Raw -Encoding UTF8
    # accept straight or curly quotes (outputs 2 and 3 were copied with curly quotes)
    $q = '["\u201C\u201D]'
    if ($t -match ($q + 'verdict' + $q + '\s*:\s*' + $q + '([^"\u201C\u201D]+)')) { $old = $matches[1].Trim() }
  }

  if ($compiles) { $new = $old } else { $new = 'NO - COMPILATION ERROR' }

  [pscustomobject]@{
    case = $id; bug_type = $type; resulting_compiles = $compiles
    claude_verdict_frozen = $old; correct_frozen = ($old -eq $expected)
    verdict_with_gate = $new; correct_with_gate = ($new -eq $expected)
  }
}

$out | Export-Csv (Join-Path 'design' 'results.csv') -NoTypeInformation -Encoding UTF8
$out | Format-Table -AutoSize
"Frozen:    " + @($out | Where-Object { $_.correct_frozen }).Count + " / " + @($out).Count
"With gate: " + @($out | Where-Object { $_.correct_with_gate }).Count + " / " + @($out).Count
