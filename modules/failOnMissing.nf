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
        val iid

    // Script to process the input data
    script:
        """
        echo "ERROR: no metadata found for IID ${iid}" >&2
        exit 1
        """

    stub:
        """
        echo "stub-run: ignoring assay-uid assurance check"
        """
}
