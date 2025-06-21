#!/usr/bin/env nextflow

/*
================================================================================
    Process: checkGit
--------------------------------------------------------------------------------
    Description: 

    Input:

    Output:

    Example output:

================================================================================
*/

process checkGit {

    // Define the output
    output:
        val(true)

    // Script to process the input data
    script:
        """
        ## Ensure we are on the main branch
        if [ "\$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
            echo "Not on main branch"
            echo "Run 'git checkout main' to switch to the main branch"
            exit 1
        fi

        ## Ensure we have the latest changes
        if [ "\$(git rev-parse HEAD)" != "\$(git ls-remote origin main | cut -f1)" ]; then
            echo "Local repository is not up to date with remote"
            echo "Run 'git pull' to update your local repository"
            exit 1
        fi

        ## Ensure we have no uncommitted changes
        if [ -n "\$(git status --porcelain)" ]; then
            echo "Working directory is dirty"
            exit 1
        fi
        """
}
