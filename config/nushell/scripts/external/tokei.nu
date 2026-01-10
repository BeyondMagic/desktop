# Count lines of code in a project.
#
# This script requires that `tokei` be installed and available!
export def main [
    ...args : string # Extra arguments to pass to tokei.
] : nothing -> table<language: string, files: int, lines_code: int, lines_comments: int, lines_blanks: int> {
    ^tokei --output json ...$args
    | from json
    | transpose
    | rename language lines
    | insert files {|item| $item.lines.reports | length }
    | select language files lines.code lines.comments lines.blanks
}
