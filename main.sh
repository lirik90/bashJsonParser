#!/bin/bash

# Public JSON parser function
function parseJson() {
	parseJsonImpl 1 0 "$@"
}

# Public JSON minifier function
function minifyJson() {
	local -i escaped=0 quoted=0 i
	local s="$1" c="" res=""

	for ((i=0; i<${#s}; ++i)); do
		c="${s:i:1}"
		if [ $escaped -eq 1 ]; then
			escaped=0
			if [ "$c" = "n" ] || [ "$c" = "r" ] && [ $quoted -eq 0 ]; then
				res="${res:0:-1}"
			else
				res+="$c"
			fi
			continue
		fi
		if [ "$c" = "\\" ]; then
			escaped=1
		elif [ "$c" = "\"" ]; then
			[ $quoted -eq 1 ] && quoted=0 || quoted=1
		fi

		if [ "$c" = " " ] || [[ "$c" == $'\n' ]] || [[ "$c" == $'\r' ]]; then
			[ $quoted -eq 0 ] && continue
		fi
		res+="$c"
	done
	echo "$res"
}

# 'Open'-'Close' braces calculator
function calcBraces() {
	local -i sum=$1 escaped=0 quoted=0 i
	local s="$2" c=""

	for ((i=0; i<${#s}; ++i)); do
		processJson
	done
	echo $sum
}

# Calc length one object from 'open' to 'close' braces
function jsonObjectLength() {
	local -i sum=1 escaped=0 quoted=0 i
	local s="$1" c=""

	# Check first char is open braces
	[ "${s:0:1}" = "{" ] && for ((i=1; i<${#s}; ++i)); do
		if [ $sum -eq 0 ]; then
			echo $i
			return
		fi
		processJson
	done
	echo 0
}

# Helper function for filter data in JSON stream
function processJson() {
	if [ $escaped -eq 1 ]; then
		escaped=0
		return
	fi

	c="${s:i:1}"
	if [ "$c" = "\\" ]; then
		escaped=1
	elif [ "$c" = "\"" ]; then
		[ $quoted -eq 1 ] && quoted=0 || quoted=1
	fi

	[ $quoted -eq 1 ] && return
	if [ "$c" = "{" ]; then
		sum=$((sum+1))
	elif [ "$c" = "}" ]; then
		sum=$((sum-1))
	fi
}

function parseJsonImpl() {
	local -i depth=$1 br=$2 newPos=0 i
	local JSON="$3" m=""
	shift; shift; shift
	local obj=("$@")

	while [ 1 ]; do
		if [[ ${obj[0]} =~ ^[0-9]+$ ]]; then
			# Check is array under position
			[ "${JSON:0:1}" = "[" ] || return
			JSON="${JSON:1}"

			for ((i=0; i<${obj[0]}; ++i)); do
				newPos=$(jsonObjectLength "${JSON}")
				[ $newPos -eq 0 ] && return
				JSON="${JSON:$newPos}"

				# Check is next object available
				[ "${JSON:0:1}" = "," ] || return
				JSON="${JSON:1}"
			done

			# Check is next object under position
			[ "${JSON:0:1}" = "{" ] || return
			JSON="${JSON:1}"
			br=$((br+1))
			depth=$((depth-1))

			break
		fi

		m="${JSON%%"\"${obj[0]}\":"*}"
		[[ "$m" = "$JSON" ]] && return
		newPos=$((${#m}+${#obj[0]}+3))
		JSON="${JSON:${newPos}}"
		[ -z "$m" ] && break

		br=$(calcBraces $br "$m")
		[ $br -eq $depth ] && break
	done

	if [ ${#obj[@]} -gt 1 ]; then
		unset 'obj[0]'
		parseJsonImpl $((depth+1)) $br "${JSON}" "${obj[@]}"
	elif [[ $JSON =~ ^\"(([^\"]|\\\")*)\" ]]; then
		echo "${BASH_REMATCH[1]}"
	elif [[ $JSON =~ ^(-?[0-9]*) ]]; then
		echo "${BASH_REMATCH[1]}"
	fi
}

i=$(( ((RANDOM<<15)|RANDOM) % 10 ))
DATA=$(curl -s https://jsonplaceholder.typicode.com/users)
DATA=$(minifyJson "$DATA")

name=$(parseJson "$DATA" $i name)
city=$(parseJson "$DATA" $i address city)
company=$(parseJson "$DATA" $i company name)
echo "Hi! My name is $name. I live in $city and am a good specialist of $company company."
