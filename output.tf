output "tls_private_key" {   
value = module.VM_1.tls_private_key
}

#uncomment if you need the ssh key for the VM2 and VM3 otherwise use VM1 as a bastion server
#output "tls_private_key23" {   
#value = module.VM23.tls_private_key
#}

