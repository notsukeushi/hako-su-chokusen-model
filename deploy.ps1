# GitHub 公開スクリプト（プログラムフォルダで実行）
# 事前に: gh auth login --web で GitHub にログインしてください

$ErrorActionPreference = "Stop"
$RepoName = "hako-su-chokusen-model"

Set-Location $PSScriptRoot

Write-Host "GitHub ログイン確認..." -ForegroundColor Cyan
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "先にログインしてください: gh auth login --web" -ForegroundColor Yellow
    exit 1
}

$owner = gh api user -q .login
Write-Host "ユーザー: $owner" -ForegroundColor Green

if (-not (git rev-parse --git-dir 2>$null)) {
    git init
    git branch -M main
}

git add index.html "2026_05_23_小学3年_箱数直線モデル_3パート_乱数版.html" "2026_05_23_小学3年_箱数直線モデル_3パート_21問_スマホ専用.html"
$status = git status --porcelain
if ($status) {
    git commit -m "箱数直線モデル 3パート21問を更新"
}

if (git remote get-url origin 2>$null) {
    Write-Host "リモート origin あり → push します" -ForegroundColor Cyan
    git push origin main
} else {
    Write-Host "GitHub リポジトリを作成して push..." -ForegroundColor Cyan
    gh repo create $RepoName --public --source=. --remote=origin --push --description "小学3年 箱数直線モデル（3パート21問）"
}

Write-Host "GitHub Pages を有効化..." -ForegroundColor Cyan
gh api -X POST "/repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pages は Settings → Pages から main / (root) を選んで有効化してください" -ForegroundColor Yellow
}

$base = "https://$owner.github.io/$RepoName"
Write-Host ""
Write-Host "公開URL（数分後に有効）:" -ForegroundColor Green
Write-Host "  トップ:     $base/"
Write-Host "  スマホ専用: $base/2026_05_23_小学3年_箱数直線モデル_3パート_21問_スマホ専用.html"
Write-Host "  一覧版:     $base/2026_05_23_小学3年_箱数直線モデル_3パート_乱数版.html"
