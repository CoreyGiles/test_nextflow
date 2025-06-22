#!/usr/bin/env nextflow

/*
================================================================================
    Process: loadCsv
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

    Publish directory: 

================================================================================
*/

def loadCsv(data_path) {
    Channel.fromPath(data_path)
    | splitCsv(header: true)
}

