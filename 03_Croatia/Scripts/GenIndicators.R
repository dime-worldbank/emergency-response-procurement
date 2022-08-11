# ---------------------------------------------------------------------------- #
#
#                         Emergency Response Procurement
#
#                                  Croatia
#
#                            Generate Indicators 
#
#       Author: Hao Lyu                           Update: 08/10/2022
#
# ---------------------------------------------------------------------------- #

# ================================= Task 1 =================================== #
# 
#       Objectives: 
#
#         1  Indicator for Winners and Bidders 
#
#         2  Indicator for Market Concentration 
#
#         3  Indicator for Covid Periods 
#
#         4  Product Classification
#     
#         
#       Datasets: 
#
#         1   Process level              -  procurementprocess    //  60,  84k  // typeofdocument_name, ref_bidding_id, process_datesentfirst
#         2   Lot level                  -  process_item          //  76, 228k  //
#         3   Contract level             -  process_contract_item // 106, 235k  // 
#         4   Bid level                  -  process_item_bid      // 122, 697k  //process_item_bid_id
#
# ---------------------------------------------------------------------------- #


      # since the file is too large, creating a random sample to test codes 
        
          process_contract_item         <- as.data.table(process_contract_item)
          process_contract_item_sample  = process_contract_item[sample(.N, 1000)]
          
          process_item                  <- as.data.table(process_item)
          process_item_sample           = process_item[sample(.N, 1000)]
          
          procurementprocess            <- as.data.table(procurementprocess)
          procurementprocess_sample     = procurementprocess[sample(.N, 1000)]
          
          process_item_bid              <- as.data.table(process_item_bid)
          process_item_bid_sample       = process_item_bid[sample(.N, 1000)]
          
        

# 1 Indicator for Winners and Bidders  ----------------------------------------
        
      # bid level; whether firm can bid in specific tenders- check sushimita's comments 
          
      # number of bidders per tender 
          # @ Maria - did not find tender ID in any of the datasets, as well as the previous do file 
          no_bid_tender <- process_item_bid[c(bid_item_id, tendertype_name)]
          
          no_bid_tender = process_item_bid[, .N, by = c("tendertype_name")]
          
          # bid_item_id is about bid 
          
      # new winners 
          
      # new bidders 

          
        

# 2 Indicator for Market Concentration ----------------------------------------
      
      # sector level - item 
          

# 3 Indicator for Covid Periods -----------------------------------------------



# 4 Product Classification ----------------------------------------------------

      
          
          

# make the list 
# go through the code 
# the raw dataset 
# thu: 











