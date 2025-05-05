//+------------------------------------------------------------------+
//|                                             Optimum_Lot_Size.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>


CTrade Trading;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

input bool IsBuy=true;
input double RiskPercent=0.01;
input double RiskToReward=2;


void OnStart()
  {   
    
      double temp_RiskPercent=RiskPercent;
      double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      double StopLoss;
      double TakeProfit;
      double LotSize;
      double Price;
       
      
      if(temp_RiskPercent>0.04) temp_RiskPercent=0.04;
     
      if (IsBuy)
      {
         Price = Ask;
         StopLoss = NormalizeDouble(Ask-100*Point(),Digits());
         TakeProfit = NormalizeDouble(Ask+RiskToReward*100*Point(),Digits());
         LotSize=OptimumLotSize(Symbol(),Price,StopLoss,temp_RiskPercent);
         //Trading.Buy(LotSize,Symbol(),Ask,StopLoss,TakeProfit);  
         Alert("BUY "+LotSize+" of "+Symbol()+" at "+Price);  
      }
      else 
      {
         Price = Bid;
         StopLoss = NormalizeDouble(Bid+100*Point(),Digits());
         TakeProfit = NormalizeDouble(Bid-RiskToReward*100*Point(),Digits());
         LotSize=OptimumLotSize(Symbol(),Price,StopLoss,temp_RiskPercent);
         //Trading.Sell(LotSize,Symbol(),Bid,StopLoss,TakeProfit);  
         Alert("SELL "+LotSize+" of "+Symbol()+" at "+Price);  
      }
      Alert(Symbol()+" LotSize: "+LotSize+" Price: "+Price+" StopLoss: "+StopLoss+" TakeProfit: "+TakeProfit);  
   
  }


double OptimumLotSize(string symbol,double EntryPoint, double StoppLoss, double RiskPercent)
  {
      int            Diigit         =SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double         OneLotValue    =SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //MathPow(10,Diigit);
      
      double         ask            =SymbolInfoDouble(symbol,SYMBOL_ASK);
      //double         bid            =SymbolInfoDouble(symbol,SYMBOL_BID);
      
      string         BaseCurrency   =SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);
      string         ProfitCurency  =SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT); 
      string         AccountCurency =AccountInfoString(ACCOUNT_CURRENCY);
      
      double         AllowedLoss    =NormalizeDouble(RiskPercent*AccountInfoDouble(ACCOUNT_EQUITY),2);
      double         LossPoint      =NormalizeDouble(MathAbs(EntryPoint-StoppLoss),Diigit);
      double         Lotsize;

      //Fix rounding with the StopLoss
      StoppLoss = NormalizeDouble(StoppLoss,Diigit);
      
//      Alert(symbol + " EntryPoint: " + EntryPoint + " StopLoss: " + StoppLoss);
//
//      Alert("AllowedLoss    = "+AllowedLoss);
//      Alert("Diigit         = "+Diigit);
//      Alert("OneLotValue    = "+OneLotValue);
//      Alert("BaseCurrency   = "+BaseCurrency);
//      Alert("ProfitCurency  = "+ProfitCurency);
//      Alert("AccountCurency = "+AccountCurency);
//      Alert("LossPoint      = "+LossPoint);
      
      if (ProfitCurency==AccountCurency) 
         { 
         Lotsize=AllowedLoss/LossPoint; 
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
      //Alert("ProfitCurency==AccountCurency   LotSize="+Lotsize);
         
         return(Lotsize); 
         }
         
      else if (BaseCurrency==AccountCurency)
         {
         AllowedLoss=EntryPoint*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
      //Alert("BaseCurrency==AccountCurency  AllowedLoss = "+AllowedLoss);
         Lotsize=AllowedLoss/LossPoint; 
      //Alert("BaseCurrency==AccountCurency  LossPoint   = "+LossPoint);
      //Alert("BaseCurrency==AccountCurency  Lotsize     = "+Lotsize);
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2); 
      //Alert("BaseCurrency==AccountCurency  OneLotValue = "+OneLotValue);
      //Alert("BaseCurrency==AccountCurency  LotSize     = "+Lotsize);
         return(Lotsize);
         }
      
         else
         {
            string TransferCurrency=AccountCurency+ProfitCurency;
            ask=SymbolInfoDouble(TransferCurrency,SYMBOL_ASK);
            
            if(ask!=0) 
            {
               AllowedLoss=ask*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
               Lotsize=AllowedLoss/LossPoint; 
               Lotsize=NormalizeDouble(Lotsize/OneLotValue,2); 
               return(Lotsize);   
            
            }
            else
            {
               TransferCurrency=ProfitCurency+AccountCurency;
               ask=SymbolInfoDouble(TransferCurrency,SYMBOL_ASK);
               ask=1/ask;
               AllowedLoss=ask*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
               Lotsize=AllowedLoss/LossPoint; 
               Lotsize=NormalizeDouble(Lotsize/OneLotValue,2); 
               return(Lotsize);
            
            }
            
            if (ProfitCurency=="JPY") 
               { 
               Lotsize=AllowedLoss*1.5/LossPoint; 
               Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
               Alert("ProfitCurency==JPY   LotSize="+Lotsize);
                
               return(Lotsize); 
               }
                  
         return Lotsize; 
         }
          
  }
  