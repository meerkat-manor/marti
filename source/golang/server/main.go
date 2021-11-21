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
	directory := flag.String("d", "static", "Static directory content")
	docsDirectory := flag.String("docs", "", "Docs directory content")
	flag.Parse()

	http.HandleFunc("/data/", func( res http.ResponseWriter, req *http.Request ) {
		//log.Printf("Data file %s \n", req.URL.Path)
		http.ServeFile(res, req, req.URL.Path[1:]);
	})

	http.HandleFunc("/docs/", func( res http.ResponseWriter, req *http.Request ) {
		if (*docsDirectory == "") {
			temp := "../../.."
			docsDirectory = &temp
		}
		//log.Printf("Docs file %s \n", req.URL.Path)
		localPath := filepath.FromSlash(*docsDirectory+req.URL.Path)
		f, err := os.Open(localPath)
		if err != nil {
			http.ServeFile(res, req, filepath.FromSlash(*directory + "/404.html"));
		} else {
			s, err := f.Stat()
			if err != nil || s.IsDir() {
				http.ServeFile(res, req, filepath.FromSlash(*directory + "/404.html"));
			} else {
				http.ServeFile(res, req, localPath);
			}
		}
	})

	fileServer := http.FileServer(FileSystem{http.Dir(*directory)})
	http.Handle("/", fileServer)

	log.Printf("Serving \"%s\" on HTTP port: %s\n", *directory, *port)
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
	//log.Printf("File %s \n", path)
	if s.IsDir() {
		index := strings.TrimSuffix(path, "/") + "/index.html"
		if _, err := fs.fs.Open(index); err != nil {
			return nil, err
		}
	}

	return f, nil
}