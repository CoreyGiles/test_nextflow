#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CoreyGiles/test_nextflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/CoreyGiles/test_nextflow
----------------------------------------------------------------------------------------
*/

/*
 * Pipeline parameters
 */
params.cohort = 'Ausdiab'
params.datatype = 'Lipidomics_Test'
params.freeze = 1
params.revision = 0

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

import groovy.yaml.YamlSlurper
include { checkGit              } from './modules/checkGit.nf'
include { getFileProperties     } from './modules/getFileProperties.nf'
include { writeCsv              } from './modules/writeCsv.nf'
include { loadCsv               } from './modules/loadCsv.nf'
include { loadYaml              } from './modules/loadYaml.nf'
include { merge                 } from './modules/merge/main.nf'



// Assay results to process
def getDataPath(cohort, datatype, freeze, revision) {
    return "data/${cohort}/${datatype}/Freeze_${freeze}/Revision_${revision}/${params.cohort}_${params.datatype}*.csv"
}

// Mapping for assay results
def getMappingPath(cohort, datatype, freeze, revision) {
    return "data/${cohort}/${datatype}/Freeze_${freeze}/Revision_${revision}/${cohort.toLowerCase()}_iid_map.csv"
}

// Metadata for assay results
def getMetadataPath(cohort, datatype, freeze, revision) {
    return "data/${cohort}/${datatype}/Freeze_${freeze}/Revision_${revision}/${cohort.toLowerCase()}_metadata.yaml"
}

// Projects table
def getProjectsTablePath() {
    return "data/acdc_projects_table.csv"
}

// Data versions table
def getDataVersionsTablePath() {
    return "data/acdc_data_versions_table.csv"
}

// Variable dictionary file table
def getVariableDictionaryFileTablePath() {
    return "data/variable_dictionary_file_table.csv"
}

// Assay information table
def getAssayInformationTablePath() {
    return "data/assay_information_table.csv"
}

// Subjects table
def getSubjectsTablePath(cohort) {
    return "data/${cohort}/${cohort.toLowerCase()}_subjects_table.csv"
}

// Samples table
def getSamplesTablePath(cohort) {
    return "data/${cohort}/${cohort.toLowerCase()}_samples_table.csv"
}


def loadData(cohort, datatype, freeze, revision) {

    // Load the data to process
    data = loadCsv(getDataPath(cohort, datatype, freeze, revision))

    // Load the mapping
    mapping = loadCsv(getMappingPath(cohort, datatype, freeze, revision))

    // Load the metadata
    metadata = loadYaml(getMetadataPath(cohort, datatype, freeze, revision))

    // Load the projects table
    projects = loadCsv(getProjectsTablePath())

    // Load the data versions table
    dataVersions = loadCsv(getDataVersionsTablePath())

    // Load the variable dictionary file table
    variableDictionary = loadCsv(getVariableDictionaryFileTablePath())

    // Load the assay information table
    assayInformation = loadCsv(getAssayInformationTablePath())

    // Load the subjects table
    subjects = loadCsv(getSubjectsTablePath(cohort))

    // Load the samples table
    samples = loadCsv(getSamplesTablePath(cohort))

    // Return both datasets
    [data, mapping, metadata, projects, dataVersions, variableDictionary, assayInformation, subjects, samples]
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {

    // Check git status
    checkGit()

    // Load the data and tables
    (data, mapping, metadata, projects, dataVersions, variableDictionary, assayInformation, subjects, samples) = 
        loadData(params.cohort, params.datatype, params.freeze, params.revision)

    // Merge the data and mapping on 'iid'
    //joined_data = merge(data, mapping, 'iid', true, false)
    joined_data = merge(x: data, y: mapping, by: 'iid')
    //| view

    // Add the assay UID to the data
    data = joined_data
    | map { iid, data, mapping ->
        (['assay_record_uid': mapping.assay_record_uid] + data)
    }
    //| view

    // Remove the 'iid' column from the data
    data = data.map { row ->
        row.remove('iid')
        row
    }
    //| view

    // Convert the data to a CSV format
    data_output = data.map { row ->
        // Create the file path
        file_path = "output/${params.cohort}/${params.datatype}/Freeze_${params.freeze}/Revision_${params.revision}/files"
        // Create the content for the CSV file
        content = row.keySet().join(',') + '\n'
        content += row.values().join(',')
        // Tuple for input to writeCsv
        [row.assay_uid, row.assay_uid, content, file_path]
    }

    // Write the data to CSV using process
    output_files = writeCsv(data_output)

    // Try to get the file properties
    getFileProperties(output_files)
    //| view

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/