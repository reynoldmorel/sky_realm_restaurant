defmodule SkyRealmRestaurant do
  alias SkyRealmRestaurant.Seed.InitialData

  alias SkyRealmRestaurant.Controllers.OrderController
  alias SkyRealmRestaurant.Controllers.CategoryController
  alias SkyRealmRestaurant.Controllers.FinalProductController
  alias SkyRealmRestaurant.Controllers.TaxController
  alias SkyRealmRestaurant.Controllers.CashierController
  alias SkyRealmRestaurant.Controllers.InventoryController
  alias SkyRealmRestaurant.Entities.Order
  alias SkyRealmRestaurant.Entities.OrderDetail
  alias SkyRealmRestaurant.Entities.Cashier

  alias SkyRealmRestaurant.Constants.MeasureUnit

  alias SkyRealmRestaurant.Core.Simulator.Server
  alias SkyRealmRestaurant.Core.Simulator.KitchenSimulator
  alias SkyRealmRestaurant.Core.Queue

  alias SkyRealmRestaurant.Constants.PreparationStatus

  @moduledoc """
  Documentation for `SkyRealmRestaurant`.
  """

  def create_order() do
    {:ok, %Cashier{id: cashier_msmith_id}} = CashierController.find_by_username_enabled("msmith")

    {:ok, final_product_jam_sandwich} =
      FinalProductController.find_by_serial_enabled("xxx-0fp-002")

    {:ok, [_category_beverages | [category_sandwiches | _categories]]} =
      CategoryController.find_all()

    {:ok, [tax_itbis_18 | _taxes]} = TaxController.find_all_taxes_for_products_enabled()

    {:ok, [tax_ley_10 | _taxes]} = TaxController.find_all_taxes_for_orders_enabled()

    {:ok, [inventory | _categories]} = InventoryController.find_all()

    OrderController.create(%Order{
      cashier_id: cashier_msmith_id,
      order_details: [
        %OrderDetail{
          product: final_product_jam_sandwich,
          categories: [category_sandwiches],
          taxes: [tax_itbis_18],
          quantity: 1,
          price: final_product_jam_sandwich.price,
          selected_measure_unit: MeasureUnit.unit(),
          inventory: inventory
        }
      ],
      taxes: [tax_ley_10],
      paid_amount: 1000
    })
  end

  def initialize_data, do: InitialData.run()

  def run_simulator do
    queue_capacity = 100_000

    ready_preparaion_status = PreparationStatus.ready()

    kitchen_simulator_queues =
      Map.put(%{}, ready_preparaion_status, %Queue{
        capacity: queue_capacity,
        name: ready_preparaion_status
      })

    preparing_preparaion_status = PreparationStatus.preparing()

    kitchen_simulator_queues =
      Map.put(kitchen_simulator_queues, preparing_preparaion_status, %Queue{
        capacity: queue_capacity,
        name: preparing_preparaion_status
      })

    completed_preparaion_status = PreparationStatus.completed()

    kitchen_simulator_queues =
      Map.put(kitchen_simulator_queues, completed_preparaion_status, %Queue{
        capacity: queue_capacity,
        name: completed_preparaion_status
      })

    canceled_preparaion_status = PreparationStatus.canceled()

    kitchen_simulator_queues =
      Map.put(kitchen_simulator_queues, canceled_preparaion_status, %Queue{
        capacity: queue_capacity,
        name: canceled_preparaion_status
      })

    Server.start_link(%{
      simulators: [KitchenSimulator],
      kitchen_simulator_state: %{queues: kitchen_simulator_queues}
    })
  end
end
