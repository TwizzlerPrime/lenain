#!/bin/bash
shopt -s nocasematch

#Variables 
player_hp=100
player_energy=100

ai_hp=100


turn_taken=false
defending=false



fight_menu(){
read -p "which way of fighting do you choose?
1. Sword
2. Uppercut" fight_choice
	case $fight_choice in
	1)
		read -p "Are you sure you want to use sword?" sword_choice
			if [[ $sword_choice == "yes" ]]; then
			echo "Swung sword"
			fi
		;;
	2)
		read -p "Are you sure you want to uppercut?" uppercut_choice
			if [[ $uppercut_choice == "yes" ]]; then
			echo "Threw uppercut"
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
	read -p "There are a majority of things you can do with energy.
	Choose between:
	1. Thorns Enchant - Reflect 25% of the damage you take 
	back to their attacker.

	2. Battle Heal - Recover 50% of the damage you take as
	health. 

	3.Sharpness - Double sword damage for a turn. You take a bonus turn immediately after.
	

	Type back to return" nrg

	case $nrg in
	1)
		read -p "Thorns costs 20 energy. Are you sure you want to enchant?
		" thorns
			if [[ $thorns == "yes" && player_energy -ge 20 ]]; then
				echo "Enchanted"
				turn_taken=true
				
			else
				echo "Not enough energy or exited interface."
				
			fi

		;;
	2)
		read -p "Battle Heal costs 30 energy. Are you sure you want to enchant?
		" bheal
			if [[ $bheal == "yes" && player_energy -ge 30  ]]; then
				echo "Enchanted"
				turn_taken=true
				
			fi
		;;
	3)	read -p "Sharpness costs 40 energy. Are you sure you want to enchant?
		" sharpness
			if [[ $sharpness == "yes" && player_energy -ge 20 ]]; then
				player_energy = $((player_energy-= 0))
				echo "Enchanted"
				turn_taken=false
				
			fi
		;;
	*)  echo "returning to main screen"
			
			;;

	esac
}


 ai_turn() {
 	clear

 }

AI_encounter(){
while ((player_hp > 0 && ai_hp > 0)); do
	
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
	ai_turn
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
