# Compile check (M4 design): compiles the original and resulting program of every case with javac.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File design\compile_gate.ps1
# Output: design\compile_gate\logs\<id>_<version>.txt and design\compile_gate\compile_results.csv

$jar = "lib\junit-platform-console-standalone-1.10.2.jar"
New-Item -ItemType Directory -Force design\compile_gate\logs | Out-Null

$cases = @(Get-ChildItem cases -Directory)
if (Test-Path event_a\cases) { $cases += @(Get-ChildItem event_a\cases -Directory) }

$rows = foreach ($c in $cases) {
  foreach ($v in "original","resulting") {
    $src = Get-ChildItem "$($c.FullName)\$v" -Filter *.java -Recurse | ForEach-Object { $_.FullName }
    $out = "build\$($c.Name)\$v"
    New-Item -ItemType Directory -Force $out | Out-Null
    javac -cp $jar -d $out $src 2>&1 | Out-File "design\compile_gate\logs\$($c.Name)_$v.txt" -Encoding UTF8
    [pscustomobject]@{ case = [int]$c.Name; version = $v; compiles = ($LASTEXITCODE -eq 0) }
  }
}

$rows | Sort-Object case, version | Export-Csv design\compile_gate\compile_results.csv -NoTypeInformation
$rows | Sort-Object case, version | Format-Table
