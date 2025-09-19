#!/usr/bin/env sh

# Author: asdo92@duck.com
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
  echo 'pngfile' > ${desktop_file_path}/${desktop_file_name}.png
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
  echo "Linking libraries ${libraries}"
  for libraries in ${libs} ; do
    cp -L ${libraries} ${temp_dir}/
  done
  echo "Creating executable linker"
  echo "#!/usr/bin/env sh" > ${temp_dir}/AppRun
  echo "" >> ${temp_dir}/AppRun
  echo "\$(dirname \$0)/${ld_so} --library-path \$(dirname \$0) \$(dirname \$0)/${program} \"\$@\"" >> ${temp_dir}/AppRun
  create_desktop_file "${temp_dir}" "${program}"
  chmod 777 -R "${temp_dir}" 2> /dev/null
  echo "Building static binary in ${2}"
  appimagetool ${temp_dir} "${2}" > /dev/null 2> /dev/null
  rm -rf ${temp_dir}
  if [ -f "${2}" ] ; then
    echo "Created successfully"
  else
    echo "FAILED!"
    exit 1
  fi
fi

