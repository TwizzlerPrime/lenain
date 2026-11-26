#!/bin/bash
#AI Variables
NPC_NAME="John"
AI_hp=100
AI_damage_buff=0
AI_actions_left=0
AI_defense=0
AI_effects=()
Black_hole() {
	local dark_damage=$((25 + AI_damage_buff))
	echo "John unleashes a lesser black hole!"

	player_hp=$((player_hp - dark_damage))
	on_player_hit dark_damage

	
}

Shatterpoint() {
	local shatter_damage=$((15 + AI_damage_buff))
	sleep 2
	echo "John shatters your kneeecaps."
	
	echo -e "You can't use abilities for a turn."
	apply_effect "player" "Crippled" "misc" 1 0 inactive 
	
	player_hp=$((player_hp - shatter_damage))
	on_player_hit shatter_damage

	
}

De-atomizer() {
	local charges=0
	local atomizer_damage=9999999
	if (( $charges < 3 )); then
		echo -e "John charges up the De-atomizer"
		
		$charges=$((charges++))
		echo -e "$((3 - charges)) charges left"

	elif (( $charges = 3 )); then
		echo "John de-atomizes you. Not a trace remains"

		$player_hp=$((player_hp - atomizer_damage))

	fi



}

AI_turn() {
 	
 	echo "actor = $actor"
 	clear
 	echo -e "----The AI is taking a turn ----"
 	sleep 2
 	
 	AI_choice=$((RANDOM % 3 + 1))

 	case $AI_choice in
 		1)
 			Black_hole 
 			;;
 		2) 
 			Shatterpoint
 			;;

 		3) 	De-atomizer		
 			;;
 		



 		
 	esac

 	AI_status
 }


