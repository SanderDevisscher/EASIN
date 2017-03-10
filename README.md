# EASIN Workflow

##Scripts

##Arcgis part I
###T0_Toolbox.tbx
Is an ESRI-arcgis toolbox containing the finished models used for post-script analysis.
The toolbox contains the following models:
* Stap 1 GRID10k Link
* Stap 2 GRID10k Merge (2)
* Stap 3 Dissolve
* Stap 4 GRID10k EASIN and T0 Link (2)
* Stap 5 MS_Belgium_Check (2)
* Extra MS_Belgium_CorrectNames => Changes species names with correct names and Outputs EASIN.dbf & MS_BELGIUM_Joined2
* Extra Project UTM Layers => Projects the UTM1x1 and GRID10k layers to ETRS_1989_LAEA

Extra's should be run when new layers are provided by EASIN or when in a rare case other projections are needed.

####Stap 1 GRID10k Link
Iterates through the species in the script output (default: GRID10kData_Source_dd_mm_yy_Export_dd_mm_yy.dbf) and links it with the GRID10k layer
![Model](Stap1.png)

Prior to iteration species names had to be simplified (substitute all; .,"" ,() ,..., etc... for _) 
####Stap 2 GRID10k Merge (2)
Merges the outputs of Stap 1 GRID10k Link into a geodatabase file named GRID10k_Linked_ALL and a dbf file (GRID_ALL.dbf). This last file is used in the EASIN.accdb to link with the output from the `Extra MS_Belgium_CorrectNames`model (EASIN.dbf). 

##MS Access

##Arcgis part II
