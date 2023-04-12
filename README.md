# Simple Json parser for Bash
That code work at least on Bash 3.2.57 and above.  
This is a pure Bash implementation with no dependencies.  

### ATTENTION: Below is a list of unimplemented things:
1. Get value from numeric or string array, now only from object array
2. Get boolean or null values, now only number and strings.
3. Maybe much more another important things. If anyone need anything from it, please [contact to me](mailto:qc424j85o@relay.firefox.com), and i will try to do it.

##### ATTENTION: It's works slowly with big JSON documents.

##### Please, try it:
```bash
git clone https://github.com/lirik90/bashJsonParser.git
bash bashJsonParser/example.sh
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
