# Golang

There is a working prototype of the **martiLQ** framework in Go.

Check out the source code under [client](client/)

The prototype is able to:

 * Initialise by creating a config file
 * Create a JSON **martiLQ** definition file based on files in a directory


## Client

__TO COME__

Publish of Golang package is yet to occur. A binary executable will also be
published for Linux and Windows of the prototype. 

This will occur after merge of code into ``main`` branch.

## Server

A web UI exists as a functionnal demonstration to view a collection of
**martiLQ** definition files.

## Docker

Please remember to copy documents into "docs" folder.

```

go env -w GOOS=linux
go env -w GOARCH=386
go build ./src/main.go

docker build -t martilq-go-server:latest .
```
