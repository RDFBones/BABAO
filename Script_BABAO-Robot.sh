#! /bin/bash

build=0
cleanup=0
full=0
update=0

function usage {
    
    echo " "
    echo "usage: $0 [-b][-c][-f][-u]"
    echo " "
    echo "    -b          just build BABAO ontology extension"
    echo "    -c          cleanup temporary output files"
    echo "    -f          build BABAO ontology extension and include the RDFBones core ontology"
    echo "    -u          initiate and update submodules if they are not up to date"
    echo "    -h -?       print this help"
    echo " "

    exit

}



while getopts "bcfuh?" opt; do

    case "$opt" in

	b)
	    build=1
	    ;;

	c)
	    cleanup=1
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

    ## BUILD ONTOLOGY EXTENSION
    ###########################

    ## Build Template

    robot template --input RDFBones-O/robot/results/rdfbones.owl \
	  --template Template_Babao.tsv \
	  --prefix "babao: http://w3id.org/rdfbones/ext/babao/" \
	  --prefix "obo: http://purl.obolibrary.org/obo/" \
	  --prefix "rdfbones: http://w3id.org/rdfbones/core#" \
	  --ontology-iri "http://w3id.org/rdfbones/ext/babao/latest/babao.owl" \
	  --output results/babao.owl

    ## Quality Test of Output

    robot reason --reasoner ELK \
	  --input results/babao.owl \
	  -D results/babao-debug.owl

    robot annotate  --input results/babao.owl \
	  --remove-annotations \
	  --ontology-iri "http://w3id.org/rdfbones/ext/babao/latest/babao.owl" \
	  --version-iri "http://w3id.org/rdfbones/ext/babao/v0-1/babao.owl" \
    	  --annotation dc:creator "Felix Engel" \
    	  --annotation dc:creator "Stefan Schlager" \
    	  --annotation owl:versionInfo "0.1" \
    	  --language-annotation dc:description "This RDFBones ontology extension implements the 'Guidelines to the Standards for Recording Human Remains' issued by the British Association for Biological Anthropology and Osteoarchaeology (BABAO) and the Institute of Field Archaeologists (IFA)." en \
    	  --language-annotation rdfs:label "Guidelines to the Standards for Recording Human Remains" en \
    	  --language-annotation rdfs:comment "Reference: Brickley, M., & McKinley, J. I. (Eds.). (2004). Guidelines to the Standards for Recording Human Remains. Southampton & Reading: BABAO & IFA." en \
	  --output results/babao.owl
    

fi

## PREPARE OUTPUT
#################

if [ $full -eq 1 ];then

    robot merge --input RDFBones-O/robot/results/rdfbones.owl \
	  --input results/babao.owl \
	  --output results/babao_ext_core.owl

    robot annotate --input results/babao_ext_core.owl \
	  --remove-annotations \
	  --ontology-iri "http://w3id.org/rdfbones/core/latest/rdfbones.owl" \
	  --language-annotation dc:description "This is the RDFBones core ontology and the BABAO ontology extension merged together." en \
	  --language-annotation rdfs:label "RDFBones core ontology and BABAO extension" en \
	  --language-annotation rdfs:comment "CAUTION: This is not a properly curated ontology. Use for testing purposes only! For productivity, obtain separate versions of the core ontology and ontology extensions." en \
	  --output results/babao_ext_core.owl
	  

    if [ $cleanup -eq 1 && $build -eq 0 ];then

	rm results/babao.owl

    fi

fi
