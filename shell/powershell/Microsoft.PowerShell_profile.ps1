# ===== Modules =====
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# ===== CLI Tools =====
Remove-Item alias:ls -Force -ErrorAction SilentlyContinue

# cat → bat (syntax-highlighted cat, falls back to Get-Content)
function cat {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command bat -ErrorAction SilentlyContinue) {
    & bat --style=plain --paging=never @Args
  }
  else {
    Get-Content @Args
  }
}

# df → disk free space
function df {
  Get-PSDrive -PSProvider FileSystem |
    Select-Object Name,
      @{N='Used(GB)';  E={[math]::Round($_.Used / 1GB, 1)}},
      @{N='Free(GB)';  E={[math]::Round($_.Free / 1GB, 1)}},
      @{N='Total(GB)'; E={[math]::Round(($_.Used + $_.Free) / 1GB, 1)}},
      Root |
    Format-Table -AutoSize
}

# env → list environment variables (sorted)
function env {
  Get-ChildItem Env: | Sort-Object Name | Format-Table Name, Value -AutoSize -Wrap
}

# find → fd (falls back to Get-ChildItem -Recurse -Filter)
function find {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command fd -ErrorAction SilentlyContinue) {
    & fd @Args
  }
  else {
    Get-ChildItem -Recurse -Filter @Args
  }
}

# grep → ripgrep (falls back to Select-String)
function grep {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command rg -ErrorAction SilentlyContinue) {
    & rg @Args
  }
  else {
    Select-String @Args
  }
}

# head N lines of a file (default: 10)
function head {
  param(
    [int]$N = 10,
    [Parameter(ValueFromRemainingArguments = $true)] $Args
  )
  Get-Content @Args | Select-Object -First $N
}

# ls -a (show all including hidden)
function la {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd -a @Args
  }
  else {
    Get-ChildItem -Force @Args
  }
}

# ls -l (long format)
function ll {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd -l @Args
  }
  else {
    Get-ChildItem @Args | Format-Table Mode, LastWriteTime, Length, Name
  }
}

# ls -la (long format + hidden)
function lla {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd -la @Args
  }
  else {
    Get-ChildItem -Force @Args | Format-Table Mode, LastWriteTime, Length, Name
  }
}

# ls -l --tree (long format tree view)
function llt {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd -l --tree @Args
  }
  else {
    Write-Warning "lsd is not installed. Install: winget install lsd-rs.lsd"
  }
}

# ls → lsd (modern ls replacement, falls back to Get-ChildItem)
function ls {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd @Args
  }
  else {
    Get-ChildItem @Args
  }
}

# ls --tree (tree view)
function lt {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command lsd -ErrorAction SilentlyContinue) {
    & lsd --tree @Args
  }
  else {
    Write-Warning "lsd is not installed. Install: winget install lsd-rs.lsd"
  }
}

# md5 → file MD5 hash
function md5 {
  param([Parameter(Mandatory)][string]$Path)
  (Get-FileHash $Path -Algorithm MD5).Hash
}

# mkfile → create a dummy file of specified size (e.g. mkfile 10MB test.bin)
function mkfile {
  param(
    [Parameter(Mandatory)][string]$Size,
    [Parameter(Mandatory)][string]$Path
  )
  $bytes = [int64](Invoke-Expression $Size)
  $fs = [System.IO.File]::Create($Path)
  $fs.SetLength($bytes)
  $fs.Close()
  Write-Host "Created $Path ($Size)"
}

# display $env:PATH entries one per line
function path {
  $env:PATH -split ';' | Where-Object { $_ -ne '' }
}

# show listening TCP ports with process info
function ports {
  Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Sort-Object LocalPort |
    ForEach-Object {
      $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
      [PSCustomObject]@{
        Port    = $_.LocalPort
        PID     = $_.OwningProcess
        Process = if ($proc) { $proc.ProcessName } else { '-' }
      }
    } |
    Sort-Object Port -Unique |
    Format-Table -AutoSize
}

# ripgrep explicit alias for rg (falls back to Select-String)
function ripgrep {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command rg -ErrorAction SilentlyContinue) {
    & rg @Args
  }
  else {
    Select-String @Args
  }
}

