#' @title PDB Cleaning.
#' @name clean_pdb
#'
#' @description Cleaning PDB performs the reorganization of data from an input
#'              PDB file. This function is responsible for removing lines and
#'              information that are not necessary for calculating occluded
#'              areas. In addition, the residues and their atoms are renumbered
#'              to perform the area calculations.
#'
#' @param pdb Input containing only the name of the 4-digit PDB file, the file will be obtained online. If there is an extension ".pdb" or full path, the file will be obtained locally.
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
#'
#' @importFrom bio3d get.pdb
#' @importFrom bio3d read.pdb
#' @importFrom bio3d write.pdb
#' @importFrom readr read_file
#'
clean_pdb = function(pdb){
   if(!grepl(".pdb",pdb)){
     if (!file.exists(pdb)){
       bio3d::get.pdb(pdb)
       pdb = paste(pdb,".pdb",sep = "")
     }
   }
  file.copy(pdb,"temp1.pdb")
  clean("temp1.pdb")
  system_arch_1 = Sys.info()
  if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
    dyn.load(system.file("libs", "FIBOS.so", package = "FIBOS"))
  } else if(system_arch_1["sysname"] == "Windows"){
    if(system_arch_1["machine"] == "x86-64"){
      dyn.load(system.file("libs/x64", "FIBOS.dll", package = "FIBOS"))
    } else{
      dyn.load(system.file("libs/x86", "FIBOS.dll", package = "FIBOS"))
    }
  }
  .Fortran("renum", PACKAGE = "FIBOS")
  file.rename("new.pdb", "temp.pdb")
  file.remove("temp1.cln")
  pdb = bio3d::read.pdb("temp.pdb")
  resno = pdb$atom$resno[1]-1
  for(i in 1:length(pdb$atom$resno)){
    pdb$atom$resno[i] = pdb$atom$resno[i]-resno
  }
  bio3d::write.pdb(pdb, "temp.pdb")
  iresf = as.integer(pdb$atom$resno[1])
  iresl = as.integer(pdb$atom$resno[length(pdb$atom$resno)])
  interval = c(iresf,iresl)
  if(system_arch_1["sysname"] == "Linux"||system_arch_1["sysname"] == "Darwin"){
    dyn.unload(system.file("libs", "FIBOS.so", package = "FIBOS"))
  } else if(system_arch_1["sysname"] == "Windows"){
    if(system_arch_1["machine"] == "x86-64"){
      dyn.unload(system.file("libs/x64", "FIBOS.dll", package = "FIBOS"))
    } else{
      dyn.unload(system.file("libs/x86", "FIBOS.dll", package = "FIBOS"))
    }
  }
  file.remove("temp1.pdb")
  return(interval)
}


clean = function(name_file){
   i = 0
   l1 = c("B", "2", "L")
   l2 = c("A","B","C","D","E","F","G","H","I")
   l3 = c("A","1","U")
   l4 = c("HOH","PMS","FOR","ALK","ANI")
   t = FALSE
   new_file = list()
   name_new_file = "temp1.cln"
   con = file(name_new_file,"w")
   file = readLines(name_file)
   for(line in file){
     if(startsWith(line,"ATOM")){
       if((substr(line,13,13)!="H")&&(substr(line,14,14)!="H")&&(substr(line,14,16)!="OXT")&&(substr(line,14,15)!="2H")&&(substr(line,14,15)!="3H")&&(substr(line,14,14)!="D")&&(substr(line,13,13)!="D")){
         if(!(substr(line,17,17) %in% l1) && !(substr(line,27,27) %in% l2)){
           if(substr(line,17,17) %in% l3){
             line=paste(substr(line,1,16),substr(line,18,100))
           }
           for(item in l4){
             if (item %in% line){
               t=TRUE
             }
           }
           if(i==0){
             line=paste(substr(line,1,24)," 1",substr(line,27,100),sep="")
             i = 1
           }
           if("HSD" %in% line){
             line = gsub("HSD","HIS",line)
           }
           if("HSE" %in% line){
             line = gsub("HSE","HIS",line)
           }
           if("OT1" %in% line){
             line = gsub("OT1","O",line)
           }
           if("OT2" %in% line){
             line = gsub("OT2","OXT",line)
           }
           if("CD ILE" %in% line){
             line = gsub("CD ILE","CD1 ILE",line)
           }
           if (t==FALSE){
             writeLines(line,con)
           }
         }
       }
     }
   }
   writeLines("END",con)
   close(con)
}
