
1.	Use terraform to set up the following scenario on Azure:
-	 Create three VMs, named VM#1, VM#2, and VM#3  in the Canada Central region in Azure
-	Set up networking on VM#1 so that:
-	 SSH traffic is only permitted by a static IP (use 174.91.158.103)
-	Set up networking on VM#2 and VM#3 so that:
-	incoming traffic on HTTPS traffic is permitted from anywhere
-	incoming SSH traffic is only accessible from VM#1
-	all other incoming traffic is denied

2.	Using the following kubernetes resources define a NetworkSecurityPolicy such that:
-	The rails pod accepts incoming HTTP traffic over port 8080
-	The rails pod is permitted to send traffic outbound to a specific static IP over port 5432
-	The rails pod is permitted to send traffic outbound to a specific static IP over port 6379
-	The rails pod does not accept any other incoming or outgoing traffic
-	The sidekiq pod can communicate outbound to a the same static IP over port 6379 as the rails pod is configured with
-	The sidekiq pod can not make any other communication inbound or outbound

 
