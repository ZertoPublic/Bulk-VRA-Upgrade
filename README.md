# Legal Disclaimer
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.

# Automating VRA Upgrades 
For customers running ZVR 5.5 or older this script will connect to the specified VMware or Hyper-V Zerto environment, based on the variables configured in the script, and upgrade the out dated VRAs in the environment. 

# Prerequisities 
Environment Requirements: 
  - VMware PowerCLI 6.0+
  - ZVR 5.0u3+
  - Network access to ZVM, vCenter / SCVMM 
  - Access permissions to write logging
Script Requirements: 
  - ZVM IP Address 
  - vCenter Username 
  - vCenter password 

# Running Script 
Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\vraUpgrade.ps1

