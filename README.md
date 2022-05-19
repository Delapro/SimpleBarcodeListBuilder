# SimpleBarcodeListBuilder
Erzeugt eine HTML-Seite mit SVG-Barcodes welche aus einer Textdatei stammen. Dazu wird ZINT benötigt, zu finden unter https://sourceforge.net/projects/zint/, bzw. die Anleitung: https://zint.org.uk/.

> Hinweis: Die Barcodes müssen mit einem AIM Präfix versehen sein, damit der passende Barcode erzeugt werden kann, außerdem sind nur einfache DataMatrix (]d1) und Code128 (]C0) Varianten aktuell implementiert. Aber der Rumpf steht...

Aufruf im Verzeichnis wo Zint.EXE und die Testbarcode-Datei liegt:
```Powershell
# Funktionen laden
. .\Barcodes.PS1

# Barcodes und Seite erzeugen
New-BarcodeHTMLPage -FilePath .\TestBarcodes.Txt -HtmlFilePath .\Sample.Html

# erzeugte Seite öffnen
Start .\Sample.Html
```
