provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git@github.com:pankajyadavdevops/terraform-azure-resource-group.git"
  version     = "1.0.1"
  name        = "app"
  environment = "test"
  location    = "North Europe"
}

module "vnet" {
  source              = "git@github.com:pankajyadavdevops/terraform-azure-vnet.git"
  version             = "1.0.1"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

module "subnet" {
  source               = "git@github.com:pankajyadavdevops/terraform-azure-subnet.git"
  version              = "1.0.1"
  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}
module "nat_gateway" {
  depends_on          = [module.resource_group, module.vnet]
  source              = "./../."
  name                = "app"
  environment         = "test"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  subnet_ids          = module.subnet.default_subnet_id
}
