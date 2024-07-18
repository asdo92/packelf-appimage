#!/usr/bin/env sh

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
  echo 'pngfile' > ${desktop_file_path}/${desktop_file_name}.png
}

# Check if folder exist
if [ -z "${1}" ] ; then
  echo "Usage: ${0} <FOLDER> <FILENAME> <EXECUTABLE_RUN>"                                                                                                                                                            
  exit 0
else
  if [ ! -d "${1}" ] ; then
    echo "${0}: Folder ${1} does not exist"
    exit 1
  fi
fi

# Check if destination file exist
if [ -z "${3}" ] ; then
  echo "Usage: ${0} <FOLDER> <FILENAME> <EXECUTABLE_RUN>"
  exit 0
else
  folder=${1}
  filename=${2}
  executable_run=${3}
  current_dir=$(pwd)
  cd ${folder}
  desktop_exist=$(ls -1 *.desktop 2> /dev/null | wc -l)
  if [ ${desktop_exist} -eq 0 ] ; then
    create_desktop_file $(pwd) "default"
  fi
  cd ${current_dir}
  chmod 777 -R "${folder}" 2> /dev/null
  echo "Creating static binary ${2} from folder ${1}"
  echo "Creating executable linker"
  cd ${folder}
  if [ ! -f AppRun ] ; then
    ln -s ${executable_run} AppRun
  fi
  cd ${current_dir}
  echo "Building static binary in ${2}"
  ARCH=$(arch) appimagetool ${folder} "${filename}" > /dev/null 2> /dev/null
  rm -rf ${temp_dir}
  if [ -f "${2}" ] ; then
    echo "Created successfully"
  else
    echo "FAILED!"
    exit 1
  fi
fi

