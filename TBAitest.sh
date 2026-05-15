#!/bin/bash
shopt -s nocasematch

#Variables 
player_hp=100
player_defense=0
player_energy=100

player_effects=()
AI_effects=()

damage_buff=0
bonus_turn=false

defending=false


#AI Variables
AI_hp=100
AI_damage_buff=0
AI_actions_left=0
AI_defense=0

#Effect functions
apply_effect() {
	local effect=$1
	local type=$2
	local duration=$3
	local value=$4

	player_effects+=("$effect:$type:$duration:$value")
}


update_effects() {
	local new_effects=()

	for effect in "${player_effects[@]}"; do
		name="${effect%%:*}" #Takes just the name in the entire effect list
		
		temp="${effect#*:}" #Removes the name so that the remaining parameters are type:turns:value
		type="${temp%%:*}" #Accesses the new temp to get just the type
		
		temp2="${temp#*:}" #Removes the type (everything at the start to the first colon) to keep turns:value
		turns="${temp2%%:*}" #Accesses temp2 and removes the end to the first colon to hold turns

		value="${temp2##*:}" #Cuts out the turns to get only the value

		((turns--))

		if ((turns > 0)); then
			new_effects+=("$name:$type:$turns:$value")


		else
			echo "$name has worn off."
		fi
	done

	player_effects=("${new_effects[@]}")

}

has_effect() {
	local active_effect=$1
	#For each effect the player has, take only the effect name and store it as a variable/
	for effect in "${player_effects[@]}"; do
		[[ ${effect%%:*} == "$active_effect" ]] && return 0
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
		local reflect=$((damage_taken * 25 / 100))
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
			effect_name="${effect%%:*}" #Crops out just effect name from full effect list

			cut1="${effect#*:}"
			cut2="${cut1#*:}" # After 2 cuts, we now have just duration:value

			effect_turns="${cut2%%:*}" #


			echo " - $effect_name ($effect_turns turns left)"
		done
	fi
}

AI_status(){
	echo "AI HP: $AI_hp | AI defense: $AI_defense"
	sleep 1
	echo "Current damage buff: $AI_damage_buff %"
	
}

start_of_turn() {
	 for effect in "${player_effects[@]}"; do
        name="${effect%%:*}"

        temp="${effect#*:}"
        type="${temp%%:*}"

        temp2="${temp#*:}"
        turns="${temp2%%:*}"

        value="${temp2##*:}"

}

end_turn() {
	update_effects
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

					echo "You deal $sword_damage damage!"
					sleep 2

					bonus_turn=true

					
					
				
				else
					
					AI_hp=$((AI_hp - sword_damage))
					echo "You deal $sword_damage damage!"
					
					sleep 2
				fi
			fi
			end_turn
		;;
	2)
		local uppercut_damage=$(calculate_damage 15 $damage_buff $AI_defense)
		read -p "Are you sure you want to uppercut?" uppercut_choice
			if [[ $uppercut_choice == "yes" ]]; then
			echo "Threw uppercut"

			AI_hp=$((AI_hp - uppercut_damage))
			


			fi
			end_turn
		;;

	esac
}

defend_menu() {
	read -p "Are you sure?" defend
		if [[ $defend == "yes" ]]; then
			echo "You base in and prepare to defend the next hit."
			shielding=true
			end_turn
		fi
}

energy_menu(){

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

			if has_effect "Thorns"; then
				echo "Too many thorns don't you think?"
				sleep 1
				return 0
			fi

			if [[ $thorns == "yes" && $player_energy -ge 20 ]]; then
				player_energy=$((player_energy-=20))
				echo "Enchanted"
				apply_effect "Thorns" "misc" 2 10
				
				

				
			else
				echo "Not enough energy or exited interface."
				
			fi
			
		;;
	2)
		read -p "Battle Heal costs 30 energy. Are you sure you want to enchant?
		" bheal

			if has_effect "Lifesteal"; then
				echo "too much vampire in your system"
				sleep 1
				return 0 
			fi

			if [[ $bheal == "yes" && $player_energy -ge 30  ]]; then
				player_energy=$((player_energy - 30))
				echo "Enchanted"
				apply_effect "Lifesteal" "healthbuff" 2 15

				

				
				end_turn
				
			fi
						
		;;
	3)	read -p "Sharpness costs 40 energy. Are you sure you want to enchant?
		" sharpness
			if has_effect "Sharpness"; then
				echo "a little too sharp ay??"
				sleep 1
				return 0
			fi

			if [[ $sharpness == "yes" && $player_energy -ge 40 ]]; then
				
				player_energy=$((player_energy - 40))
				damage_buff=$((damage_buff + 10))
				
				echo "Enchanted"
				apply_effect "Sharpness" "damagebuff" 1 10
				
				bonus_turn=true


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
	
	

	if (((RANDOM % 10 + 1) < 10)); then
		echo "The player is burning."
		apply_effect "Burning" "DOT_debuff" 2 10
	fi
	
	AI_status
	
	((AI_actions_left--))
	end_turn
}

AI_buffs() {
	local buff=$((RANDOM % 2 + 1))
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
				((AI_actions_left--))
				
				if (( AI_hp > 100 )); then
					AI_hp=$((AI_hp = 100))
				fi
			else
				AI_cero
			fi
				;;


		esac
		end_turn
	AI_status
}		

 AI_turn() {
 	clear
 	
 	AI_actions_left=1

 	while (( $AI_actions_left >= 1 )); do
 	echo -e "----The AI is taking a turn ----"
 	sleep 2
 	AI_choice=$((RANDOM % 2 + 1))

 	case $AI_choice in
 		1)
 			AI_cero 
 			;;
 		2) 
 			AI_buffs 
 			;;
 		
 	esac


 	
 	sleep 2
 	
 	done
 
 }

player_menus() {
	
}

player_turn() {
	start_of_turn

	bonus_turn=false

	while true; do
		read -p "Action to take 
		1. Fight
		2. Defend
		3. Energy moves
		4. Display current effects
		" choice
	
		case $choice in
			1)
		  		fight_menu
		  		break
		  		;;
			2)
				defend_menu
				break
				;;
			3)
				energy_menu
				break
				;;
		
			4)	
				player_status
				;;
			*)
				echo -e "Do I need to translate to Bahasa Indonesia for you???"
				;;


		esac

	done
	end_turn

	if [[ $bonus_turn == true ]]; then
		echo "Bonus turn!"
		sleep 1
		player_turn
	fi
}

AI_encounter(){
while ((player_hp > 0 && AI_hp > 0)); do
	bonus_turn=false


		player_turn

		if ((AI_hp <= 0)); then
			while true; do
			read -p "You beat the training system. Retry? (y/n)" retry
			
			
				if [[ $retry == "y" ]]; then
					echo "cool"
					sleep 1
					clear
					./TBAitest.sh
					exit 0

				elif [[ $retry == "n" ]]; then
					echo "begone"
					exit 0

				else
					echo "figure it out"

				fi
			done
		fi

	
	AI_turn
	
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



