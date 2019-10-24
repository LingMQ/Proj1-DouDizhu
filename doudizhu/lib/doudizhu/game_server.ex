defmodule Doudizhu.GameServer do
  use GenServer

  alias Doudizhu.BackupAgent
  alias Doudizhu.Game
  alias Doudizhu.Chat
  
  @doc """
  Generate the process query statement with given name.
  """
  def reg(name) do
    {:via, Registry, {Doudizhu.GameReg, name}}
  end
  
  @doc """
  Start a new game process under the supervisor's charge.
  """
  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Doudizhu.GameSup.start_child(spec)
  end
  
  def start_link(name) do
    game = BackupAgent.get(name) 
      || Game.new() |> Map.merge(Chat.new())
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  # client side interface

  @doc """
  Add a new player to current game if there is no more than 
  3 player in this room
  Return {:ok, game} states if success, :error otherwise.
  """
  def add_player(name, player) do
    GenServer.call(reg(name), {:add, name, player})
  end

  @doc """
  Add a new observer to current game 
  Return game states if success, :error otherwise.
  """
  def add_observer(name, observer) do
    GenServer.call(reg(name), {:add_ob, name, observer})
  end

  def add_text(name, observer, text) do
    GenServer.call(reg(name), {:add_text, name, observer, text})
  end

  def set_player(name, observer, player) do
    GenServer.call(reg(name), {:set_p, name, observer, player})
  end

  @doc """
  Set a player to be ready for a new game, if all three players are prepared,
  The game will be started automatically.
  Return the latest game state
  """
  def ready(name, player) do
    GenServer.call(reg(name), {:ready, name, player})
  end

  @doc """
  Put a player into the pool bidding for the landlord.
  Return the latest game state
  """
  def bid(name, player) do
    GenServer.call(reg(name), {:bid, name, player})
  end

  @doc """
  Pick a landlord from the bidding pool, the winner of last game have 
  double chance to get the landlord.
  """
  def assign_landlord(name) do
    GenServer.call(reg(name), {:assign, name})
  end

  @doc """
  Play the cards for the given player, return the updated game state
  """
  def play_cards(name, player, cards) do
    GenServer.call(reg(name), {:play, name, player, cards})
  end

  def naive_play(name) do
    GenServer.call(reg(name), {:naive, name})
  end

  @doc """
  Check if there is a player has played all its cards, set it as the winner
  Reset the game to the pre-ready state.
  """
  def terminate(name) do
    GenServer.call(reg(name), {:terminate, name})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end
  
  # Server side implementation
  def init(game) do
    {:ok, game}
  end

  def handle_call({:add, name, player}, _from, game) do
    case Game.add_player(game, player) do
      {:ok, game} -> BackupAgent.put(name, game)
                     {:reply, {:ok, game}, game}
      {:error, game} -> {:reply, :error, game}
    end
  end

  def handle_call({:add_ob, name, observer}, _from, game) do
    case Chat.add_observer(game, observer) do
      {:ok, game} -> BackupAgent.put(name, game)
                     {:reply, {:ok, game}, game}
      {:error, reason} -> {:reply, {:error, reason}, game}
    end
  end

  def handle_call({:add_text, name, ob, text}, _from, game) do
    case Chat.add_text(game, ob, text) do
      {:error, reason} -> {:reply, {:error, reason}, game}
      {:ok, game} -> BackupAgent.put(name, game)
        {:reply, {:ok, game}, game}
    end
  end

  def handle_call({:add_text, name, ob, p}, _from, game) do
    case Chat.set_player(game, ob, p) do
      {:error, reason} -> {:reply, {:error, reason}, game}
      {:ok, game} -> BackupAgent.put(name, game)
        {:reply, {:ok, game}, game}
    end
  end

  def handle_call({:ready, name, player}, _from, game) do
    case Game.ready(game, player) do
      {:ready, game} -> BackupAgent.put(name, game)
                     {:reply, {:ready, game}, game}
      {:go, game} -> game = Game.init_game(game)
                     BackupAgent.put(name, game)
                     {:reply, {:go, game}, game}
    end
  end

  def handle_call({:bid, name, player}, _from, game) do
    game = Game.bid_landlord(game, player)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:assign, name}, _from, game) do
    game = Game.assign_lord(game)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:play, name, player, cards}, _from, game) do
    if player == Game.current_player(game) do
      case Game.play_cards(game, cards) do
        {:ok, game} -> BackupAgent.put(name, game)
                       {:reply, game, game}
        {:error, game} -> {:reply, :error, game}
      end
    else
      {:reply, :error, game}
    end
  end

  def handle_call({:naive, name}, _from, game) do
    game = Game.naive_play(game)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:terminate, name}, _from, game) do
    case Game.terminated(game) do
      {false, game} -> {:reply, {false, game}, game}
      {true, game} -> BackupAgent.put(name, game)
                      {:reply, {true, game}, game}
    end
  end


  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end
  
end
