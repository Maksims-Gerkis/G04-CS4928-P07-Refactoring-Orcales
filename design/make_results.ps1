# Applies the compile check to the frozen Claude verdicts and compares the two (M4 verification).
# Run after compile_gate.ps1, from the repo root:  powershell -ExecutionPolicy Bypass -File design\make_results.ps1
# Output: design\results.csv
# Note: BC cases are scored on the verdict only (generated JUnit tests are not executed).

$cr = Import-Csv design\compile_gate\compile_results.csv | Where-Object { $_.version -eq 'resulting' }

$out = foreach ($r in $cr) {
  $id = $r.case
  $compiles = ($r.compiles -eq 'True')
  if ($compiles) { $type = 'BC'; $expected = 'NO - BEHAVIOR CHANGE' } else { $type = 'CE'; $expected = 'NO - COMPILATION ERROR' }

  $f = $null
  if (Test-Path "raw_outputs\$id.json") { $f = "raw_outputs\$id.json" }
  elseif (Test-Path "event_a\raw_outputs\$id.json") { $f = "event_a\raw_outputs\$id.json" }

  $old = ''
  if ($f) {
    $t = (Get-Content $f -Raw -Encoding UTF8) -replace '[“”]', '"'
    if ($t -match '"verdict"\s*:\s*"([^"]+)"') { $old = $matches[1].Trim() }
  }

  if ($compiles) { $new = $old } else { $new = 'NO - COMPILATION ERROR' }

  [pscustomobject]@{
    case = $id; bug_type = $type; resulting_compiles = $compiles
    claude_verdict_frozen = $old; correct_frozen = ($old -eq $expected)
    verdict_with_gate = $new; correct_with_gate = ($new -eq $expected)
  }
}

$out | Export-Csv design\results.csv -NoTypeInformation
$out | Format-Table -AutoSize
"Frozen:    " + @($out | Where-Object { $_.correct_frozen }).Count + " / " + @($out).Count
"With gate: " + @($out | Where-Object { $_.correct_with_gate }).Count + " / " + @($out).Count
