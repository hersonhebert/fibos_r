#' @title Calcule the Surface
#' @name occluded_surface
#'
#' @description The calculation of occluded surface areas is essential for
#'              understanding the possibility of an enzyme passing between atoms
#'              of a protein. To perform the calculation, it is considered that
#'              a surface is occluded based on tests with a probe, which is
#'              typically the water molecule.
#'
#' @param pdb Input containing only the name of the 4-digit PDB file, the file will be obtained online. If there is an extension ".pdb" or full path, the file will be obtained locally.
#' @param method Method to be used: OS or FIBOS
#'
#' @seealso [read_prot()]
#' @seealso [read_osp()]
#' @seealso [osp()]
#'
#' @author Carlos Henrique da Silveira (carlos.silveira@unifei.edu.br)
#' @author Herson Hebert Mendes Soares (hersonhebert@hotmail.com)
#' @author João Paulo Roquim Romanelli (joaoromanelli@unifei.edu.br)
#' @author Patrick Fleming (Pat.Fleming@jhu.edu)
#'
#' @export
occluded_surface = function(pdb, method = "FIBOS"){
  remove_files()
  create_folder()
  meth = 0
  if(grepl(".pdb", pdb) ==  FALSE){
    arq_aux = paste(pdb,".pdb", sep = "")
    if(file.exists(arq_aux)){
      file.remove(arq_aux)
    }
  }
  else{
    if(file.exists(pdb) == FALSE){
      stop("File not Found: ", pdb)
    }
  }
  path = system.file("extdata", "radii", package = "FIBOS")
  file.copy(from = path, to = getwd())
  interval = clean_pdb(pdb)
  iresf = interval[1]
  iresl = interval[2]
  if(toupper(method) == "OS"){
    meth = 1
  }
  if(toupper(method) == "FIBOS"){
    meth = 2
  }
  if(!(toupper(method) == "OS")&!(toupper(method) == "FIBOS")){
    stop("Wrong Method")
  }
  execute(1, iresl, meth)
  remove_files()
  pdb_name = change_files(pdb)
  return(read_prot(pdb_name))
}

remove_files = function(){
  files_list = dir(pattern = "\\.ms")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  files_list = dir(pattern = "\\.inp")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  files_list = dir(pattern = "\\.txt")
  if(length(files_list)>0){
    file.remove(files_list)
    files_list = NULL
  }
  if(file.exists("file.srf")){
    file.remove("file.srf")
  }
  if(file.exists("fort.6")){
    file.remove("fort.6")
  }
  if(file.exists("part_i.pdb")){
    file.remove("part_i.pdb")
  }
  if(file.exists("part_v.pdb")){
    file.remove("part_v.pdb")
  }
  if(file.exists("temp.pdb")){
    file.remove("temp.pdb")
  }
  if(file.exists("radii")){
    file.remove("radii")
  }
}
