param([int]$Port = 8000)
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pythonExe = Join-Path $projectRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $pythonExe)) { throw 'Install requirements into .venv first; see README.md.' }
$member1Dir = Join-Path $projectRoot 'original_modules\person1'
$member2Dir = Join-Path $projectRoot 'original_modules\person2\member2'
$member3Dir = Join-Path $projectRoot 'original_modules\person3\moon_navigation'
$env:LUNA_SITE_URL = 'http://127.0.0.1:8001'
$env:LUNA_VISIBILITY_URL = 'http://127.0.0.1:8002'
$member1 = Start-Process -FilePath $pythonExe -ArgumentList '-m','uvicorn','landing_site_analyzer.app:app','--host','127.0.0.1','--port','8001' -WorkingDirectory $member1Dir -WindowStyle Hidden -PassThru
$member2 = Start-Process -FilePath $pythonExe -ArgumentList '-m','uvicorn','visibility_planner.api:app','--host','127.0.0.1','--port','8002' -WorkingDirectory $member2Dir -WindowStyle Hidden -PassThru
$member3 = $null
if (Test-Path -LiteralPath (Join-Path $member3Dir 'node_modules')) {
  $pnpmExe = (Get-Command pnpm.cmd -ErrorAction Stop).Source
  $env:LUNA_NAVIGATION_URL = 'http://127.0.0.1:3003'
  $member3 = Start-Process -FilePath $pnpmExe -ArgumentList 'start' -WorkingDirectory $member3Dir -WindowStyle Hidden -PassThru
} else { Write-Warning 'Person 3 dependencies missing; run pnpm install in original_modules\person3\moon_navigation. Navigation remains MOCK.' }
try {
  & $pythonExe -m uvicorn api.main:app --host 127.0.0.1 --port $Port --app-dir $projectRoot
} finally {
  Stop-Process -Id $member1.Id,$member2.Id -ErrorAction SilentlyContinue
  if ($member3) { Stop-Process -Id $member3.Id -ErrorAction SilentlyContinue }
}
