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
			llCards: [],
			hands: [], // this the cards this client has
			left: {},
			right: {},
			middle: {},
			selected: [],
			base: 3,
			time: 0,
			messages: [],
			ob: false
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
			this.setState({ob: true})
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

	ready() {
		this.channel.push("ready", {});
	}

	bid() {
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
			<h2 align="center">Hello, {window.playerName}! Welcome to Fight Against Landlord game room "{window.gameName}"... </h2>

			<div className="row-firstline">
				{/*<Scoreboard root={this} />*/}
				<LandlordCard renderCards={this.renderCards.bind(this)} data={this.state.llCards} />
				<Timer time={this.state.time}/>
			</div>
			<div className="row">
				<div className="column" float="left">
					<OpponentDealCard renderCards={this.renderCards.bind(this)} data={this.state.left} />
				</div>
				<div className="column" float="right">
					<OpponentDealCard renderCards={this.renderCards.bind(this)} data={this.state.right} />
				</div>
			</div>
			<div className="column">
				<MyDealCard root={this} data={this.state.middle} />
			</div>

			<button className="readyButton" 
				onClick={this.ready.bind(this)}>Ready!</button>
			<button className="readyButton" 
				onClick={this.bid.bind(this)}>Bid for Landlord!</button>
			<button className="readyButton" 
				onClick={this.play.bind(this)}>Hands Out!</button>
			<div className="column">
				<AHandOfCard hands={this.state.hands} 
					selected={this.state.selected}
					onSelect={this.onSelect.bind(this)} />
			</div>
			<Chat display={this.state.ob} data={this.state.messages}
				onKeyPress={this.submit.bind(this)}/>
		</div>
		);
	}
}

function Chat(props) {
	if (props.display) {
		let m = [];
		for (let i = 0; i < props.data.length; i++) {
			let u = props.data[i][0];
			let t = props.data[i][1];
			m.push(
				<li> {u}: {t} </li>
				)
		}
		return (
			<div className= "row">
				<ul>{m} </ul>
				<input type="text" id="chat-input" 
					onKeyPress={props.onKeyPress} />
			</div>
			);
	} else {
		return <div></div>
	}
}

function OpponentDealCard(props) {
	let cards = props.renderCards(props.data.last)
	return (
		<div>
			<p>{props.data.player}</p>
			<p>{props.data.total}</p>
			<p>{cards}</p>
		</div>
	);
}

function MyDealCard(props) {
	let cards = props.root.renderCards(props.data.last)
	return (
		<div>
			<p>{props.data.player}</p>
			<p>{props.data.total}</p>
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
			<div className="row">
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

