#!/usr/bin/env nextflow

/*
================================================================================
    Process: loadYaml
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

    Publish directory: 

================================================================================
*/

import groovy.yaml.YamlSlurper

def loadYaml(data_path) {
    Channel.fromPath(data_path)
    | map { file ->
        new YamlSlurper().parse(file)
    }
}

