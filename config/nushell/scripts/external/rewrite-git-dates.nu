#!/usr/bin/env nu

export def main [
    n: int,                      # Number of commits to alter
    start_date: datetime,        # Initial start date boundary
    end_date: datetime           # End date boundary
] {
    # 1. Calculate the static period duration
    let total_duration = ($end_date - $start_date)
    let period = ($total_duration / ($n * 1min ))

    # Collect the hashes of the last n commits (oldest to newest)
    let commit_hashes = (^git log --max-count=($n) --format="%H" | lines | reverse)

    if ($commit_hashes | is-empty) {
        error make {msg: "No commits found to alter."}
    }

    # Backup current branch pointer before rewriting history
    let current_branch = (^git branch --show-current)
    print $"Rewriting history for ($n) commits starting from ($start_date)..."

    # Detach HEAD at the parent of the oldest commit we want to change
    ^git checkout $"($commit_hashes | first)~1"

    # Mutable tracking variable for dates
    mut current_start = $start_date

    # Loop through each commit sequentially
    for hash in $commit_hashes {
        # 2. Assign current tracking date to the commit
        let datetime = ($current_start | format date "%Y-%m-%dT%H:%M:%S")
        
        # Cherry-pick the target commit to our new history line
        ^git cherry-pick $hash

        # Apply your specified date changing variables and amend
        with-env { 
            GIT_COMMITTER_DATE: $datetime, 
            GIT_AUTHOR_DATE: $datetime 
        } {
            ^git commit --amend --no-edit --date $datetime
        }

        # 3. Generate a random duration between 0min and the calculated period
        let random_seconds = (random int 0..($period | into int))
        let random_delay = ($random_seconds * 1min)

        # Update start_date tracker for the next iteration
        $current_start = ($current_start + $random_delay)
    }

    # 4. Point the original branch to our newly generated history sequence
    if ($current_branch | is-empty) {
        print "Finished in detached HEAD state. Run 'git switch -c new-branch-name' to save."
    } else {
        ^git update-ref $"refs/heads/($current_branch)" HEAD
        ^git checkout $current_branch
        print $"Successfully updated branch: ($current_branch)"
    }
}

