package;

import tink.state.*;

using Lambda;

class Main extends coconut.ui.View {
	static function main() {
		js.Browser.document.body.appendChild(new Main({game: new Game()}).toElement());
	}
	
	@:attr var game:Game;
	
	function render() '
		<div>
			<if ${game.winner != null}>
				Player ${game.winner} wins!
			<else>
				Player ${game.currentPlayer}\'s turn.
			</if>
			<div>
				<box pos=${0}/>
				<box pos=${1}/>
				<box pos=${2}/>
			</div>
			<div>
				<box pos=${3}/>
				<box pos=${4}/>
				<box pos=${5}/>
			</div>
			<div>
				<box pos=${6}/>
				<box pos=${7}/>
				<box pos=${8}/>
			</div>
		</div>
	';
	
	function box(attr:{pos:Int}) '
		<button onclick=${game.select.bind(attr.pos)}>
			<pre>
				<switch ${game.steps.toArray().find(v -> v.position == attr.pos)}>
					<case ${null}>\u00a0
					<case ${{player: 0}}>O
					<case ${{player: 1}}>X
					<case ${_}>\u00a0
				</switch>
			</pre>
		</button>
	';
}

class Game implements coconut.data.Model {
	@:editable var steps:ObservableArray<Step> = new ObservableArray();
	
	@:computed var currentPlayer:Int = {
		switch steps.length {
			case 0: 0;
			case v: steps.get(v - 1).player == 0 ? 1 : 0;
		}
	}
	
	@:computed var winner:Int = {
		var arr = steps.toArray();
		var player0 = [];
		var player1 = [];
		
		function check(v:Array<Int>) {
			for(pattern in patterns) {
				var matched = true;
				for(pos in pattern) {
					if(v.indexOf(pos) == -1) matched = false;
				}
				if(matched) return true;
			}
			return false;
		}
		
		for(v in arr) {
			if(v.player == 0) {
				player0.push(v.position);
				if(check(player0)) return 0;
			} else {
				player1.push(v.position);
				if(check(player1)) return 1;
			}
		}
		return null;
	}
	
	static var patterns = [
		[0,1,2],
		[3,4,5],
		[6,7,8],
		[0,3,6],
		[1,4,7],
		[2,5,8],
		[0,4,8],
		[2,4,6],
	];
	
	public function select(i:Int) {
		if(winner != null) return;
		steps.push({
			player: currentPlayer,
			position: i,
		});
	}
}

typedef Step = {
	final player:Int;
	final position:Int;
}