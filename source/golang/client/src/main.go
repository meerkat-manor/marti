package main

import (
	"fmt"
	"os"
	"strings"
	"merebox.com/martilq"
	"time"
	"io/ioutil"
)


type Parameters struct {
	task string
	sourcePath string
	recursive bool
	configPath string
	outputPath string

	title string
	description string
	describedBy string
	landing string
}

var params Parameters

// go run . -- -t INIT -c ./test/my_martilq.ini 
// go run . -- -t GEN -o ./test/test_martilq_directoryC.json -c ./config/martilq.ini -s ./martilq
// go run . -- -t GEN -o ./test/test_martilq_directoryC.json -c ./config/martilq.ini -s ./martilq --title "Sample run of GEN" --description "@./config/description.txt"


func loadArguments(args []string) {

	maxArgs := len(args)
	ix := 1
	for ix < maxArgs {
		matched := false

		if args[ix] == "-t" || args[ix] == "--task" {
			matched = true
			if ix < maxArgs {
				ix = ix + 1
				params.task = strings.ToUpper(args[ix])
			} else {
				panic("Missing parameter for TASK")
			}
		}

		if args[ix] == "-c" ||  args[ix] == "--config" {
			matched = true
			ix = ix + 1
			if ix < maxArgs {
				params.configPath = args[ix]
			} else {
				panic("Missing parameter for CONFIG")
			}
		}

		if args[ix] == "-s" ||  args[ix] == "--source" {
			matched = true
			ix = ix + 1
			if ix < maxArgs {
				params.sourcePath = args[ix]
			} else {
				panic("Missing parameter for SOURCE")
			}
		}	

		if args[ix] == "-o" ||  args[ix] == "--output" {
			matched = true
			ix = ix + 1
			if ix < maxArgs {
				params.outputPath = args[ix]
			} else {
				panic("Missing parameter for OUTPUT")
			}
		}	



		if args[ix] == "--title" {
			matched = true
			if ix < maxArgs {
				ix = ix + 1
				params.title = args[ix]
			} else {
				panic("Missing parameter for TITLE")
			}
		}
		
		if args[ix] == "--description" {
			matched = true
			if ix < maxArgs {
				ix = ix + 1
				if args[ix][0] == '@' {
					desc, err := ioutil.ReadFile(args[ix][1:])	
					if err != nil {
						panic("Description file not found: " + args[ix][1:])
					} 
					params.description = string(desc)
				} else {
					params.description = args[ix]
				}
			} else {
				panic("Missing parameter for DECRIPTION")
			}
		}

		if args[ix] == "--landing" {
			matched = true
			if ix < maxArgs {
				ix = ix + 1
				params.landing = args[ix]
			} else {
				panic("Missing parameter for LANDING")
			}
		}

		if !matched && args[ix] != "--" {
			fmt.Println("Unrecognised command line argument: " + args[ix])
		}

		ix = ix + 1
	}

}

func main () {

	currentDirectory, _ := os.Getwd()
	params.sourcePath = currentDirectory
	//params.outputPath = "" 
	//params.configPath = "" 

	loadArguments(os.Args)

	matched := false

	if params.task == "INIT" {
		if params.configPath == "" {
			panic("Missing 'config' parameter")
		}

		c := martilq.NewConfiguration()
		if c.SaveConfig(params.configPath) != true {
			panic("Configuration not saved to: "+ params.configPath)
		}
		fmt.Println("Created MARTILQ INI definition: " + params.configPath)
		matched = true
	}

	if params.task == "GEN" {

		if params.sourcePath == "" {
			panic("Missing 'source' parameter")
		}
		if params.outputPath == "" {
			panic("Missing 'output' parameter")
		}

		m := martilq.ProcessDirectory(params.configPath, params.sourcePath, params.recursive, params.outputPath )
		if params.title != "" {
			m.Title = params.title
		}
		if params.landing != "" {
			m.LandingPage = params.landing
		}
		if params.description != "" {
			m.Description = params.description
		}
		m.Modified = time.Now()
		m.Save(params.outputPath)

		fmt.Println("Created MARTILQ definition: " + params.outputPath)
		matched = true
	}

	if params.task == "RECON" {
		
		matched = true
	}

	if matched {
		fmt.Println("Completed " + params.task)
	} else {
		fmt.Println("Unknown task: " + params.task)
	}
}
