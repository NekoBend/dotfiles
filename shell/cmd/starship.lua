-- ===== Suppress banners / normalize spacing =====
settings.set("clink.logo", "none")
settings.set("prompt.spacing", "sparse")  -- cmd.exe adds its own newline + starship add_newline = 2 lines; sparse normalizes to 1

-- ===== Add bin/ to PATH (wrapper scripts for cmd aliases) =====
local bin_dir = os.getenv("LOCALAPPDATA") .. "\\clink\\bin"
local current_path = os.getenv("PATH") or ""
if not current_path:find(bin_dir, 1, true) then
    os.setenv("PATH", bin_dir .. ";" .. current_path)
end

-- ===== Hardware info (for starship) =====
-- Uses PowerShell for CIM queries (WMIC deprecated on Win11)
local h = io.popen('powershell.exe -NoProfile -NoLogo -Command "'
    .. '$cpu=(Get-CimInstance Win32_Processor).Name.Trim();'
    .. '$gpu=(Get-CimInstance Win32_VideoController|Select -First 1).Name.Trim();'
    .. 'Write-Host $cpu;Write-Host $gpu"')
if h then
    local cpu_raw = (h:read("*l") or ""):gsub("%s+$", "")
    local gpu_raw = (h:read("*l") or ""):gsub("%s+$", "")
    h:close()

    if cpu_raw ~= "" then
        local cpu_short = cpu_raw
            :gsub(".*Core%(TM%)%s*", "")
            :gsub(".*Ryzen%s*", "Ryzen ")
            :gsub("%s+", " ")
            :match("^%s*(.-)%s*$")
        if cpu_raw:find("Intel") then
            os.setenv("STARSHIP_CPU_INTEL", cpu_short)
        elseif cpu_raw:find("AMD") then
            os.setenv("STARSHIP_CPU_AMD", cpu_short)
        end
    end

    if gpu_raw ~= "" then
        local gpu_short = gpu_raw
            :gsub("NVIDIA%s+GeForce%s*", "")
            :gsub("AMD%s+", "")
            :gsub("Intel%(R%)%s*", "")
            :gsub("%s+", " ")
            :match("^%s*(.-)%s*$")
        if gpu_raw:find("NVIDIA") then
            os.setenv("STARSHIP_GPU_NVIDIA", gpu_short)
        elseif gpu_raw:find("AMD") or gpu_raw:find("Radeon") then
            os.setenv("STARSHIP_GPU_AMD", gpu_short)
        elseif gpu_raw:find("Intel") then
            os.setenv("STARSHIP_GPU_INTEL", gpu_short)
        end
    end
end

-- ===== Navigation (doskey - simple aliases) =====
os.execute('doskey ..=cd ..')
os.execute('doskey c=cls')

-- ===== Git =====
os.execute('doskey g=git $*')
os.execute('doskey ga=git add $*')
os.execute('doskey gaa=git add --all')
os.execute('doskey gb=git branch $*')
os.execute('doskey gc=git commit $*')
os.execute('doskey gcm=git commit -m $*')
os.execute('doskey gco=git checkout $*')
os.execute('doskey gd=git diff $*')
os.execute('doskey gds=git diff --staged $*')
os.execute('doskey gf=git fetch --all --prune')
os.execute('doskey gl=git log --oneline --graph $*')
os.execute('doskey gpl=git pull $*')
os.execute('doskey gps=git push $*')
os.execute('doskey gst=git status -sb')
os.execute('doskey gsw=git switch $*')

-- ===== Docker =====
os.execute('doskey d=docker $*')
os.execute('doskey dc=docker compose $*')
os.execute('doskey dcb=docker compose build $*')
os.execute('doskey dcd=docker compose down $*')
os.execute('doskey dce=docker compose exec $*')
os.execute('doskey dcl=docker compose logs $*')
os.execute('doskey dcu=docker compose up $*')
os.execute('doskey di=docker images $*')
os.execute('doskey dps=docker ps $*')
os.execute('doskey dri=docker run -it $*')
os.execute('doskey drir=docker run -it --rm $*')

-- ===== Editor =====
os.execute('doskey code=code-insiders $*')
os.execute('doskey gu=gitui $*')

-- ===== Starship =====
load(io.popen('starship init cmd'):read("*a"))()
