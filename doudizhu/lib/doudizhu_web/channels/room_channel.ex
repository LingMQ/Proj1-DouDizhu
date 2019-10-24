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

					IO.inspect(game)		
					send(self(), {:after_join, game})

					{:ok, socket}
		end
	end


	def handle_out(msg, game, socket) do
		push(socket, msg, 
			Game.client_view(game, socket.assigns[:user]))
		{:noreply, socket}
	end

	# TODO: for ready, we can just reply with 
	def handle_in("ready", _, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		case GameServer.ready(name, user) do
			{:ready, game} -> broadcast!(socket, "user_ready", game)
			{:go, game} -> broadcast!(socket, "start_bid", game)
						   Process.send_after(self(), {:assign, name}, 15000)
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
		 		{false, game} -> broadcast!(socket, "update", game)
								 Process.send_after(
								 	self(), 
									{:next, name, Game.current_round(game)}, 
									30000)
		 		{true, game} ->  broadcast!(socket, "terminate", game)
		 			IO.inspect(game)
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
		broadcast!(socket, "update", game)
		{:noreply, socket}
	end

	def handle_info({:next, name, current_round}, socket) do
		cr = name 
			|> GameServer.peek 
			|> Game.current_round
		if current_round == cr do
			GameServer.naive_play(name)
			case GameServer.terminate(name) do
		 		{false, game} -> broadcast!(socket, "update", game)
					Process.send_after(self(), 
						{:next, name, Game.current_round(game)}, 30000)
		 		{true, game} ->  broadcast!(socket, "terminate", game)
			end
		end
		{:noreply, socket}
	end


end