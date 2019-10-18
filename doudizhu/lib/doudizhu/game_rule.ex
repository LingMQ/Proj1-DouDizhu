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
    map = count(cards, %{})
    l1 = []
    l2 = []
    l3 = []
    l4 = []
  end 
  
  defp count([], m) do
    m
  end
  
  defp count(c, m) do
    [ head | c ] = c
    m = Map.put(m, head, Map.get(m, head, 0) + 1)
    count(c, m)
  end


end
