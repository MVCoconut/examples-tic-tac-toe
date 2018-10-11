package;

import tink.state.*;
import tink.pure.*;

using Lambda;

class Main extends coconut.ui.View {
	static function main() {
		js.Browser.document.body.appendChild(new Main({game: new Game()}).toElement());
	}
	
	@:attr var game:Game;
	
	function render() '
		<div>
			<button onclick=${game.reset}>Reset</button>
			<div>
				<switch ${game.state}>
					<case ${Won(winner)}>
						Player ${winner} wins!
					<case ${Tied}>
						Tied.
					<case ${InProgress}>
						Player ${game.currentPlayer}\'s turn.
				</switch>
			</div>
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
		<button style="width:4em" onclick=${game.select.bind(attr.pos)}>
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
	@:observable var steps:List<Step> = null;
	
	@:computed var currentPlayer:Int = {
		switch steps.first() {
			case None: 0;
			case Some(v): v.player == 0 ? 1 : 0;
		}
	}
	
	@:computed var state:State = {
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
		
		for(v in steps) {
			if(v.player == 0) {
				player0.push(v.position);
				if(check(player0)) return Won(0);
			} else {
				player1.push(v.position);
				if(check(player1)) return Won(1);
			}
		}
		return steps.length == 9 ? Tied : InProgress;
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
	
	@:transition
	function select(i:Int) {
		return switch state {
			case InProgress if(steps.first(v -> v.position == i) == None):
				{
					steps: steps.prepend({
						player: currentPlayer,
						position: i,
					}),
				}
			case _:
				@patch {}
		}
	}
	
	@:transition
	function reset() {
		return {steps: null}
	}
}

typedef Step = {
	final player:Int;
	final position:Int;
}

enum State {
	InProgress;
	Won(winner:Int);
	Tied;
}