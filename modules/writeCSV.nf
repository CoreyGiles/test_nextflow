#!/usr/bin/env nextflow

/*
================================================================================
    Process: writeCsv
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

    Publish directory: 

================================================================================
*/

process writeCsv {

    // Define the input channels
    input:
        tuple \
            val(id),                // ID to track
            val(file_name),         // The file name
            val(content),           // The content to write to the CSV file
            val(file_path)          // The file path

    // Define the output files
    output:
        tuple \
            val(id),
            path("${file_name}.csv")

    // Set the Publish directory
    publishDir "${file_path}", mode: 'copy'
    
    // Script to process the input data
    exec:
        def csv_file = task.workDir.resolve("${file_name}.csv")
        csv_file.text = content
}
