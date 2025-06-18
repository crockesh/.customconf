#!/usr/bin/env bash
dry_run="0"
shared_dir=$DEV_ENV/shared

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no default config dir"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "env DEV_ENV needs to be present"
    exit 1
fi

if [[ $1 == "--dry" ]]; then
    dry_run="1"
fi

configdir=$DEV_ENV/personal

if [[ $2 == "--work" ]] then
    configdir=$DEV_ENV/work
fi

log() {
    if [[ $dry_run == "1" ]] then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "env: $DEV_ENV"

update_files() {
    log "copying over files from: $1"
    pushd $1 &> /dev/null
    (
        configs=`find . -mindepth 1 -maxdepth 1 -type d`
        for c in $configs; do
            directory=${2%/}/${c#./}

            log "   removing : rm -rf $directory"

            if [[ $dry_run == "0" ]]; then
                rm -rf $directory
            fi

            log "   copying env: cp $c $2"
            
            if [[ $dry_run == "0" ]]; then
                cp -r ./$c $2
            fi

        done

    )
    popd &> /dev/null
}

update_files $shared_dir/.config $XDG_CONFIG_HOME
update_files $configdir/.config $XDG_CONFIG_HOME

log "reloading hyprland"
hyprctl reload
