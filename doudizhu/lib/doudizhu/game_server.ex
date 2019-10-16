defmodule Doudizhu.GameServer do
  use GenServer
  
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
    game = Doudizhu.BackupAgent.get(name) || Doudizhu.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end
  
  def start_game(name) do
    GenServer.call(reg(name), {:start})
  end
  
  def playCard(name, player, cards) do
    GenServer.call(reg(name), {:paly, player, cards})
  end
  
  
  def init(game) do
    {:ok, game}
  end
  
end
