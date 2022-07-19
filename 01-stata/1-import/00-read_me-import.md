# 1: Introduction

The code inside this folder, `1-import`, is destinate to read the raw files and harmonize the files. It means, adjust names, labels, formats and minor cleannings.
The main idea is that we have a set of data in dta/rds format that we can easy merge and append to create the data we requires for our astudy.

# 2: Source data

Federal public procurement in Brazil has three main source, two of them is public and one is restrict.

## Public sources

* [Portal da transparência](https://www.portaltransparencia.gov.br/origem-dos-dados): A website that we have access to the 
federal expense composition. It allows to download data of tenders and contracts monthly. 
* [Compras dados](http://compras.dados.gov.br/): It is a website that allows to download almost every piece of information in the tender procces. However,
it is quite more difficult to download the data.

## Prite source
* SIASG datawarehouse: this is the original source that has restrict access.

# 3: Programs

The import proccess were made in the KCP project and FA project.=