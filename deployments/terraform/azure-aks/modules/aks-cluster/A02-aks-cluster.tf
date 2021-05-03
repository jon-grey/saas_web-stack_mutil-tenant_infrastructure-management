

# az aks create \
#     -n $AZURE_AKS_CLUSTER_NAME \
#     -g $AZURE_RESOURCE_GROUP \
#     -l $AZURE_LOCATION \
#     -c 2 \
#     --vm-set-type AvailabilitySet  \
#     --generate-ssh-keys \
#     --service-principal $ARM_CLIENT_ID \
#     --client-secret $ARM_CLIENT_SECRET

resource "azurerm_user_assigned_identity" "aks" {
  name                = "user-assigned-identity_${var.cluster_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "aks" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "aks_save_key" {
  triggers = {
    key = tls_private_key.aks.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.root}/.ssh
      echo "${tls_private_key.aks.private_key_pem}" > ${path.root}/.ssh/id_rsa
      chmod 0600 ${path.root}/.ssh/id_rsa
EOF
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  dns_prefix          = var.dns_prefix
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version
  private_cluster_enabled = false

  linux_profile {
    admin_username = var.admin_username

    ## SSH key is generated using "tls_private_key" resource
    ssh_key {
      key_data = "${trimspace(tls_private_key.aks.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  default_node_pool {
    os_disk_size_gb = 30
    node_count      = var.agent_count
    name            = "agentpool"
    vm_size         = "Standard_D2_v2"
    type            = "VirtualMachineScaleSets"
  }

  # service_principal {
  #   client_id     = var.client_id
  #   client_secret = var.client_secret
  # }

  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks.id
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    # deprecated from v19 in AKS
    kube_dashboard {
      enabled = false
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "kubenet"
  }

  tags = {
    environment = "multistage"
  }
}

resource "azurerm_role_assignment" "aks" {
  role_definition_name = "Contributor"
  scope                = azurerm_kubernetes_cluster.aks.id
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

