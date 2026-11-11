# Cai dat may in Canon LBP2900 (CAPT v3.30) cho Windows 10/11
# Chay qua Cai-May-In.bat (tu dong xin quyen Administrator)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$DrvDir  = Join-Path $Root 'driver'
$Work    = 'C:\CanonLBP2900'
$Is64    = [Environment]::Is64BitOperatingSystem
$Referer = 'https://asia.canon/'

if ($Is64) {
    $ExeName = 'LBP2900_R150_V330_W64_uk_EN_2.exe'
    $Url     = 'https://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwMjc4MjA0&cmp=ACB&lang=EN'
} else {
    $ExeName = 'LBP2900_R150_V330_W32_uk_EN_2.exe'
    $Url     = 'https://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDkwMDAwNzg1NzA3&cmp=ACB&lang=EN'
}

function Step($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "    OK: $m" -ForegroundColor Green }
function Warn($m) { Write-Host "    ! $m" -ForegroundColor Yellow }

try {
    Step "Kiem tra quyen Administrator"
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Can chay bang quyen Administrator. Hay double-click file Cai-May-In.bat"
    }
    Ok "Da co quyen Administrator"

    # 1. Lay file driver (uu tien ban co san trong thu muc driver, neu khong thi tai ve)
    Step "Chuan bi file driver ($ExeName)"
    New-Item -ItemType Directory -Force $Work | Out-Null
    $Exe   = Join-Path $Work $ExeName
    $Local = Join-Path $DrvDir $ExeName
    if (Test-Path $Local) {
        Copy-Item $Local $Exe -Force
        Ok "Dung file co san: $Local"
    } else {
        Warn "Chua co file driver, dang tai tu Canon (~11 MB)..."
        Invoke-WebRequest -Uri $Url -OutFile $Exe -Headers @{ Referer = $Referer } -UserAgent 'Mozilla/5.0' -UseBasicParsing
        Ok "Da tai xong"
    }
    if ((Get-Item $Exe).Length -lt 5MB) { throw "File driver tai ve bi loi (qua nho). Kiem tra mang roi chay lai." }
    if ((Get-AuthenticodeSignature $Exe).Status -ne 'Valid') {
        Warn "File driver khong co chu ky so hop le (ban Canon cu co the nhu vay)."
    }

    # 2. Giai nen (file Canon tu giai nen vao thu muc canh no roi bat Setup)
    Step "Giai nen driver"
    Get-ChildItem $Work -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath $Exe -WorkingDirectory $Work | Out-Null

    $inf = $null
    for ($i = 0; $i -lt 90 -and -not $inf; $i++) {
        Start-Sleep 1
        $inf = Get-ChildItem $Work -Recurse -Filter *.inf -ErrorAction SilentlyContinue |
               Where-Object { Select-String -Path $_.FullName -Pattern 'LBP2900' -Quiet } |
               Select-Object -First 1
    }

    if ($inf) {
        Ok "Tim thay file driver: $($inf.FullName)"
        Start-Sleep 3
        # Dong cua so Setup tu bat de khong bi cai 2 lan
        Get-Process -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -and $_.Path.StartsWith($Work, 'OrdinalIgnoreCase') } |
            Stop-Process -Force -ErrorAction SilentlyContinue

        # 3. Nap driver vao Windows
        Step "Cai driver vao Windows"
        $out = & pnputil.exe /add-driver $inf.FullName /install 2>&1
        $out | ForEach-Object { Write-Host "    $_" }

        # Dang ky driver cho spooler
        $text = Get-Content $inf.FullName -Raw
        $m = [regex]::Matches($text, '"(Canon LBP2900[^"]*)"') | Select-Object -First 1
        $DrvName = if ($m) { $m.Groups[1].Value } else { 'Canon LBP2900' }
        if (-not (Get-PrinterDriver -Name $DrvName -ErrorAction SilentlyContinue)) {
            try { Add-PrinterDriver -Name $DrvName } catch { Warn "Add-PrinterDriver: $($_.Exception.Message)" }
        }
        if (Get-PrinterDriver -Name $DrvName -ErrorAction SilentlyContinue) { Ok "Driver da dang ky: $DrvName" }
    } else {
        Warn "Khong tu giai nen duoc. Trinh cai dat chinh thuc cua Canon dang mo: bam Next/Yes theo huong dan."
        Warn "Khi no hoi, hay cam day USB va bat nguon may in."
        Read-Host "Cai xong bam Enter de tiep tuc"
        $DrvName = 'Canon LBP2900'
    }

    # 4. May in: chi cho may in USB
    Step "Tim may in (hay cam cap USB va BAT NGUON may in)"
    $printer = $null
    for ($i = 0; $i -lt 60 -and -not $printer; $i++) {
        $printer = Get-Printer -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'LBP2900' -or $_.DriverName -match 'LBP2900' } | Select-Object -First 1
        if (-not $printer) {
            $port = Get-PrinterPort -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'USB0*' } | Select-Object -First 1
            if ($port -and (Get-PrinterDriver -Name $DrvName -ErrorAction SilentlyContinue)) {
                try { Add-Printer -Name 'Canon LBP2900' -DriverName $DrvName -PortName $port.Name; Start-Sleep 2 } catch {}
            }
            Start-Sleep 2
        }
    }
    if (-not $printer) { throw "Chua thay may in. Kiem tra cap USB + nguon, roi chay lai script." }
    Ok "May in: $($printer.Name) ($($printer.PortName))"

    # 5. Dat mac dinh, A4, khong de Windows tu doi may in mac dinh
    Step "Dat may in mac dinh"
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows' -Name LegacyDefaultPrinterMode -Value 1 -ErrorAction SilentlyContinue
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($printer.Name)
    try { Set-PrintConfiguration -PrinterName $printer.Name -PaperSize A4 } catch {}
    Ok "Mac dinh: $($printer.Name), kho giay A4"

    # 6. Chuot phai file .md -> Print (dung Notepad)
    Step "Them menu chuot phai 'Print' cho file .md / .markdown"
    foreach ($ext in '.md', '.markdown') {
        $k = "HKCU:\Software\Classes\SystemFileAssociations\$ext\shell\print\command"
        New-Item -Path $k -Force | Out-Null
        Set-ItemProperty -Path $k -Name '(default)' -Value '"%SystemRoot%\System32\notepad.exe" /p "%1"'
    }
    Ok "Da them"

    # 7. In thu
    Step "In trang thu"
    $ans = Read-Host "In trang thu ngay bay gio? (Y/n)"
    if ($ans -notmatch '^[nN]') {
        $test = Join-Path $env:TEMP 'test-canon.txt'
        "Canon LBP2900 - in thu thanh cong`r`n$(Get-Date)`r`nMay: $env:COMPUTERNAME" | Set-Content $test
        Start-Process notepad.exe -ArgumentList '/pt', "`"$test`"", "`"$($printer.Name)`"" -Wait
        Ok "Da gui lenh in. Cho may in keu va nha giay."
    }

    Write-Host "`nXONG! Gio chi can chuot phai file -> Print, hoac Ctrl+P trong ung dung." -ForegroundColor Green
}
catch {
    Write-Host "`nLOI: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Xem muc 'Xu ly su co' trong HUONG-DAN.md" -ForegroundColor Yellow
}
Read-Host "`nBam Enter de dong"
