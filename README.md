# Particle CLI Installer
[Download the most recent release.](https://github.com/mumblepins/Particle-CLI-Installer/releases/latest)

An installer to make the setup of the [Particle CLI](https://github.com/spark/particle-cli) easier.  Uses the NSIS installer to download and install the components for Windows.  Checks against [`sources.json`](https://github.com/mumblepins/Particle-CLI-Installer/blob/master/sources.json) for latest version.  

###Components
* Installs the [Particle CLI](https://github.com/spark/particle-cli) and all prerequisites necessary
  * [NodeJS](https://nodejs.org/)
  * If required (not as thoroughly tested, only needed if NPM can't use precompiled binaries for some Particle CLI requirements)
	  * Visual Studio Community 2015
	  * [Python](https://www.python.org/)
* [dfu-util](http://dfu-util.sourceforge.net/)
* [Zadig](http://zadig.akeo.ie/)

The installer will also add the necessary paths to the user PATH environment variable

###Process
1. Run installer, leave all components checked for default install
2. If you installed Zadig, run it from `%InstallDir%\Tools\` with your particle device plugged in and set to DFU mode to replace the USB driver
2. Once everything is done, run a command prompt, type `particle login`, and log into the cloud

##License
* All packages are copyright their respective owners.  See individual websites for details.
* Installation files are released under the ISC license
