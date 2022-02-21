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
