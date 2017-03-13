# EASIN Workflow
##Rationale
To create an update to the memberstate T0 layer provided by EASIN (MS_BELGIUM.shp) using the data aggregated by the memberstate in their [T0 dataset](https://github.com/inbo/invasive-t0-occurrences). The update is provided by stating, in the column Accepted,  whether the squares provided by EASIN are correct (Y) or incorrect (N). New squares, those missing from the EASIN - Layer, should also be added with the value "New" in the Accepted column. 

Since most of the squares in belgium would be "New", experts decided it would be easier to provide EASIN with a new layer, in a similar format, for EASIN to subsitute its layer with.  

##Scripts
* Update Source 
 * Downloads T0 dataset from github
* subset data 
 * Subsets the data from T0 dataset 
  * Only Listed species
  * Only records with at least Grid10k cellcode (added in aggregation process, no cellcode means record with incorrect spatial reference)
  * Only records from 01/01/2000 to 31/01/2016
  * Only records with correct validationstatus
   * Certain more common and recognisable species are non-propotionally not treated, under treatment or not treatable. Experts selected the following species to have all validation statuses included.
    * Threskiornis aethiopicus (Latham, 1790) 
    * Oxyura jamaicensis (Gmelin, 1789)
    * Procyon lotor (Linnaeus, 1758)
    * Cabomba caroliniana A. Gray
    * Tamias sibiricus (Laxmann, 1769)
    * Nasua nasua (Linnaeus, 1766)
    * Eriocheir sinensis H. Milne Edwards, 1853
    * Pseudorasbora parva (Temminck & Schlegel, 1846)
    * Trachemys Agassiz, 1857
  
* Dataexploratie

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
Using the outputs from Extra MS_Belgium_CorrectNames and Stap 2 GRID10k Merge (2) 

##Arcgis part II
