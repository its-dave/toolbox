# toolbox
* Dave's script toolbox
* Clone this repo and add it to your `$PATH` for quick access to the following scripts

## kx - kubectl extensions
* The `kx` script runs `kubectl get pods`, continually refreshing the output
* Script runs locally against a configured kubernetes cluster
* Full instructions available [here](./kx_README.md) or by calling `kx -?`

## highlight
* The `highlight` script highlights specified strings and the lines on which they appear
* Commands should be piped to `highlight` as you would with `grep`
    * e.g. `cat file | highlight string1 string2`

## rclone bisync
* The `rclone-bisync.sh` script is a wrapper for `rclone bisync` with some specific options for google drive and onedrive, as well as backups and some other general options
    * The local dir must have already been created with `rclone bisync --resync`
* The `rclone-sync` script runs `rclone-bisync.sh` for a specified folder with the same name prefix as a defined remote
    * e.g. `rclone-sync name` would run `rclone bisync` for a directory at `~/rclone/id/` and a remote called `remote-id:`
    * The `rclone-sync-all` script runs the same for all directories in `~/rclone/`
