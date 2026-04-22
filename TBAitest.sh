#!/bin/bash
shopt -s nocasematch

#Variables 
player_hp=100
player_defense=0
player_energy=100

player_effects=()
AI_effects=()

damage_buff=0
turn_taken=false
defending=false


#AI Variables
AI_hp=100
AI_damage_buff=0
AI_turn_taken=false
AI_defense=0

#Effect functions
apply_effect() {
	local effect=$1
	local duration=$2

	player_effects+=("$effect:$duration")
}


update_effects() {
	local new_effects=()

	for effect in "${player_effects[@]}"; do
		name="${effect%%:*}"
		turns="${effect##*:}"

		((turns--))

		if ((turns > 0)); then
			new_effects+=("$name:$turns")
		else
			echo "$name has worn off."
		fi
	done

	player_effects=("${new_effects[@]}")

}

has_effect() {
	local target=$1
	for effect in "${player_effects[@]}"; do
		[[ ${effect%%:*} == "$target" ]] && return 0
	done
	return 1
}

calculate_damage() {
	local base=$1
	local active_dmg_buff=$2
	local defender_defense=$3
 
	local damage=$((base * (100 + active_dmg_buff) / 100))
	damage=$((damage * (100 - defender_defense) / 100))

	echo $damage
}

# This works for when there is a reactive enchantment
on_player_hit() {
	local damage_taken=$1
	if has_effect "Thorns"; then
		local reflect$((damage_taken * 25 / 100))
		echo "Reflect $reflect damage with thorns."
		AI_hp=$((AI_hp - reflect))
	fi
	
}


player_status(){
	echo "Player HP: $player_hp | Player energy: $player_energy"
	sleep 1
	echo "Player defense: $player_defense | Current damage buff: $damage_buff %"

	echo -e "Current status effects:"
	if ((${#player_effects[@]} == 0)); then
		echo "None"
	else
		for effect in "${player_effects[@]}"; do
			echo " - $effect"
		done
	fi
}

AI_status(){
	echo "AI HP: $AI_hp | AI defense: $AI_defense"
	sleep 1
	echo "Current damage buff: $AI_damage_buff %"
	
}

fight_menu(){
read -p "which way of fighting do you choose?
1. Sword
2. Uppercut" fight_choice
	case $fight_choice in
	1)
		local sword_damage=$(calculate_damage 20 $damage_buff $AI_defense)
		local critical=$((RANDOM % 100))
		
		read -p "Are you sure you want to use sword?" sword_choice
			if [[ $sword_choice == "yes" ]]; then
				echo "Swung sword"
				sleep 1	
				
				if ((critical < 10)); then
					echo "Critical hit! You get a bonus turn."
					sword_damage=$((sword_damage *= 2))
					AI_hp=$((AI_hp - sword_damage))
					turn_taken=false
				
				else
					AI_hp=$((AI_hp - sword_damage))
					turn_taken=true
					echo "You deal $sword_damage damage!"
					sleep 2
				fi
			fi
		;;
	2)
		local uppercut_damage=$(calculate_damage 15 $damage_buff $AI_defense)
		read -p "Are you sure you want to uppercut?" uppercut_choice
			if [[ $uppercut_choice == "yes" ]]; then
			echo "Threw uppercut"

			AI_hp=$((AI_hp - uppercut_damage))
			turn_taken=true
			fi

		;;

	esac
}

defend_menu() {
	read -p "Are you sure?" defend
		if [[ $defend == "yes" ]]; then
			echo "You base in and prepare to defend the next hit."
			shielding=true
			turn_taken=true
		fi
}

energy_menu(){
	local duration=0
	read -p "There are a majority of things you can do with energy.
	Choose between:
	1. Thorns Enchant - Reflect 25% of the damage you take 
	back to their attacker for 1 turn.

	2. Battle Heal - Recover 50% of the damage you take as
	health for 2 turns. 

	3.Sharpness - Double sword damage for a turn. You take a bonus turn immediately after.
	

	Type back to return" nrg

	case $nrg in
	1)
		read -p "Thorns costs 20 energy. Are you sure you want to enchant?
		" thorns
			if [[ $thorns == "yes" && $player_energy -ge 20 ]]; then
				player_energy=$((player_energy-=20))
				echo "Enchanted"
				apply_effect "Thorns" 1
				turn_taken=true
				
			else
				echo "Not enough energy or exited interface."
				
			fi

		;;
	2)
		read -p "Battle Heal costs 30 energy. Are you sure you want to enchant?
		" bheal
			if [[ $bheal == "yes" && $player_energy -ge 30  ]]; then
				player_energy=$((player_energy - 30))
				echo "Enchanted"
				apply_effect "Lifesteal" 2
				turn_taken=true
				
			fi
		;;
	3)	read -p "Sharpness costs 40 energy. Are you sure you want to enchant?
		" sharpness
			if [[ $sharpness == "yes" && $player_energy -ge 40 ]]; then
				player_energy=$((player_energy - 40))
				damage_buff=$((damage_buff + 10))
				echo "Enchanted"
				apply_effect "Sharpness" 1
				turn_taken=false
				sleep 2
			fi
		;;
	*)  echo "returning to main screen"
			
			;;

	esac
}