# sha256 → file SHA256 hash
function sha256 {
  param([Parameter(Mandatory)][string]$Path)
  (Get-FileHash $Path -Algorithm SHA256).Hash
}

# split a file into chunks (default: 1000 lines per chunk)
function split {
  param(
    [Parameter(Mandatory)][string]$Path,
    [int]$Lines = 1000,
    [string]$Prefix = 'chunk_'
  )
  $content = Get-Content $Path
  $total = [math]::Ceiling($content.Count / $Lines)
  for ($i = 0; $i -lt $total; $i++) {
    $start = $i * $Lines
    $content[$start..($start + $Lines - 1)] | Set-Content "${Prefix}${i}.txt"
  }
  Write-Host "Split into $total files (${Prefix}0.txt .. ${Prefix}$($total - 1).txt)"
}

# tail N lines of a file (default: 10)
function tail {
  param(
    [int]$N = 10,
    [Parameter(ValueFromRemainingArguments = $true)] $Args
  )
  Get-Content @Args | Select-Object -Last $N
}

# touch → create empty file or update timestamp
function touch {
  param([Parameter(Mandatory)][string]$Path)
  if (Test-Path $Path) {
    (Get-Item $Path).LastWriteTime = Get-Date
  }
  else {
    New-Item -ItemType File -Path $Path | Out-Null
  }
}

# wc → line, word, and character count
function wc {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  Get-Content @Args | Measure-Object -Line -Word -Character
}

# which → Get-Command (show command location)
function which {
  param([Parameter(Mandatory)][string]$Name)
  Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

# ===== Navigation =====
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
Remove-Item alias:cd -Force -ErrorAction SilentlyContinue

# cd .. (go up one directory)
function .. {
  Set-Location ..
}

# clear screen
function c {
  Clear-Host
}

# cd → zoxide (smart directory jump)
function cd {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)

  if ($Args.Count -eq 0) {
    Set-Location ~
    return
  }

  if (Get-Command z -ErrorAction SilentlyContinue) {
    & z @Args
    return
  }

  Set-Location @Args
}

# fuzzy find and cd into a subdirectory (requires fzf)
function cdf {
  if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Write-Warning "fzf is not installed. Install: winget install junegunn.fzf"
    return
  }
  $dir = Get-ChildItem -Directory -Recurse -ErrorAction SilentlyContinue |
    ForEach-Object { $_.FullName } |
    & fzf

  if (-not [string]::IsNullOrWhiteSpace($dir)) {
    Set-Location $dir
  }
}

# mkdir + cd in one step
function mkcd {
  param([string]$Name)
  if ([string]::IsNullOrWhiteSpace($Name)) {
    Write-Error "usage: mkcd <dir>"
    return
  }
  New-Item -ItemType Directory -Force -Path $Name | Out-Null
  Set-Location $Name
}

# reload PowerShell profile
function reload {
  . $PROFILE
}

# yazi file manager (tracks cwd on exit, requires yazi)
function y {
  if (-not (Get-Command yazi -ErrorAction SilentlyContinue)) {
    Write-Warning "yazi is not installed. Install: winget install sxyazi.yazi"
    return
  }
  $tmp = [System.IO.Path]::GetTempFileName()
  & yazi @Args --cwd-file="$tmp"
  $cwd = Get-Content $tmp -ErrorAction SilentlyContinue
  if (-not [string]::IsNullOrWhiteSpace($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location $cwd
  }
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

# ===== Git =====
# git
function g {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git @Args
}

# git add
function ga {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git add @Args
}

# git add --all
function gaa {
  & git add --all
}

# git branch
function gb {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git branch @Args
}

# git commit
function gc {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git commit @Args
}

# git commit -m
function gcm {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git commit -m @Args
}

# git checkout
function gco {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git checkout @Args
}

# git diff
function gd {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git diff @Args
}

# git diff --staged
function gds {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git diff --staged @Args
}

# git fetch --all --prune
function gf {
  & git fetch --all --prune
}

# git log --oneline --graph
function gl {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git log --oneline --graph @Args
}

# git pull
function gpl {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git pull @Args
}

# git push
function gps {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git push @Args
}

# git status (short)
function gst {
  & git status -sb
}

# git switch
function gsw {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & git switch @Args
}

# ===== Docker =====
# docker
function d {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker @Args
}

# docker compose
function dc {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose @Args
}

# docker compose build
function dcb {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose build @Args
}

# docker compose down
function dcd {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose down @Args
}

# docker compose exec
function dce {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose exec @Args
}

# docker compose logs
function dcl {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose logs @Args
}

# docker compose up
function dcu {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker compose up @Args
}

# docker images
function di {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker images @Args
}

# docker ps
function dps {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker ps @Args
}

# docker run -it (interactive)
function dri {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker run -it @Args
}

# docker run -it --rm (interactive, auto-remove)
function drir {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  & docker run -it --rm @Args
}

# ===== Editor =====
# code → code-insiders (falls back to code stable)
function code {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command code-insiders -ErrorAction SilentlyContinue) {
    code-insiders @Args
  }
  elseif (Get-Command code.cmd -ErrorAction SilentlyContinue) {
    code.cmd @Args
  }
  else {
    Write-Warning "VS Code is not installed."
  }
}

# gitui (terminal git UI, requires gitui)
function gu {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command gitui -ErrorAction SilentlyContinue) {
    & gitui @Args
  }
  else {
    Write-Warning "gitui is not installed. Install: winget install gitui"
  }
}

