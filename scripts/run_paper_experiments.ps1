$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$modelSrc = Join-Path $repoRoot "france_religious_composition_abm.nlogo"
$netlogoExe = "C:\Program Files\NetLogo 6.4.0\netlogo-headless.bat"

if (-not (Test-Path $netlogoExe)) {
  throw "NetLogo headless executable not found: $netlogoExe"
}
if (-not (Test-Path $modelSrc)) {
  throw "Model file not found: $modelSrc"
}

$tmp = "C:\temp\netlogo-paper"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
Copy-Item -Path $modelSrc -Destination "$tmp\model.nlogo" -Force

$xml = @'
<experiments>
  <experiment name="baseline_30y" repetitions="200" sequentialRunOrder="true" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>count turtles</metric>
    <metric>count turtles with [religion = "muslim"]</metric>
    <metric>count turtles with [religion = "non-muslim"]</metric>
    <metric>ifelse-value (count turtles = 0) [0] [count turtles with [religion = "muslim"] / count turtles]</metric>
    <enumeratedValueSet variable="share-muslim-incoming"><value value="0.52"/></enumeratedValueSet>
    <enumeratedValueSet variable="muslim-birth-rate"><value value="2.81"/></enumeratedValueSet>
    <enumeratedValueSet variable="non-muslim-birth-rate"><value value="1.56"/></enumeratedValueSet>
    <enumeratedValueSet variable="coverage-coefficient"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-coming"><value value="3.36"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-leaving"><value value="1.66"/></enumeratedValueSet>
  </experiment>

  <experiment name="no_migration_30y" repetitions="200" sequentialRunOrder="true" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>count turtles</metric>
    <metric>count turtles with [religion = "muslim"]</metric>
    <metric>count turtles with [religion = "non-muslim"]</metric>
    <metric>ifelse-value (count turtles = 0) [0] [count turtles with [religion = "muslim"] / count turtles]</metric>
    <enumeratedValueSet variable="share-muslim-incoming"><value value="0.52"/></enumeratedValueSet>
    <enumeratedValueSet variable="muslim-birth-rate"><value value="2.81"/></enumeratedValueSet>
    <enumeratedValueSet variable="non-muslim-birth-rate"><value value="1.56"/></enumeratedValueSet>
    <enumeratedValueSet variable="coverage-coefficient"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-coming"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-leaving"><value value="0"/></enumeratedValueSet>
  </experiment>

  <experiment name="high_inflow_share_30y" repetitions="200" sequentialRunOrder="true" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="30"/>
    <metric>count turtles</metric>
    <metric>count turtles with [religion = "muslim"]</metric>
    <metric>count turtles with [religion = "non-muslim"]</metric>
    <metric>ifelse-value (count turtles = 0) [0] [count turtles with [religion = "muslim"] / count turtles]</metric>
    <enumeratedValueSet variable="share-muslim-incoming"><value value="0.70"/></enumeratedValueSet>
    <enumeratedValueSet variable="muslim-birth-rate"><value value="2.81"/></enumeratedValueSet>
    <enumeratedValueSet variable="non-muslim-birth-rate"><value value="1.56"/></enumeratedValueSet>
    <enumeratedValueSet variable="coverage-coefficient"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-coming"><value value="3.36"/></enumeratedValueSet>
    <enumeratedValueSet variable="agents-leaving"><value value="1.66"/></enumeratedValueSet>
  </experiment>
</experiments>
'@

$xml = $xml.TrimStart()
[System.IO.File]::WriteAllText("$tmp\paper_experiments.xml", $xml, [System.Text.UTF8Encoding]::new($false))

$experiments = @(
  "baseline_30y",
  "no_migration_30y",
  "high_inflow_share_30y"
)

foreach ($exp in $experiments) {
  Write-Host "Running $exp ..."
  & $netlogoExe --model "$tmp\model.nlogo" --setup-file "$tmp\paper_experiments.xml" --experiment $exp --table "$tmp\$exp.csv"
  if ($LASTEXITCODE -ne 0) {
    throw "Experiment failed: $exp"
  }
}

$paperDir = Join-Path $repoRoot "data\paper_runs"
$rawDir = Join-Path $paperDir "raw"
New-Item -ItemType Directory -Force -Path $rawDir | Out-Null
Get-ChildItem -Path $rawDir -Filter "*.csv" -ErrorAction SilentlyContinue | Remove-Item -Force
Copy-Item -Path "$tmp\baseline_30y.csv" -Destination $rawDir -Force
Copy-Item -Path "$tmp\no_migration_30y.csv" -Destination $rawDir -Force
Copy-Item -Path "$tmp\high_inflow_share_30y.csv" -Destination $rawDir -Force
Copy-Item -Path "$tmp\paper_experiments.xml" -Destination (Join-Path $paperDir "paper_experiments.xml") -Force

Write-Host "Done. Raw outputs copied to $rawDir"
