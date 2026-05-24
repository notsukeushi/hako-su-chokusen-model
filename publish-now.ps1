$ErrorActionPreference = "Continue"
$RepoName = "hako-su-chokusen-model"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Set-Location $PSScriptRoot

function Test-GhAuth {
    gh auth status 2>&1 | Out-Null
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-GhAuth)) {
    Write-Host "Opening GitHub device login..."
    Start-Process "https://github.com/login/device"
    gh auth login --hostname github.com --git-protocol https --web
    if (-not (Test-GhAuth)) {
        Write-Error "GitHub login not completed."
        exit 1
    }
}

$ErrorActionPreference = "Stop"
$owner = gh api user -q .login
Write-Host "Logged in as: $owner"

git add index.html deploy.ps1 publish-now.ps1 "2026_05_23_小学3年_箱数直線モデル_3パート_乱数版.html" "2026_05_23_小学3年_箱数直線モデル_3パート_21問_スマホ専用.html"
$st = git status --porcelain
if ($st) { git commit -m "Publish hako-su-chokusen 3-part 21 questions" }

if (git remote get-url origin 2>$null) { git remote remove origin }
git remote add origin "https://github.com/$owner/$RepoName.git"

gh repo view "$owner/$RepoName" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    gh repo create $RepoName --public --description "Grade3 box number line model"
}

git push -u origin main

gh api -X POST "/repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>&1 | Out-Null

$base = "https://$owner.github.io/$RepoName"
Write-Host "Done: $base/"
