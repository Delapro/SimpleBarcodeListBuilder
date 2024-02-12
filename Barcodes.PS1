Function Get-BarcodeInfo ($barcode) {

  $type = 'unbekannt'

  # https://support.honeywellaidc.com/s/article/List-of-barcode-symbology-AIM-Identifiers
  switch ($barcode.SubString(0, 3)) {
    ']A0' {$type='Code39'}     # No check character nor Full ASCII processing.
    ']C0' {$type='Code128'}    # Standard. No FNC1 in first or second symbol character position after start character.
    ']E0' {$type='UPC/EAN'}    # Standard packet in full EAN country code format, which is 13 digits for UPC-A and UPC-E
    ']I0' {$type='Interleave2of5'}  # No check digit processing.
    ']O4' {$type='Codablock F'}     # FNC1 not used
    ']Q0' {$type='QR Code'}         # Model 1 symbol.
    ']Q1' {$type='QR Code'}         # Model 2 (QR Code 2005), ECI protocol **not** implemented.
    ']d0' {$type='Data Matrix'}     # ECC 000-140.
    ']d1' {$type='Data Matrix'}     # ECC 200.
    ']d2' {$type='Data Matrix GS1'}     # ECC 200, FNC1 in first or fifth position.  GS1 Datamatrix
    ']d7' {$type='Data Matrix Rectangular Extension (DMRE)'}  # siehe https://github.com/zxing-cpp/zxing-cpp/issues/346#issuecomment-1164127712
    ']d8' {$type='Data Matrix Rectangular Extension (DMRE) GS1'}  # GS1 noch nicht bestätigt, aber analog zu ]d2 von den Einstellungen
    ']e0' {$type='GS1'}             # GS1 DataBar / GS1 DataBar Limited / GS1 Databar Expanded
  }
  [PSCustomObject]@{Barcode=$barcode.SubString(3);AIM=$barcode.SubString(0,3);Type=$type;RawBarcode=$barcode}
}

# gibt ein Array mit den Parametern für den Zint.exe-Aufruf zurück passend zum übergebenen Barcode und Dateinamen
Function Get-ZintCLArguments ($barcodeInfo, $filePath) {

  $gs1 = $null
  $dmre= $null

  switch ($barcodeInfo.AIM) {
    ']C0'  {$type=20}
    ']d1'  {$type=71}
    ']d2'  {$type=71; $gs1=$true}
    ']d7'  {$type=71; $dmre=$true}
    ']d8'  {$type=71; $dmre=$true; $gs1=$true}
  }

  '-o'
  $filePath
  "--barcode=$type"
  If ($gs1) {
	"--gs1"
        # TODO: AIs bei $barcodeInfo.barcode müssen noch mit [] umfasst werden
        # braucht z. B. [01]04223323323236
	# RS/GS noch abklären, wie die angegeben werden
  }
  If ($type -eq 71) {
	If ($dmre) {
	  "--dmre" # sucht sich automatisch die passende version, sonst --vers 31-48
	} else {
	  "--square"  # erzwingt die Erzeugung von quadratischen Datamatrix Codes
	}
  }
  '-d'
  "$($barcodeInfo.barcode)"

}

Function New-BarcodeHTMLPage ($FilePath, $HtmlFilePath) {

  # Barcodedaten lesen und Barcodes erzeugen
  $bc=Get-Content $FilePath
  $bcn=$bc| % {$i=0} {$bi=Get-BarcodeInfo $_; $bi| Add-Member -Type NoteProperty -Name 'Index' -Value $i; $i++; $bi}
  $bcn | % {Start-Process -FilePath '.\Zint.exe' -ArgumentList (Get-ZintCLArguments $_ "BC$($_.Index).svg") -NoNewWindow; "BC$($_.Index).svg" }

  # Nun die erzeugten Barcodes in eine HTML-Seite einbetten
  $htmlPicture=''
  $htmlBegin='<html><body><style>.Barcode {padding: 150px;} .Rand {padding: 20px;} p {line-height: 200%;} </style>'
  $bcn | % {$htmlPicture+="<section><div class='Barcode'><img src='.\BC$($_.Index).svg' class='Rand'>$($_.Barcode)</div></section>"}
  $htmlEnd='</body></html>'
  "$htmlBegin$htmlPicture$htmlEnd" | Set-Content $HtmlFilePath
}
