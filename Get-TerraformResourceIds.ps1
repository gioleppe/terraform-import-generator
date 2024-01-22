param(
    [Parameter(Mandatory=$true)]
    [string]$TerraformFilePath,

    [Parameter(Mandatory=$true)]
    [string]$TerraformStateFilePath
)

# Ensure the terraform state file exists
if (-Not (Test-Path $TerraformStateFilePath)) {
    Write-Error "Terraform state file not found at the path: $TerraformStateFilePath"
    exit 1
}

# Ensure the terraform file exists
if (-Not (Test-Path $TerraformFilePath)) {
    Write-Error "Terraform file not found at the path: $TerraformFilePath"
    exit 1
}

# Define the import file path
$ImportFilePath = "$TerraformFilePath-import.tf"

# Clear the contents of the import file if it already exists, or create a new one if it does not
if (Test-Path $ImportFilePath) {
    Clear-Content $ImportFilePath
} else {
    New-Item -Path $ImportFilePath -ItemType File
}

# Process each resource from the Terraform configuration file
python parse_tf_resources.py $TerraformFilePath | ForEach-Object {
    $resource = $_ | ConvertFrom-Json
    $resourceType = $resource.type
    $resourceName = $resource.name
    $query = ".resources[] | select(.type == `"$resourceType`" and .name == `"$resourceName`").instances[0].attributes.id"
    
    # Run jq query to get resource ID
    $resourceId = jq -r $query $TerraformStateFilePath
    
    # Check if the resource ID is not empty or null
    if (-Not [string]::IsNullOrWhiteSpace($resourceId)) {
        # Construct the import block
        $importBlock = "import {`n  to = `"$resourceType.$resourceName`"`n  id = `"$resourceId`"`n}`n"
        
        # Append the import block to the import file
        Add-Content -Path $ImportFilePath -Value $importBlock
    }
}

Write-Host "Import blocks have been written to $ImportFilePath"
