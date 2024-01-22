# Terraform Import Script

This PowerShell script is designed to facilitate the creation of Terraform import statements. It generates a file containing `import` blocks for each resource in a Terraform configuration file, based on the resource information from a Terraform state file.
The script assumes you want to import the resource to another resource with the same name, if this is not the case modify the script accordingly.

## Prerequisites

- PowerShell
- Python
- `jq` command-line JSON processor

Ensure that Python and `jq` are installed and accessible from your system's PATH.
Also ensure to install requirements using `pip install -r requirements.txt`

## Usage

To use this script, you must provide two parameters:

1. The path to your Terraform `.tf` configuration file.
2. The path to your Terraform `.tfstate` state file.

The script will generate a file with the name `[TerraformFilePath]-import.tf`, containing the import statements for all resources defined in the Terraform configuration file and present in the state file.

### Running the Script

Save your script as `ImportTerraformResources.ps1` and execute it from PowerShell with the required parameters:

```powershell
.\ImportTerraformResources.ps1 -TerraformFilePath "path\to\your\terraform_file.tf" -TerraformStateFilePath "path\to\your\terraform.tfstate"
```

Replace `"path\to\your\terraform_file.tf"` and `"path\to\your\terraform.tfstate"` with the actual paths to your files.

## Minimal Example

Consider the following minimal Terraform configuration file named `example.tf`:

```terraform
resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources"
  location = "West Europe"
}
```

And a Terraform state file named `terraform.tfstate` that includes the state of the above resource.

By running the script with these files as input:

```powershell
.\ImportTerraformResources.ps1 -TerraformFilePath ".\example.tf" -TerraformStateFilePath ".\terraform.tfstate"
```

The script will create a file named `example.tf-import.tf` with an import block similar to the following:

```terraform
import {
  to = "azurerm_resource_group.example_rg"
  id = "/subscriptions/xxxxx/resourceGroups/example-resources"
}
```

## Note

Ensure that the Python script `parse_tf_resources.py` is located in the same directory as the PowerShell script, or update the PowerShell script to point to the correct location of the Python script.

## Known Issues

This utility was hacked together in a hurry to help me in a migration, as such, it does not support count and for_each. Keep this in mind when inspecting the resulting file. 