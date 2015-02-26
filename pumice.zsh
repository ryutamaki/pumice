function pumice() {
    local subcommand=$1

    if [ -z $subcommand ]; then
        _help
        return 1
    fi

    shift # remove subcommand from arguments

    if functions "_$subcommand" >/dev/null; then
        "_$subcommand" "$@"
    else
        echo -e "\e[31mPumice: Unknown command: \e[m\e[33m$subcommand\e[m" 1>&2
        return 1
    fi

    return 0
}

function _bundle() {
    local repo=$1
    local target=$2

    # check arguments is passed correctly
    if [[ -z $repo || -z $target ]]; then
        echo -e "\e[33mex) pumice bundle ryutamaki/pumice pumice.zsh\e[m" 1>&2
        return 1
    fi

    local repo_replaced_slash=$(echo $repo | sed -e s./.#.g)
    local dir="$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash"

    if [ ! -d $dir ]; then
        git clone "https://github.com/$repo" $dir
    fi

    if [ -e "$dir/$target" ]; then
        source "$dir/$target"
    else
        echo -e "\e[31mPumice: Target not found: \e[m\e[33m$repo/$target\e[m" 1>&2
        return 1
    fi

    return 0
}

function _update() {
    ls $_PUMICE_PLUGINS_INSTALL_DIRECTORY | sed |
        while read repo_dir; do
            echo -e "\e[32mPumice: Try to update: $repo_dir\e[m"
            cd "$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_dir" && git pull
            cd ../
        done

    return 0
}

function _remove() {
    local repo=$1
    local repo_replaced_slash=$(echo $repo | sed -e s./.#.g)
    local dir="$_PUMICE_PLUGINS_INSTALL_DIRECTORY/$repo_replaced_slash"

    if [ -d $dir ]; then
        rm -r $dir
    else
        echo -e "\e[31mPumice: Target directory not found: $repo_replaced_slash\e[m" 1>&2
        return 1
    fi

    return 0
}

function _list() {
    ls $_PUMICE_PLUGINS_INSTALL_DIRECTORY | sed |
        while read repo_dir; do
            echo $repo_dir | sed -e s.#./.g
        done

    return 0
}

function _help() {
    echo 'has NOT implemented yet'
}

function _pumice() {
    _values \
        'subcommands' \
        'bundle[load a plugin]' \
        'update[update a plugin]' \
        'remove[remove a plugin]' \
        'list[list installed plugins]' \
        'help[show help]'
}

function _setup_pumice() {
    export _PUMICE_PLUGINS_INSTALL_DIRECTORY="$HOME/.pumice"
    if [ ! -d $_PUMICE_PLUGINS_INSTALL_DIRECTORY ]; then
        mkdir -p $_PUMICE_PLUGINS_INSTALL_DIRECTORY
    fi
}
_setup_pumice
compdef _pumice pumice
