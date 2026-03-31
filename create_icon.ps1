Add-Type -AssemblyName System.Drawing

$s = 1024
$bmp = New-Object System.Drawing.Bitmap($s, $s)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Dark gray background (matching the image: #636363)
$bgColor = [System.Drawing.Color]::FromArgb(255, 99, 99, 99)
$bgBrush = New-Object System.Drawing.SolidBrush($bgColor)
$g.FillRectangle($bgBrush, 0, 0, $s, $s)

# Font: bold, large, sans-serif
$fontSize = 260
$font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

# Colors
$whiteColor = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$blueColor  = [System.Drawing.Color]::FromArgb(255, 26, 110, 191)
$whiteBrush = New-Object System.Drawing.SolidBrush($whiteColor)
$blueBrush  = New-Object System.Drawing.SolidBrush($blueColor)

# Measure each part
$wChar  = "W"
$hubStr = "hub"

$wSize   = $g.MeasureString($wChar,  $font, [System.Drawing.PointF]::new(0,0), [System.Drawing.StringFormat]::GenericTypographic)
$hubSize = $g.MeasureString($hubStr, $font, [System.Drawing.PointF]::new(0,0), [System.Drawing.StringFormat]::GenericTypographic)

$totalWidth = $wSize.Width + $hubSize.Width
$totalHeight = $wSize.Height

# Center the text block
$startX = ($s - $totalWidth) / 2
$startY = ($s - $totalHeight) / 2

$fmt = [System.Drawing.StringFormat]::GenericTypographic

# Draw "W" in white
$g.DrawString($wChar, $font, $whiteBrush, [System.Drawing.PointF]::new($startX, $startY), $fmt)

# Draw "hub" in blue right after W
$g.DrawString($hubStr, $font, $blueBrush, [System.Drawing.PointF]::new($startX + $wSize.Width, $startY), $fmt)

# Save
$dir = "assets\icon"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$bmp.Save("assets\icon\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Host "Whub icon created!"
