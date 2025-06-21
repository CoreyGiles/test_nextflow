#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params.cohort = 'Ausdiab'
params.datatype = 'Lipidomics_Test'
params.freeze = 1
params.revision = 0


/*
 * Include modules
 */
include { checkGit } from './modules/checkGit.nf'
include { failOnMissing } from './modules/failOnMissing.nf'
include { getFileProperties } from './modules/getFileProperties.nf'
include { writeCSV } from './modules/writeCSV.nf'
checkGit

/*
 * Main workflow
 */
workflow {

    // Check git status
    checkGit()

    // Get the path to the data files
    data_path = Channel.fromPath("data/${params.cohort}/${params.datatype}/Freeze_${params.freeze}/Revision_${params.revision}/${params.cohort}_${params.datatype}*.csv")
    
    // Load the data
    data = data_path.splitCsv(header: true)
    | map { row ->
        [row.iid, row]
    }

    // Get the metadata path
    metadata_path = Channel.fromPath("data/${params.cohort}/${params.datatype}/Freeze_${params.freeze}/Revision_${params.revision}/${params.cohort.toLowerCase()}_iid_map.csv")

    // Load the metadata
    metadata = metadata_path.splitCsv(header: true)
    | map { row ->
        [row.iid, row]
    }

    // Join the data with metadata
    joined_data = data.join(metadata, remainder: true)
    //| view

    // Remove excess rows (removes rows with no data)
    filtered_data = joined_data.filter { row ->
        row[1] != null
    }
    //| view

    // Split the data into two channels: one with metadata and ones missing metadata
    data_with_metadata = filtered_data.branch { iid, row, metadata ->
        valid: metadata != null
        missing: metadata == null
    }

    // Make sure we fail if there are any missing metadata
    //failOnMissing(data_with_metadata.missing)

    //data_with_metadata.valid
    //| view

    data_with_metadata.missing
    //| view

    // Add the assay UID to the data
    data_merged = data_with_metadata.valid
    | map { iid, row, metadata ->
        (['assay_uid': metadata.assay_uid] + row)
    }
    //| view

    // Remove the 'iid' column from the data
    data_merged = data_merged.map { row ->
        row.remove('iid')
        row
    }
    //| view

    // Convert the data to a CSV format
    header = data_merged.map { row ->
        content = row.keySet().join(',') + '\n'
        content += row.values().join(',')
        [row.assay_uid, content, params.cohort, params.datatype, params.freeze, params.revision]
    }
    //| view

    // Write the data to CSV using process
    output_files = writeCSV(header)

    // Write the data to a CSV file
    //output_file = header
    //| map { assay_uid, content ->
    //    def csv_file = file("output/${params.cohort}/${params.datatype}/Freeze_${params.freeze}/Revision_${params.revision}/files/${assay_uid}.csv")
    //    csv_file.text = content
    //    [assay_uid, csv_file]
    //}
    //| view

    // Try to get the file properties
    getFileProperties(output_files)
    | view

    // // Create a table of file paths for tables
    // def metaDataPaths = [
    //     projects: file("data/acdc_projects_table.csv"),
    //     mapping_file: file("data/mapping_file_table.csv"),
    //     assay_information: file("data/assay_information_table.csv"),
    //     subjects: file("data/${params.cohort}/${params.cohort.toLowerCase()}_subjects_table.csv"),
    //     samples: file("data/${params.cohort}/${params.cohort.toLowerCase()}_samples_table.csv"),
    //     assays: file("data/${params.cohort}/${params.cohort.toLowerCase()}_*_assays_table.csv"),
    // ]

}
