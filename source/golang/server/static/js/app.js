
"use strict";

const output = document.querySelector(".output");
var localJsonFile = "data/marti_test_asic.json";
 
var btn = document.getElementById("loadBtn");
btn.onclick = dataLoadFunction;

function dataLoadFunction() {
    var loadDef = document.getElementById("loaddefinition")
    fetchData("data/"+loadDef.value);
}

window.addEventListener("DOMContentLoaded", () => {
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('martilq')) {
        var loadDef = urlParams.get('martilq');
        fetchData("data/"+ loadDef);
        var ld = document.getElementById("loaddefinition")
        ld.value = loadDef
    } else {
        output.textContent = "Please supply a MartiLQ definition to load, such as \"marti_test_asic.json\"";
    }
});

function fetchData(dataFile) {
    output.textContent = "Loading....";

    fetch(dataFile)
    .then((response) => response.json()) 
    .then((data) => {
        output.innerHTML = ""; 

        var hdr = itemHeader(data)
        output.append(hdr);

        const br = document.createElement("br");
        output.append(br);

        const tble = document.createElement("table");
        tble.classList.add("table");
        tble.classList.add("table-striped");
        tble.classList.add("table-sm");

        var thd  = document.createElement("thead");
        var th = document.createElement("tr");
        //scope="col"
        th.innerHTML = "<th>Title</th><th>Document</th><th>Size</th><th>Issued</th><th>Modified</th><th>Expires</th><th>State</th><th>Version</th>";
        thd.append(th);
        tble.append(thd);

        var tby  = document.createElement("tbody");
        data.resources.forEach((el) => {
            //console.log(el);
            jsonList(tby, el);
        });
        tble.append(tby);
        output.append(tble);
    });
}

function jsonList(tble, item) {
  const tr = document.createElement("tr");
  tr.innerHTML = itemRow(item);
  tble.append(tr);
}


function itemHeader(item) {

    const hdr = document.createElement("table");
    hdr.classList.add("table");
    hdr.classList.add("table-striped");
    hdr.classList.add("table-sm");

    var describe =  item.description.replace(/\r\n/g, "<br>");
    var rows = `<tr><th>Title</th><td>${item.title}</td></tr>`;
    rows = rows+ `<tr><th>UID</th><td>${item.uid}</td></tr>`;
    rows = rows+ `<tr><th>Description</th><td>${describe}</td></tr>`;
    rows = rows+ `<tr><th>Issued</th><td>${item.issued}</td></tr>`;
    rows = rows+ `<tr><th>Modified</th><td>${item.modified}</td></tr>`;
    rows = rows+ `<tr><th>Access Level</th><td>${item.accessLevel}</td></tr>`;
    rows = rows+ `<tr><th>Rights</th><td>${item.rights}</td></tr>`;
    hdr.innerHTML = rows;

    return hdr
}


function itemRow(item) {

    var row = `<td>${item.title}</td>`;
    row = row + `<td><a href="${item.url}">${item.documentName}</a></td>`;
    row = row + `<td>${item.length}</td>`;
    row = row + `<td>${item.issuedDate}</td>`;
    row = row + `<td>${item.modified}</td>`;
    row = row + `<td>${item.expires}</td>`;
    row = row + `<td>${item.state}</td>`;
    row = row + `<td>${item.version}</td>`;

    return row
}
