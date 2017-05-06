REM This patch file will install in a Windows 10 based computer
REM all the software required to work.
REM With this environment, you can use a Linux VM easily and also
REM develop with Python, PHP, C++, C#

REM Install all the required software
choco install -y git googlechrome firefox python2 python pycharm-community git putty notepadplusplus winscp filezilla vim emacs sublimetext3 ccleaner

REM Visual Studio
choco install -y visualstudio2017Community visualstudio2017-workload-vctools visualstudio2017-workload-manageddesktop visualstudio2017-workload-netweb

REM Virtualization software
choco install -y virtualbox

REM PHP related stuff
choco install -y php