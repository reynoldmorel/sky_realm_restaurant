defmodule SkyRealmRestaurant do
  alias SkyRealmRestaurant.Seed.InitialData

  @moduledoc """
  Documentation for `SkyRealmRestaurant`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SkyRealmRestaurant.hello()
      :world

  """
  def hello do
    :world
  end

  def initialize_data, do: InitialData.run()
end
