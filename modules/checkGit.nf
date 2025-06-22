#!/usr/bin/env nextflow

/*
================================================================================
    Process: checkGit
--------------------------------------------------------------------------------
    Description: This process checks the current git repository status to ensure that:
    - The user is on the main branch
    - The local repository is up to date with the remote repository
    - There are no uncommitted changes in the working directory
    If any of these checks fail, the process will exit with an error message.
    Use -stub-run to skip these checks.

    Input: None

    Output: 
        val(true)  // Returns true if all checks pass

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
            echo "ERROR: Not on main branch" >&2
            echo "SUGGEST: Run 'git checkout main' to switch to the main branch" >&2
            exit 1
        fi

        ## Ensure we have the latest changes
        if [ "\$(git rev-parse HEAD)" != "\$(git ls-remote origin main | cut -f1)" ]; then
            echo "ERROR: Local repository is not up to date with remote" >&2
            echo "SUGGEST: Run 'git pull' to update your local repository or create a pull request to merge changes" >&2
            exit 1
        fi

        ## Ensure we have no uncommitted changes
        if [ -n "\$(git status --porcelain)" ]; then
            echo "ERROR: Working directory is dirty" >&2
            echo "SUGGEST: Stash changes or create a pull request to merge" >&2
            exit 1
        fi
        """

    stub:
        """
        echo "stub-run: ignoring git checks"
        """
}
