# OpenGFX - 8bpp Graphics Base Set for [OpenTTD](https://www.openttd.org)

## Table of contents

- 1.0 [About](#10-about)
- 2.0 [Downloading](#20-downloading)
- 3.0 [Installing](#30-installing)
  - 3.1 [Installation or update via Online Content service](#31-installation-or-update-via-online-content-service)
  - 3.2 [Manual Installation](#32-manual-installation)
- 4.0 [Reporting bugs and Contributing](#40-reporting-bugs-and-contributing)
  - 4.1 [Reporting bugs](#41-reporting-bugs)
  - 4.2 [Obtaining the source](#42-obtaining-the-source)
  - 4.3 [Building OpenGFX](#43-building-opengfx)
  - 4.4 [Notes for package maintainers](#44-notes-for-package-maintainers)
  - 4.5 [Note on the xcf and psd files](#45-note-on-the-xcf-and-psd-files)
  - 4.6 [Making an OpenGFX release](#46-making-an-opengfx-release)
- 5.0 [License](#50-license)
- 6.0 [Credits](#60-credits)

## 1.0 About

OpenGFX is an open source graphics base set designed to be used by [OpenTTD](https://www.openttd.org).

OpenGFX provides a set of free and open source base graphics, and aims to ensure the best possible out-of-the-box experience with OpenTTD.

The project's home is https://github.com/OpenTTD/OpenGFX.

OpenGFX provides you with...

- all graphics you need to enjoy OpenTTD
- uniquely drawn rail vehicles for every climate
- completely snow-aware rivers
- different river and sea water
- snow-aware buoys

This version of OpenGFX requires OpenTTD 1.2.0 or newer. For older versions of OpenTTD or TTDPatch please use OpenGFX 0.4.1.

## 2.0 Downloading

OpenGFX is available from a few locations. This readme will only cover the official download locations.

We cannot support third party download locations and we cannot refund your money if you have paid money for OpenGFX.

- If you're new to OpenTTD, the easiest way is to use the installer (Windows) or your package manager (Linux) and install OpenTTD, OpenGFX and OpenSFX.
- If you're new to OpenTTD, cannot use an installer and don't have access to the original TTD files, you'll have to follow the manual installation procedure. This is really not as difficult as it may sound, so don't worry too much about it.
- If you already have OpenTTD up and running using the original TTD base graphics, installing OpenGFX using the Online Content Service is the easy way to obtain OpenGFX.

## 3.0 Installing

### 3.1 Installation or update via Online Content service

This method uses the [Online content service (BaNaNaS)](http://bananas.openttd.org/en/) to download OpenGFX. In order to use this OpenGFX version, you need a working OpenTTD and again at least OpenTTD version 1.2.0 or a recent nightly.

1. Start OpenTTD and on the main menu click the Check Online Content button. A new window will pop up. If OpenTTD doesn't start, follow the manual installation procedure.
2. Find the OpenGFX entry from the list at the left. You can use the search box in the upper right corner of the window.
3. Click the little square in front of the OpenGFX entry in order to mark it for download.
4. Click the Download button in the bottom right corner. After download, close the open windows.
5. In the main menu of the game, click the Game Options button. The Game Options dialog will appear.
6. Select OpenGFX from the drop-down list below Base graphics set if that's not selected already (bottom left of window). Close the window using the × in the upper left corner.

### 3.2 Manual Installation

1. First, make sure that you downloaded and installed at least OpenTTD version 1.2.0 or later.
2. Next, download the latest OpenGFX package. There are a few sources:
   - [official](https://www.openttd.org/downloads/opengfx-releases/latest.html)
   - [archive](https://cdn.openttd.org/opengfx-releases/)
3. Unpack the zip file into the OpenTTD's baseset directory (see [section 4.2 of the OpenTTD readme](https://github.com/OpenTTD/OpenTTD#42-openttd-directories) for a detailed treatise on all data dirs OpenTTD recognizes).
There's no need to unpack the tar, so just leave it as it is.
The baseset directories are:
   - Windows:
     - C:\My Documents\OpenTTD\baseset (95, 98, ME)
     - C:\Documents and Settings\<username>\My Documents\OpenTTD\baseset (2000, XP)
     - C:\Users\<username>\Documents\OpenTTD\baseset (Vista, 7, 8, 10)
   - Mac OSX: ~/Documents/OpenTTD/baseset
   - Linux: ~/.openttd/baseset
The `/baseset/` directory inside of the OpenTTD installation can also be used.
4. Run OpenTTD. Chances are that you'll miss a sound set. Get one (we recommend our sister project OpenSFX) and install it into the same directory as OpenGFX.
5. In the main menu of the game, click the Game Options button. The Game Options dialog will appear.
6. Select OpenGFX from the drop-down list below Base graphics set if that's not selected already (bottom left of window). Close the window using the × in the upper left corner.
   - If you did not install the original TTD base graphics during the installation of OpenTTD, you can skip this step.
   - If you installed the original TTD base graphics as well, this is where you can switch base graphic sets.

Now that wasn't so hard, was it?

Anyway, if you're having trouble getting OpenGFX to work, please file a detailed report on what you did, what error messages you got and where you got stuck in the OpenGFX release topic on the [TT-Forums](http://www.tt-forums.net/viewtopic.php?f=36&t=40162) or (preferably) at our [issue tracker](https://github.com/OpenTTD/OpenGFX/issues).

## 4.0 Reporting bugs and contributing

### 4.1 Reporting bugs

If you spot any graphical bugs or glitches in the available graphics, please let us know preferrably via our [issue tracker](https://github.com/OpenTTD/OpenGFX/issues) or via the OpenGFX release topic on the [TT-Forums](http://www.tt-forums.net/viewtopic.php?f=36&t=40162).
Please make sure that you're using the latest available version before reporting a bug. You can check the [issue tracker](https://github.com/OpenTTD/OpenGFX/issues) to see if the bug you've found is already reported (or fixed!).

If you have made yourself improvements to either graphics or the source code itself, please also share that with us either via the [pull request page](https://github.com/OpenTTD/OpenGFX/pulls) or the [development discussion thread](http://www.tt-forums.net/viewtopic.php?f=26&t=38122&start=0).

### 4.2 Obtaining the source

The OpenGFX source is available in a git repository or as gzip'ed tarball. You can do an anonymous checkout from https://github.com/OpenTTD/OpenGFX, e.g. using `git clone https://github.com/OpenTTD/OpenGFX` or obtain the tarball from the [release page](https://github.com/OpenTTD/OpenGFX/releases).

### 4.3 Building OpenGFX

Prerequisites to building OpenGFX:

- gcc (the pre-processor is needed)
- [NML 0.5+](https://github.com/OpenTTD/nml)
- grfid from the [grfcodec package](http://www.openttd.org/download-grfcodec)
- some gnu utils: `make`, `cat`, `sed`, `awk` and you might additionally want a text editor of your choice and a graphics programme suitable to handle palettes.

Optionally, required to re-generated all graphics files from their layered source files after executing `maintainer-clean`:

- [GIMP 2.4](https://www.gimp.org/downloads/) or later

#### Windows

We advise you get a MinGW development environment, NML and git from the sources mentioned above. For more detailed instructions see our guide on the [wiki](http://dev.openttdcoop.org/projects/home/wiki) and the very extensive and detailed installation instructions on the [MinGW wiki](http://www.mingw.org/wiki/Getting_Started).

#### Linux

Your system should already have most tools, you'll probably only need NML and git available from the source mentioned above. For installation instructions concerning git refer to the manual of your distribution.

#### Mac

Install the developers tools and get NML from the source mentioned above. git is easiest installed via MacPorts:
`sudo port install git`

On OSX GIMP is not found in the path, if you installed the app package as supplied from the GIMP's project page. You can add that to your search path if you link the binary which requires the X-environment to be running:
`sudo ln /Applications/Gimp.app/Contents/Resources/bin/gimp /usr/local/bin/gimp`

The use of git is strongly encouraged as only that allows to keep track of
changes.

Once all tools are installed, get a checkout of the repository and you can build OpenGFX using make. The following targets are available:

- `all`: builds all grfs and the obg file
- `install`: build and then copy OpenGFX in your OpenTTD data directory. Use Makefile.local to specify a different path.
- `clean`: cleans all generated files
- `mrproper`: also cleans generated directories
- `maintainer-clean`: clean also the graphics files can be re-generated via GIMP
- `bundle_src`: create a source tarball
- `bundle_zip`: create a zip archive of OpenGFX
- `bundle_bz2`: create a bzip2 archive of OpenGFX
- `bundle_tar`: create a tar archive of OpenGFX
- `check`: checks the md5 sums of the built grf and obg files against those of the official release versions

Given the usual case that you modify something within OpenGFX and want to test that, a simple `make install` should suffice and you can immediately test the changes ingame, if you selected the nightly version of OpenGFX. Given default paths, a `make install` will overwrite a previous nightly version of OpenGFX. Mind to re-start OpenTTD as it needs to re-read the grf files.

### 4.4 Notes for package maintainers

- Checking for build success: The source releases contain an additional file `opengfx-<version>.md5` which indicates the md5 sums of the generated files as released in the binary release. You can check your build by running `make check`. Mind that you'll overwrite the file with the original md5 sums, if you call `make bundle_src` or `make md5`.
- The source release also contains a `Makefile.local` and a slightly appended `Makefile.def`, both supplying additional variable definitions which otherwise would be determined by accessing repository properties.
- The variable which supplies the install path changed for the sake of consistency and better readability to `INSTALL_DIR`. The old `INSTALLDIR` still works but is deprecated.

### 4.5 Note on the .xcf and .psd files

The repository contains a few `.xcf2png` files which indicate which png files can be generated from the source `.xcf` or `.psd` files. This will only be used, if GIMP is found. Calling `maintainer-clean` will delete the png files which can be re-generated from a `.xcf` or `.psd` file.

### 4.6 Making an OpenGFX release

1. Check that all relevant PRs are approved and merged.
2. Update the changelog.
This is done manually, and commits are grouped by type.
Example: https://github.com/OpenTTD/OpenGFX/blob/master/changelog.txt
3. Decide what the version number will be.
4. Publish a new release using the release tool in the Github project: https://github.com/OpenTTD/OpenGFX/releases/new
5. GitHub Actions will build the release and publish to OpenTTD CDN.
6. Ask TrueBrain to update the OpenGFX for NSIS Windows installer.
7. Upload the release manually to BaNaNaS.
The openttdcoop BaNaNaS account is usually used for this.

## 5.0 License

OpenGFX Graphics Base Set for OpenTTD
Copyright (C) 2007-2016 by the OpenGFX team (see [credits section](#60-credits) below)

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License version 2 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the

Free Software Foundation, Inc.
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

## 6.0 Credits

OpenGFX is created by the following people (in reverse alphabetical order):

| Name              | Realname              |
| ----------------- | --------------------- |
| Zuu               | Leif Linse            |
| Zephyris          | Richard Wheeler       |
| Varivar           | N/A                   |
| V453000           | Vaclav Benc           |
| uzurpator         | N/A                   |
| supermop          | N/A                   |
| Spaz O Mataz      | N/A                   |
| Soeb              | Stanislaw Gackowski   |
| Snail             | Jacopo Coletto        |
| skidd13           | Benedikt Brüggemeier  |
| Rubidium          | Remko Bijker          |
| Roujin            | Manuel Wolf           |
| Red*Star          | David Krebs           |
| Raumkraut         | Mel Collins           |
| Purno             | Mark Leppen           |
| planetmaker       | Ingo von Borstel      |
| PikkaBird         | David Dallaston       |
| PaulC             | Paul Charlesworth     |
| orudge            | Owen Rudge            |
| oberheumer        | N/A                   |
| northstar2        | N/A                   |
| Mr. X             | N/A                   |
| mph               | Matthew Haines        |
| molace            | Zoltán Molnár         |
| michi_cc          | Michael Lutz          |
| mb                | Michael Blunck        |
| mart3p            | N/A                   |
| LordAzamath       | Johannes Maids Aasmäe |
| lead@inbox        | Serge Saphronov       |
| Lawton27          | Jack Lawton           |
| Jonha             | N/A                   |
| Irwe              | Alexander Irwe        |
| Gwyd              | N/A                   |
| George            | N/A                   |
| Gen.Sniper        | N/A                   |
| frosch            | Christoph Elsenhans   |
| Froix             | N/A                   |
| Foobar            | Jasper Vries          |
| erikjanp          | N/A                   |
| EdorFaus          | Frode Austvik         |
| drginaldee        | N/A                   |
| DJ Nekkid         | Thomas Mjelva         |
| DanMacK           | Dan MacKellar         |
| buttercup         | N/A                   |
| bubersson         | Petr Mikota           |
| Born Acorn        | Chris Jones           |
| Brumi             | N/A                   |
| Bilbo             | N/A                   |
| BenK              | N/A                   |
| Ben_Robbins_      | Ben Robbins           |
| athanasios        | Athanasios Palaiologos|
| andythenorth      | Andrew Parkhouse      |
| AndersI           | Anders Isaksson       |
| Ammler            | Marcel Gmür           |
| 2006TTD           | Anthony Lam           |

- The monospaced characters are generated from the font Liberation Mono: https://www.redhat.com/promo/fonts/ created by Pravin Satpute and Caius Chance, released under GPL v2.

Contact: `planetmaker@openttd.org` or on `irc.oftc.net/#openttd`

A detailed list of who worked on what is available in the file [docs/authoroverview.csv](https://github.com/OpenTTD/OpenGFX/blob/master/docs/authoroverview.csv) in the source repository.
