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
				.receive("error", resp => {console.log("Can't join!", resp)});
	}

	renderThreeCard(facevalue) {
		return <Card value={facevalue} />
	}

	render() {
		return (
		<div>
			<div className="row">
			<p>Hello!</p>
			</div>

			<AHandOfCard root={this} />

			<div id="container">
				<div className="rowScore">
					<div className="name">Player1</div>
					<div className="score">430</div>
				</div>

				<div className="rowScore">
					<div className="name">Player2</div>
					<div className="score">580</div>
				</div>

				<div className="rowScore">
					<div className="name">Player3</div>
					<div className="score">310</div>
				</div>
			</div>
		</div>
		);
	}


	get_view(view) {
		this.setState(view.game);
	}
}

class AHandOfCard extends React.Component {
	renderCard(i, faceValue) {
		return <Card key={i} value={faceValue} />
	}
	render() {
		let r = [];
		for (let i = 0; i < 17; i++) {
			r.push(this.renderCard(i,"back"))
		}
		return (
			<div className="row">
				{r}
			</div>
		);
	}
}

function Card(props) {
	if (props.value === "back") {
		return <img src="https://i.ibb.co/b6TDqMS/back.png" width="50" height="100"/>;
	} else {

	}
}
