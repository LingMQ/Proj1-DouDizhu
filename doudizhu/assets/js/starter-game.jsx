import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';


export default function game_init(root, channel) {
	ReactDOM.render(<Game channel={channel}/>, root);
}

class Game extends React.Component {
	constructor(props) {
		super(props);
		this.channel = props.channel;
		this.state = {
			// phase: null,
			landlord: null,
			currentPlayer: null,
			llCards: [],
			hands: [], // this the cards this client has
			left: {},
			right: {},
			middle: {},
			selected: [],
			base: 3,
			time: 0,
			text: [],
			ob: false,
			readyButton: false,
			bidLandlordButton: false,
		};
		
		this.channel.join()
				.receive("ok", this.init_ob.bind(this))
				// TODO: display the reason
				.receive("error", resp => {console.log("Can't join!", resp)});

		

		this.channel.on("user_joined", this.get_view.bind(this));
		this.channel.on("user_ready", this.get_view.bind(this));
		this.channel.on("user_bid", this.get_view.bind(this));
		this.channel.on("start_bid", this.get_view.bind(this));
		this.channel.on("update", this.get_view.bind(this));
		this.channel.on("terminate", this.get_view.bind(this));

		this.channel.on("new_msg", this.new_msg.bind(this));
	}

	renderCards(cards) {
		let c = [];
		if (cards) {
			for (let i = 0; i < cards.length; i++) {
		      c.push(<Card key={cards[i]} value={cards[i]} select={false} />);
		    }
		}
	    return c;
	}

	init_ob(view) {
		if (view.game) {
			this.setState(view.game);
			this.setState({ob: true, text: view.text})
		}
	}

	get_view(view) {
		if (view.time) {
			this.setState(view.game);
			this.setState({time: view.time});
			clearInterval(this.timeId);
			this.timeId = setInterval(() => this.tick(), 1000);
		} else {
			this.setState(view.game);
		}
	}

	tick() {
		let time = this.state.time - 1;
		if (time < 1) {
			console.log("clearInterval!")
			clearInterval(this.timeId);
		}
		this.setState(_.extend(this.state, {time: time}));
	}

	submit(ev) {
		let chatIn = document.querySelector("#chat-input")
		if (ev.charCode === 13) {
			this.channel.push("chat", {text: chatIn.value});
			chatIn.value = "";
		}
	}

	new_msg(msg) {
		this.setState(msg);
	}

	switch_view(player) {
		this.channel.push("switch", {player: player})
					.receive("ok", (view) => (this.setState(view.game)))
	}

	ready() {
		this.setState({readyButton: true})
		this.channel.push("ready", {});
	}

	bid() {
		if (this.state.readyButton == true) {
			this.setState({bidLandlordButton: true})
		}
		this.channel.push("bid", {});
	}

	play() {
		this.channel.push("play", {cards: this.state.selected});
	}

	onSelect(card) {
		let s = this.state.selected.concat([]);
		if (s.includes(card)) {
			s.splice(s.indexOf(card), 1);
		} else {
			s.push(card);
		}
		this.setState(_.extend(this.state, {selected: s}));
	}

