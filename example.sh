#!/bin/bash

source "$(dirname "$0")/jsonParser.sh"

i=$(( ((RANDOM<<15)|RANDOM) % 10 ))
DATA=$(curl -s https://jsonplaceholder.typicode.com/users)
DATA=$(minifyJson "$DATA")

name=$(parseJson "$DATA" $i name)
city=$(parseJson "$DATA" $i address city)
company=$(parseJson "$DATA" $i company name)
echo "Hi! My name is $name. I live in $city and am a good specialist of $company company."
