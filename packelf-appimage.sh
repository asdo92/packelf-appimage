#!/bin/bash

# Author: q3aql@duck.com
# Pack elf binary and it's dependencies into standalone executable using appimagetool
# License: GPLv2.0
# Require: https://github.com/AppImage/appimagetool/releases
#
# Note: packelf-appimage was inspired by https://github.com/oufm/packelf

# Check dependencies
path_check="/usr/bin /bin /usr/local/bin ${HOME}/.local/bin $(brew --prefix 2> /dev/null)/bin"
dependencies="ldd grep sed basename bash echo appimagetool mktemp pwd"
dependencies_found=""
dependencies_not_found=""
for checkPath in ${path_check} ; do
  for checkDependencies in ${dependencies} ; do
    if [ -f ${checkPath}/${checkDependencies} ] ; then
      dependencies_found="${dependencies_found} ${checkDependencies}"
    fi
  done
done
for notFound in ${dependencies} ; do
  check_found_one=$(echo ${dependencies_found} | grep " ${notFound}")
  check_found_two=$(echo ${dependencies_found} | grep "${notFound} ")
  if_not_found="${check_found_one}${check_found_two}"
  if [ -z "${if_not_found}" ] ; then
    dependencies_not_found="${dependencies_not_found} ${notFound}"
  fi
done
# Show if all tools are installed
if [ -z "${dependencies_not_found}" ] ; then
  echo > /dev/null
else
  echo "${0}: Some required tools are not installed:${dependencies_not_found}"
  exit 1
fi

# Create desktop file for appimage
# Sintax: create_desktop_file <DESKTOP_FILE_PATH> <NAME_DESKTOP_FILE>
create_desktop_file() {
  desktop_file_path="${1}"
  desktop_file_name="${2}"
  # Create desktop file
  echo "[Desktop Entry]" > ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Type=Application" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Name=${desktop_file_name}" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Icon=${desktop_file_name}" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Exec=${desktop_file_name}" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Terminal=false" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "Categories=System;" >> ${desktop_file_path}/${desktop_file_name}.desktop
  echo "StartupWMClass=mpv" >> ${desktop_file_path}/${desktop_file_name}.desktop
  # Create icon for desktop file
  echo '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" version="1">' > ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <rect style="opacity:0.2" width="40" height="40" x="4" y="5" rx="12" ry="12"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <rect style="fill:#e4e4e4" width="40" height="40" x="4" y="4" rx="12" ry="12"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <path style="opacity:0.2;fill:#ffffff" d="M 16,4 C 9.352,4 4,9.352 4,16 v 1 C 4,10.352 9.352,5 16,5 h 16 c 6.648,0 12,5.352 12,12 V 16 C 44,9.352 38.648,4 32,4 Z"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <path style="fill:#3084e9" d="M 17 12 A 5 5 0 0 0 12 17 A 5 5 0 0 0 17 22 L 31 22 L 31 12 L 17 12 z"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <path style="fill:#aeaeae" d="M 17 26 L 17 36 L 31 36 A 5 5 0 0 0 36 31 A 5 5 0 0 0 31 26 L 17 26 z"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <path style="opacity:0.1" d="M 17 12 A 5 5 0 0 0 12 17 A 5 5 0 0 0 12.027344 17.515625 A 5 5 0 0 1 17 13 L 31 13 L 31 12 L 17 12 z M 17 26 L 17 27 L 31 27 A 5 5 0 0 1 35.972656 31.484375 A 5 5 0 0 0 36 31 A 5 5 0 0 0 31 26 L 17 26 z"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <path style="opacity:0.2" d="M 31 13 A 5 5 0 0 0 26 18 A 5 5 0 0 0 31 23 A 5 5 0 0 0 36 18 A 5 5 0 0 0 31 13 z M 17 27 A 5 5 0 0 0 12 32 A 5 5 0 0 0 17 37 A 5 5 0 0 0 22 32 A 5 5 0 0 0 17 27 z"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <circle style="fill:#ffffff" cx="31" cy="17" r="5"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo ' <circle style="fill:#ffffff" cx="17" cy="31" r="5"/>' >> ${desktop_file_path}/${desktop_file_name}.svg
  echo '</svg>' >> ${desktop_file_path}/${desktop_file_name}.svg
}

# Check if file exist
if [ ! -z "${1}" ] ; then
  if [ ! -f "${1}" ] ; then
    echo "${0}: File ${1} does not exist"
    exit 1
  else
    libs="$(ldd "${1}" | grep -F '/' | sed -E 's|[^/]*/([^ ]+).*?|/\1|')"
    ld_so="$(echo "$libs" | grep -F '/ld-linux-' || echo "$libs" | grep -F '/ld-musl-' || echo "$libs" | grep -F '/ld.so')"
    ld_so="$(basename "$ld_so")"
    program="$(basename "${1}")"
    if [ -z "${libs}" ] ; then
      echo "${0}: Not a dynamic executable"
      exit 1
    fi
  fi
else
  echo "Usage: ${0} <ELF_SRC_PATH> <ELF_DST_PATH>"
  exit 0
fi

# Check if destination file exist
if [ -z "${2}" ] ; then
  echo "Usage: ${0} <ELF_SRC_PATH> <ELF_DST_PATH>"
  exit 0
else
  temp_dir=$(mktemp -d)
  echo "Creating static binary ${2} from ${1}"
  cp -L ${1} ${temp_dir}/ 
  for libraries in ${libs} ; do
    echo "Linking library ${libraries}"
    cp -L ${libraries} ${temp_dir}/
  done
  echo "Creating executable linker"
  echo "#!/usr/bin/env sh" > ${temp_dir}/AppRun
  echo "" >> ${temp_dir}/AppRun
  echo "\$(dirname \$0)/${ld_so} --library-path \$(dirname \$0) \$(dirname \$0)/${program} \"\$@\"" >> ${temp_dir}/AppRun
  create_desktop_file "${temp_dir}" "${program}"
  chmod 777 -R "${temp_dir}"
  echo "Building static binary in ${2}"
  appimagetool ${temp_dir} "${2}" &> /dev/null
  rm -rf ${temp_dir}
  if [ -f "${2}" ] ; then
    echo "Created successfully"
  else
    echo "FAILED!"
    exit 1
  fi
fi

