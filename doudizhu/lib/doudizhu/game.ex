defmodule Doudizhu.Game do

  alias Doudizhu.Rule

  def new do
    %{
      players: %{}, #{player => %{index, ready, total}}
      winner: nil,
    }
  end

  def new_state do
    %{
      hands: [[], [], [], []],
      last:[[], [], []],
      last_valid: {},
      current_player: nil,
      current_round: 0,
      landlord: nil,
      base: 3,
    }
  end
  
  @doc """
  Add an user to current table if there is a seat, report :error otherwise.
  """
  def add_player(game, player) do
    players = game[:players]
    if (map_size(p) < 3) do
      p = %{index: map_size(players), ready: false, total:0}
      game = %{game | players: Map.put(players, player, p)}
      {:ok, game}
    else
      {:error, game}
    end
  end

  @doc """
  Set a player to be ready for a game, if all the players are ready, 
  start the game directly.
  """
  def ready(game, player) do
    players = game[:players]
    |> Map.put(player, %{players[player] | ready: true})

    if Enum.reduce(players, false, fn {_, y}, acc -> y[:ready] && acc end) do
      {:go, Map.put(game, :players, players)}
    else
      {:ready, Map.put(game, :players, players)}
    end
  end
  
  @doc """
  Initialize the game, deal cards to each player and set 3 card for
   landlord.
  Return the new game state
  """
  def init_game(game) do
    new_state
    |> Map.put(:hands, deal_cards)
    |> Map.put(:bid, [])
    |> (&(Map.put(game, :state, &1))).()
  end

  @doc """
  Add a player to the candidate for the landlord
  """ 
  def bid_landlord(game, player) do
    state = game[:state]
    state[:bid] 
    |> Enum.concat([player]) 
    |> Enum.uniq
    |> (&(Map.put(state, :bid, &1))).()
    |> (&(Map.put(game, :state, &1))).()
  end
  
  @doc """
  Pick a landlord from the candidate, assign the 3 extra card 
  to him/her
  """
  def assign_lord(game) do
    # pick a landlord
    state = game[:state]
    bid = if game[:winner] == nil, do: state[:bid], 
          else: state[:bid] ++ [game[:winner]]
    ll = Enum.take_random(bid, 1)
    # Assign 3 cards
    index = game[:players][ll][:index]
    hands = state[:hands]
    hands = merge(hands, index, 3)
    state = %{state | hands: hands, 
                      landlord: ll, 
                      current_player: ll}
    %{game | state: state, bid: []}
  end

  # if the user does not give any card, assume player is 
  # the current player
  def play_cards(game, []) do
    state = game[:state]
    player = state[:current_player]
    case state[:last_valid] do
      {} -> {:error, game}
      {^player, _} -> {:error, game}
      {p, f} -> 
        # next round, shift current player
        state = %{state | current_player: next_player(game[:players], player),
                          current_round: state[:current_round] + 1}
        {:ok, Map.put(game, :state, state)}
    end
  end
  
  # if the user feed cards, assume the player is the current player
  def play_cards(game, cards) do
    cards = preproc(cards)
    state = game[:state]
    player = state[:current_player]
    if has_card(game, player, cards) do
    	case validate(game, cards) do
        {true, feature} -> 
          {:ok, update(game, player, cards, feature)}
        {false, _} -> {:error, game}
      end
    else
      {:error, game}
    end
  end

  # check whether there is a player played all his card
  # If it is, return a new game state with the updated winner,
  # player information, which is a state before preparing for a new game.
  def terminated(game) do
    wi = game
        |> Map.get(:state)
        |> Map.get(:hands)
        |> Enum.find_index(&Enum.empty?/1)
    case wi do
      nil -> {false, game}
      w -> base = game[:state][:base]
           landlord = Map.get(game[:players], game[:state][:landlord])
           p = game[:players]
           |> Enum.map(fn {k, v} -> # {player, %{index:, ready:, total:} 
                {k, update_score({w, v, base, landlord)} 
              end)
           |> Map.new
           winner = game[:players] 
           |> Enum.find(fn {k, v} -> v[:index] == wi end)
           |> elem(0)
           {true, %{player: p, winner: winner}}
    end
  end

  # calculate the total score, return a new information map
  # %{index: , ready: , total:}
  defp update_score(winner, info, base, landlord) do
    if winner != landlord, do: base = -base
    case info[:index] do
      ^landlord -> {index: landlord, 
                    ready: false, 
                    total: info[:total] + base * 2}
      a -> {index: a, 
            ready: false, 
            total: info[:total] - base}
    end
  end

  # find the next player, given the index map and current player
  defp next_player(players, player) do
    index = rem(players[player][:index] + 1, 3)
    players 
    |> Enum.find(fn {k, v} -> v[:index] == index end)
    |> elem(0)
  end
  
  defp has_card(game, player, cards) do
    index = game[:players][player][:index]
    h = Enum.at(game[:state][:hands], index)
    (length(h) - length(cards)) == length(h -- cards)
  end
  
  # Validate the card by following step:
  # 1. get the feature of current playing
  # 2. check whether current playing can conquer last valid playing
  # return {true/false, feature of the lastest valid playing}
  defp validate(game, cards) do
    state = game[:state]
    case state[:last_valid] do
      {} -> {true, Rule.get_cat(cards)}
      {^players, _} -> {true, Rule.get_cat(cards)}
      {_, f} -> cards 
                |> get_cat 
                |> Rule.conquer(f)
    end
  end
  
  # Preprocess, get ride of the suits, then sort the cards
  defp preproc(cards) do
   cards
   |> Enum.map(fn(x) ->
        if x < 52 do
          div(x, 4)
        end
      end)
   |> Enum.sort
  end
  
  # Update the state of current game: 
  # Player's hands, last playing
  # current_round, current_player last_valid playing
  # base if there is a bomb or rocket
  defp update(game, player, cards, feature) do
    state = game[:state]
    index = game[:players][player][:index]
    hands = state[:hands]
    |> Enum.at(index)
    |> (&(&1 -- cards)).()
    |> (&(List.replace_at(state[:hands], index, &1))).()
    last = List.replace_at(state[:last], index, cards)
    base = case feature do
      :rocket -> 2 * state[:base]
      {:bomb, _len, _low} -> 2 * state[:base]
      _ -> state[:base]
    end
    state = %{state | hands: hands,
                      last: last,
                      base: base,
                      current_player: next_player(game[:players], player),
                      current_round: state[:current_round] + 1},
                      last_valid: {player, feature},
            }
    %{game | state: state}
  end
  
  defp merge(list, a, b) do 
    l1 = Enum.at(list, a)
    l2 = Enum.at(list, b)
    List.replace_at(list, a, l1 ++ l2)
  end
  
  defp deal_cards() do
    [0..53]
    |> Enum.concat
    |> Enum.shuffle
    |> Enum.chunk_every(17)
  end

end
