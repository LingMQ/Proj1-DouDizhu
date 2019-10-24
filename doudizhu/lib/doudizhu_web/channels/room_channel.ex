defmodule DoudizhuWeb.RoomChannel do
	use DoudizhuWeb, :channel

	alias Doudizhu.Game
	alias Doudizhu.GameServer

	intercept [
		"user_joined", 
		"user_ready", 
		"user_bid", 
		"start_bid", 
		"update",
		"terminate"
	]

	def join("room:" <> name, payload, socket) do
		user = payload["user"]
		GameServer.start(name)
		case GameServer.add_player(name, user) do
			:error -> {:error, %{reason: "This room is full!"}}
			game -> socket = socket 
							|> assign(:name, name) 
							|> assign(:user, user)

					send(self(), {:after_join, game})

					{:ok, socket}
		end
	end

	def handle_out("start_bid", view, socket) do
		game = view["game"]
		push(socket, "update", 
			Map.put(view, "game", 
				Game.client_view(game, socket.assigns[:user])))
		{:noreply, socket}
	end

	def handle_out("update", view, socket) do
		game = view["game"]
		push(socket, "update", 
			Map.put(view, "game", 
				Game.client_view(game, socket.assigns[:user])))
		{:noreply, socket}
	end

	def handle_out(msg, game, socket) do
		push(socket, msg, 
			%{"game" => Game.client_view(game, socket.assigns[:user])})
		{:noreply, socket}
	end

	# TODO: for ready, we can just reply with 
	def handle_in("ready", _, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		case GameServer.ready(name, user) do
			{:ready, game} -> broadcast!(socket, "user_ready", game)
			{:go, game} -> broadcast_limited("start_bid", 
				{:assign, name}, game, 15, socket)
		end
		{:noreply, socket}
	end

	def handle_in("bid", _, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		game = GameServer.bid(name, user)
		broadcast!(socket, "user_bid", game)
		{:noreply, socket}
	end

	def handle_in("play", %{"cards" => cards}, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		if GameServer.play_cards(name, user, cards) == :error do
			{:reply, {:error, %{reason: "Cannot play in this way!"}}, socket}
		else
			case GameServer.terminate(name) do
		 		{false, game} -> broadcast_limited("update", 
					{:next, name, Game.current_round(game)}, game, 30, socket)

		 		{true, game} ->  broadcast!(socket, "terminate", game)
			end
		end
		{:noreply, socket}
	end

	def handle_info({:after_join, game}, socket) do
		broadcast!(socket, "user_joined", game)
		{:noreply, socket}
	end

	def handle_info({:assign, name}, socket) do
		game = GameServer.assign_landlord(name)
		broadcast_limited("update", 
			{:next, name, Game.current_round(game)}, game, 30, socket)
		{:noreply, socket}
	end

	def handle_info({:next, name, current_round}, socket) do
		cr = name 
			|> GameServer.peek 
			|> Game.current_round
		if current_round == cr do
			GameServer.naive_play(name)
			case GameServer.terminate(name) do
		 		{false, game} -> broadcast_limited("update", 
					{:next, name, Game.current_round(game)}, game, 30, socket)
		 		{true, game} ->  broadcast!(socket, "terminate", game)
			end
		end
		{:noreply, socket}
	end

	defp broadcast_limited(msg, self_msg, game, time, socket) do
		IO.inspect(self_msg)
		IO.inspect(time)
		broadcast!(socket, msg, %{"game" => game, "time" => time})
		Process.send_after(self(), self_msg, time * 1000)
	end


end