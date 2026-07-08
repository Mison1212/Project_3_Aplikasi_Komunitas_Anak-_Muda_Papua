$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'api_secure_patch'
$target = 'C:\xampp\htdocs\papua_youth_career_api'
$backup = Join-Path $PSScriptRoot ('api_backup_' + (Get-Date -Format 'yyyyMMdd_HHmmss'))

if (-not (Test-Path $source)) {
  throw "Folder patch tidak ditemukan: $source"
}

if (-not (Test-Path $target)) {
  throw "Folder API tidak ditemukan: $target"
}

New-Item -ItemType Directory -Force -Path $backup | Out-Null

$files = Get-ChildItem -Path $source -Recurse -File | Where-Object { $_.Name -ne 'README.md' }
foreach ($file in $files) {
  $relative = $file.FullName.Substring($source.Length).TrimStart('\')
  $targetFile = Join-Path $target $relative
  $backupFile = Join-Path $backup $relative

  if (Test-Path $targetFile) {
    New-Item -ItemType Directory -Force -Path (Split-Path $backupFile) | Out-Null
    Copy-Item -Path $targetFile -Destination $backupFile -Force
  }

  New-Item -ItemType Directory -Force -Path (Split-Path $targetFile) | Out-Null
  Copy-Item -Path $file.FullName -Destination $targetFile -Force
}

Write-Host "Patch keamanan API berhasil dipasang."
Write-Host "Backup file lama: $backup"