AI_cero() {
	local cero_damage=$((20 + AI_damage_buff))
	echo "The AI charges a Cero! You are damaged by a laser."
	player_hp=$((player_hp - cero_damage))
	AI_turn_taken=true

	if (((RANDOM % 10 + 1) < 10)); then
		echo "The player is burning."
		apply_effect "Burning" 2
	fi

	player_status
	AI_status

}

AI_buffs() {
	local buff=$((RANDOM % 2 + 1))
	case $buff in 

		1)  
			if (( AI_damage_buff < 30 )); then
				echo "The AI uses a damage buff!"
				AI_damage_buff=$((AI_damage_buff + 10)) 
				AI_turn_taken=true
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
				AI_turn_taken=true
				
				if (( AI_hp > 100 )); then
					AI_hp=$((AI_hp = 100))
				fi
			else
				AI_cero
			fi
				;;
	esac
	AI_status
	player_status
}		

 AI_turn() {
 	clear
 	while [[ $AI_turn_taken == false ]]; do
 	echo -e "----The AI is taking a turn ----"
 	sleep 2
 	AI_choice=$((RANDOM % 2 + 1))

 	case $AI_choice in
 		1)
 			AI_cero ;;
 		2) 
 			AI_buffs ;;
 		
 	esac


 	
 	sleep 2
 	
 	done
 
 }

AI_encounter(){
while ((player_hp > 0 && AI_hp > 0)); do
	
	turn_taken=false

	while [[ $turn_taken == false ]]; do
		read -p "Action to take 
		1. Fight
		2. Defend
		3. Energy moves
		" choice
	
		case $choice in
			1)
		  		fight_menu
		  		;;
			2)
				defend_menu
				;;
			3)
				energy_menu
				;;
		
			*)
				echo -e "Do I need to translate to Bahasa Indonesia for you???"
				;;


		esac
	done
	AI_turn
	AI_turn_taken=false
done
}
	
echo "Today, you will fight an AI with a pre-determined loadout."
sleep 2
while true; do
	read -p "You ready (yes/no)?" combat
	if [[ $combat == "yes" || $combat == "y" ]]; then
		echo "Let us begin."
		sleep 2
		AI_encounter
		break

	elif [[ $combat == "no" || "n" ]]; then
		echo "get out"
		sleep 2
		exit 0

	else
		echo "hm?"
	fi
done


AI_encounter(){
while ((player_hp > 0 && AI_hp > 0)); do
	
	turn_taken=false

	while [[ $turn_taken == false ]]; do
		read -p "Action to take 
		1. Fight
		2. Defend
		3. Energy moves
		" choice
	
		case $choice in
			1)
		  		fight_menu
		  		;;
			2)
				defend_menu
				;;
			3)
				energy_menu
				;;
		
			*)
				echo -e "Do I need to translate to Bahasa Indonesia for you???"
				;;


		esac
	done
	update_effects
	AI_turn
	AI_turn_taken=false
	update_effects
done
}
	
echo "Today, you will fight an AI with a pre-determined loadout."
sleep 2
while true; do
	read -p "You ready (yes/no)?" combat
	if [[ $combat == "yes" || $combat == "y" ]]; then
		echo "Let us begin."
		sleep 2
		AI_encounter
		break

	elif [[ $combat == "no" || "n" ]]; then
		echo "get out"
		sleep 2
		exit 0

	else
		echo "hm?"
	fi
done
