[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

function Resize-Image {
    param (
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )
    $src = [System.Drawing.Image]::FromFile($InputPath)
    $dest = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, $Width, $Height)
    $dest.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $dest.Dispose()
    $src.Dispose()
}

$source = "a:\project\Backend project\PDD\SignLanguageApp\public\favicon.png"
$resDir = "a:\project\Backend project\PDD\SignLanguageApp\android\app\src\main\res"

$sizes = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $sizes.Keys) {
    $size = $sizes[$folder]
    $targetFolder = Join-Path $resDir $folder
    
    if (-not (Test-Path $targetFolder)) {
        New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
    }
    
    $outSquare = Join-Path $targetFolder "ic_launcher.png"
    $outRound = Join-Path $targetFolder "ic_launcher_round.png"
    
    Write-Host "Generating icon in $folder at size ${size}x${size}"
    Resize-Image -InputPath $source -OutputPath $outSquare -Width $size -Height $size
    Resize-Image -InputPath $source -OutputPath $outRound -Width $size -Height $size
}

Write-Host "App icon generation completed successfully!"
