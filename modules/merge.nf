#!/usr/bin/env nextflow

/*
================================================================================
    Process: merge
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

    Publish directory: 

================================================================================
*/

def merge(Map args) {
    def x = args.x
    def y = args.y
    def on = args.get('on', 'id')
    def all_x = args.get('all_x', true)
    def all_y = args.get('all_y', false)
    def fail_on_missing = args.get('fail_on_missing', true)

    // Ensure that the first item in x is 'on'
    x = x
    | map { row ->
        [row[on], row]
    }

    // Ensure that the first item in y is 'on'
    y = y
    | map { row ->
        [row[on], row]
    }

    // Merge the two channels on the specified (first) key
    merged_data = x.join(y, remainder: true)
    
    // If all_x is false, filter out rows from x that do not have a match in y
    if (!all_x) {
        merged_data = merged_data.filter { row ->
            row[2] != null
        }
    }

    // If all_y is false, filter out rows from y that do not have a match in x
    if (!all_y) {
        merged_data = merged_data.filter { row ->
            row[1] != null
        }
    }

    // If fail_on_missing is true, split the data into two channels:
    // one with valid matches and one with missing matches
    if (fail_on_missing) {

        // Branch the merged data into valid and missing matches
        merged_data = merged_data.branch { id, x_dat, y_dat ->
            valid: x_dat != null && y_dat != null
            missing: x_dat == null || y_dat == null
        }

        // Fail on missing matches
        failOnMissing(merged_data.missing.map { id, x_dat, y_dat -> id })

        // Return only the valid matches
        merged_data = merged_data.valid

    }

    // Return the merged data
    return merged_data
}

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