# packelf-appimage

Pack elf binary and it's dependencies into standalone executable using appimagetool.
`packelf-appimage` was inspired by https://github.com/oufm/packelf. 


## usage

```
Usage: ./packelf-appimage.sh <ELF_SRC_PATH> <ELF_DST_PATH>
```

## dependence
* sh
* tar
* sed
* grep
* chmod
* appimagetool (https://github.com/AppImage/appimagetool/releases)
* ldd (only needed for packing, not needed for executing or unpacking)
* fusermount (only for executing)
