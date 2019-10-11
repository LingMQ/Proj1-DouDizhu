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
	
	render() {
		return (
		<div>
			<div className="row">
			<p>Hello!</p>
			</div>
		</div>
		);
	}
	
	
}
