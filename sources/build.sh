#!/bin/bash
set -e
# Builds variable and static fonts.
#
# All steps needed to build new fonts are contained within
# this script, so font builds are repeatable and documented.
#
# Requirements: Python3[3] and a Unix-like environment
# (Linux, MacOS, Windows Subsystem for Linux, etc),
# with a Bash-like shell(most Unix terminal applications).
#
# All Python dependencies will be installed in a temporary
# virtual environment by the script. If you want to setup your own
# virtual environment, disable the setting in the settings section
# of this script.
#
# To build new fonts, open a terminal in the root directory
# of this project(Git repository) and run the script:
#
# $ sh build.sh
#
# Also, if you are updating the font for Google Fonts, you can
# use the "-gf" flag to run additional pull-request-helper
# commands as well. Just remember to change the "GOOGLE_FONTS_DIR"
# file path constant if you aren't building to ~/Google/fonts/ofl/.../:
#
# $ sh build.sh -gf
#
# The default settings should produce output that will conform
# to the Google Fonts Spec [1] and pass all FontBakery QA Tests [2].
# However, the Build Script Settings below are designed to be easily
# modified for other platforms and use cases.
#
# See the GF Spec [1] and the FontBakery QA Tool [2] for more info.
#
# Script by Eli H. If you have questions, please send an email [4].
#
# [1] https://github.com/googlefonts/gf-docs/tree/master/Spec
# [2] https://pypi.org/project/fontbakery/
# [3] https://www.python.org/
# [4] elih@protonmail.com

##################
# BUILD SETTINGS #
##################

alias ACTIVATE_PY_VENV=". BUILD_VENV/bin/activate"  # Starts a Python 3 virtual environment when invoked
GOOGLE_FONTS_DIR="~/Google/fonts"                   # Where is Google Fonts repo is cloned: https://github.com/google/fonts
OUTPUT_DIR="google-fonts"                           # Where the output from this script goes
FAMILY_NAME="Ferrite Core DX"                       # Font family name for output files
MAKE_NEW_VENV=true                                  # Set to `true` if you want to build and activate a python3 virtual environment
BUILD_STATIC_FONTS=true                             # Set to `true` if you want to build static fonts
#AUTOHINT=false                                     # Set to `true` if you want to use auto-hinting (ttfautohint)
NOHINTING=true                                      # Set to `true` if you want the fonts unhinted

#################
# BUILD PROCESS #
#################

echo "\n* ** **** ** * FERRITE CORE DX BUILD SCRIPT * ** **** ** *"
echo "[INFO] Build start time: \c"
date

if [ "$1" = "-gf" ]; then
  echo "\n[INFO] Preparing a pull request to Google Fonts at: $GOOGLE_FONTS_DIR";
fi

if [ "$MAKE_NEW_VENV" = true ]; then
  echo "[INFO] Building a new Python3 virtual environment"
  python3 -m venv BUILD_VENV > /dev/null
  echo "[INFO] Activating the Python3 virtual environment"
  ACTIVATE_PY_VENV > /dev/null
  echo "[INFO] Python3 setup..."
  pip install --upgrade pip > /dev/null
  pip install --upgrade fontmake > /dev/null
  #pip install --upgrade fonttools > /dev/null
  pip install --upgrade git+https://github.com/googlefonts/gftools > /dev/null
  which python  # Test to see if the VENV setup worked
  echo "[INFO] Done with Python3 virtual environment setup"
  echo ""
fi

mkdir -p google-fonts

fontmake -g sources/FerriteCoreDX-GF.glyphs -o variable \
    --output-path google-fonts/FerriteCoreDX\[wght\].ttf

# gftools hotfixes
# fixes fontbakery check: com.google.fonts/check/drig
gftools fix-dsig -f google-fonts/*.ttf > /dev/null
# fixes fontbakery check: com.google.fonts/check/smart_dropout
gftools fix-nonhinting google-fonts/FerriteCoreDX\[wght\].ttf google-fonts/temp.ttf > /dev/null
mv google-fonts/temp.ttf google-fonts/FerriteCoreDX\[wght\].ttf
rm -rf google-fonts/*backup-fonttools-prep-gasp.ttf

echo "[INFO] Cleaning up build files..."
rm -rf master_ufo BUILD_VENV

# GOOGLE FONTS FLAG ONLY SECTION
# METADATA
metadata='name: "Ferrite Core DX"
designer: "OFL"
license: "OFL"
category: "SERIF"
date_added: "2020-07-13"
fonts {
  name: "Ferrite Core DX"
  style: "normal"
  weight: 400
  filename: "FerriteCoreDX[wght].ttf"
  post_script_name: "FerriteCoreDX"
  full_name: "Ferrite Core DX"
  copyright: "Copyright 2019 The Ferrite Core DX Project Authors (https://github.com/froyotam/ferrite-core)"
}
subsets: "latin"
subsets: "menu"
subsets: "vietnamese"
axes {
  tag: "wght"
  min_value: 400.0
  max_value: 900.0
}'

if [ "$1" = "-gf" ]; then
  echo ""
  echo "[INFO] Preparing a pull request to Google Fonts at ~/Google/fonts/ofl";
  cp ../DESCRIPTION.en_us.html $GOOGLE_FONTS_DIR/ofl/ferritecoredx/
  cp ../FONTLOG.txt $GOOGLE_FONTS_DIR/ofl/ferritecoredx/
  echo "$metadata" > $GOOGLE_FONTS_DIR/ofl/ferritecoredx/METADATA.pb
  cp ../OFL.txt $GOOGLE_FONTS_DIR/ofl/ferritecoredx/
  cp google_fonts/FerriteCoreDX\[wght\].ttf $GOOGLE_FONTS_DIR/ofl/ferritecoredx/
fi

echo "[INFO] Done!😃"
