#!/bin/bash
installfailed () { echo "Installation failed. Exitting."; exit 1; }

installonubuntu () {
  # do the bizz
  [[ "$USER" != "root" ]] && {
    echo "Error: Script must be runned with root access. Use sudo."; exit 1;
  }
  installperl=0
  installperltk=0
  installp7zip=0
  installunrar=0
  if hash perl >/dev/null 2>&1; then
    echo "You have perl ... OK"
  else
    answer=""
    read -n1 -p"PERL is missing, install it now? (y/n)" answer
    echo ""
    echo ""
    [[ "$answer" == "y" ]] || { installfailed; }
    [[ "$answer" == "y" ]] && { installperl=1; }
  fi
  if dpkg -s perl-Tk 2>&1|grep "Status: install ok" >/dev/null; then
    echo "You have perl-tk ... OK"
  else
    answer=""
    read -n1 -p"The package perl-tk is needed, install it now? (y/n) " answer
    echo ""
    [[ "$answer" == "y" ]] || { installfailed; }
    [[ "$answer" == "y" ]] && { installperltk=1; }
  fi
  if dpkg -s p7zip-full 2>&1|grep "Status: install ok" >/dev/null; then
    echo "You have p7zip-full ... OK"
  else
    answer=""
    read -n1 -p"The package p7zip-full is needed, install it now? (y/n) " answer
    echo ""
    [[ "$answer" == "y" ]] || { installfailed; }
    [[ "$answer" == "y" ]] && { installp7zip=1; }

  fi
  if dpkg -s unrar 2>&1|grep "Status: install ok" >/dev/null; then
    echo "You have unrar ... OK"
  else
    if dpkg -s rar 2>&1|grep "Status: install ok" >/dev/null; then
      echo "Unrar not found. Found rar instead ... OK"
    else
      answer=""
      echo "You have either rar or unrar packages. We need one of those."
      read -n1 -p"Install package unrar now? (y/n) " answer
      echo ""
      [[ "$answer" == "y" ]] || { installfailed; }
      [[ "$answer" == "y" ]] && { installunrar=1; }
    fi
  fi

  [[ $installperl -eq 1 || $installperltk -eq 1 || $installp7zip -eq 1 || $installunrar -eq 1 ]] && {
    echo " ------- launching apt-get"
  }
  [[ $installperl -eq 1 ]] && { apt-get install perl; }
  [[ $installperltk -eq 1 ]] && { apt-get install perl-tk; }
  [[ $installp7zip -eq 1 ]] && { apt-get install p7zip-full; }
  [[ $installunrar -eq 1 ]] && { apt-get install unrar; }

  [[ $installperl -eq 1 || $installperltk -eq 1 || $installp7zip -eq 1 || $installrar -eq 1 ]] && {
    echo " ------- end of apt-get"
  }
  dpkg -s zenity 2>&1|grep "Status: install ok" >/dev/null || {
    apt-get install zenity;
  }

  hash perl >/dev/null 2>&1 || { echo >&2 "PERL must be installed."; installfailed; }
  #echo "#!"$(command -v perl) >/usr/bin/fruitpeeler || { echo "Try run with sudo?"; installfailed; }
  cat fruitpeeler.pl >/usr/bin/fruitpeeler || { installfailed; }
  chmod 715 /usr/bin/fruitpeeler || { installfailed; }

  if [ -d /usr/share/pixmaps ] ; then
    cp -v ./ZIP-File-icon_48.png /usr/share/pixmaps || { echo "Unable to copy icon image"; }
    if [ -d $HOME/Desktop ] ; then
      cp -v ./fruitpeeler.desktop $HOME/Desktop
      chmod 715 $HOME/Desktop/fruitpeeler.desktop
      chown $SUDO_USER $HOME/Desktop/fruitpeeler.desktop
    else
      echo "Unable to locate folder \$HOME/Desktop. No icons copied."
      fail=1
    fi
  else
    echo "Unable to locate folder /usr/share/pixmaps. No icons copied."
    fail=1
  fi
  [ $fail -eq 1 ] && {
    echo "Script encountered trouble with installing icons."
    echo "FruitPeeler can be launched by writing the command \"fruitpeeler\".";
  }

}

