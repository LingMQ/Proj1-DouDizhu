defmodule Doudizhu.Game do

  def new do
    %{
      players: %{},
      hands: [],
      last: [],
      last_valid: {},
      current_player: nil,
      landlord: nil,
      base: 3,
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
  
  # TODO: check if there is three player
  @doc """
  Initialize the game, deal cards to each player and set 3 card for
   landlord.
  """
  def init_game(game) do
    %{game | hands: deal_cards()} 
  end
  
  @doc """
  Assign the 3 extra card to the 
  """
  def assign_lord(game, player) do
    index = game[:players][player]
    hands = game[:hands]
    hands = merge(hands, index, 3)
    %{game | hands: hands, landlord: player}
  end
  
  def play_cards(game, player, cards) do
    if has_card(game, player, cards) 
    	and validate(game, player, cards) do
    	# TODO: bomb
      {:ok, update(game, player, cards, false)}
    else
      {:error, game}
    end
  end
  
  defp has_card(%{hands: hands, players: p}, player, cards) do
    index = p[player]
    h = Enum.at(hands, index)
    (length(h) - length(cards)) == length(h -- cards)
  end
  
  defp validate(game, player, cards) do
    
  end
  
  defp preproc(cards) do
   cards
   |> Enum.map(fn(x) ->
        if x < 52 do
          div(x, 4)
        end
      end)
   |> Enum.sort
  end
  
  defp update(game, player, cards, bomb) do
    index = game[:players][player]
    hands = game[:hands]
    |> Enum.at(index)
    |> (&(&1 -- cards)).()
    |> (&(List.replace_at(game[:hands], index, &1))).()
    last = List.replace_at(game[:last], index, cards)
    if (bomb) do
      game = Map.put(game, :base, 2 * game[:base])
      %{game | hands: hands, last: last}
    else
      %{game | hands: hands, last: last}
    end
    
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
