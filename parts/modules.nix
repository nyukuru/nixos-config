{
  lib,
  inputs,
  ...
}: let
  inherit (lib.attrsets) 
    attrNames 
    filterAttrs;

  inherit (lib.lists) 
    foldl 
    length 
    reverseList;

  inherit (lib.strings) 
    concatStringsSep;
  inherit (lib.options) 
    mkOption;
  inherit (builtins) 
    readDir;

  setAttrAlongPath = attrPath: value: let
    backWalk = acc: n:
      acc // {
        ${n} = acc // {imports = value;};
      };
  in removeAttrs (foldl backWalk {imports = value;} (reverseList attrPath)) ["imports"];

  mkModuleTree = path: let
    # Recursive helper
    mkModuleTree' = dirList: let
      filePath = path + ("/" + (concatStringsSep "/" dirList));
      allFiles = readDir filePath;
      dirFiles = attrNames (filterAttrs (_: v: v == "directory") allFiles);
    in 
      # End branch when a module file is found
      # There shouldn't be multiple module files sharing a parent folder
      if allFiles ? "module.nix" then {imports = [(filePath + "/module.nix")];}
      # Directory case
      else 
	foldl (
	  acc:
	  file: let
	    subDirList = dirList ++ [file];
	    result = mkModuleTree' subDirList;
	  in 
	    # A module file leaf
	    if (length (attrNames result) == 1) then
	      acc // 
                {
		  ${file} = result;
		  imports = (acc.imports or []) 
		    ++ result.imports 
		    ++ [
		      {
		        options = (setAttrAlongPath subDirList (mkOption {
			  readOnly = true;
			  internal = true;
			}));
		      } 
	            ];
		}
	    # Branch contains module file
	    else if (result != {}) then 
	      acc // {
		${file} = result;
		imports = (acc.imports or []) ++ result.imports;
	      }
	    else acc 
	) {} dirFiles;
  in removeAttrs (mkModuleTree' []) ["imports"];
in {
  # Disable apply function which breaks set accessing
  disabledModules = ["${inputs.flake-parts.outPath}/modules/nixosModules.nix"];
  flake.nixosModules = lib.traceValSeq (mkModuleTree ../modules);
}
