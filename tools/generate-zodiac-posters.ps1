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
  $rawPoints = @($lineFeature.geometry.coordinates | ForEach-Object { $_ | ForEach-Object { $_ } })
  $angles = @($rawPoints | ForEach-Object { [Math]::Atan2([Math]::Sin([double]$_[0] * [Math]::PI / 180), [Math]::Cos([double]$_[0] * [Math]::PI / 180)) })
  $centerRa = [Math]::Atan2((($angles | ForEach-Object { [Math]::Sin($_) }) | Measure-Object -Sum).Sum, (($angles | ForEach-Object { [Math]::Cos($_) }) | Measure-Object -Sum).Sum) * 180 / [Math]::PI
  $projectedPoints = @($rawPoints | ForEach-Object { [pscustomobject]@{ Ra = Unwrap-Ra ([double]$_[0]) $centerRa; Dec = [double]$_[1] } })
  $minRa = ($projectedPoints.Ra | Measure-Object -Minimum).Minimum - 6
  $maxRa = ($projectedPoints.Ra | Measure-Object -Maximum).Maximum + 6
  $minDec = ($projectedPoints.Dec | Measure-Object -Minimum).Minimum - 6
  $maxDec = ($projectedPoints.Dec | Measure-Object -Maximum).Maximum + 6
  $middleDec = ($minDec + $maxDec) / 2
  $cosDec = [Math]::Cos($middleDec * [Math]::PI / 180)
  $fieldWidth = ($maxRa - $minRa) * $cosDec
  $fieldHeight = $maxDec - $minDec
  $targetAspect = 0.78
  if ($fieldWidth / $fieldHeight -lt $targetAspect) {
    $halfWidth = ($fieldHeight * $targetAspect / $cosDec) / 2
    $midRa = ($minRa + $maxRa) / 2; $minRa = $midRa - $halfWidth; $maxRa = $midRa + $halfWidth
  } else {
    $halfHeight = ($fieldWidth / $targetAspect) / 2
    $midDec = ($minDec + $maxDec) / 2; $minDec = $midDec - $halfHeight; $maxDec = $midDec + $halfHeight
  }
  $chartX = 80; $chartY = 300; $chartW = 840; $chartH = 1010
  $toX = { param([double] $ra) $chartX + ((Unwrap-Ra $ra $centerRa - $minRa) * $cosDec / (($maxRa - $minRa) * $cosDec)) * $chartW }
  $toY = { param([double] $dec) $chartY + (($maxDec - $dec) / ($maxDec - $minDec)) * $chartH }
  $backgroundStars = @($stars | Where-Object { Is-InFrame ([double]$_.geometry.coordinates[0]) ([double]$_.geometry.coordinates[1]) $centerRa $minRa $maxRa $minDec $maxDec })
  $dsoCandidates = @(($messier + $dsos) | Where-Object { Is-InFrame ([double]$_.geometry.coordinates[0]) ([double]$_.geometry.coordinates[1]) $centerRa $minRa $maxRa $minDec $maxDec }) |
    Group-Object id | ForEach-Object { $_.Group[0] } |
    Sort-Object @{ Expression = { $m = 99.0; [void][double]::TryParse(([string]$_.properties.mag), [ref]$m); $m } }, id |
    Select-Object -First 12

  $starMarkup = foreach ($star in $backgroundStars) {
    $mag = [double]$star.properties.mag; $r = [Math]::Max(0.8, [Math]::Min(4.2, 5.3 - $mag * 0.62))
    '<circle class="star" cx="{0:N2}" cy="{1:N2}" r="{2:N2}" />' -f (& $toX ([double]$star.geometry.coordinates[0])), (& $toY ([double]$star.geometry.coordinates[1])), $r
  }
  $lineMarkup = foreach ($path in $lineFeature.geometry.coordinates) {
    $commands = @(); $first = $true
    foreach ($point in $path) {
      $command = if ($first) { 'M' } else { 'L' }; $first = $false
      $commands += '{0} {1:N2},{2:N2}' -f $command, (& $toX ([double]$point[0])), (& $toY ([double]$point[1]))
    }
    '<path class="constellation" d="{0}" />' -f ($commands -join ' ')
  }
  $dsoMarkup = foreach ($dso in $dsoCandidates) {
    $x = & $toX ([double]$dso.geometry.coordinates[0]); $y = & $toY ([double]$dso.geometry.coordinates[1])
    $kind = [string]$dso.properties.type
    $shape = if ($kind -match 'g|gg') { '<ellipse class="dso" cx="{0:N2}" cy="{1:N2}" rx="8" ry="4" transform="rotate(-25 {0:N2} {1:N2})" />' -f $x,$y }
      elseif ($kind -match 'oc|gc|sc') { '<circle class="dso" cx="{0:N2}" cy="{1:N2}" r="6" />' -f $x,$y }
      else { '<path class="dso" d="M {0:N2},{1:N2} l 6,6 l -6,6 l -6,-6 Z" />' -f $x,($y-6) }
    $label = if ($dso.id) { [string]$dso.id } else { [string]$dso.properties.desig }
    "$shape<text class=`"dso-label`" x=`"$([math]::Round($x + 11, 2))`" y=`"$([math]::Round($y - 7, 2))`">$(Escape-Xml $label)</text>"
  }
  $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 1000 1414" role="img" aria-labelledby="title desc">
  <title id="title">$($spec.Korean) 실제 좌표 성도</title>
  <desc id="desc">J2000 적경과 적위를 등거리로 투영한 $($spec.Latin) 별자리 성도. 항성, 별자리 선, 딥스카이 위치를 표시한다.</desc>
  <style>
    .title { fill:#f9eec2; font:800 56px 'Malgun Gothic',sans-serif; letter-spacing:-2px } .latin { fill:#adbee9; font:24px Arial,sans-serif; letter-spacing:4px } .period { fill:#f3cc70; font:600 22px Arial,sans-serif } .note { fill:#a9b7dc; font:16px 'Malgun Gothic',sans-serif } .grid { stroke:#7891c9; stroke-opacity:.18; stroke-width:1 } .star { fill:#fff6c6; } .constellation { fill:none; stroke:#f6d36a; stroke-width:3; stroke-linecap:round; stroke-linejoin:round; filter:url(#glow) } .dso { fill:#d7a4ff; fill-opacity:.65; stroke:#f0c6ff; stroke-width:1.5 } .dso-label { fill:#edccff; font:600 14px Arial,sans-serif; paint-order:stroke; stroke:#101a42; stroke-width:4px; stroke-linejoin:round } .edge { fill:none; stroke:#e5c45f; stroke-width:2 } .legend { fill:#d8e2ff; font:15px 'Malgun Gothic',sans-serif }
  </style>
  <defs><radialGradient id="sky"><stop stop-color="#1d2a65"/><stop offset="1" stop-color="#060b24"/></radialGradient><filter id="glow"><feGaussianBlur stdDeviation="2" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>
  <rect width="1000" height="1414" fill="#060b24"/><rect x="34" y="34" width="932" height="1346" rx="14" fill="url(#sky)" stroke="#f0d47e" stroke-opacity=".6"/>
  <text class="title" x="80" y="125">$($spec.Korean)</text><text class="latin" x="82" y="164">$($spec.Latin.ToUpperInvariant())</text><text class="period" x="920" y="139" text-anchor="end">$($spec.Period)</text>
  <text class="note" x="80" y="218">실제 항성 위치 · J2000 적경/적위 기준</text><text class="note" x="80" y="244">보라색: 딥스카이 천체(메시에·밝은 DSO)</text>
  <rect x="$chartX" y="$chartY" width="$chartW" height="$chartH" fill="#070d2b" fill-opacity=".48" class="edge"/>
  $starMarkup
  $lineMarkup
  $dsoMarkup
  <line x1="80" x2="920" y1="1342" y2="1342" stroke="#8497c8" stroke-opacity=".35"/>
  <text class="legend" x="80" y="1367">별 위치: XHIP (VizieR V/137D) · DSO: Messier/Saguaro DB · 별자리 선: d3-celestial</text>
  <text class="legend" x="920" y="1367" text-anchor="end">과학·수학 축전 천문 동아리</text>
</svg>
"@
  [System.IO.File]::WriteAllText((Join-Path $OutputRoot ("{0}.svg" -f $spec.Id.ToLowerInvariant())), $svg, $utf8NoBom)
}
