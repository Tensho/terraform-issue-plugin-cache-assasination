#!/bin/bash

set -x

# Backup current Terraform CLI configuration file
cp ~/.terraformrc ~/.terraformrc.bak

# Configure Terraform CLI to use provider cache directory
echo "plugin_cache_dir = \"\$HOME/.terraform.d/providers-cache\"" > ~/.terraformrc

# Create custom providers cache directory if it doesn't yet exist
mkdir -p ~/.terraform.d/providers-cache

# Cleanup custom providers cache directory
rm -rf ~/.terraform.d/providers-cache/*

# Install "null" provider to plugins directory during "provider-null" project initialization as usual.
# Terraform caches provider symlinking to the actual binary file in plugins directory.
terraform init provider-null

# >>> Here ninja comes and assassinates cached provider. For example, it could happen if you manually change providers layout due to the new hierarchical providers layout in Terraform 0.13.

# Delete "null" provider binary file from cache
rm -rf ~/.terraform.d/provider-caches/registry.terraform.io/hashicorp/null/2.1.0/darwin_amd64
# Now we have broken symlink: .terraform/plugins/... –> ~/.terraform.d/provider-caches/...

# >>> Let's try to work with "archive" provider in "provider-archive" project...

# Install "archive" provider to plugin directory as usual
terraform init provider-archive

# Error: Failed to validate installed provider
#
# Validating provider hashicorp/archive v1.3.0 failed: selected package for
# registry.terraform.io/hashicorp/archive is no longer present in the target
# directory; this is a bug in Terraform

# Restore saved Terraform CLI configuration file back
mv ~/.terraformrc.bak ~/.terraformrc

# Remove custom providers cache directory
rm -rf ~/.terraform.d/providers-cache
