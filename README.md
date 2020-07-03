# knossos_installer
This is a script I created for a system restore procedure during a fresh install. When upgrading from Ubuntu 18.04 to Kubuntu 20.04 I found that knossos did not have a release file. So I decided to build from source but I carefully documented and scripted the steps as part of a larger script that reinstalls all of my common programs and settings.

Each stage of the script will confirm if you want to continue, giving you the option to stop should errors occur.

The script will ask where you want to install, it is recommended to keep the default. The files will be copied and built in-place. You will be given the option to install the knossos version included with this script or pull the latest version.

# Packages for Reference (installed automatically):
<pre>
  nodejs
  npm
  python3-wheel
  python3-setuptools
  pyqt5-dev
  pyqt5-dev-tools
  qttools5-dev-tools
  qt5-default
  pipenv
  yarn
  ninja-build
</pre>

# Addons
This is a launcher for Freespace Open and game created using the FSO engine. The launcher has the ability to add and remove games. The following is a list of my preferred games.

<pre>
  Freespace Open
  Freespace 2
  Diaspora
  Solaris
</pre>