# ===== Python / uv =====
# display warning that direct python/pip is disabled
function Show-UvOnlyMessage {
  param([string]$CommandName)
  Write-Host "Direct use of '$CommandName' is disabled. Please use uv instead."
}

# pip → uv pip (falls back to system pip)
function pip {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Show-UvOnlyMessage 'pip'
    & uv pip @Args
  }
  else {
    & pip.exe @Args
  }
}

# pip3 → uv pip (falls back to system pip3)
function pip3 {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Show-UvOnlyMessage 'pip3'
    & uv pip @Args
  }
  else {
    & pip3.exe @Args
  }
}

# python → uv run python (falls back to system python)
function python {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Show-UvOnlyMessage 'python'
    & uv run python @Args
  }
  else {
    & python.exe @Args
  }
}

# python3 → uv run python (falls back to system python3)
function python3 {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Show-UvOnlyMessage 'python3'
    & uv run python @Args
  }
  else {
    & python3.exe @Args
  }
}

# py → uv run python (short alias, falls back to system python)
function py {
  param([Parameter(ValueFromRemainingArguments = $true)] $Args)
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Show-UvOnlyMessage 'py'
    & uv run python @Args
  }
  else {
    & python.exe @Args
  }
}

# activate Python venv (default: .venv)
function va {
  param([string]$Name = '.venv')

  $activatePath = Join-Path $Name 'Scripts/Activate.ps1'
  if (-not (Test-Path $activatePath)) {
    Write-Error "activate script not found: $activatePath"
    return
  }

  . $activatePath
}

# ===== Hardware info (for starship) =====
try {
  $cpuName = (Get-CimInstance Win32_Processor -ErrorAction Stop).Name.Trim()
  # strip verbose prefixes: "13th Gen Intel(R) Core(TM) " → "i9-13900HX"
  $cpuShort = $cpuName -replace '.*Core\(TM\)\s*' -replace '.*Ryzen\s*', 'Ryzen ' -replace '\s+', ' '
  if ($cpuName -match 'Intel') { $env:STARSHIP_CPU_INTEL = $cpuShort.Trim() }
  elseif ($cpuName -match 'AMD') { $env:STARSHIP_CPU_AMD = $cpuShort.Trim() }
} catch {}
try {
  $gpuName = (Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object -First 1).Name.Trim()
  # strip vendor prefix: "NVIDIA GeForce " → "RTX 4090", "Intel(R) " → "UHD Graphics"
  $gpuShort = $gpuName -replace 'NVIDIA\s+GeForce\s*' -replace 'AMD\s+' -replace 'Intel\(R\)\s*' -replace '\s+', ' '
  if ($gpuName -match 'NVIDIA') { $env:STARSHIP_GPU_NVIDIA = $gpuShort.Trim() }
  elseif ($gpuName -match 'AMD|Radeon') { $env:STARSHIP_GPU_AMD = $gpuShort.Trim() }
  elseif ($gpuName -match 'Intel') { $env:STARSHIP_GPU_INTEL = $gpuShort.Trim() }
} catch {}

# ===== Starship =====
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}