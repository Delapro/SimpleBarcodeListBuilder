# SimpleBarcodeListBuilder
Erzeugt eine HTML-Seite mit SVG-Barcodes welche aus einer Textdatei stammen. Dazu wird ZINT benötigt, zu finden unter https://sourceforge.net/projects/zint/, bzw. die Anleitung: https://zint.org.uk/.

Aufruf im Verzeichnis wo Zint.EXE und die Testbarcode-Datei liegt:
```Powershell
New-BarcodeHTMLPage -FilePath .\TestBarcodes.Txt -HtmlFilePath .\Sample.Html

# erzeugte Seite öffnen
Start .\Sample.Html
```
