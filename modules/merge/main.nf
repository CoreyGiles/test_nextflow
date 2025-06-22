/*
================================================================================
    Workflow: merge
--------------------------------------------------------------------------------
    Description: Merges two channel streams by key, with optional inner/outer join
        and fail-on-missing process.

    Input:
        - x: Channel containing the first dataset
        - y: Channel containing the second dataset
        - on: Key to merge on (default: 'iid')
        - all_x: Include all rows from x (default: true)
        - all_y: Include all rows from y (default: false)
        - fail_on_missing: Fail if any keys are missing in the merge (default: true)

    Output:
        - merged_data: Channel containing the merged dataset

    Example output:
        - Merged channel of structure:
            [key, x_data, y_data]

================================================================================
*/

// Process to fail if any keys are missing
process failOnMissing {

    tag "Fail if missing keys are found"

    input:
        val(ids)

    script:
        """
        echo "ERROR: Missing matches for ID: ${ids}" >&2
        exit 1
        """
}

// Workflow to merge two datasets by a specified key
workflow merge {

    take:
        args                // channel: [x, y, on, all_x, all_y, fail_on_missing]

    main:
        // Unpack the input arguments
        def x = args.x
        def y = args.y
        def on = args.get('on', 'iid')
        def all_x = args.get('all_x', true)
        def all_y = args.get('all_y', false)
        def fail_on_missing = args.get('fail_on_missing', true)

        // Prepare the input channels
        x = x.map { row -> [row[on], row] }
        y = y.map { row -> [row[on], row] }

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

    emit:
        merged_data
}
