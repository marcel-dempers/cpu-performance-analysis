package main

import (
	"fmt"
	"net/http"
	"encoding/json"
	"os"
	"io/ioutil"
)

type squad struct {
    SquadName string
    HomeTown string
    Formed int
    SecretBase string
    Active bool
}

type Member struct {
	Name           string
	Age            int
	SecretIdentity string
	Powers         []string
}

func GetJsonFile() []byte{
	file, e := ioutil.ReadFile("/app/sample/sample.json")
	if e != nil {
        fmt.Printf("Read sample json file error: %v\n", e)
        os.Exit(1)
	}
	return file
}

func main() {

	fmt.Println("Hello! I am the go API! V1")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("You have triggered a log from the go API")
		
		file := GetJsonFile()
		
		s := squad{} 
		err := json.Unmarshal(file, &s)
	
		if err != nil {
			fmt.Printf("Problem in config file: %v\n", err.Error())
			os.Exit(1)
		}

		fmt.Fprintln(w, "Hello! I am the go API! V1")
	})

	http.ListenAndServe(":80", nil)
}