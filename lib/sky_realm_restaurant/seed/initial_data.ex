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

  alias SkyRealmRestaurant.Constants.MeasureUnit

  def run do
    create_ceo()
    create_cashiers()
    create_waiters()
    create_clients()
    create_chefs()
    create_categories()
    create_products()
    create_final_products()
    create_inventories()
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
      difficulty_level: 5
    }

    FinalProductController.create(final_product_hamburger)

    final_product_jam_sandwich = %FinalProduct{
      serial: "xxx-0fp-002",
      name: "Jam Sandwich",
      display_name: "Jam Sandwich",
      price: 350,
      supported_measure_units: [MeasureUnit.unit()],
      difficulty_level: 3
    }

    FinalProductController.create(final_product_jam_sandwich)
  end

  def create_inventories() do
    inventory = %Inventory{
      name: "Inventory"
    }

    InventoryController.create(inventory)
  end
end
