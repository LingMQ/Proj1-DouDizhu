defmodule Doudizhu.Game do

  def new do
    %{
      players: %{},
      hands: [],
      last: [],
      last_player: {},
      base: 0,
    }
  end
  
  @doc """
  Add an user to current table if there is a seat, report :error otherwise.
  """
  def add_player(game, player) do
    p = game[:players]
    if (map_size(p) < 3) do
      game = %{game | players: Map.put(p, player, map_size(p))}
      {:ok, game}
    else
      {:error, game}
    end
  end
  
  def init_game(game) do
    %{game | hands: deal_cards()} 
  end
  
  def assign_lord(game, player) do
    index = game[:players][player]
    hands = game[:hands]
    hands = merge(hands, index, 3)
    Map.put(game, :hands, hands)
  end
  
  defp merge(list, a, b) do 
    l1 = Enum.at(list, a)
    l2 = Enum.at(list, b)
    List.replace_at(list, a, l1 ++ l2)
  end
  
  defp deal_cards() do
    new_cards([], 53) 
    |> Enum.shuffle
    |> Enum.chunk_every(17)
  end
  
  defp new_cards(card, 0) do
   [0 | card]
  end
  
  defp new_cards(card, count) do
   new_cards([count | card], count - 1)
  end

end
