defmodule SkyRealmRestaurant.Seed.InitialData do
  alias SkyRealmRestaurant.Controllers.CashierController
  alias SkyRealmRestaurant.Controllers.EmployeeController
  alias SkyRealmRestaurant.Controllers.UserController
  alias SkyRealmRestaurant.Controllers.WaiterController
  alias SkyRealmRestaurant.Controllers.ClientController
  alias SkyRealmRestaurant.Controllers.ChefController
  alias SkyRealmRestaurant.Controllers.CategoryController
  alias SkyRealmRestaurant.Controllers.FinalProductController
  alias SkyRealmRestaurant.Controllers.ProductController
  alias SkyRealmRestaurant.Controllers.InventoryController
  alias SkyRealmRestaurant.Controllers.TaxController
  alias SkyRealmRestaurant.Services.InMemoryStore.RoleService
  alias SkyRealmRestaurant.Services.InMemoryStore.UserRoleService
  alias SkyRealmRestaurant.Services.InMemoryStore.ProductCategoryService
  alias SkyRealmRestaurant.Services.InMemoryStore.ProductTaxService
  alias SkyRealmRestaurant.Services.InMemoryStore.InventoryProductService
  alias SkyRealmRestaurant.Services.InMemoryStore.FinalProductProductService

  alias SkyRealmRestaurant.Entities.Cashier
  alias SkyRealmRestaurant.Entities.Employee
  alias SkyRealmRestaurant.Entities.User
  alias SkyRealmRestaurant.Entities.Waiter
  alias SkyRealmRestaurant.Entities.Client
  alias SkyRealmRestaurant.Entities.Chef
  alias SkyRealmRestaurant.Entities.Category
  alias SkyRealmRestaurant.Entities.FinalProduct
  alias SkyRealmRestaurant.Entities.Product
  alias SkyRealmRestaurant.Entities.Inventory
  alias SkyRealmRestaurant.Entities.Tax
  alias SkyRealmRestaurant.Entities.Role
  alias SkyRealmRestaurant.Entities.UserRole
  alias SkyRealmRestaurant.Entities.ProductCategory
  alias SkyRealmRestaurant.Entities.ProductTax
  alias SkyRealmRestaurant.Entities.InventoryProduct
  alias SkyRealmRestaurant.Entities.FinalProductProduct

  alias SkyRealmRestaurant.Constants.MeasureUnit
  alias SkyRealmRestaurant.Constants.CookingStatus

  def run do
    create_ceo()
    create_users()
    create_cashiers()
    create_waiters()
    create_clients()
    create_chefs()
    create_categories()
    create_products()
    create_final_products()
    create_inventories()
    create_taxes()
    create_roles()
    create_user_roles()
    create_product_categories()
    create_product_taxes()
    create_inventory_products()
    create_final_product_products()
    {:ok}
  end

  def create_ceo() do
    ceo_john = %Employee{
      employee_type: "ceo",
      employee_code: "00001",
      document_id: "402-5458964-3",
      name: "John",
      last_name: "Gilbert",
      age: 52,
      username: "jgilbert",
      password: "1234"
    }

    EmployeeController.create(ceo_john)
  end

  def create_cashiers() do
    cashier_michael = %Cashier{
      employee_code: "00002",
      document_id: "402-5458964-2",
      name: "Michael",
      last_name: "Smith",
      age: 25,
      username: "msmith",
      password: "1234"
    }

    CashierController.create(cashier_michael)
  end

  def create_users() do
    user_juan = %User{
      document_id: "402-5458964-1",
      name: "Juan",
      last_name: "Almonte",
      age: 34,
      username: "jalmonte",
      password: "1234"
    }

    UserController.create(user_juan)
  end

  def create_waiters() do
    waiter_pedro = %Waiter{
      document_id: "402-5458964-4",
      name: "Pedro",
      last_name: "Perez",
      age: 28,
      username: "pperez",
      password: "1234"
    }

    WaiterController.create(waiter_pedro)
  end

  def create_clients() do
    client_jose = %Client{
      client_code: "c00005",
      document_id: "402-5458964-5",
      name: "Jose",
      last_name: "Almanzar",
      age: 22,
      username: "jalmanzar",
      password: "1234"
    }

    ClientController.create(client_jose)
  end

  def create_chefs() do
    chef_alberto = %Chef{
      document_id: "402-5458964-6",
      name: "Alberto",
      last_name: "Torres",
      age: 36,
      username: "atorres",
      password: "1234",
      experience_level: 3
    }

    ChefController.create(chef_alberto)

    chef_angel = %Chef{
      document_id: "402-5458964-7",
      name: "Angel",
      last_name: "Capellan",
      age: 30,
      username: "acapellan",
      password: "1234",
      experience_level: 8
    }

    ChefController.create(chef_angel)

    chef_reynold = %Chef{
      document_id: "402-5458964-8",
      name: "Reynold",
      last_name: "Morel",
      age: 37,
      username: "rmorel",
      password: "1234",
      experience_level: 5
    }

    ChefController.create(chef_reynold)
  end

  def create_categories() do
    category_beverages = %Category{
      name: "Beverages"
    }

    CategoryController.create(category_beverages)

    category_sandwiches = %Category{
      name: "Sandwiches"
    }

    CategoryController.create(category_sandwiches)

    category_fries = %Category{
      name: "Fries"
    }

    CategoryController.create(category_fries)
  end

  def create_products() do
    product_cheese = %Product{
      serial: "xxx-000-001",
      name: "Cheese",
      display_name: "Cheese",
      price: 80,
      supported_measure_units: [MeasureUnit.unit()]
    }

    ProductController.create(product_cheese)

    product_tomatoe = %Product{
      serial: "xxx-000-002",
      name: "Tomatoe",
      display_name: "Tomatoe",
      price: 5,
      supported_measure_units: [MeasureUnit.unit()]
    }

    ProductController.create(product_tomatoe)

    product_bread = %Product{
      serial: "xxx-000-003",
      name: "Bread",
      display_name: "Bread",
      price: 15,
      supported_measure_units: [MeasureUnit.slice()]
    }

    ProductController.create(product_bread)

    product_jam = %Product{
      serial: "xxx-000-004",
      name: "Jam",
      display_name: "Jam",
      price: 150,
      supported_measure_units: [MeasureUnit.slice()]
    }

    ProductController.create(product_jam)
  end

  def create_final_products() do
    final_product_hamburger = %FinalProduct{
      serial: "xxx-0fp-001",
      name: "Hamburger",
      display_name: "Hamburger",
      price: 350,
      supported_measure_units: [MeasureUnit.unit()],
      difficulty_level: 5,
      cooking_steps: CookingStatus.get_cooking_steps(2)
    }

    FinalProductController.create(final_product_hamburger)

    final_product_jam_sandwich = %FinalProduct{
      serial: "xxx-0fp-002",
      name: "Jam Sandwich",
      display_name: "Jam Sandwich",
      price: 350,
      supported_measure_units: [MeasureUnit.unit()],
      difficulty_level: 3,
      cooking_steps: CookingStatus.get_cooking_steps(3)
    }

    FinalProductController.create(final_product_jam_sandwich)

    final_product_lemon_juice = %FinalProduct{
      serial: "xxx-0fp-003",
      name: "Lemon Juice",
      display_name: "Lemon Juice",
      price: 50,
      supported_measure_units: [MeasureUnit.unit()],
      difficulty_level: 1,
      cooking_steps: CookingStatus.get_cooking_steps(5)
    }

    FinalProductController.create(final_product_lemon_juice)
  end

  def create_inventories() do
    inventory = %Inventory{
      name: "Inventory"
    }

    InventoryController.create(inventory)
  end

  def create_taxes() do
    tax_18 = %Tax{
      name: "18% ITBIS",
      tax_value: 0.18,
      tax_percentage: 18,
      is_order: false,
      is_product: true
    }

    TaxController.create(tax_18)

    tax_10_ley = %Tax{
      name: "10% Ley",
      tax_value: 0.1,
      tax_percentage: 10,
      is_order: true,
      is_product: false
    }

    TaxController.create(tax_10_ley)
  end

  def create_roles() do
    role_admin = %Role{
      name: "admin"
    }

    RoleService.create(role_admin)

    role_chef = %Role{
      name: "chef"
    }

    RoleService.create(role_chef)

    role_user = %Role{
      name: "user"
    }

    RoleService.create(role_user)

    role_client = %Role{
      name: "client"
    }

    RoleService.create(role_client)

    role_waiter = %Role{
      name: "waiter"
    }

    RoleService.create(role_waiter)

    role_cashier = %Role{
      name: "cashier"
    }

    RoleService.create(role_cashier)
  end

  def create_user_roles() do
    {:ok, [%Role{id: role_admin_id} | roles]} = RoleService.find_all()
    [%Role{id: role_chef_id} | roles] = roles
    [%Role{id: role_user_id} | roles] = roles
    [%Role{id: role_client_id} | roles] = roles
    [%Role{id: role_waiter_id} | roles] = roles
    [%Role{id: role_cashier_id} | _roles] = roles

    {:ok, %User{id: user_jalmonte_id}} = UserController.find_by_username_enabled("jalmonte")

    {:ok, %Employee{id: ceo_jgilbert_id}} =
      EmployeeController.find_by_username_enabled("jgilbert")

    {:ok, %Cashier{id: cashier_msmith_id}} = CashierController.find_by_username_enabled("msmith")

    {:ok, %Waiter{id: waiter_pperez_id}} = WaiterController.find_by_username_enabled("pperez")

    {:ok, %Client{id: cient_jalmanzar_id}} =
      ClientController.find_by_username_enabled("jalmanzar")

    {:ok, %Chef{id: chef_atorres_id}} = ChefController.find_by_username_enabled("atorres")

    {:ok, %Chef{id: chef_acapellan_id}} = ChefController.find_by_username_enabled("acapellan")

    {:ok, %Chef{id: chef_rmorel_id}} = ChefController.find_by_username_enabled("rmorel")

    UserRoleService.create(%UserRole{user_id: user_jalmonte_id, role_id: role_user_id})

    UserRoleService.create(%UserRole{user_id: ceo_jgilbert_id, role_id: role_admin_id})

    UserRoleService.create(%UserRole{user_id: cashier_msmith_id, role_id: role_cashier_id})

    UserRoleService.create(%UserRole{user_id: waiter_pperez_id, role_id: role_waiter_id})

    UserRoleService.create(%UserRole{user_id: cient_jalmanzar_id, role_id: role_client_id})

    UserRoleService.create(%UserRole{user_id: chef_atorres_id, role_id: role_chef_id})

    UserRoleService.create(%UserRole{user_id: chef_acapellan_id, role_id: role_chef_id})

    UserRoleService.create(%UserRole{user_id: chef_rmorel_id, role_id: role_chef_id})
  end

  def create_product_categories() do
    {:ok, [%Category{id: cateogry_beverages_id} | categories]} = CategoryController.find_all()
    [%Category{id: category_sandwiches} | categories] = categories
    [%Category{id: category_fries} | _categories] = categories

    {:ok, %Product{id: product_cheese_id}} =
      ProductController.find_by_serial_enabled("xxx-000-001")

    {:ok, %Product{id: product_tomatoe_id}} =
      ProductController.find_by_serial_enabled("xxx-000-002")

    {:ok, %Product{id: product_bread_id}} =
      ProductController.find_by_serial_enabled("xxx-000-003")

    {:ok, %Product{id: product_jam_id}} = ProductController.find_by_serial_enabled("xxx-000-004")

    {:ok, %FinalProduct{id: final_product_hamburger_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-001")

    {:ok, %FinalProduct{id: final_product_jam_sandwich_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-002")

    {:ok, %FinalProduct{id: final_product_lemon_juice_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-003")

    ProductCategoryService.create(%ProductCategory{
      product_id: product_cheese_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: product_tomatoe_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: product_bread_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: product_jam_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: product_jam_id,
      category_id: category_fries
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: final_product_hamburger_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: final_product_jam_sandwich_id,
      category_id: category_sandwiches
    })

    ProductCategoryService.create(%ProductCategory{
      product_id: final_product_lemon_juice_id,
      category_id: cateogry_beverages_id
    })
  end

  def create_product_taxes() do
    {:ok, [%Tax{id: tax_18_id} | _taxes]} = TaxController.find_all()

    {:ok, %Product{id: product_cheese_id}} =
      ProductController.find_by_serial_enabled("xxx-000-001")

    {:ok, %Product{id: product_tomatoe_id}} =
      ProductController.find_by_serial_enabled("xxx-000-002")

    {:ok, %Product{id: product_bread_id}} =
      ProductController.find_by_serial_enabled("xxx-000-003")

    {:ok, %Product{id: product_jam_id}} = ProductController.find_by_serial_enabled("xxx-000-004")

    {:ok, %FinalProduct{id: final_product_hamburger_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-001")

    {:ok, %FinalProduct{id: final_product_jam_sandwich_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-002")

    {:ok, %FinalProduct{id: final_product_lemon_juice_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-003")

    ProductTaxService.create(%ProductTax{
      product_id: product_cheese_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: product_tomatoe_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: product_bread_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: product_jam_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: product_jam_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: final_product_hamburger_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: final_product_jam_sandwich_id,
      tax_id: tax_18_id
    })

    ProductTaxService.create(%ProductTax{
      product_id: final_product_lemon_juice_id,
      tax_id: tax_18_id
    })
  end

  def create_inventory_products() do
    {:ok, [%Inventory{id: inventory_id} | _inventories]} = InventoryController.find_all()

    {:ok, %Product{id: product_cheese_id}} =
      ProductController.find_by_serial_enabled("xxx-000-001")

    {:ok, %Product{id: product_tomatoe_id}} =
      ProductController.find_by_serial_enabled("xxx-000-002")

    {:ok, %Product{id: product_bread_id}} =
      ProductController.find_by_serial_enabled("xxx-000-003")

    {:ok, %Product{id: product_jam_id}} = ProductController.find_by_serial_enabled("xxx-000-004")

    {:ok, %FinalProduct{id: final_product_hamburger_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-001")

    {:ok, %FinalProduct{id: final_product_jam_sandwich_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-002")

    {:ok, %FinalProduct{id: final_product_lemon_juice_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-003")

    InventoryProductService.create(%InventoryProduct{
      product_id: product_cheese_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: product_tomatoe_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: product_bread_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: product_jam_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: product_jam_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: final_product_hamburger_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: final_product_jam_sandwich_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })

    InventoryProductService.create(%InventoryProduct{
      product_id: final_product_lemon_juice_id,
      inventory_id: inventory_id,
      quantity: 100,
      measure_unit: MeasureUnit.unit()
    })
  end

  def create_final_product_products() do
    {:ok, %Product{id: product_cheese_id}} =
      ProductController.find_by_serial_enabled("xxx-000-001")

    {:ok, %Product{id: product_tomatoe_id}} =
      ProductController.find_by_serial_enabled("xxx-000-002")

    {:ok, %Product{id: product_bread_id}} =
      ProductController.find_by_serial_enabled("xxx-000-003")

    {:ok, %Product{id: product_jam_id}} = ProductController.find_by_serial_enabled("xxx-000-004")

    {:ok, %FinalProduct{id: final_product_hamburger_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-001")

    {:ok, %FinalProduct{id: final_product_jam_sandwich_id}} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-002")

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_cheese_id,
      final_product_id: final_product_hamburger_id,
      quantity: 2,
      measure_unit: MeasureUnit.unit()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_tomatoe_id,
      final_product_id: final_product_hamburger_id,
      quantity: 1,
      measure_unit: MeasureUnit.unit()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_bread_id,
      final_product_id: final_product_hamburger_id,
      quantity: 2,
      measure_unit: MeasureUnit.slice()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_cheese_id,
      final_product_id: final_product_jam_sandwich_id,
      quantity: 2,
      measure_unit: MeasureUnit.unit()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_jam_id,
      final_product_id: final_product_jam_sandwich_id,
      quantity: 2,
      measure_unit: MeasureUnit.unit()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_tomatoe_id,
      final_product_id: final_product_jam_sandwich_id,
      quantity: 1,
      measure_unit: MeasureUnit.unit()
    })

    FinalProductProductService.create(%FinalProductProduct{
      product_id: product_bread_id,
      final_product_id: final_product_jam_sandwich_id,
      quantity: 2,
      measure_unit: MeasureUnit.slice()
    })
  end
end
