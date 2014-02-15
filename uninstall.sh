#!/bin/bash

uninstallonubuntu () {
  # do the bizz
  [[ "$USER" != "root" ]] && {
    echo "Error: Script must be runned with root access. Use sudo."; exit 1;
  }
  rm -v /usr/bin/fruitpeeler
  rm -v /usr/local/bin/fruitpeeler
  rm -v "$HOME/Desktop/fruitpeeler.desktop"
  # rm -v /usr/share/applications/fruitpeeler.desktop
  # rm -v /usr/share/pixmaps/ZIP-File-icon_48.png
}

uninstalloncygwin () {
  rm -v /usr/bin/fruitpeeler
  rm -v /usr/local/bin/fruitpeeler
  rm -v "$HOME/.bashrcfruitpeeler"
  rm -v "$(cygpath "$USERPROFILE")/Desktop/FruitPeeler.bat"

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

[ -z $mydistro ] && { echo "ERROR: Unable to determine distro"; exit 1; }
[[ "$mydistro" == "Ubuntu" ]] && { uninstallonubuntu; }
[[ "$mydistro" == "Cygwin" ]] && { uninstalloncygwin; }

answer=""
read -n1 -p"Do you want to remove config including all passwords? (y/n) " answer
echo ""
[[ "$answer" == "y" ]] && {
  [ -f "$HOME/.fruitpeeler" ] && { rm -v "$HOME/.fruitpeeler"; };
  [ -f "$HOME/.crackdpck" ] && { rm -v "$HOME/.crackdpck"; };
}
 
exit 0;

