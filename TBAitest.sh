#!/bin/bash
echo "Today, you will fight an AI with a pre-determined loadout."
read -p "You ready?"combat
if [[ $combat == "y|Y" ]]; then
	echo "Let us begin."
	sleep 2
else 