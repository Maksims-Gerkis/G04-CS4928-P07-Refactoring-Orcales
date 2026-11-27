# Compile check (M4 design): compiles the original and resulting program of every case with javac.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File design\compile_gate.ps1
# Works in Windows PowerShell 5.1 and PowerShell 7 (Windows, macOS, Linux). Requires JDK 21 (javac on PATH).
# Output: design\compile_gate\logs\<id>_<version>.txt and design\compile_gate\compile_results.csv

$jar = Join-Path 'lib' 'junit-platform-console-standalone-1.10.2.jar'   # needed for the authors' reference tests in BC folders
$logs = Join-Path 'design' (Join-Path 'compile_gate' 'logs')
New-Item -ItemType Directory -Force $logs | Out-Null

$cases = @(Get-ChildItem cases -Directory)
if (Test-Path (Join-Path 'event_a' 'cases')) { $cases += @(Get-ChildItem (Join-Path 'event_a' 'cases') -Directory) }

$rows = foreach ($c in $cases) {
  foreach ($v in "original","resulting") {
    $src = Get-ChildItem (Join-Path $c.FullName $v) -Filter *.java -Recurse | ForEach-Object { $_.FullName }
    $out = Join-Path 'build' (Join-Path $c.Name $v)
    New-Item -ItemType Directory -Force $out | Out-Null
    javac -cp $jar -d $out $src 2>&1 | Out-File (Join-Path $logs "$($c.Name)_$v.txt") -Encoding UTF8
    [pscustomobject]@{ case = [int]$c.Name; version = $v; compiles = ($LASTEXITCODE -eq 0) }
  }
}

$rows | Sort-Object case, version | Export-Csv (Join-Path 'design' (Join-Path 'compile_gate' 'compile_results.csv')) -NoTypeInformation -Encoding UTF8
$rows | Sort-Object case, version | Format-Table
