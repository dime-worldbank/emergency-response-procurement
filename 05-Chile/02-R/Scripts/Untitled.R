first_slide = fcase(
  panel_names == "Awarding time", 
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: awarding time is defined as the difference in days between awarding (<em>FechaAdjudicacion             </em>) and the contract signature (<em>Fecha Aceptacion</em>) \n \n \n
    - **Sample Restriction**: contracts (<em>ordenes de compra</em>) orginated by tenders (<em>Licitation</em>) and whose the stage is <em>enviada al proveedor</em>, <em>en proceso, aceptada</em>, and <em>recepción conforme</em>\n"),
  panel_names == "Total Processing Time",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: total processing time is defined as the difference in days between awarding (<em>FechaAdjudicacion</em>) and the beggining of the process (<em>FechaCreacion</em>) \n \n \n
    - **Sample Restriction**: contracts (<em>ordenes de compra</em>) orginated by tenders (<em>Licitation</em>) and whose the stage is <em>enviada al proveedor</em>, <em>en proceso, aceptada</em>, and <em>recepción conforme</em>\n"),
  panel_names == "Submission Time",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: submission time is defined as the difference in days between the beggining of the bidding window (<em>FechaPublicacion</em>) and the end of the bidding window (<em>FechaCierre</em>) \n \n \n
    - **Sample Restriction**: contracts (<em>ordenes de compra</em>) orginated by tenders (<em>Licitation</em>) and whose the stage is <em>enviada al proveedor</em>, <em>en proceso, aceptada</em>, and <em>recepción conforme</em>\n"),
  panel_names == "Decision Time",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: decision time is defined as the difference in days between the awarding (<em>FechaAdjudicacion</em>) and the end of the bidding window (<em>FechaCierre</em>) \n \n \n
    - **Sample Restriction**: contracts (<em>ordenes de compra</em>) orginated by tenders (<em>Licitation</em>) and whose the stage is <em>enviada al proveedor</em>, <em>en proceso, aceptada</em>, and <em>recepción conforme</em>\n"),
  panel_names == "Same Municipality Bidder",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the offer was made by a firm that is recorded to be from the same municipality as the purchasing entity \n \n \n
    - **Sample Restriction**: all offers for each tender that were succesfully registered"),
  panel_names == "Same Municipality Supplier",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the offer was won by a firm that is recorded to be from the same municipality as the purchasing entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered and had a winner"),
  panel_names == "Average Number of Bidders",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: average number of offers per lot (<em>ItemXLicitacion<e/m>)\n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Average Number of Direct Contracts",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the contract (<em>ordenes de compra</em>) was generated through a direct procurement process (<em>EsTratoDirecto = 1</em>)\n \n \n
    - **Sample Restriction**: all contracts (<em>ordenes de compra</em>)"),
  panel_names == "New Bidder Within the Last 12 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 12 months for any purchase organized by the same entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Bidder Within the Last 12 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 12 months for any purchases \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Bidder Within the Last 24 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 24 months for any purchase organized by the same entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Bidder Within the Last 24 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 24 months for any purchases \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Bidder Within the Last 6 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 6 months for any purchase organized by the same entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Bidder Within the Last 6 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submitted by a firm that hasn't bidded in the last 6 months for any purchases \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "New Supplier Within the Last 12 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 12 months for any purchases organized by the same entity \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "New Supplier Within the Last 12 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 12 months for any purchases \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "New Supplier Within the Last 24 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 24 months for any purchases organized by the same entity \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "New Supplier Within the Last 24 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 24 months for any purchases \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "New Supplier Within the Last 6 months to the Entity",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 6 months for any purchases organized by the same entity \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "New Supplier Within the Last 6 months",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was won by a firm that hasn't won in the last 6 months for any purchases \n \n \n
    - **Sample Restriction**: all lot (<em>ItemXLicitacion<e/m>) that were succesfully awarded"),
  panel_names == "Share of Only One Bidder Tenders",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the lot (<em>ItemXLicitacion<e/m>) was received only one offer \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Same Region Bidder",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submbitted by a firm that is located in the same region as the purchasing entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Same Region Supplier",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the winning offer was submbitted by a firm that is located in the same region as the purchasing entity \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Share of SMEs Bidding",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the bid was submbitted by a firm that is defined as a small medium enterprise as reported by tax data \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Share of SMEs winning", 
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it takes value 1 if the winning offer was submbitted by a firm that is defined as a small medium enterprise as reported by tax data \n \n \n
    - **Sample Restriction**: all bids that were succesfully registered"),
  panel_names == "Share of Direct contracts (values)",
  paste0("\n---\n\n\n\n# ", panel_names[i], "\n\n.panelset[\n  .panel[.panel-name[Intro]\n
    - **Outcome of Interest**: it is the net awarded amount in usd. The dummy for direct takes value 1 if the contract (<em>ordenes de compra</em>) was generated through a direct procurement process (<em>EsTratoDirecto = 1</em>)\n \n \n
    - **Sample Restriction**: all contracts (<em>ordenes de compra</em>)"),
)