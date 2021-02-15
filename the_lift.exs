defmodule Kata do
  def the_lift(queues, capacity) do
    queues
    |> init_state
    |> Map.put(:capacity, capacity)
    |> run_lift
  end
  
  def init_state(queues) do
    Enum.reduce(queues, %{todo: 0}, fn x, acc -> 
      acc
      |> Map.put(map_size(acc) - 1, x)
      |> Map.update!(:todo, &(&1 + length(x)))
    end)
    |> Map.put(:floor, 0)
    |> Map.put(:history, [0])
    |> Map.put(:riders, [])
    |> Map.put(:height, length(queues) - 1)
  end
  
  def run_lift(%{:todo => 0} = state), do: state.history |> add_history(0) |> Enum.reverse
  def run_lift(state) do
    state
    |> validate_direction
    |> pick_up
    |> move
    |> drop_off
    |> run_lift
  end
  
  def validate_direction(%{:floor => a, :height => a} = state), do: Map.put(state, :direction, "DN")
  def validate_direction(%{:floor => 0} = state), do: Map.put(state, :direction, "UP")
  def validate_direction(state), do: state
  
  def pick_up(state) do
    {ready, not_ready} =
      Enum.split_with(state[state.floor], fn x -> 
        case state.direction do
          "UP" -> x > state.floor
          "DN" -> x < state.floor
        end
      end)
      
    {taken, cant_fit} = 
      Enum.split(ready, state.capacity - length(state.riders))
      
    state
    |> Map.update!(:riders, &(taken ++ &1))
    |> Map.put(state.floor, not_ready ++ cant_fit)
    |> Map.put(:history, if length(ready) > 0 do add_history(state.history, state.floor) else state.history end)
  end
    
  def move(%{:direction => "UP"} = state), do: Map.update!(state, :floor, &(&1 + 1))
  def move(%{:direction => "DN"} = state), do: Map.update!(state, :floor, &(&1 - 1))
  
  def drop_off(state) do
    {done, waiting} = Enum.split_with(state.riders, &(&1 == state.floor))
    done = length(done)
    
    state
    |> Map.update!(:todo, &(&1 - done))
    |> Map.put(:riders, waiting)
    |> Map.put(:history, if done > 0 do add_history(state.history, state.floor) else state.history end)
  end
  
  def add_history([h | t], h), do: [h | t]
  def add_history([h | t], a), do: [a | [h | t]]
end
