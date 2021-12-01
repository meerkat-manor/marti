
"use strict";

const output = document.querySelector(".output");
var localJsonFile = "";
 
var btn = document.getElementById("loadBtn");
if (btn) {
    btn.onclick = dataLoadFunction;
}

function dataLoadFunction() {
    var loadDef = document.getElementById("loaddefinition")
    if (loadDef.value.startsWith("http://") || loadDef.value.startsWith("https://")) {
        fetchData(loadDef.value);
    } else {
        fetchData("data/"+ loadDef.value);
    }
}


var definition_must = "";
var jdata = {};

window.addEventListener("DOMContentLoaded", () => {

    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('martilq')) {
        var loadDef = urlParams.get('martilq');
        if (loadDef.startsWith("http://") || loadDef.startsWith("https://")) {
            fetchData(loadDef);
        } else {
            fetchData("data/"+ loadDef);
        }
        var ld = document.getElementById("loaddefinition")
        if (ld) {
            ld.value = loadDef
        }
    } else {
        output.innerHTML = "Please supply a MartiLQ definition to load, such as \"<a href=\"?martilq=martilq_asic.json\">martilq_asic.json</a>\"";
    }
});

function fetchData(dataFile) {
    output.textContent = "Loading....";

    fetch(dataFile)
    .then((response) => response.json()) 
    .then((data) => {

        var template = "template/martilq_default.must";
        jdata["item"] = data;
        if (data.description) {
            jdata["describe"] = data.description.replace(/\r\n/g, "<br>");
        }

        if (data["custom"]) {
            data.custom.forEach((el) => {
                if (el.extension == "template" && el.renderer == "MARTILQREFERENCE:Mustache") {
                    template = el.url;
                }
            });
        }
        // Use the template
        if (template == "") {
            template = "template/martilq_no_struct.must"
        }
        fetchMust(template);

    });
}


function fetchMust(mustTemplateFile) {

    fetch(mustTemplateFile)
    .then((response) => response.text())
    .then((data) => {
        definition_must = data

        const dMust = document.createElement("div");
        dMust.innerHTML = Mustache.render(definition_must, jdata);
        output.innerHTML = ""; 
        output.append(dMust);
    });

}
