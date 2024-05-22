# 1: Introduction

The code inside this folder, `1-import`, is destinate to read the raw files and harmonize the files. It means, adjust names, labels, formats and minor cleannings.
The main idea is that we have a set of data in dta/rds format that we can easy merge and append to create the data we requires for our astudy.

# 2: Source data

Federal public procurement in Brazil has three main source, two of them is public and one is restrict.

## 2.1 Procurement data

* [Portal da transparência](https://www.portaltransparencia.gov.br/origem-dos-dados): A website that we have access to the 
federal expense composition. It allows to download data of tenders and contracts monthly. 
* [Compras dados](http://compras.dados.gov.br/): It is a website that allows to download almost every piece of information in the tender procces. However,
it is quite more difficult to download the data.
* SIASG datawarehouse: this is the original source that has restrict access.

##  2.2 Product Classification 
The procurement processes dataset and the contracts dataset contain detailed information on purchased items. Items are classified using the CATSER (catálogo de serviços) catalog for service, and the CATMAT (catálogo de materiais) catalog for goods.  Using these classifications, it is possible categorizes items in some agreagation level. 

Download option:
* [CATMAT/CATSER](https://www.gov.br/compras/pt-br/acesso-a-informacao/consulta-detalhada/planilha-catmat-catser): www.gov.br
* [CATMAT](http://compras.dados.gov.br/docs/lista-metodos-materiais.html): compras.dados.gov
* [CATSER](http://compras.dados.gov.br/docs/lista-metodos-servicos.html): compras.dados.gov

### [CATMAT](https://www.gov.br/saude/pt-br/acesso-a-informacao/gestao-do-sus/economia-da-saude/banco-de-precos-em-saude/catalogo-de-materiais-2013-catmat)
  Goods are detailed up to 6 digits levels. The materials are classifications that are aggregable by 2, 3, and 5 digits level.
https://www.gov.br/compras/pt-br/acesso-a-informacao/consulta-detalhada/planilha-catmat-catser/view 

### [CATSER](http://compras.dados.gov.br/): 
  Services are detailed up to 5 digits levels. The materials are classifications that are aggregable by 1, 2, 3, and 4 digits level.
 
# 3: Programs
The import proccess were made in the KCP project and FA project.

# 4: Outputs
In this sections the usefull outputs that is not in the overleaf file.

* **01-table_products_covid_level.xlsx**: Table of Covid products levels (code, name, covid level, total expenses)

# 5: Frenquently questions



## 01: Purchase methods
The tender data has the following methods to do federal public expense:

* Competitive Bidding (concorrência pública)
* Reverse Auction (pregão).
* Reverse Auction thogth price registration (FA: Framework Agreement) (pregão registro de preços).
* Invited Bidding (Convite)
* Unenforceable Biddings (inexigibilidade de licitacao).
* Direct purchase (dispensa de licitação)
* Restricted bidding (tomada de precos)

In our agreggations we have:
 * Reverse Auction:  Reverse Auction (pregão) + Reverse Auction thogth price registration 
 * Tender waiver: Direct purchase (dispensa de licitação)
 * Tender unenforce: Unenforceable Biddings (inexigibilidade de licitacao)
 
 Tender waiver is used in crises such as COVID-19.
 
## 02: Grey Bar meaning
This means the Covid-19 waves shared by Hao.

## 03: Sample regression
The data for impact evaluation takes into account the lot/tender data for the period between 2015 and 2022. It compares "High covid items" vs. "No covid items". It is limited to **goods** (5 digits) that was purchased an average of over 50 per year. 

It has dropped all low covid and medium covid. 	

## 04: Extra controls in the regressions
The extra controls are the Fixed effect described in the title of the graphs or rows in the tables. For instance, the column (3) uses **item FE**, **month FE**, and **Buyer FE**.


# Tasks 20240516

Dear Leandro,

 

As discussed, I am sending here a list of todos in order of importance. You will see the detailed comments in the word file with the draft write-up.

 

Please note that this is a relatively long list, but (with the exception of the first one) all points are very very minor! Please let me know your views in terms of feasibility. For example, would it be possible to do the high priority points by this Friday?

 

High priority:

 

> **New graphs/tables:**
>  * 1) 1 table to provide a list of few covid-related products that can be used as examples (sectionts for Covid-re 3); 
>  * 2) one graph with the time trends (at quarter or semester level) in the number of contraclated products (high covid) and non-Covid products (no covid);
>  * 3) one graph with the time trends (at quarter or semester level) in the total contracting volume for Covid-related products (high covid) and non-Covid products (no covid);
>  * 4) one graph with the time trends (at quarter or semester level) in the average contract value for Covid-related products (high covid) and non-Covid products (no covid). You may have done this already!
> * Section 4: 
> * 1) Add some numbers in the test where indicated. This is from the analysis already done, but it is hard to get the exact numbers from the graphs.
> * 2)  For each graph/table in section 4, I have added questions in graph note on specific aspects of the analysis that I am not sure about, so it should be sufficient if you just reply to those questions.
> * 3)  For each graph/table in section 4, I have added small minor points to correct labels, graph titles, yaxis titles, etc. Primarily, in all graphs we need to: (i) use “Covid-related products” for “high covid” and “non-Covid products” for “no covid”; (ii) indicate the variable reported in y-axis as y-axis title rather than graph title, (iii) make small adjustments to the label for the outcome variable. These are only small twists to the outlook!
> * 4)  For the analysis of firm exist, I would need a small change in the time references for the calculation of survival rates

> * In the abstract, section 1, section 2, and section 3 there are few questions to clarify small (but urgent) aspects about the analysis (eg definition of “small and micro” firms; original vs final prices; etc).
 
### Ansering comments:

> **@Leandro Justino Pereira Veloso  , can you please confirm if these references / data sources are correct, and if not correct them?**
> * Portal da transparência and Firm's register in the Federal Taxes portal are  open sources. RAIS is restricted, we have access thorugh tecnical coperation. 

> @Leandro Justino Pereira Veloso , is it correct that in our analysis we consider final contract prices (so, after renegotiations, in case there was any renegotiations)
> * I our analysis we use estimate price! 

Section 4:

Note: Is there any sample restriction for this analysis? If yes, why? Is this analysis at tender level? Does this represent the number of Covid tenders by procurement methods? “Covid tenders” are defined based on a text search of key words, as explained in section 3, right? 



contracts signed is not clear. I prefer purchases or lots... 
Covid-related products is only high COVID?


> @Leandro Justino Pereira Veloso , can you please confirm that the analysis looks at SMALL and MICRO enterprises? SMEs stands for small and medium enterprises. It is ok if we looked at small and micro, but let's please be sure on this. In this case, can you please provide a sentence with the rationale of looking at SMALL and MICRO enterprises rather than SMEs (small and medium enterprises)?


# Graph changes

legend to : change labels to "Covid-related products" and "Non-Covid products"


"time between starts of the process and contract award"

 "number of bidders"
 
 
2020 firms into 2021
2019 firms into 2020
2018 firms into 2019
2017 firms into 2018
------------------------
2019 firms into 2021
2018 firms into 2020
2017 firms into 2019

 