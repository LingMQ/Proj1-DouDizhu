defmodule Doudizhu.BackupAgent do
  use Agent
  
  # TODO: Add timestamps and expiration.
  
  def start_link(_opt) do 
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end
  
  def put(name, val) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, val)
    end
  end
  
  def get(name) do 
    Agent.get __MODULE, fn state -> 
      Map.get(state, name)
    end
  end
end
