# BoxPack
 Prepares data for upload to box by zipping files over 15 GB and folder with over 75 files

BoxPack
============
BoxPack will scan a tree and convert all folders containing over %fLimit% items and files over %fSizeMaxMB% MB 
    into ZIP archives (*.boxPack.zip.*). (These parameters can be changed in the SETTINGS section of the source code)
  - This avoids synchronization problems due to files above the cloud size limit.
  - Having less files makes up/downloading significantly faster.
  - Archiving only folders with many files means most of the tree remains browsable/accessible in a web interface.

BoxUnpack
============
This program is the companion program to box Packer. It restores a tree containing box packer archives (*.boxPack.zip.*) 
back to its original state.


Conflict Finder
============
This program will scan a tree for possible conflicts when running box (un)Packer; it then lists all the folders that have 
eponymous boxPack archives (*.boxPack.zip.*) next to them (sign of incomlete archival or extraction).


There are two ways of running these programs:
 1) Place the .bat at the root of any tree you want processed, and double-click.
 2) Call the .bat from the command line with the tree root as the first parameter, e.g: 
                 boxPack C:\mydata     (using no parameter defaults to the current directory)