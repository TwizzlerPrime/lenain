#!/bin/bash
shopt -s nocasematch

player_hp=100
ai_hp=100



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
		;;

	esac
}

echo "Today, you will fight an AI with a pre-determined loadout."
read -p "You ready?"combat
if [[ $combat == "y|Y" ]]; then
	echo "Let us begin."
	sleep 2
else
	echo -e "Please retry."
	exit 0
while ((player_hp > 0 && ai_hp > 0)); do
	read -p "Action to take 
	1. Fight
	2. Defend
	3. Energy moves" choice
	case $choice in
		1) 
		   fight_menu
		   ;;
		2) 
			defend_menu
			;;
		3) energy_menu
			;;

