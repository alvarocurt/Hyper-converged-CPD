# Hyper-converged-CPD
Ansible for the deployment of an OpenNebula+Ceph infrastructure as part of my Bachelor's Thesis.
The roles include from a complete preparation of each host, to the deployment of Ceph and OpenNebula. The playbook includes the option to raise an example template and VM in the newly deployed OpenNebula.
Further documentation will be written

It's active project, so radical changes are still feasible. Most changes are still done in local because I'm still new to control version :P

Variable files to edit are the ansible inventory files, and the vars.yml file. In case you want to have some resources up on the fresh OpenNebula, define them in the custom.tf file inside the  the terraform_workspace folder.