	render() {
		return (
		<div>
			<h2 className="gameTitle"> Game Room</h2> <h1 className="gameTitle"> {window.gameName} </h1>

			<div className="row">
				{/*<Scoreboard root={this} />*/}
				<div className="column">
					<div className="row">
						<p className="firstLineInfo"><u> Landlord: {this.state.landlord} </u></p>
					</div>
					<div className="row">
						<p className="firstLineInfo"><u> Current Player: {this.state.currentPlayer} </u></p>
					</div>
				</div>
				<div className="column" align="center">
				<LandlordCard renderCards={this.renderCards.bind(this)} data={this.state.llCards} />
				</div>
				<div className="column">
				<Timer time={this.state.time}/>
				</div>
			</div>
			<div className="row">
				<div className="column" float="left">
					<OpponentDealCard renderCards={this.renderCards.bind(this)} 
						data={this.state.left} 
						ob={this.state.ob}
						switch={this.switch_view.bind(this)}/>
				</div>
				<div className="column" float="right">
					<OpponentDealCard renderCards={this.renderCards.bind(this)} 
						data={this.state.right} 
						ob={this.state.ob} 
						switch={this.switch_view.bind(this)}/>
				</div>
				<Chat display={this.state.ob} data={this.state.text}
					  onKeyPress={this.submit.bind(this)}/>
			</div>
			<div className="column">
				<MyDealCard root={this} data={this.state.middle} />
			</div>

			<div className="row-button">
				<button className="readyButton" disabled={this.state.readyButton}
					onClick={this.ready.bind(this)}>Ready!</button>
				<button className="readyButton" disabled={this.state.bidLandlordButton}
					onClick={this.bid.bind(this)}>Bid for Landlord!</button>
			</div>
				<button className="handoutButton"
					onClick={this.play.bind(this)}>Hands Out!</button>
			<div className="column">
				<AHandOfCard hands={this.state.hands} 
					selected={this.state.selected}
					onSelect={this.onSelect.bind(this)} />
			</div>
		</div>
		);
	}
}

function Chat(props) {
	if (props.display) {
		let m = [];
		for (let i = props.data.length - 1; i >= 0; i--) {
			let u = props.data[i][0];
			let t = props.data[i][1];
			let k = u + i;
			m.push(
				<li key={k}> {u}: {t} </li>
				);
		}
		return (
			<div className= "row-firstline">
				<p className="chatterPlace"> Chatter Place </p>
				<input type="text" id="chat-input"
					   onKeyPress={props.onKeyPress} />
				<ul>{m} </ul>
			</div>
			);
	} else {
		return <div></div>
	}
}

function OpponentDealCard(props) {
	let cards = props.renderCards(props.data.last);
	let p = props.data.player;
	let text = "";
	if (props.data.ready) {
		text = props.data.player + "is Ready!"
	}

	if (props.ob) {
		<div>
			<button className="handoutButton"
					onClick={() => props.switch(p)}>Watch {p}</button>
			<p className="player"> Score: {props.data.total}</p>
			<p>{text}</p>
			<p>{cards}</p>
		</div>
	} else {
		return (
		<div>
			<p className="player"> Player: {p}</p>
			<p className="player"> Score: {props.data.total}</p>
			<p>{text}</p>
			<p>{cards}</p>
		</div>
	);
	}
}

function MyDealCard(props) {
	let cards = props.root.renderCards(props.data.last)
	let text = ""
	if (props.data.ready) {
		text = "I am Ready!"
	}
	return (
		<div>
			<p className="player"> Player: {props.data.player}</p>
			<p className="player"> Score: {props.data.total}</p>
			<p>{text}</p>
			<p>{cards}</p>
		</div>
		);
}


function AHandOfCard(props) {
	let h = [];
	let s = _.concat(props.selected, [])
	for(let i = 0; i < props.hands.length; i++) {
		let f = s.includes(props.hands[i]);
		h.push(<Card key={props.hands[i]} 
			value={props.hands[i]} 
			select={f} 
			onSelect={() => props.onSelect(props.hands[i])} />)
	}
	return (
			<div className="row" align="center">
				{h}
			</div>
		);
}

function Card(props) {
	let cardUrl = (require("./card").dict)[props.value];
	if (props.select) {
		return (<span onClick={props.onSelect}>
			<img src={cardUrl} width="85" height="160"/>
			</span>);
	} else {
		return (<span onClick={props.onSelect}>
			<img src={cardUrl} width="58" height="108"/>
			</span>);
	}
}

function LandlordCard(props) {
	let cards = props.renderCards(props.data)
	return (<div className="dizhuCard">
					{cards}
			</div>);
}

function Timer(props) {
	return (<div className="time"> {props.time} </div>)
}

