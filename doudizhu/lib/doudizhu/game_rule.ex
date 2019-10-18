defmodule Doudizhu.Rule do
  @moduledoc """
  This is a module that imposes the rule of fighting landlord.
  """
  
  def get_cat([]) do
    :none
  end

  def get_cat([52, 53]) do
    :rocket
  end

  def get_cat(cards) when length(cards) < 5 do
    if (hd(cards) == List.last(cards)) do
      case length(cards) do
        1 -> :single
        2 -> :pair
        3 -> :trio
        4 -> :bomb
      end
    else
      if length(cards) == 4 
        && (Enum.at(cards, 0) == Enum.at(cards, 2) 
        || Enum.at(cards, 1) == Enum.at(cards, 3)) do
        :trio1
      end
    end
  end
  
  def get_cat(cards) do
  	cards
    |> count(%{})
    |> (&(Enum.group_by(&1, 
            fn {x, y} -> Map.get(&1, x) end, 
            fn {x, y} -> x end))).()
    |> cat_helper(length(cards))
  end 
  
  defp count([], m) do
    m
  end
  
  defp count(c, m) do
    [ head | c ] = c
    m = Map.put(m, head, Map.get(m, head, 0) + 1)
    count(c, m)
  end

  # trio with 2
  defp cat_helper(%{2 => [a], 3 => [b]}}, 5) do
  	{:trio2, b}
  end

  # four with two individual single tickers
  defp cat_helper(%{1 => _, 4 => [b]}, 6) do
  	{:four1, b}
  end

  # four with two individual pair tickers 
  defp cat_helper(%{2 => [a, b], 4 => [c]}, 8) do
  	{:four2, c}
  end
   
  # TODO: airplane sequence 2,3,4,5,6 
  defp cat_helper() do
  	
  end

  # TODO: airplane sequence with single kiker, 2,3,4,5

  # TODO: airplane sequence with double kiker, 2,3,4

  # TODO: single sequence 5-12 last < 12

  # TODO: double sequence 3-10, last < 12


end
