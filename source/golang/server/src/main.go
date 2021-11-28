package main

import (
	"flag"
	"log"
	"net/http"
	"strings"
	"path/filepath"
	"io/ioutil"
	"os"
	"encoding/json"
)

func main() {
	port := flag.String("p", "8080", "Http listen port")
	staticDirectory := flag.String("static", "static", "Static directory content")
	docsDirectory := flag.String("docs", "", "Document directory content")
	dataDirectory := flag.String("data", "", "Data directory content")
	templateDirectory := flag.String("template", "", "Template directory content")
	trace := flag.Bool("trace", false, "Produce trace logs")
	flag.Parse()

	if *trace == true {	
		log.Printf("static folder: %s\n", *staticDirectory)
		log.Printf("data folder: %s\n", *dataDirectory)
		log.Printf("docs folder: %s\n", *docsDirectory)
		log.Printf("template folder: %s\n", *templateDirectory)
	}

	http.HandleFunc("/data/", func( res http.ResponseWriter, req *http.Request ) {
		safePath := ValidatePath(req.URL.Path[1:])
		if (*dataDirectory != "") {
			safePath = filepath.FromSlash(filepath.Join(*dataDirectory, strings.Replace(safePath, "data/", "", 1)))
		}
		if *trace == true {	
			log.Printf("resolved data folder: %s\n", safePath)
		}
		http.ServeFile(res, req, safePath)
	})

	http.HandleFunc("/template/", func( res http.ResponseWriter, req *http.Request ) {
		safePath := ValidatePath(req.URL.Path[1:])
		if (*templateDirectory != "") {
			safePath = filepath.FromSlash(filepath.Join(*templateDirectory, strings.Replace(safePath, "template/", "", 1)))
		}
		if *trace == true {	
			log.Printf("resolved template folder: %s\n", safePath)
		}
		http.ServeFile(res, req, safePath)
	})

	http.HandleFunc("/docs/", func( res http.ResponseWriter, req *http.Request ) {
		localPath := ""
		if (*docsDirectory == "") {
			temp := "../../.."
			docsDirectory = &temp
			localPath = ValidatePath(filepath.FromSlash(*docsDirectory+req.URL.Path))
		} else {
			localPath = ValidatePath(filepath.FromSlash(*docsDirectory+strings.Replace(req.URL.Path, "docs/", "", 1)))
		}
		if *trace == true {	
			log.Printf("resolved docs folder: \"%s\"", localPath)
		}
		f, err := os.Open(localPath)
		if err != nil {
			log.Printf("fetch docs error: \"%s\" with %s", localPath, err)
			http.NotFound(res, req)
		} else {
			s, err := f.Stat()
			if err != nil || s.IsDir() {
				log.Printf("fetch docs stat error: \"%s\"", localPath)
				http.NotFound(res, req)
				//http.ServeFile(res, req, filepath.FromSlash(*staticDirectory + "/404.html"))
			} else {
				http.ServeFile(res, req, localPath)
			}
		}
	})

	
	http.HandleFunc("/api/", apiHandler)
	http.HandleFunc("/api/view", apiHandlerView)

	fileServer := http.FileServer(FileSystem{http.Dir(*staticDirectory)})
	http.Handle("/", fileServer)

	log.Printf("Serving on HTTP port: %s\n", *port)
	log.Fatal(http.ListenAndServe(":"+*port, nil))
}



type FileSystem struct {
	fs http.FileSystem
}

func (fs FileSystem) Open(path string) (http.File, error) {
	f, err := fs.fs.Open(path)
	if err != nil {
		return nil, err
	}

	s, err := f.Stat()
	if s.IsDir() {
		index := strings.TrimSuffix(path, "/") + "/index.html"
		if _, err := fs.fs.Open(index); err != nil {
			return nil, err
		}
	}

	return f, nil
}

func ValidatePath(path string) string {

	safePath := path

	return safePath
}

func apiHandler(res http.ResponseWriter, req *http.Request) {

	apiPath := req.URL.Path
	log.Printf("fetch api: \"%s\"", apiPath)

	res.Write([]byte("<h1>Welcome to my web server!</h1>"))
}


type oTemplate struct {
	Extension string `json:"extension"`
	Renderer string  `json:"renderer"`
	Url string `json:"url"`
}

type Definition struct {
	FileName string `json:"fileName"`
	Describe string `json:"describe"`
}
 
type DirectoryList struct {
	Custom []oTemplate `json:"custom"`
	Files []Definition `json:"files"`
}

func apiHandlerView(res http.ResponseWriter, req *http.Request) {

	dataFolder := "data/"

	if req.Method == "GET" {
		res.Header().Set("contentType", "application/json")

		files, err := ioutil.ReadDir(dataFolder)
		if err != nil {
			log.Fatal(err)
		}
	
		template := oTemplate{Extension: "template", Renderer: "MARTILQREFERENCE:Mustache", Url: "template/martilq_view.must"}
		fileList := []Definition{}
		list := DirectoryList{}
		list.Custom = append(list.Custom, template)

		for _, file := range files {
			if !file.IsDir() {
				if filepath.Ext(file.Name()) == ".json" {
					describe := ""
					// Fetch the description
					data, err := ioutil.ReadFile(filepath.Join(dataFolder,file.Name()))
					if err != nil {
						log.Fatal("error with file read ")
					} else {
					
						var unknown map[string]interface{}
						err = json.Unmarshal(data, &unknown)
						if err != nil {
							log.Fatal("error with json read ")
						} else {
							describe = unknown["title"].(string)
						}
					}
				
					def := Definition{FileName: file.Name(), Describe: describe}
					fileList = append(fileList, def)
				}
			}
		}

		list.Files = fileList

		content, _ := json.Marshal(list)
        res.Write([]byte(content))
    } else {
        http.Error(res, "Only GET requests are allowed!", http.StatusMethodNotAllowed)
    }
	
}