defmodule Doudizhu.Chat do

	def new do
		%{
			observers: %{}, # ob => seat
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
			|> Map.put(ob, game[:players] |> Map.values |> hd)
			{:ok, %{game | observers: obs}}
		else
			{:error, "Duplicate name!"}
		end
	end

	def add_text(game, ob, text) do
		if Map.has_key?(game[:observers], ob) do
			{:ok, %{game | history: game[:history] ++ [[ob, text]]}}
		else
			{:error, "No such observer!"}
		end
	end

	@doc """
	Get the name of the player the given observer is watching.
	"""
	def get_player(game, ob) do
		if Map.has_key?(game[:observers], ob) do
			index = game[:observers][ob]
			{:ok, Doudizhu.Game.get_player(game, index)}
		else
			{:error, "No such observer!"}
		end
	end

	@doc """
	Change the player which the given observer is watching, the player is
	actually focus on the seat instead of the player.
	"""
	def set_player(game, ob, p) do
		obs = game[:observers]
		index = game[:players][p][:index]
		if Map.has_key?(obs, ob) do
			{:ok, %{game | observers: Map.put(obs, ob, index)}}
		else
			{:error, "No such observer!"}
		end
	end

end