installoncygwin () {
  failinstall=0
  hash perl >/dev/null 2>&1 && { echo "You have perl..OK"; } || { echo >&2 "Error: PERL must be installed."; failinstall=1; }
  cygcheck xinit >/dev/null 2>&1 && { echo "You have xinit (X11 server)..OK"; } || {
    echo "ERROR: You need to install the X11 package xinit.";
    echo "See http://x.cygwin.com/ for more installation instructions."
    failinstall=1;
  }
  cygcheck -c perl-tk|grep "OK" >/dev/null 2>&1 && { echo "You have perl-tk..OK"; } || {
    echo "ERROR: You need to install the perl-tk package.";
    failinstall=1;
  }
  cygcheck -c p7zip|grep "OK" >/dev/null 2>&1 && { echo "You have p7zip..OK"; } || {
    echo "ERROR: You need to install the p7zip package.";
    failinstall=1;
  }
  cygcheck -c perl-Win32-GUI|grep "OK" >/dev/null 2>&1 && { echo "You have perl-Win32-GUI..OK"; }|| {
    echo "RECOMENDED: You can install perl-Win32-GUI package to get the propper BrowseForFile dialog.";
    echo "Without that package you'll get the UUGLAAY chooseDirectory dialog that comes with Perl-Tk.";
    [[ $failinstall -eq 0 ]] && { echo "Run Setup.exe to install packages."; }
  }
  [[ $failinstall -eq 1 ]] && { echo "Run Setup.exe to install packages.";
    installfailed;
  }
  echo "Installing fruitpeeler script -> /usr/bin/fruitpeeler"
  #echo "#!"$(command -v perl) >/usr/bin/fruitpeeler || { installfailed; }
  cat fruitpeeler.pl >/usr/bin/fruitpeeler || { installfailed; }
  chmod 715 /usr/bin/fruitpeeler || { installfailed; }
  read -n1 -p"Do you want a launch icon (bat) on your desktop? (y/n) " answer
  echo ""
  [ "$answer" == y ] && {
    echo "Writing to a bashrc config -> $HOME/.bashrcfruitpeeler"
		echo "unset TMP">$HOME/.bashrcfruitpeeler
    echo "unset TEMP" >>$HOME/.bashrcfruitpeeler
    echo "nice -10 fruitpeeler" >>$HOME/.bashrcfruitpeeler
    echo "Writing to a bat file on desktop -> "$(cygpath "$USERPROFILE")"/Desktop/FruitPeeler.bat"
    echo "C:\cygwin\bin\bash.exe --login -i .bashrcfruitpeeler" >"$(cygpath "$USERPROFILE")/Desktop/FruitPeeler.bat"
  }
}
#http://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script

echo "Install-script for FruitPeeler."
fail=0

# Determine OS
hash uname >/dev/null 2>&1 && { unamis=$(uname -a); }
if [ -n "$unamis" ]; then
	[[ "$unamis" == CYGWIN* ]]  && { mydistro="Cygwin"; }
	[[ "$unamis" == *Ubuntu* ]] && { mydistro="Ubuntu"; }
else
	[[ "$OS" == *Windows* ]] && { mydistro="Cygwin"; }
fi

[ -z $mydistro ] && { echo "ERROR: Unable to determine distro"; installfailed; }
[[ "$mydistro" == "Ubuntu" ]] && { installonubuntu; }
[[ "$mydistro" == "Cygwin" ]] && { installoncygwin; }

# clean up
[ -f /usr/bin/crackdpck ] && { rm -v /usr/bin/crackdpck; }
[ -f /usr/bin/crackDpck.pl ] && { rm -v /usr/bin/crackDpck.pl; }
if [ -f $HOME/.crackDpck ] ; then
  [ -f $HOME/.fruitpeeler ] || { mv -v $HOME/.crackDpck $HOME/.fruitpeeler; }
fi

echo "Installation successful."
exit 0;

