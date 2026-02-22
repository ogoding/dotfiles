# Derived off https://github.com/Schniz/fnm/issues/463#issuecomment-2931426635
# TODO: Update to something more complete like https://github.com/nushell/nu_scripts/blob/main/modules/fnm/fnm.nu
if not (which fnm | is-empty) {
    ^fnm env --json | from json | load-env;
    $env.PATH = $env.PATH | prepend ($env.FNM_MULTISHELL_PATH | path join "bin");

    # $env.config.hooks.env_change.PWD = (
    #     $env.config.hooks.env_change.PWD? | append {
    #         condition: {|| ['.nvmrc' '.node-version'] | any {|el| $el | path exists}}
    #         code: {|| fnm use}
    #     }
    # )
}
