defmodule FuelCalculator do
  @moduledoc """
  The purpose of module is to calculate fuel to launch from one planet of the Solar system,
  and to land on another planet of the Solar system, depending on the flight route.

  The formula for fuel calculations for the launch is the following:
  mass * gravity * 0.042 - 33 rounded down

  The formula for fuel calculations for the landing is the following:
  mass * gravity * 0.033 - 42 rounded down

  Note that fuel adds weight to the ship, so it requires additional fuel,
  until additional fuel is 0 or negative.
  Additional fuel is calculated using the same formula from above.

  Take into account that fuel calculated in a way
  that it carried for all steps of trip from the single starting point.
  """

  @doc """
  Run calculations.

  ## Example

      iex> FuelCalculator.run(28801, [{:launch, 9.807}, {:land, 1.62}, {:launch, 1.62}, {:land, 9.807}])
      {:ok, 51898}

  Note that flight_params should be correct, for instance it can't contain two landings
  or launches in row or start from landing:

      iex> FuelCalculator.run(28801, [{:land, 9.807}])
      {:error, "Incorrect flight params"}

      iex> FuelCalculator.run(28801, [{:launch, 9.807}, {:launch, 1.62}, {:land, 9.807}])
      {:error, "Incorrect flight params"}

      iex> FuelCalculator.run(28801, [{:launch, 9.807}, {:land, 1.62}, {:land, 9.807}])
      {:error, "Incorrect flight params"}
  """
  @spec run(number(), [{:launch | :land, number()}]) ::
          {:ok, pos_integer()} | {:error, String.t()}
  def run(ship_mass, flight_params) do
    with :ok <- check_flight_params(flight_params) do
      result =
        flight_params
        |> Enum.reverse()
        |> Enum.reduce(0, &(&2 + one_direction_fuel_weight(&1, &2 + ship_mass)))

      {:ok, result}
    end
  end

  defp one_direction_fuel_weight({:launch, gravity}, flight_ship_mass) do
    launch = fn mass -> trunc(mass * gravity * 0.042 - 33) end
    fuel_weight(launch, launch.(flight_ship_mass))
  end

  defp one_direction_fuel_weight({:land, gravity}, flight_ship_mass) do
    land = fn mass -> trunc(mass * gravity * 0.033 - 42) end
    fuel_weight(land, land.(flight_ship_mass))
  end

  defp fuel_weight(calc_fun, weight), do: fuel_weight(calc_fun, weight, weight)

  defp fuel_weight(calc_fun, weight, acc) do
    additional_weight = calc_fun.(weight)

    if additional_weight > 0 do
      fuel_weight(calc_fun, additional_weight, additional_weight + acc)
    else
      acc
    end
  end

  defp check_flight_params(params) do
    with res when res in [:land, :launch] <- check_flight_directions(params), do: :ok
  end

  defp check_flight_directions(params) do
    Enum.reduce_while(params, :launch, fn {direction, _}, expected_direction ->
      if direction != expected_direction do
        {:halt, {:error, "Incorrect flight params"}}
      else
        {:cont, if(direction == :land, do: :launch, else: :land)}
      end
    end)
  end
end
