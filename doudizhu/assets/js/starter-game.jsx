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
			// TODO: state for timer
		};
		
		this.channel.join()
				.receive("ok", () => {console.log(this.state)})
				// TODO: display the reason
				.receive("error", resp => {console.log("Can't join!", resp)});

		

		this.channel.on("user_joined", this.get_view.bind(this));
		this.channel.on("user_ready", this.get_view.bind(this));
		this.channel.on("user_bid", this.get_view.bind(this));
		this.channel.on("start_bid", this.get_view.bind(this));
		// this.channel.on("update", this.get_view.bind(this));
		// this.channel.on("terminate", this.get_view.bind(this));
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

	get_view(view) {
		console.log(view);
		this.setState(view);
	}

	ready() {
		this.channel.push("ready", {});
	}

	bid() {
		this.channel.push("bid", {});
	}

	onSelect(card) {
		let s = this.state.selected.concat([]);
		if (s.includes(card)) {
			index = s.indexOf(card);
			s.splice(index, 1);
		} else {
			s = s.push(card);
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
				<Timer root={this}/>
			</div>
			<div className="row">
				<div className="column" float="left">
					<OpponentDealCard root={this} data={this.state.left} />
				</div>
				<div className="column" float="right">
					<OpponentDealCard root={this} data={this.state.right} />
				</div>
			</div>
			<div className="column">
				<MyDealCard root={this} data={this.state.middle} />
			</div>

			<button className="readyButton" 
				onClick={this.ready.bind(this)}>Ready!</button>
			<button className="readyButton" 
				onClick={this.bid.bind(this)}>Bid for Landlord!</button>
			<div className="column">
				<AHandOfCard hands={this.state.hands} 
					selected={this.state.selected}
					onSelect={this.onSelect.bind(this)} />
			</div>
		</div>
		);
	}
}

function OpponentDealCard(props) {
	let cards = props.root.renderCards(props.data.last)
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

// class AHandOfCard extends React.Component {
// 	renderCard(faceValue, select) {
// 		return <Card value={faceValue} select={select}/>
// 	}
// 	render() {
// 		let r = [];
// 		for (let i = 0; i < 10; i++) {
// 			r.push(this.renderCard("back", false))
// 		}
// 		r.push(<Card value={32} select={true} />)
// 		for (let i = 11; i < 20; i++) {
// 			r.push(this.renderCard("back", false))
// 		}
// 		return (
// 			<div className="row">
// 				{r}
// 			</div>
// 		);
// 	}
// }

function AHandOfCard(props) {
	let h = [];
	console.log(props);
	console.log(h.includes(1));
	for(let i = 0; i < props.hands.length; i++) {
		let f = (props.selected).includes(props.hands[i]);
		h.push(<Card key={props.hands[i]} 
			value={props.hands[i]} 
			select={f} 
			onSelect={() => props.onSelect(i)} />)
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

// class Scoreboard extends React.Component{
// 	renderOnePlayer(i, score) {
// 		let name = "Player" + (i + 1)
// 		return (
// 			<div className="rowScore">
// 				<div className="name"> {name} </div>
// 				<div className="score"> {score} </div>
// 			</div>
// 		)
// 	}

// 	render() {
// 		let scoreData = this.props.root.state.score
// 		let l = [];
// 		for (let i = 0; i < scoreData.length; i++) {
// 			l.push(this.renderOnePlayer(i, scoreData[i]))
// 		}
// 		return (
// 			<div id="container">
// 				{l}
// 			</div>
// 		);
// 	}
// }

function LandlordCard(props) {
	let cards = props.renderCards(props.data)
	return (<div className="dizhuCard">
					{cards}
			</div>);
}

function Timer(props) {
	return (<div className="time"> 00:00:00 </div>)
}

