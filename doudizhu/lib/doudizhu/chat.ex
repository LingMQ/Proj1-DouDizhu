defmodule Doudizhu.Chat do

	def new do
		%{
			observers: %{}, # ob => players
			history: [] # 2d array [ob, text]
		}
	end

	@doc """
	Add a user to the observer lists, arbitrarily pick a player,
	for the observer to watch
	"""
	def add_observer(game, ob) do
		if !Map.has_key?(game[:players], ob) do
			obs = game[:observers]
			|> Map.put(ob, game[:players] |> Map.keys |> hd)
			{:ok, %{game | observers: obs}}
		else
			{:error, "Duplicate name!"}
		end
	end

	def add_text(game, ob, text) do
		if Map.has_key?(game[:observers], ob) do
			{:ok, %{game | history: game[:history] ++ [ob, text]}}
		else
			{:error, "No such observer!"}
		end
	end

	def get_player(game, ob) do
		if Map.has_key?(game[:observers], ob) do
			{:ok, game[:observers][ob]}
		else
			{:error, "No such observer!"}
		end
	end

	def set_player(game, ob, p) do
		obs = game[:observers]
		if Map.has_key?(obs, ob) do
			{:ok, %{game | observers: Map.put(obs, ob, p)}}
		else
			{:error, "No such observer!"}
		end
	end

end
