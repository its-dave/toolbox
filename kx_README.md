# kx - kubectl extensions
* The `kx` script runs `kubectl get pods`, continually refreshing the output
* Script runs locally against a configured kubernetes cluster
    * Container support has been removed
* Clone this repo and add it to your `$PATH` for quick access

## Prereqs

* `kubectl` or `oc` is required
* `column` and `jq` are required to display pod container info

## Options

* `-k <resource>` specifies a comma-separated list of types of kubernetes resources to get (default `pods`), the output for each type of resource containing columns of details
* `-l <resource>` specifies a comma-separated list of types of kubernetes resources to get, the names of resources of each type listed on a single line
* `-s <resource-name>` specifies a single resource object to print out
* `-o` specifies an output format to be passed to `kubectl`
* `-f` specifies a field selector to be passed to `kubectl`
* `-L` specifies a label to be shown as a new column
* `-U` outputs the non-ready running containers within each pod (incompatible with `-c` and `-C`)
* `-n <namespace>` specifies the namespace to use (incompatible with `-A`)
* `-A` includes the `--all-namespaces` flag (incompatible with `-n`)
* `-c` outputs the non-ready containers within each pod (incompatible with `-U` and `-C`)
* `-C` outputs all the containers within each pod (incompatible with `-U` and `-c`)
* `-t <refreshTime>` specifies the time between refreshes in seconds (default 10, 0 to exit immediately without looping), this is actually an added sleep so the true refresh time will be slower
* `-x` clears the entire terminal on each refresh
* `-g <string>` pipes `kubectl` output through `grep`, only outputting lines containing the specified string (incompatible with `-v`)
* `-v <string>` pipes `kubectl` output through `grep -v`, only outputting lines not containing the specified string (incompatible with `-g`)
* `-h <string>` specifies a string to highlight in the output (incompatible with `-m`)
* `-z <node-label-1>,<node-label-2>` specifies a comma-separated list of node labels (correspondng to zones) to be highlighted (incompatible with `-m`)
* `-m` removes all colour and highlighting (incompatible with `-h` and `-z`)
* `-d <resource-name>` prints out the specified resource (and containers if that resource is a pod) then exits without looping, equivalent to `-s <resource-name> -C -t 0`
* `-r` outputs the names of any helm releases in the specified namespace (incompatible with `-R`)
* `-R` outputs the names and chart versions of any helm releases in the specified namespace (incompatible with `-r`)
* `-O` uses the `oc` command instead of `kubectl`
* `-?` prints out this README (using `mdv` or `markdown-cli` if installed)

## Example Usage

* `kx` prints all pods in the current namespace every 10s
* `kx -k pvc -A -g test` prints all pvcs with the string `test` in the output line in all namespaces every 10s
* `kx -v test -t 5` prints all pods without the string `test` in the output line every 5s
* `kx -k node,pv -h test` prints all nodes and pvs every 10s, highlighting every occurrance of the string `test`
* `kx -n test -l asdf` prints all pods and lists all `asdf` resources on one line in the `test` namespace
* `kx -n test -r` prints all pods and helm release names in the `test` namespace every 10s
* `kx -n test -R` prints all pods and helm release name and chart versions in the `test` namespace every 10s
* `kx -n test -U` prints all pods and any non-ready running containers in the `test` namespace every 10s
* `kx -n test -c` prints all pods and any non-ready containers in the `test` namespace every 10s
* `kx -C -t 0 -s test1` or `kx -d test1` prints all containers in pod `test1` and then exits
* `kx -f status.phase!=Succeeded` prints all pods without the `Succeeded` phases (i.e. the `Completed` status) every 10s
* `kx -L zone` prints all pods every 10s with an extra column showing the value of the `zone` label
* `kx -o wide -z zone0,zone1` prints all pods with extra information (from `kubectl get pods -o wide`) every 10s, highlighting IP addresses corresponding to nodes with labels `zone0` and `zone1` in different colours
* `docker exec -it abcdef123456 kubectl describe pod test1` describes pod `test1` currently displayed in the container with id `abcdef123456`
* `docker exec -it abcdef123456 helm list --tls` lists all helm releases on the cluster viewed in the container with id `abcdef123456`
