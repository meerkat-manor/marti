# Sample execution

A number of samples are provided to demonstrate what the **martiLQ** documents
look like and how simple the execution can be.

## Python

If you have the required Python software and packages installed, and have Internet
then the following commands will generate output for you.  If you use
a proxy, then there can be issues.

Open a terminal with the current directory set to the project root (here)

```
.\source\python\client\martiLQ.py -t MAKE -s "./docs/source/" -o "./test/python/results/test_proc_docs.json" -c ./docs/source/samples/json/sample_docs.ini -u https://github.com/meerkat-manor/marti/tree/draft_specifications/docs/source/ --filter "w*"


.\source\python\client\martiLQ.py -t GEN -s "./docs/source/samples/python/test/http/" -o "./test/python/results/test_proc_bsb.json" -c ./docs/source/samples/json/sample_bsb.ini -u http://apnedata.merebox.com.s3.ap-southeast-2.amazonaws.com/au/bsb/
```

There are also a number of Python test scripts you can execute

## Powershell

If you have the required PowerShell software and packages installed, and have Internet
access then the following commands will generate output for you.

Open a terminal with the current directory set to the project root (here)

The PowerShell command

```ps1

.\test\powershell\martiLQ_base_test.ps1

# This sample will retrieve a number of CKAN files from
# Australian government and Singapore sites to demonstrate conversion
.\test\powershell\martiLQ_ckan_test.ps1

```

## Go

If you have the required GOLANG software and packages installed, and have Internet
access then the following commands will generate output for you.  If you use
a proxy, then there can be issues.

Open a terminal with the current directory set to the project root (here)

A batch (cmd) script

```bat
SET MARTILQ_PROJECT_PATH=%CD%
CD %MARTILQ_PROJECT_PATH%\source\golang\client\src

go run . -- -t GEN -m %MARTILQ_PROJECT_PATH%/test/golang/results/test_proc_bsb.json -c %MARTILQ_PROJECT_PATH%/docs/source/samples/json/sample_docs.ini -s %MARTILQ_PROJECT_PATH%/docs/source --title "DOCS Sample" --description "Directory example for DOCS" --update

go run . -- -t GEN -m %MARTILQ_PROJECT_PATH%/test/golang/results/test_proc_bsb.json -c %MARTILQ_PROJECT_PATH%/docs/source/samples/json/sample_bsb.ini -s %MARTILQ_PROJECT_PATH%/docs/source/samples/python/test/http --title "GEN005" --description "Directory example for BSB with filter" -R --filter "BSBDirectory.*\.csv" --update

cd %MARTILQ_PROJECT_PATH%
```

A PowerShell script to execute Go program

```ps1
$env:MARTILQ_PROJECT_PATH=Get-Location
Set-Location -Path (Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "source\golang\client\src") -PassThru

$mfile = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "test/golang/results/test_proc_docs.json"
$cfile = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "docs/source/samples/conf/sample_docs.ini"
$spath = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "docs/source/"

go run . -- -t MAKE -m $mfile -c $cfile -s $spath --title "DOCS Sample" --description "Directory example for DOCS" --filter "w*"  --update

$mfile = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "test/golang/results/test_proc_bsb.json"
$cfile = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "docs/source/samples/conf/GEN005.ini"
$spath = Join-Path -Path $env:MARTILQ_PROJECT_PATH -ChildPath "docs/source/samples/python/test/http/"

go run . -- -t MAKE -m $mfile -c $cfile -s $spath --title "GEN005" --description "Directory example for BSB"   --update

Set-Location -Path $env:MARTILQ_PROJECT_PATH -PassThru
```
