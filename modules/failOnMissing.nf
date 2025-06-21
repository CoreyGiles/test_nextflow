#!/usr/bin/env nextflow

/*
================================================================================
    Process: failOnMissing
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

================================================================================
*/

process failOnMissing {

    // Define the input channels
    input:
        tuple \
            val(iid),               // The individual ID
            val(_row),              // The raw data
            val(_metadata)          // The missing metadata

    // Script to process the input data
    script:
        """
        echo "ERROR: no metadata found for IID ${iid}" >&2
        exit 1
        """
}
