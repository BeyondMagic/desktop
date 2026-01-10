use ../fork.nu

# Run Steam with appropriate environment variables set.
export def main [
  ...args : string # List of arguments to pass to Steam
]: nothing -> any {
  $env.HOME = $env.XDG_CONFIG_HOME + "/steam"

  mkdir $env.HOME

  let args = [
    "exec"
    "steam"
    ...$args
  ] | str join ' '

  fork $args
}
