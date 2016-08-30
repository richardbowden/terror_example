Have your env set:

`AWS_ACCESS_KEY`
`AWS_SECRET_ACCESS_KEY`

get you public ip address `dig +short myip.opendns.com @resolver1.opendns.com`

then run command, filling in your public ip address `TF_VAR_dynamic_sshaccess='["your public ip from command above/32"]' terraform apply` 

`TF_VAR_dynamic_sshaccess='["your public ip from command above/32"]` is just an example of using lists by passing them around and merging.

terraform.tfvars contains a few defaults, static\_sshaccess is a list, that is joined with `dynamic_sshaccess` that is specified on the command line, this allows for static ip’s to be set for remote access, the cmd line version TF_VAR_dynamic_sshaccess being for the ip that is used by your workstation for remote access



this will build a vpc using subnet 192.168.0.0/23 as its base, this shows dynamic subnet splitting on the correct boundary, then fires up some spot request instances in these subnets, using the count option and a map of zones to put a instance in each subnet.
