


REM create a resource group
az group create --name CLIVMDemo --location eastus

REM use az vm image list -f --publisher MicrosoftSQLServer --all to find the list of images.  Use the URN value as the image name
az vm create --resource-group CLIVMDemo --name CLIDemoVM --image MicrosoftSQLServer:SQL2017-WS2016:SQLDEV:latest --admin-username localadmin --admin-password Passw0rd12345 --size Standard_A5 --storage-sku Standard_LRS

REM az vm create --resource-group CLIVMDemo --name CLIDemoVM --image MicrosoftSQLServer:SQL2017-WS2016:SQLDEV:14.0.1000204 --admin-username localadmin --admin-password Passw0rd12345 --size Standard_A5 --storage-sku Standard_LRS


REM az vm stop --resource-group $ResourceGroup --name $srvName


REM az group delete --name $ResourceGroup --yes

