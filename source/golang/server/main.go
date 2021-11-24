package main

import (
	"flag"
	"log"
	"net/http"
	"strings"
	"path/filepath"
	"os"
)

func main() {
	port := flag.String("p", "8080", "Http listen port")
	staticDirectory := flag.String("s", "static", "Static directory content")
	docsDirectory := flag.String("docs", "", "Docs directory content")
	dataDirectory := flag.String("data", "", "Data directory content")
	trace := flag.Bool("trace", false, "Produce trace logs")
	flag.Parse()

	if *trace == true {	
		log.Printf("static folder: %s\n", *staticDirectory)
		log.Printf("data folder: %s\n", *dataDirectory)
		log.Printf("docs folder: %s\n", *docsDirectory)
	}

	http.HandleFunc("/data/", func( res http.ResponseWriter, req *http.Request ) {
		safePath := ValidatePath(filepath.FromSlash(req.URL.Path[1:]))
		if (*dataDirectory != "") {
			safePath = filepath.FromSlash(filepath.Join(*dataDirectory, strings.Replace(safePath, "data/", "", 1)))
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
			log.Printf("fetch docs: \"%s\"", localPath)
		}
		f, err := os.Open(localPath)
		if err != nil {
			log.Printf("fetch docs error: \"%s\" with %s", localPath, err)
			http.ServeFile(res, req, filepath.FromSlash(*staticDirectory + "/404.html"));
		} else {
			s, err := f.Stat()
			if err != nil || s.IsDir() {
				log.Printf("fetch docs stat error: \"%s\"", localPath)
				http.ServeFile(res, req, filepath.FromSlash(*staticDirectory + "/404.html"))
			} else {
				http.ServeFile(res, req, localPath)
			}
		}
	})

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