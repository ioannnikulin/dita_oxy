rmdir /s /q "C:\Program Files\Oxygen XML Author 24\frameworks\dita\DITA-OT3.x\plugins\com.oxygenxml.codeblock-tabs"
rmdir /s /q "C:\Program Files\Oxygen XML Author 24\frameworks\dita\DITA-OT3.x\plugins\com.oxygenxml.tabbed-codeblock"
mklink /D "C:\Program Files\Oxygen XML Author 24\frameworks\dita\DITA-OT3.x\plugins\com.oxygenxml.codeblock-tabs" "%~dp0\com.oxygenxml.codeblock-tabs"
mklink /D "C:\Program Files\Oxygen XML Author 24\frameworks\dita\DITA-OT3.x\plugins\com.oxygenxml.tabbed-codeblock" "%~dp0\com.oxygenxml.codeblock-tabs"

