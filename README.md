# packelf-appimage

Pack elf binary and it's dependencies into standalone executable using appimagetool.
`packelf-appimage` was inspired by https://github.com/oufm/packelf. 

## Usage packelf:

```
Usage: ./packelf-appimage.sh <ELF_SRC_PATH> <ELF_DST_PATH>
```

Example:

```
$ ./packelf-appimage.sh /usr/bin/mpv mpv-x86_64.AppImage
```

## Extract without running:

You can extract the files of a created package without executing it with the following command:

```                                                                                                                                                                                                                  
$ ./<package> --appimage-extract                                                                                                                                                                        
```  

## Usage packelf-copylibs:

```                                                                                                                                                                                                               
Usage: ./packelf-appimage-copylibs.sh <ELF_SRC_PATH> <PATH_TO_COPY_LIBRARIES>
```

Example:

```
$ ./packelf-appimage-copylibs.sh /usr/bin/mpv /opt/mpv-libs/
```

## Usage packelf-folder:

``` 
Usage: ./packelf-appimage-folder.sh <FOLDER> <FILENAME> <EXECUTABLE_RUN>
```

Example:

``` 
$ ./packelf-folder.sh /opt/mpv-package mpv-x86_64.AppImage run.sh
```

## Dependencies
* sh
* tar
* sed
* grep
* chmod
* appimagetool (https://github.com/AppImage/appimagetool/releases)
* ldd (only needed for packing, not needed for executing or unpacking)
* fusermount (only for executing)
