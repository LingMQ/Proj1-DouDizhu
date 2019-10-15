defmodule Doudizhu.GameSup do
  @moduledoc """
  This is the supervisor that supervises all the game processes.
  """
  use DynamicSupervisor
  
  def start_link(arg) do
  	DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end
  
  @doc """
  Callback that called after initialization. Initialize a new Registry for
  name-process mapping and a new supervisor for supervising process.
  """
  @impl true
  def init(_arg) do
    {:ok, _} = Registry.start_link(keys: :unique, name: Doudizhu.GameReg)
    DynamicSupervisor.init(strategy: :one_for_one)
  end
  
  @doc"""
  Spawn a new child process with given specification.
  """
  @impl true
  def start_child(spec) do
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
