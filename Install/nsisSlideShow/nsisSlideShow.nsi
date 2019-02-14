# 脚本由贾可 (jiake@vip.qq.com) 基于原例子修改编写

# 该插件由 Wizou 开发：http://wiz0u.free.fr/prog/nsisSlideshow/

!ifdef NSIS_UNICODE
!AddPluginDir .\BinU
!else
!AddPluginDir .\BinA
!endif

!include MUI2.nsh

Name nsisSlideShow
Caption nsisSlideShow
OutFile nsisSlideShow.exe
InstallDir $TEMP
SetFont "MS Shell Dlg" 8
ShowInstDetails NeverShow
RequestExecutionLevel admin

!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE ExtractImages
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE SimpChinese

Section -Main
  DetailPrint "正在安装，请稍等。"
  nsisSlideshow::Show /NOUNLOAD /auto=$PLUGINSDIR\Slides.dat
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  Sleep 1000
  nsisSlideshow::Stop
SectionEnd

Function ExtractImages
  InitPluginsDir
  File /oname=$PLUGINSDIR\Slides.dat Slides.dat
  File /oname=$PLUGINSDIR\Slide1.jpg Slide1.jpg
  File /oname=$PLUGINSDIR\Slide2.jpg Slide2.jpg
  File /oname=$PLUGINSDIR\Slide3.jpg Slide3.jpg
FunctionEnd