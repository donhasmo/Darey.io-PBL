# project-17
AUTOMATE INFRASTRUCTURE WITH IAC USING TERRAFORM. PART 2
## install graphviz
- for linux:
`sudo apt install graphviz`
- for windows:
`choco install graphviz`


## use the command below to generate dependency graph
- terraform graph -type=plan | dot -Tpng > graph.png
- terraform graph  | dot -Tpng > graph.png

## Read More abot terrafrom graph
https://www.terraform.io/docs/cli/commands/graph.html
