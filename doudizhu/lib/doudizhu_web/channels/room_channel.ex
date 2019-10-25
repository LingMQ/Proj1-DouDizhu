defmodule DoudizhuWeb.RoomChannel do
	use DoudizhuWeb, :channel

	alias Doudizhu.Game
	alias Doudizhu.Chat
	alias Doudizhu.GameServer

	intercept [
		"user_joined", 
		"user_ready", 
		"user_bid", 
		"start_bid", 
		"update",
		"terminate",
		"new_text"
	]

	def join("room:" <> name, payload, socket) do
		user = payload["user"]
		GameServer.start(name)
		case GameServer.add_player(name, user) do
			:error -> 
				case GameServer.add_observer(name, user) do
					{:error, reason} -> {:error, %{reason: reason}}	
					{:ok, game} -> 
						socket = socket 
						|> assign(:name, name) 
						|> assign(:user, user)
						{:ok, 
						%{"game" => 
						Game.client_view(game, 
							Chat.get_player(game, user) 
							|> elem(1)),
						"text" => game[:history]
						}, 
						socket}
				end
			{:ok, game} -> socket = socket 
							|> assign(:name, name) 
							|> assign(:user, user)
				send(self(), {:after_join, game})
				{:ok, socket}
		end
	end

	def handle_out("start_bid", view, socket) do
		game = view["game"]
		{t, u} = view_user(game, socket.assigns[:user])
		push(socket, "start_bid", 
			view 
			|> Map.put("game", Game.client_view(game, u))
			|> Map.put("type", t))
		{:noreply, socket}
	end

	def handle_out("update", view, socket) do
		game = view["game"]
		{t, u} = view_user(game, socket.assigns[:user])
		push(socket, "update", 
			view 
			|> Map.put("game", Game.client_view(game, u))
			|> Map.put("type", t))
		{:noreply, socket}
	end

	def handle_out("new_text", game, socket) do
		his = game[:history]
		user = socket.assigns[:user]
		{t, _} = view_user(game, user)
		if t == "o" do
			push(socket, "new_msg", %{"text" => his})
		end
		{:noreply, socket}
	end

	def handle_out("terminate", game, socket) do
		{t, u} = view_user(game, socket.assigns[:user])
		push(socket, "terminate", 
			%{} 
			|> Map.put("game", Game.client_view(game, u))
			|> Map.put("winner", game[:winner])
			|> Map.put("type", t))
		{:noreply, socket}
	end

	def handle_out(msg, game, socket) do
		{t, u} = view_user(game, socket.assigns[:user])
		push(socket, msg, 
			%{} 
			|> Map.put("game", Game.client_view(game, u))
			|> Map.put("type", t))
		{:noreply, socket}
	end

	# TODO: for ready, we can just reply with 
	def handle_in("ready", _, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		game = GameServer.peek(name)
		if not_playing(game) do
			{t, _} = view_user(game, socket.assigns[:user])
			if t == "p" do
				case GameServer.ready(name, user) do
					{:ready, game} -> broadcast!(socket, "user_ready", game)
					{:go, game} -> broadcast_limited("start_bid", 
						{:assign, name}, game, 15, socket)
				end
			end
		end
		{:noreply, socket}
	end

	def handle_in("bid", _, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		game = GameServer.peek(name)
		{t, _} = view_user(game, socket.assigns[:user])
		if t == "p" do
			broadcast!(socket, "user_bid", GameServer.bid(name, user))
		end
		{:noreply, socket}
	end

	def handle_in("play", %{"cards" => cards}, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		game = GameServer.peek(name)
		{t, _} = view_user(game, socket.assigns[:user])
		if t == "p" do
			if GameServer.play_cards(name, user, cards) == :error do
				{:reply, {:error, %{reason: "Cannot play in this way!"}}, socket}
			else
				case GameServer.terminate(name) do
			 		{false, game} -> broadcast_limited("update", 
						{:next, name, Game.current_round(game)}, game, 30, socket)

			 		{true, game} ->  broadcast!(socket, "terminate", game)
				end
			end
		end
		{:noreply, socket}
	end

	def handle_in("chat", %{"text" => text}, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		case GameServer.add_text(name, user, text) do
			{:error, reason} -> {:reply, {:error, %{reason: reason}}, socket}
			{:ok, game} -> broadcast!(socket, "new_text", game)
				{:noreply, socket}
		end
	end

	def handle_in("switch", %{"player" => player}, socket) do
		name = socket.assigns[:name]
		user = socket.assigns[:user]
		case GameServer.set_player(name, user, player) do
			{:error, reason} -> {:reply, {:error, %{reason: reason}}, socket}
			{:ok, game} -> {:reply, {:ok, 
				%{"game" => Game.client_view(game, player)}}, socket}
		end
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
		broadcast!(socket, msg, %{"game" => game, "time" => time})
		Process.send_after(self(), self_msg, time * 1000)
	end

	defp view_user(game, user) do
		p = game[:players]
		if Map.has_key?(p, user) do
			{"p", user}
		else 
			case Chat.get_player(game, user) do
				{:error, _} -> {"undefine", nil}
				{:ok, u} -> {"o", u}
			end
		end
	end


end