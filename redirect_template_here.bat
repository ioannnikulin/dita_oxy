FOR %%x in (com.oxygenxml.common com.oxygenxml.highlight com.oxygenxml.media com.oxygenxml.webhelp.common com.oxygenxml.webhelp.responsive) DO (
rmdir /s /q "C:\Program Files\Oxygen XML Editor 24\frameworks\dita\DITA-OT3.x\plugins\%%x"
mklink /D "C:\Program Files\Oxygen XML Editor 24\frameworks\dita\DITA-OT3.x\plugins\%%x" "%~dp0webhelp\%%x"
)