defmodule SkyRealmRestaurant do
  @moduledoc """
  Documentation for `SkyRealmRestaurant`.
  """

  alias SkyRealmRestaurant.Entities.Chef

  @doc """
  Hello world.

  ## Examples

      iex> SkyRealmRestaurant.hello()
      :world

  """
  def hello do
    :world
  end

  def print_me do
    user = %Chef{name: "Reynold"}
    IO.inspect(user)
  end
end
