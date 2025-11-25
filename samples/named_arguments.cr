require "../src/crest"

reponse = Crest::Request.execute(:get, "http://127.0.0.1:4567/get", invalid: "test")

# Compile time error: Error: no parameter named 'invalid'
