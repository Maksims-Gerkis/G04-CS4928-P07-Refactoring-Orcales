# Event B: runs Claude's saved JUnit test for every BC case (and the seeded bug seed1)
# against the original and the resulting program, and writes event_b\comparison.csv.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File event_b\run_bc_tests.ps1
# Works in Windows PowerShell 5.1 and PowerShell 7 (Windows, macOS, Linux). Requires JDK 21 (javac/java on PATH).
# Rule (paper Section 3.6): a BC verdict is confirmed only if the test passes on the original and fails on the resulting program.
# Outputs: event_b\tests\<id>\...\<Class>.java   (the test extracted from Claude's JSON reply)
#          event_b\logs\<id>_original.txt, event_b\logs\<id>_resulting.txt
#          event_b\comparison.csv

$jar   = Join-Path 'lib' 'junit-platform-console-standalone-1.10.2.jar'
$sep   = [IO.Path]::PathSeparator                      # ';' on Windows, ':' elsewhere
$utf8  = New-Object System.Text.UTF8Encoding $false    # javac rejects a BOM, so write tests without one
$root  = (Get-Location).Path
$cases = @('2','4','6','8','10','12','14','16','18','20','50','53','54','seed1')
# Human annotations carried into comparison.csv (not computed).
$notes = @{
  '16'    = 'saved output has "import static org.junit.Assert.;" (missing *); with * restored the test is confirmed - not counted'
  'seed1' = 'seeded Event B bug'
}

New-Item -ItemType Directory -Force (Join-Path 'event_b' 'logs') | Out-Null

function Compile($cp, $outDir, $files) {
  New-Item -ItemType Directory -Force $outDir | Out-Null
  $log = (& javac -cp $cp -d $outDir $files 2>&1 | Out-String)
  return @{ ok = ($LASTEXITCODE -eq 0); log = $log }
}

