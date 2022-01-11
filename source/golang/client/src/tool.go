package main

import (
	"fmt"
	"os"
	"strings"
	"merebox.com/martilq"
	"io/ioutil"
)


type Parameters struct {

	help bool

	task string
	sourcePath string
	recursive bool
	filter string
	update bool
	urlPrefix string
	configPath string
	definitionPath string
	outputPath string

	title string
	description string
	describedBy string
	landing string
}

var params Parameters


func loadArguments(args []string) {

	maxArgs := len(args)
	ix := 1
	for ix < maxArgs {
		matched := false

		if args[ix] == "-h" || args[ix] == "--help" {
			matched = true
			params.help = true
			break
		}

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

		if args[ix] == "-m" ||  args[ix] == "--martilq" {
			matched = true
			ix = ix + 1
			if ix < maxArgs {
				params.definitionPath = args[ix]
			} else {
				panic("Missing parameter for MARTILQ")
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


		
		if args[ix] == "-R" ||  args[ix] == "--recursive" {
			matched = true
			params.recursive = true
		}	
		
		if args[ix] == "--update" {
			matched = true
			params.update = true
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

		if args[ix] == "--filter" {
			matched = true
			if ix < maxArgs {
				ix = ix + 1
				params.filter = args[ix]
			} else {
				panic("Missing parameter for FILTER")
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
				panic("Missing parameter for DESCRIPTION")
			}
		}


		if !matched && args[ix] != "--" {
			fmt.Println("Unrecognized command line argument: " + args[ix])
		}

		ix = ix + 1
	}

}

func printHelp() {

	fmt.Println("")
	fmt.Println("\t   martilqcli_client ")
	fmt.Println("\t   ================= ")
	fmt.Println("")
	fmt.Println("\tThis program is intended as a simple reference implementation")
	fmt.Println("\tin Go of the MartiLQ framework.  It is does not provide all")
	fmt.Println("\tthe possible functionality but enough to demonstrate the concept.")
	fmt.Println("")

	fmt.Println(" The command line arguments are:")
	fmt.Println("")
	fmt.Println(" -h or --help : Display this help")
	fmt.Println(" -t or --task : Execute a predefined task which are")
	fmt.Println("           INIT initialize a new configuration file")
	fmt.Println("           MAKE make a MartiLQ definition file")
	fmt.Println("           GET resources based on MartiLQ definition file")
	fmt.Println("           RECON reconcile a MartiLQ definition file")
	fmt.Println(" -c or --config : Configuration file used by all tasks")
	fmt.Println("           This is the file written by the INIT task")
	fmt.Println(" -s or --source : Source directory or file to build MartiLQ definition")
	fmt.Println("           This is used by the MAKE and RECON task")
	fmt.Println(" -m or --martilq : MartiLQ definition file")
	fmt.Println("           This is used by the MAKE and RECON task")
	fmt.Println("           The MAKE task makes the file while")
	fmt.Println("           RECON task reads the file")
	fmt.Println(" -o or --output : Output file")
	fmt.Println("           This is used by the RECON task")

	fmt.Println("")
	fmt.Println(" --title : Title for the MartiLQ. Think of this as")
	fmt.Println("           the job name")
	fmt.Println("           This is used by the MAKE task")
	fmt.Println(" --description : Description for the MartiLQ. This can be text")
	fmt.Println("           or a pointer to a file when the @ prefix is used")
	fmt.Println("           This is used by the MAKE task")
	fmt.Println(" --Update : Update existing definition otherwise fail it exists already")
	fmt.Println("           This is used by the MAKE task")
	fmt.Println(" --filter : File filter")
	fmt.Println("           This is used by the MAKE task")
	fmt.Println(" -R or --recursive : Recursively process child folders")
	fmt.Println("           This is used by the MAKE task")

	fmt.Println("")

}

func main () {

	currentDirectory, _ := os.Getwd()
	params.sourcePath = currentDirectory

	loadArguments(os.Args)

	matched := false

	if params.help {
		printHelp()
	} else {


		if params.task == "RECON" {

			m = martilq.ReconcileFilePath(params.configPath, params.sourcePath, params.recursive, params.definitionPath, params.outputPath )
		
			matched = true


		}

		if !matched {
			printHelp()
		}

	}
}
