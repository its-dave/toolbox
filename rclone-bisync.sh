#!/usr/bin/env bash

while [ "$#" -gt 0 ]; do
    case "$1" in
        -l|--local-dir)
            localDir="$2"
            shift;;
        -r|--remote-name)
            remoteName="$2"
            [[ "${remoteName}" = *':' ]] || { echo 'ERROR: remote name must end in ":"'; exit 1; }
            shift;;
        --dry-run)
            extraParams+=('--dry-run');;
        -g|--google-drive)
            extraParams+=('--drive-acknowledge-abuse')
            extraParams+=('--drive-skip-gdocs')
            extraParams+=('--drive-skip-shortcuts')
            extraParams+=('--drive-skip-dangling-shortcuts')
            ;;
        -o|--onedrive)
            extraParams+=(--exclude='/Personal Vault/**');;
        *)
            echo -e "ERROR: invalid option [$1]"
            exit 1;;
    esac
    shift
done

[ -n "${localDir}" ] || { echo "ERROR: missing local dir, usage: $0 --local-dir '/path/to/local' --remote-name 'remote1:'"; exit 1; }
[ -n "${remoteName}" ] || { echo "ERROR: missing remote name, usage: $0 --local-dir '/path/to/local' --remote-name 'remote1:'"; exit 1; }

set -x
rclone bisync \
    "${remoteName}/" "${localDir}" \
    --compare size,modtime,checksum \
    --modify-window 1s \
    --create-empty-src-dirs \
    --metadata \
    --progress \
    --check-access \
    --verbose \
    --backup-dir2 "${localDir}-backup" \
    --track-renames \
    "${extraParams[@]}"
