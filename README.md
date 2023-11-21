# kicad-support-tools
Helper scripts / tools for Kicad


## Build Docker

Build latest docker image ...

```bash
$ ./scripts/build_docker.sh
```

Clean all previous images and then build again:

```bash
$ CLEANUP=true ./scripts/build_docker.sh
```


## Tools

**0.0.2**

| tool | version | path |
|---|---|---|
| make | GNU Make 4.3 | `/usr/bin/make` |
| bash | GNU bash, version 5.1.16(1) | `/usr/bin/bash` |
| python | 3.10.6 | `/usr/bin/python3` |
| pip | 22.0.2 from /usr/lib/python3/dist-packages/pip | `/usr/bin/pip3` |
| kicad-cli | 7.0.0 | `/usr/bin/kicad-cli` |
| pcbnew | N/A | `/usr/bin/pcbnew` |
| kifield | 1.0.1 | `/usr/local/bin/kifield` |
| kibom | 1.9.1 | `/usr/local/bin/kibom` |
| kikit | 1.3.0 | `/usr/local/bin/kikit` |
| nodejs | v18.18.2 | `/usr/bin/node` |
| npm | 9.8.1 | `/usr/bin/npm` |

**0.0.3**

| tool | version | path |
|---|---|---|
| csvkit | 1.3.0 | `/usr/local/bin/csvsort`, `/usr/local/bin/csvlook` |
| js-yaml | 4.1.0 | `/usr/bin/js-yaml` |
| prettyjson | | `/usr/bin/prettyjson` |
