#!/bin/bash
#
# This file is taken from https://github.com/lirik90/bashJsonParser

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
	local -i sum=$1 startSum=$1 escaped=0 quoted=0 i
	local s="$2" c=""

	for ((i=0; i<${#s}; ++i)); do
		processJson
		[ $? -ne 0 ] && break
	done
	echo $sum
}

# Calc length one object from 'open' to 'close' braces
function jsonObjectLength() {
	local -i sum=1 startSum=0 escaped=0 quoted=0 i
	local s="$1" c=""

	# Check first char is open braces
	[ "${s:0:1}" = "{" ] && for ((i=1; i<${#s}; ++i)); do
		if [ $sum -eq 0 ]; then
			echo $i
			return
		fi
		processJson
		[ $? -ne 0 ] && break
	done
	echo 0
}

# Helper function for filter data in JSON stream
function processJson() {
	if [ $escaped -eq 1 ]; then
		escaped=0
		return 0
	fi

	c="${s:i:1}"
	if [ "$c" = "\\" ]; then
		escaped=1
	elif [ "$c" = "\"" ]; then
		[ $quoted -eq 1 ] && quoted=0 || quoted=1
	fi

	[ $quoted -eq 1 ] && return 0
	if [ "$c" = "{" ]; then
		sum=$((sum+1))
	elif [ "$c" = "}" ]; then
		sum=$((sum-1))
		[ $sum -lt $startSum ] && return 1
	fi
	return 0
}

function parseJsonImpl() {
	local -i depth=$1 br=$2 pos=0 i
	local JSON="$3" m=""
	shift; shift; shift
	local obj=("$@")

	while true; do
		if [[ ${obj[0]} =~ ^[0-9]+$ ]]; then
			# Check is array under position
			[ "${JSON:0:1}" = "[" ] || return 1
			JSON="${JSON:1}"

			for ((i=0; i<${obj[0]}; ++i)); do
				m=$(printCurrentJsonValue "${JSON}" --keepQuotes)
				[ $? -ne 0 ] && return 1
				JSON="${JSON:${#m}}"

				# Check is next object available
				[ "${JSON:0:1}" = "," ] || return 1
				JSON="${JSON:1}"
			done

			# Check is next object under position
			if [ "${JSON:0:1}" = "{" ]; then
				JSON="${JSON:1}"
				br=$((br+1))
				depth=$((depth-1))
			fi

			break
		fi

		m="${JSON%%"\"${obj[0]}\":"*}"
		[[ "$m" = "$JSON" ]] && return 1
		pos=$((${#m}+${#obj[0]}+3))
		JSON="${JSON:$pos}"
		[ -z "$m" ] && break

		br=$(calcBraces $br "$m")
		[ $br -eq $depth ] && break
	done

	if [ ${#obj[@]} -gt 1 ]; then
		unset 'obj[0]'
		parseJsonImpl $((depth+1)) $br "${JSON}" "${obj[@]}"
	else
		printCurrentJsonValue "$JSON"
	fi
	return $?
}

function printCurrentJsonValue() {
	local JSON="$1"
	if [[ $JSON =~ ^\"(([^\"]|\\\")*)\" ]]; then
		local quote=""
		[ "$2" = "--keepQuotes" ] && quote="\""
		echo "${quote}${BASH_REMATCH[1]}${quote}"
	elif [[ $JSON =~ ^(-?[0-9]+) ]]; then
		echo "${BASH_REMATCH[1]}"
	elif [[ $JSON =~ ^(true|false|null) ]]; then
		echo "${BASH_REMATCH[1]}"
	elif [[ $JSON =~ ^\[ ]]; then
		local res="[" item
		local -i pos=1
		while true; do
			res+=$(printCurrentJsonValue "${JSON:$pos}" --keepQuotes)
			[ $? -ne 0 ] && break
			pos=${#res}
			if [ "${JSON:$pos:1}" = "," ]; then
				res+=","
				pos=$((pos+1))
			fi
		done
		echo "${res}]"
	elif [[ $JSON =~ ^\{ ]]; then
		local -i len
		len=$(jsonObjectLength "$JSON")
		[ $len -eq 0 ] && return 1
		echo "${JSON:0:$len}"
	else
		return 1
	fi
	return 0
}

