#!/bin/bash
#AI Variables
NPC_NAME="Espada"
AI_hp=100
AI_damage_buff=0
AI_actions_left=0
AI_defense=0
AI_effects=() 
AI_cero() {
	local cero_damage=$((20 + AI_damage_buff))
	
	echo "The AI charges a Cero! You are damaged by a laser."
	
	player_hp=$((player_hp - cero_damage))
	on_player_hit cero_damage
	

	if (((RANDOM % 10 + 1) < 10)); then
		echo "The player is burning."
		apply_effect player "Burning" "DOT_debuff" 2 10 "inactive"
	fi
	
	
	
	
}

AI_buffs() {
	local buff=$((RANDOM % 3 + 1))
	case $buff in 

		1)  
			if (( AI_damage_buff < 30 )); then
				echo "The AI uses a damage buff!"
				AI_damage_buff=$((AI_damage_buff + 10)) 
				
				
				if (( AI_damage_buff > 30 )); then
					AI_damage_buff=$((AI_damage_buff = 30))
				fi 
			else



				AI_cero
			fi

			;; 

		2) 
			if (( AI_hp < 100 )); then
				echo "The AI heals 20 health!"
				AI_hp=$((AI_hp + 20))
				
				
				if (( AI_hp > 100 )); then
					AI_hp=$((AI_hp = 100))
				fi
			else
				AI_knee_strike
			fi
				;;

		3)
			local added_defense=$(dynamic_defense "AI")
			if (( added_defense < 20 )); then
				echo "The AI gains more defense!"

				apply_effect "AI" "Stalwart" "defenseup" 2 10 "inactive"

				if ((added_defense > 20)); then
					added_defense=$((added_defense = 20))
				fi
			else
				AI_knee_strike
			fi
			;;

		esac
	
}		

AI_knee_strike() {
	local target_defense=$(dynamic_defense "player")
	local knee_damage=$(calculate_damage 15 AI_damage_buff $target_defense)
	
	echo "The AI throws out a knee strike!"

	player_hp=$((player_hp - $knee_damage))
	on_player_hit knee_damage

	


}

AI_turn() {
 	
 	echo "actor = $actor"
 	clear
 	echo -e "----The AI is taking a turn ----"
 	sleep 2
 	
 	AI_choice=$((RANDOM % 3 + 1))

 	case $AI_choice in
 		1)
 			AI_cero 
 			;;
 		2) 
 			AI_buffs 
 			;;

 		3) AI_knee_strike
 			;;
 		



 		
 	esac

 	
 }


