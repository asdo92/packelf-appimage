#######################################################
# Installing packelf-appimage tools (for Unix/Linux)  #
#######################################################

PREFIX=/usr

install:
	cp -rf packelf-appimage.sh $(PREFIX)/bin/packelf-appimage
	chmod +x $(PREFIX)/bin/packelf-appimage
	cp -rf packelf-appimage-folder.sh $(PREFIX)/bin/packelf-appimage-folder
	chmod +x $(PREFIX)/bin/packelf-appimage-folder
	cp -rf packelf-appimage-copylibs.sh $(PREFIX)/bin/packelf-appimage-copylibs
	chmod +x $(PREFIX)/bin/packelf-appimage-copylibs
	cp -rf packelf-appimage.1 $(PREFIX)/share/man/man1/
	
uninstall:
	rm -rf $(PREFIX)/bin/packelf-appimage
	rm -rf $(PREFIX)/bin/packelf-appimage-folder
	rm -rf $(PREFIX)/bin/packelf-appimage-copylibs
	rm -rf $(PREFIX)/share/man/man1/packelf-appimage.1
