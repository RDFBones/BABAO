#! /bin/bash

build=0
full=0
update=0

function usage {
    
    echo " "
    echo "usage: $0 [-b][-f][-u]"
    echo " "
    echo "    -b          just build BABAO ontology extension"
    echo "    -f          build BABAO ontology extension and include the RDFBones core ontology"
    echo "    -u          initiate and update submodules if they are not up to date"
    echo "    -h -?       print this help"
    echo " "

    exit

}



while getopts "bfuh?" opt; do

    case "$opt" in

	b)
	    build=1
	    ;;

	f)
	    full=1
	    ;;

	u)
	    update=1
	    ;;

	?)
	    usage
	    ;;
	
	h)
	    usage
	    ;;

    esac

done


## SUBMODULES
#############

## Check if submodules are initialised

if [ $update -eq 1 ];then

    git submodule init
    git submodule update
    
fi

if [ $build -eq 1 ] || [ $full -eq 1 ]; then

    ## BUILD DEPENDENCIES
    #####################

    ## RDFBones CORE ONTOLOGY

    cd RDFBones-O/robot/
    
    ./Script-Build_RDFBones-Robot.sh

    cd ../..

fi
