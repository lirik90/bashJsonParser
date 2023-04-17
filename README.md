# Simple Json parser for Bash
That code work at least on Bash 3.2.57 and above.  
This is a pure Bash implementation with no dependencies.  

### ATTENTION:
Maybe there are some unimplemented important things. If anyone need anything from it, please [contact to me](mailto:qc424j85o@relay.firefox.com), and i will try to do it.

##### ATTENTION: It's works slowly with big JSON documents.

##### Please, try it:
```bash
git clone https://github.com/lirik90/bashJsonParser.git
bash bashJsonParser/example.sh
```

##### Or something like that:
```bash
source <(curl -s -L -o- https://github.com/lirik90/bashJsonParser/raw/master/jsonParser.sh)
JSON='{"error": "Error message text"}'
JSON=$(minifyJson "$JSON")
echo "Message is: $(parseJson "$JSON" error)"
```

### For integrate to your project:
1. Copy code from [jsonParser.sh](jsonParser.sh) file
2. Get JSON from something place
```bash
read -d '' JSON << EOF
[{
  "name": "Leanne Graham",
  "company": {
    "name": "Romaguera-Crona",
  }
}]
EOF
```
3. If your JSON is 'pretty' formatted wrap it with minify function like bellow:
```bash
JSON=$(minifyJson "$JSON")
```
4. Choose field witch you want to parse
```bash
company=$(parseJson "$JSON" 0 company name)
echo "Company is: $company"
```
