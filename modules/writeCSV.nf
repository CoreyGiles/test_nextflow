#!/usr/bin/env nextflow

/*
================================================================================
    Process: writeCSV
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

    Publish directory: 

================================================================================
*/

process writeCSV {

    // Define the input channels
    input:
        tuple \
            val(assay_uid),
            val(content),
            val(cohort),           // The cohort name
            val(datatype),         // The datatype (e.g., Lipidomics)
            val(freeze),           // The freeze number
            val(revision)          // The revision number

    // Define the output files
    output:
        tuple \
            val(assay_uid),
            path("${assay_uid}.csv")

    // Set the Publish directory
    publishDir "output/${cohort}/${datatype}/Freeze_${freeze}/Revision_${revision}/files", mode: 'copy'
    
    // Script to process the input data
    script:
"""
cat <<-'EOF' > ${assay_uid}.csv
${content}
EOF
"""
}
