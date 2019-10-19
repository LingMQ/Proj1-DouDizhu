defmodule Doudizhu.Rule do
  @moduledoc """
  This is a module that imposes the rule of fighting landlord. 
  Including recognizing the type of cards played and determine whether 
  a playing can conquer the other.
  """
  @doc """
  Recognize the type of the cards as none if nothing played.
  """
  def get_cat([]) do
    :none
  end
  
  @doc """
  Recognize the type of the cards as rocket if both jokers are played.
  """
  def get_cat([52, 53]) do
    :rocket
  end
  
  @doc """
  Recognize the type of the cards fewer than 5.
  """
  def get_cat(cards) when length(cards) < 5 do
    if (hd(cards) == List.last(cards)) do
      case length(cards) do
        1 -> {:single, 1, hd(cards)}
        2 -> {:pair, 1, hd(cards)}
        3 -> {:trio0, 1, hd(cards)}
        4 -> {:bomb, 1, hd(cards)}
      end
    else
      if length(cards) == 4 do
        cond do
          Enum.at(cards, 0) == Enum.at(cards, 2) -> 
            {:trio1, 1, hd(cards)}
          Enum.at(cards, 1) == Enum.at(cards, 3) ->
            {:trio1, 1, List.last(cards)}
          true -> :illegal
        end
      else
        :illegal
      end
    end
  end
  
  @doc """
  Recognize the type of cards more or equal than 5
  """
  def get_cat(cards) do
  	cards
    |> count(%{})
    |> Enum.group_by( 
            fn {_, y} -> y end, 
            fn {x, _} -> x end)
    |> cat_helper(length(cards))
  end 
  
  defp count([], m) do
    m
  end
  
  # Count the frequence of each cards, return a map %{card => freq}
  defp count(c, m) do
    [ head | c ] = c
    m = Map.put(m, head, Map.get(m, head, 0) + 1)
    count(c, m)
  end

  # trio with 2
  defp cat_helper(%{2 => [_a], 3 => [b]}, 5) do
  	{:trio2, 1, b}
  end

  # four with two individual single tickers
  defp cat_helper(%{1 => _, 4 => [b]}, 6) do
  	{:four1, 1, b}
  end

  # four with two individual pair tickers 
  defp cat_helper(%{2 => [_a, _b], 4 => [c]}, 8) do
  	{:four2, 1, c}
  end

  # airplane sequence with single kiker, 2,3,4,5
  defp cat_helper(%{1 => a, 3 => b}, l) when rem(l, 4) == 0 do
  	la = length(a)
  	lb = length(b)
  	if la + lb * 3 == l && la == lb && Enum.max(b) < 12 do
  		{:air1, lb, b |> Enum.sort |> hd}
  	else
  		:illegal
  	end
  end

  # airplane sequence with double kiker, 2,3,4
  defp cat_helper(%{2 => a, 3 => b}, l) when rem(l, 5) == 0 do
  	la = length(a)
  	lb = length(b)
  	if la + lb * 3 == l && la == lb  && Enum.max(b) < 12 do
  		{:air2, lb, b |> Enum.sort |> hd}
  	else
  		:illegal
  	end
  end


  # airplane sequence 2,3,4,5,6 without ticker, :air0
  defp cat_helper(%{3 => a}, l) when rem(l, 3) == 0 do
  	if length(a) * 3 == l && Enum.max(a) < 12 do
  		{:air0, length(a), a |> Enum.sort |> hd}
  	else
  		:illegal
  	end
  end

  # single sequence 5-12 last < 12
  defp cat_helper(%{1 => a}, l) do
  	a = Enum.sort(a)
  	if (length(a) == l 
  		&& List.last(a) < 12
  		&& List.last(a) - hd(a) == l - 1) do
  		{:schain, length(a), hd(a)}
  	else
  		:illegal
  	end
  end

  # double sequence 3-10, last < 12
  defp cat_helper(%{2 => a}, l) do
  	a = Enum.sort(a)
  	if (length(a) * 2 == l 
  		&& List.last(a) < 12
  		&& List.last(a) - hd(a) == div(l, 2) - 1) do
  		{:pchain, length(a), hd(a)}
  	else
  		:illegal
  	end
  end

  # Capture whatever other illegal case
  defp cat_helper(_) do
  	:illegal
  end

end
