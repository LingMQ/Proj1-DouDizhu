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
		this.channel.join()
				.receive("ok", () => {console.log("ok!")})
				// TODO: display the reason
				.receive("error", resp => {console.log("Can't join!", resp)});

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

		// this.channel.on("user_joined", this.get_view.bind(this));
		// this.channel.on("user_ready", this.get_view.bind(this));
		// this.channel.on("user_bid", this.get_view.bind(this));
		// this.channel.on("start_bid", this.get_view.bind(this));
		// this.channel.on("update", this.get_view.bind(this));
		// this.channel.on("terminate", this.get_view.bind(this));
	}

	render() {
		return (
		<div>
			<h2 align="center">Hello, {window.playerName}! Welcome to Fight Against Landlord game room "{window.gameName}"... </h2>

			<div className="row-firstline">
				<Scoreboard root={this} />
				<div className="dizhuCard">
					<Card value={37} select={false}/>
					<Card value={37} select={false}/>
					<Card value={37} select={false}/>
				</div>
				<Timer root={this}/>
			</div>

			<div className="row">
				<div className="column" float="left">
					<OpponentDealCard root={this} />
				</div>
				<div className="column" float="right">
					<OpponentDealCard root={this} />
				</div>
			</div>
			<div className="column">
				<MyDealCard root={this} />
			</div>

			<button className="readyButton" onClick={this.addGamePlayer.bind(this)}> Ready for Game?? </button>
			<div className="column">
				<AHandOfCard root={this} />
			</div>
		</div>
		);
	}


	get_view(view) {
		this.setState(view);
	}

	// addGamePlayer() {
	// 	//TODO work on the channel side for this ???
	// 	this.channel.push("addPlayer", {})
	// 		.receive("ok", this.get_view.bind(this))
	// }
}

function OpponentDealCard(props) {
	return (
		<div>
			<Card value={37} select={false}/>
			<Card value={37} select={false}/>
			<Card value={37} select={false}/>
		</div>
	);
}

function MyDealCard(props) {
	return <Card value={37} select={false}/>
}

class AHandOfCard extends React.Component {
	renderCard(faceValue, select) {
		return <Card value={faceValue} select={select}/>
	}
	render() {
		let r = [];
		for (let i = 0; i < 10; i++) {
			r.push(this.renderCard("back", false))
		}
		r.push(<Card value={32} select={true} />)
		for (let i = 11; i < 20; i++) {
			r.push(this.renderCard("back", false))
		}
		return (
			<div className="row">
				{r}
			</div>
		);
	}
}

function Card(props) {
	let cardUrl = (require("./card").dict)[props.value];

	if (props.value == "back") {
		return <img src={cardUrl} width="55" height="100"/>
	} else {
		if (props.select) {
			return <img src={cardUrl} width="85" height="160"/>
		} else {
			return <img src={cardUrl} width="58" height="108"/>
		}
	}
}

class Scoreboard extends React.Component{
	renderOnePlayer(i, score) {
		let name = "Player" + (i + 1)
		return (
			<div className="rowScore">
				<div className="name"> {name} </div>
				<div className="score"> {score} </div>
			</div>
		)
	}

	render() {
		let scoreData = this.props.root.state.score
		let l = [];
		for (let i = 0; i < scoreData.length; i++) {
			l.push(this.renderOnePlayer(i, scoreData[i]))
		}
		return (
			<div id="container">
				{l}
			</div>
		);
	}
}

function Timer(props) {
	return (<div className="time"> 00:00:00 </div>)
}

