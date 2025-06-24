#!/usr/bin/env nextflow

/*
================================================================================
    Process: getFileProperties
--------------------------------------------------------------------------------
    Description: This process retrieves properties of the input data files, such as
                 the MD5 hash, file size in kilobytes, and creation date.

    Input:
        path(data_path)         // The data file path

    Output:
        tuple \
            path(data_path),       // The data file path
            val(md5sum),           // The MD5 hash of the file
            val(file_size)         // The file size in kilobytes

    Example output:
        - data_path: "Ausdiab_Lipidomics_Species_Fr1_Rev0.csv"
        - md5sum: "d41d8cd98f00b204e9800998ecf8427e"
        - file_size: 1234.56

================================================================================
*/

process getFileProperties {
    stageInMode 'copy'

    // Define the input channels
    input:
        tuple \
            val(assay_uid),  // The Assay UID
            path(data_path)  // The data file path

    // Define the output files
    output:
        tuple \
            val(assay_uid),
            path(data_path),
            eval("md5sum ${data_path} | cut -d' ' -f1"),
            eval("stat --format='%s' ${data_path}"),
            eval("date -r ${data_path} +%Y-%m-%dT%H:%M:%S")

    // Script to process the input data
    script:
        """
        true
        """
}
