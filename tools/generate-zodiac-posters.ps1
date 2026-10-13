param(
  [Parameter(Mandatory = $true)] [string] $DataRoot,
  [string] $OutputRoot = (Join-Path $PSScriptRoot '..\assets\zodiac-charts')
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$posterSpecs = @(
  @{ Id = 'Ari'; Korean = '양자리'; Latin = 'Aries'; Period = '3.21–4.19' },
  @{ Id = 'Tau'; Korean = '황소자리'; Latin = 'Taurus'; Period = '4.20–5.20' },
  @{ Id = 'Gem'; Korean = '쌍둥이자리'; Latin = 'Gemini'; Period = '5.21–6.21' },
  @{ Id = 'Cnc'; Korean = '게자리'; Latin = 'Cancer'; Period = '6.22–7.22' },
  @{ Id = 'Leo'; Korean = '사자자리'; Latin = 'Leo'; Period = '7.23–8.22' },
  @{ Id = 'Vir'; Korean = '처녀자리'; Latin = 'Virgo'; Period = '8.23–9.22' },
  @{ Id = 'Lib'; Korean = '천칭자리'; Latin = 'Libra'; Period = '9.23–10.22' },
  @{ Id = 'Sco'; Korean = '전갈자리'; Latin = 'Scorpius'; Period = '10.23–11.21' },
  @{ Id = 'Sgr'; Korean = '사수자리'; Latin = 'Sagittarius'; Period = '11.22–12.21' },
  @{ Id = 'Cap'; Korean = '염소자리'; Latin = 'Capricornus'; Period = '12.22–1.19' },
  @{ Id = 'Aqr'; Korean = '물병자리'; Latin = 'Aquarius'; Period = '1.20–2.18' },
  @{ Id = 'Psc'; Korean = '물고기자리'; Latin = 'Pisces'; Period = '2.19–3.20' }
)

function Read-GeoJson([string] $Name) {
  Get-Content -LiteralPath (Join-Path $DataRoot $Name) -Raw -Encoding UTF8 | ConvertFrom-Json
}
function Unwrap-Ra([double] $Value, [double] $Center) {
  while ($Value - $Center -gt 180) { $Value -= 360 }
  while ($Value - $Center -lt -180) { $Value += 360 }
  return $Value
}
function Escape-Xml([string] $Text) {
  [System.Security.SecurityElement]::Escape($Text)
}
function Format-SvgNumber([double] $Value) {
  $Value.ToString('0.##', [System.Globalization.CultureInfo]::InvariantCulture)
}
function Is-InFrame($Ra, $Dec, $CenterRa, $MinRa, $MaxRa, $MinDec, $MaxDec) {
  $unwrappedRa = Unwrap-Ra ([double]$Ra) $CenterRa
  return (($unwrappedRa -ge $MinRa) -and ($unwrappedRa -le $MaxRa) -and ([double]$Dec -ge $MinDec) -and ([double]$Dec -le $MaxDec))
}

$stars = (Read-GeoJson 'stars.6.json').features
$dsos = (Read-GeoJson 'dsos.bright.json').features
$messier = (Read-GeoJson 'messier.json').features
$lineFeatures = (Read-GeoJson 'constellations.lines.json').features
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

foreach ($spec in $posterSpecs) {
  $lineFeature = $lineFeatures | Where-Object { $_.id -eq $spec.Id }
  if ($null -eq $lineFeature) { throw "Constellation line data not found: $($spec.Id)" }
  $rawPoints = [System.Collections.Generic.List[object]]::new()
  foreach ($linePath in $lineFeature.geometry.coordinates) {
    foreach ($point in $linePath) {
      [void]$rawPoints.Add(@([double]$point[0], [double]$point[1]))
    }
  }
  $angles = @($rawPoints | ForEach-Object { [Math]::Atan2([Math]::Sin([double]$_[0] * [Math]::PI / 180), [Math]::Cos([double]$_[0] * [Math]::PI / 180)) })
  $centerRa = [Math]::Atan2((($angles | ForEach-Object { [Math]::Sin($_) }) | Measure-Object -Sum).Sum, (($angles | ForEach-Object { [Math]::Cos($_) }) | Measure-Object -Sum).Sum) * 180 / [Math]::PI
  $projectedPoints = @($rawPoints | ForEach-Object { [pscustomobject]@{ Ra = Unwrap-Ra ([double]$_[0]) $centerRa; Dec = [double]$_[1] } })
  $minRa = ($projectedPoints.Ra | Measure-Object -Minimum).Minimum - 2
  $maxRa = ($projectedPoints.Ra | Measure-Object -Maximum).Maximum + 2
  $minDec = ($projectedPoints.Dec | Measure-Object -Minimum).Minimum - 2
  $maxDec = ($projectedPoints.Dec | Measure-Object -Maximum).Maximum + 2
  $middleDec = ($minDec + $maxDec) / 2
  $cosDec = [Math]::Cos($middleDec * [Math]::PI / 180)
  $fieldWidth = ($maxRa - $minRa) * $cosDec
  $fieldHeight = $maxDec - $minDec
  # 정사각형 PNG 카드에서 별자리 선이 화면 중심을 충분히 채우도록 투영 범위를 맞춘다.
  $targetAspect = 1.0
  if ($fieldWidth / $fieldHeight -lt $targetAspect) {
    $halfWidth = ($fieldHeight * $targetAspect / $cosDec) / 2
    $midRa = ($minRa + $maxRa) / 2; $minRa = $midRa - $halfWidth; $maxRa = $midRa + $halfWidth
  } else {
    $halfHeight = ($fieldWidth / $targetAspect) / 2
    $midDec = ($minDec + $maxDec) / 2; $minDec = $midDec - $halfHeight; $maxDec = $midDec + $halfHeight
  }
  $chartX = 50; $chartY = 50; $chartW = 1500; $chartH = 1500
  $toX = { param([double] $ra) $chartX + (((Unwrap-Ra $ra $centerRa) - $minRa) * $cosDec / (($maxRa - $minRa) * $cosDec)) * $chartW }
  $toY = { param([double] $dec) $chartY + (($maxDec - $dec) / ($maxDec - $minDec)) * $chartH }
  $backgroundStars = @($stars | Where-Object { Is-InFrame ([double]$_.geometry.coordinates[0]) ([double]$_.geometry.coordinates[1]) $centerRa $minRa $maxRa $minDec $maxDec })
  $dsoCandidates = @(($messier + $dsos) | Where-Object { Is-InFrame ([double]$_.geometry.coordinates[0]) ([double]$_.geometry.coordinates[1]) $centerRa $minRa $maxRa $minDec $maxDec }) |
    Group-Object id | ForEach-Object { $_.Group[0] } |
    Sort-Object @{ Expression = { $m = 99.0; [void][double]::TryParse(([string]$_.properties.mag), [ref]$m); $m } }, id |
    Select-Object -First 12

  $starMarkup = foreach ($star in $backgroundStars) {
    $mag = [double]$star.properties.mag; $r = [Math]::Max(0.8, [Math]::Min(4.2, 5.3 - $mag * 0.62))
    '<circle class="star" cx="{0}" cy="{1}" r="{2}" />' -f (Format-SvgNumber (& $toX ([double]$star.geometry.coordinates[0]))), (Format-SvgNumber (& $toY ([double]$star.geometry.coordinates[1]))), (Format-SvgNumber $r)
  }
  $lineMarkup = foreach ($path in $lineFeature.geometry.coordinates) {
    $commands = @(); $first = $true
    foreach ($point in $path) {
      $command = if ($first) { 'M' } else { 'L' }; $first = $false
      $commands += '{0} {1},{2}' -f $command, (Format-SvgNumber (& $toX ([double]$point[0]))), (Format-SvgNumber (& $toY ([double]$point[1])))
    }
    '<path class="constellation" d="{0}" />' -f ($commands -join ' ')
  }
  $dsoMarkup = foreach ($dso in $dsoCandidates) {
    $x = & $toX ([double]$dso.geometry.coordinates[0]); $y = & $toY ([double]$dso.geometry.coordinates[1])
    $kind = [string]$dso.properties.type
    $xText = Format-SvgNumber $x; $yText = Format-SvgNumber $y
    $shape = if ($kind -match 'g|gg') { '<ellipse class="dso" cx="{0}" cy="{1}" rx="8" ry="4" transform="rotate(-25 {0} {1})" />' -f $xText,$yText }
      elseif ($kind -match 'oc|gc|sc') { '<circle class="dso" cx="{0}" cy="{1}" r="6" />' -f $xText,$yText }
      else { '<path class="dso" d="M {0},{1} l 6,6 l -6,6 l -6,-6 Z" />' -f $xText,(Format-SvgNumber ($y-6)) }
    $label = if ($dso.id) { [string]$dso.id } else { [string]$dso.properties.desig }
    "$shape<text class=`"dso-label`" x=`"$(Format-SvgNumber ($x + 11))`" y=`"$(Format-SvgNumber ($y - 7))`">$(Escape-Xml $label)</text>"
  }
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="1600" viewBox="0 0 1600 1600" role="img" aria-labelledby="title desc">
  <title id="title">$($spec.Korean) 실제 좌표 성도</title>
  <desc id="desc">J2000 적경과 적위를 등거리로 투영한 $($spec.Latin) 별자리 성도. 항성, 별자리 선, 딥스카이 위치를 표시한다.</desc>
  <style>
    .star { fill:#fff6c6; } .constellation { fill:none; stroke:#f6d36a; stroke-width:5; stroke-linecap:round; stroke-linejoin:round; filter:url(#glow) } .dso { fill:#d7a4ff; fill-opacity:.65; stroke:#f0c6ff; stroke-width:2 } .dso-label { fill:#edccff; font:700 20px Arial,sans-serif; paint-order:stroke; stroke:#101a42; stroke-width:5px; stroke-linejoin:round } .edge { fill:none; stroke:#e5c45f; stroke-width:2 }
  </style>
  <defs><radialGradient id="sky"><stop stop-color="#1d2a65"/><stop offset="1" stop-color="#060b24"/></radialGradient><filter id="glow"><feGaussianBlur stdDeviation="2" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
  <rect width="1600" height="1600" fill="#060b24"/><rect x="20" y="20" width="1560" height="1560" rx="20" fill="url(#sky)" stroke="#f0d47e" stroke-opacity=".6"/>
  <rect x="$chartX" y="$chartY" width="$chartW" height="$chartH" fill="#070d2b" fill-opacity=".48" class="edge"/>
  $starMarkup
  $lineMarkup
  $dsoMarkup
</svg>
"@
  [System.IO.File]::WriteAllText((Join-Path $OutputRoot ("{0}.svg" -f $spec.Id.ToLowerInvariant())), $svg, $utf8NoBom)
}
