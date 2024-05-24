# Terraform File Generator

## Overview

This project provides a PowerShell script that dynamically generates Terraform configuration files (`main.tf`, `variables.tf`, and `outputs.tf`) based on JSON input. This approach streamlines the process of creating Terraform files, making infrastructure management more efficient and less error-prone.

## Features

- **Automates Terraform file creation**: Generates `main.tf`, `variables.tf`, and `outputs.tf` files dynamically.
- **JSON-based input**: Uses a JSON file to define the provider, resources, variables, and outputs.
- **Module-based approach**: Ensures consistency and reduces manual errors by following a predefined pattern.

## Prerequisites

- **PowerShell**: Ensure PowerShell is installed on your system.
- **Terraform**: Basic knowledge of Terraform and its configuration files.

## Usage

### Step 1: Prepare JSON Input

Create a JSON file (e.g., `example.json`) with the necessary configuration details. Below is a sample JSON structure:

```json
{
    "provider": {
        "name": "aws"
    },
    "variables": [
        {
            "name": "region",
            "description": "The AWS region to deploy in",
            "type": "string",
            "default": "us-west-2"
        },
        {
            "name": "instance_type",
            "description": "The type of instance to use",
            "type": "string",
            "default": "t2.micro"
        },
        {
            "name": "instance_name",
            "description": "The name of the instance",
            "type": "string",
            "default": "ExampleInstance"
        }
    ],
    "resources": [
        {
            "type": "aws_instance",
            "name": "example",
            "properties": {
                "ami": "var.ami",
                "instance_type": "var.instance_type"
            }
        }
    ],
    "outputs": [
        {
            "name": "instance_id",
            "description": "The ID of the EC2 instance",
            "value": "aws_instance.example.id"
        },
        {
            "name": "public_ip",
            "description": "The public IP of the EC2 instance",
            "value": "aws_instance.example.public_ip"
        }
    ]
}
```
## Step 2: Run the PowerShell Script
### Save the PowerShell script below as generate_terraform_files.ps1:

```Powershell
param (
    [string]$jsonInput
)

function New-MainTf {
    param (
        $data
    )

    $provider = $data.provider
    $resources = $data.resources

    $providerBlock = @"
provider "$($provider.name)" {
  region = var.region
}`n
"@

    $resourcesBlock = ""

    foreach ($resource in $resources) {
        $resourceBlock = @"
resource "$($resource.type)" "$($resource.name)" {
"@
        foreach ($key in $resource.properties.Keys) {
            $resourceBlock += "  $key = $($resource.properties.$key)`n"
        }
        $resourceBlock += @"
`n  tags = {
    Name = var.instance_name
  }
}`n
"@ 
        $resourcesBlock += $resourceBlock
    }

    $content = $providerBlock + $resourcesBlock
    Set-Content -Path ".\main.tf" -Value $content
}

function New-VariablesTf {
    param (
        [PSCustomObject]$data
    )

    $variables = $data.variables

    $variablesBlock = ""

    foreach ($var in $variables) {
        $default = if ($var.ContainsKey('default')) { "  default     = `"$($var.default)`"" } else { "" }
        $variableBlock = @"
variable "$($var.name)" {
  description = "$($var.description)"
  type        = $($var.type)
$default
}`n
"@
        $variablesBlock += $variableBlock
    }

    Set-Content -Path ".\variables.tf" -Value $variablesBlock
}

function New-OutputsTf {
    param (
        [PSCustomObject]$data
    )

    $outputs = $data.outputs

    $outputsBlock = ""

    foreach ($output in $outputs) {
        $outputBlock = @"
output "$($output.name)" {
  description = "$($output.description)"
  value       = $($output.value)
}`n
"@
        $outputsBlock += $outputBlock
    }

    Set-Content -Path ".\outputs.tf" -Value $outputsBlock
}

function Main {
    param (
        $jsonInput
    )

    $data = $jsonInput | ConvertFrom-Json
    New-MainTf -data $data
    New-VariablesTf -data $data
    New-OutputsTf -data $data
    Write-Output "Terraform files have been generated successfully."
}

Read the JSON input file
$jsonInput = Get-Content -Path ".\example.json"
Main -jsonInput $jsonInput
```

# Step 3: Execute the Script
Open PowerShell and navigate to the directory containing the script and the JSON file. Run the following command to execute the script:
```PowerShell
Copy code
.\generate_terraform_files.ps1
```
## Result
Upon execution, the script will generate the following Terraform configuration files in the same directory:

&#8226; main.tf <br>
&#8226; variables.tf <br>
&#8226; outputs.tf# <br>
