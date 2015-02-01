pumice () {
    local subcommand="$1"
    if [[ -z $subcommand ]]; then
        _help
        return 1
    fi

    shift # remove subcommand from arguments

    if functions "_$subcommand" > /dev/null; then
        "_$subcommand" "$@"
    else
        echo -e "\e[31mPumice: Unknown command: \e[m\e[33m$subcommand\e[m" >&2
    fi
}


function _bundle () {
    local repo="$1"
    local target="$2"
    if [[ -z $repo || -z $target ]]; then
        echo -e "\e[33mex) pumice bundle ryutamaki/pumice pumice.zsh\e[m"
        return 1
    fi

    local repo_replaced_slash=$(echo $repo | sed -e s./.#.g)

    cd $_PUMICE_PLUGINS_INSTALL_DIRECTORY
    if [[ ! -d "$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash" ]]; then
        git clone "https://github.com/$repo" "$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash"
    fi

    if [[ -e "$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash/$target" ]]; then
        source "$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash/$target"
    else
        echo "\e[31mPumice: Target not found: \e[m\e[33m$repo/$target\e[m" >&2
    fi
}

function _update () {
    cd $_PUMICE_PLUGINS_INSTALL_DIRECTORY
    ls | sed |
        while read $repo_dir; do
            cd $repo_dir && git pull
            cd ../
        done
}

function _remove () {
    echo 'has NOT implemented yet'
}

function _list() {
    cd $_PUMICE_PLUGINS_INSTALL_DIRECTORY
    ls | sed |
        while read repo_dir; do
            echo $repo_dir | sed -e s.#./.g
        done
}

function _help() {
    echo 'has NOT implemented yet'
}


function _pumice () {
    _values \
        'subcommands'               \
        'bundle[load a plugin]'     \
        'update[update a plugin]'   \
        'remove[remove a plugin]'   \
        'help[show help]'           \
}
function _setup_pumice () {
    export _PUMICE_PLUGINS_INSTALL_DIRECTORY="$(cd "$(dirname "$0")" && pwd)/.pumice"
    mkdir -p $_PUMICE_PLUGINS_INSTALL_DIRECTORY

    # compdef _pumice pumice
}
_setup_pumice
