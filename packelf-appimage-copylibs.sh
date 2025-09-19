#!/usr/bin/env sh

# Author: asdo92@duck.com                                                                                                                                                                                             
# Pack elf binary and it's dependencies into standalone executable using appimagetool                                                                                                                                
# License: GPLv2.0                                                                                                                                                                                                   
# Require: https://github.com/AppImage/appimagetool/releases

if [ -z "${1}" ] ; then
  echo "$0 <ELF_SRC_PATH> <PATH_TO_COPY_LIBRARIES>"
  exit 0
else
  if [ -z "${2}" ] ; then
    echo "$0 <ELF_SRC_PATH> <PATH_TO_COPY_LIBRARIES>"
    exit 0
  else
    libs="$(ldd "${1}" | grep -F '/' | sed -E 's|[^/]*/([^ ]+).*?|/\1|')"
    for library in ${libs} ; do
      cp -L ${library} ${2}
      echo "Copied ${library} to ${2}"
    done
  fi
fi