$rows = foreach ($id in $cases) {
  if ($id -eq 'seed1') { $raw = Join-Path 'event_b' (Join-Path 'raw_outputs' 'seed1.json'); $caseDir = Join-Path 'event_b' (Join-Path 'cases' 'seed1') }
  else                 { $raw = Join-Path 'raw_outputs' "$id.json";                          $caseDir = Join-Path 'cases' $id }

  # Read Claude's reply. Replies were copied by hand, and four saved files are not strictly valid JSON:
  # 2 and 3 use curly quotes as delimiters; 3, 14 and 50 also contain unescaped quotes inside strings.
  # We parse strictly first, then repair curly quotes, then fall back to reading the fields directly.
  $text = Get-Content $raw -Raw -Encoding UTF8
  $verdict = $null; $test = $null; $jsonState = 'valid'
  try { $j = $text | ConvertFrom-Json -ErrorAction Stop; $verdict = $j.verdict; $test = $j.junit_test }
  catch {
    $fixed = $text.Replace([string][char]0x201C, '"').Replace([string][char]0x201D, '"')
    try { $j = $fixed | ConvertFrom-Json -ErrorAction Stop; $verdict = $j.verdict; $test = $j.junit_test; $jsonState = 'repaired (curly quotes)' }
    catch {
      $jsonState = 'lenient (fields read directly)'
      $vm = [regex]::Match($fixed, '"verdict"\s*:\s*"([^"]+)"')
      if ($vm.Success) { $verdict = $vm.Groups[1].Value }
      $tm = [regex]::Match($fixed, '"junit_test"\s*:\s*"([\s\S]*)"\s*\}\s*$')
      if ($tm.Success) {
        $test = [regex]::Replace($tm.Groups[1].Value, '\\(["\\/nrt])', {
          param($m)
          switch -CaseSensitive ($m.Groups[1].Value) { 'n' { "`n" } 'r' { "`r" } 't' { "`t" } default { $m.Groups[1].Value } }
        })
      }
    }
  }
  $verdict = "$verdict".Trim()

  $row = [ordered]@{ case = $id; raw_json = $jsonState; verdict = $verdict; before_verdict_only = ''; test_on_original = ''; test_on_resulting = ''
                     after_test_executed = ''; correct_after = 'no'; note = '' }
  if ($verdict -eq 'NO - BEHAVIOR CHANGE') { $row.before_verdict_only = 'correct (unverified)' } else { $row.before_verdict_only = 'wrong' }
  if ($notes.ContainsKey($id)) { $row.note = $notes[$id] }

  if ([string]::IsNullOrWhiteSpace($test)) {
    $row.after_test_executed = 'no test'
  } else {
    # Write the test as <Class>.java, inside its package folder if it declares one.
    $class = [regex]::Match($test, 'public\s+class\s+(\w+)').Groups[1].Value
    $pkgM  = [regex]::Match($test, '(?m)^\s*package\s+([\w.]+)\s*;')
    $testDir = Join-Path 'event_b' (Join-Path 'tests' $id)
    if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
    $fq = $class; $dir = $testDir
    if ($pkgM.Success) { $fq = "$($pkgM.Groups[1].Value).$class"; foreach ($part in $pkgM.Groups[1].Value.Split('.')) { $dir = Join-Path $dir $part } }
    New-Item -ItemType Directory -Force $dir | Out-Null
    $testFile = Join-Path $dir "$class.java"
    [IO.File]::WriteAllText((Join-Path $root $testFile), $test.TrimEnd() + "`n", $utf8)

    $res = @{}
    foreach ($v in 'original','resulting') {
      # Program sources, excluding the authors' reference tests (*Test*.java) in the case folders.
      $src = Get-ChildItem (Join-Path $caseDir $v) -Filter *.java -Recurse | Where-Object { $_.Name -notlike '*Test*' } | ForEach-Object { $_.FullName }
      $progOut = Join-Path 'build' (Join-Path 'event_b' (Join-Path $id $v))
      $testOut = Join-Path 'build' (Join-Path 'event_b' (Join-Path $id "t_$v"))
      $p = Compile $jar $progOut $src
      if (-not $p.ok) { throw "program $id/$v does not compile:`n$($p.log)" }
      $t = Compile "$progOut$sep$jar" $testOut @($testFile)
      $log = $t.log
      if ($t.ok) {
        $cp = "$testOut$sep$progOut$sep$jar"
        if ($test -match 'org\.junit\.jupiter') { $log += (& java -jar $jar -cp $cp --select-class $fq --disable-banner 2>&1 | Out-String) }
        else                                    { $log += (& java -cp $cp org.junit.runner.JUnitCore $fq 2>&1 | Out-String) }
        if ($LASTEXITCODE -eq 0) { $res[$v] = 'PASS' } else { $res[$v] = 'FAIL' }
      } else { $res[$v] = 'TEST DOES NOT COMPILE' }
      [IO.File]::WriteAllText((Join-Path $root (Join-Path 'event_b' (Join-Path 'logs' "${id}_$v.txt"))), $log, $utf8)
    }
    $row.test_on_original = $res['original']; $row.test_on_resulting = $res['resulting']
    if ($res['original'] -eq 'TEST DOES NOT COMPILE' -or $res['resulting'] -eq 'TEST DOES NOT COMPILE') { $row.after_test_executed = 'test does not compile' }
    elseif ($res['original'] -eq 'PASS' -and $res['resulting'] -eq 'FAIL') { $row.after_test_executed = 'confirmed'; $row.correct_after = 'yes' }
    elseif ($res['original'] -eq $res['resulting']) { $row.after_test_executed = 'does not expose change' }
    else { $row.after_test_executed = 'inverted (fails on original, passes on resulting)' }
  }
  [pscustomobject]$row
}

$rows | Export-Csv (Join-Path 'event_b' 'comparison.csv') -NoTypeInformation -Encoding UTF8
$rows | Format-Table case, verdict, test_on_original, test_on_resulting, after_test_executed -AutoSize
$bc = @($rows | Where-Object { $_.case -ne 'seed1' })
"BC verdict only: " + @($bc | Where-Object { $_.before_verdict_only -eq 'correct (unverified)' }).Count + " / " + $bc.Count
"BC tests run:    " + @($bc | Where-Object { $_.correct_after -eq 'yes' }).Count + " / " + $bc.Count + " confirmed"
"seed1:           " + ($rows | Where-Object { $_.case -eq 'seed1' }).after_test_executed
