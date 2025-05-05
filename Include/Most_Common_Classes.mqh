//+------------------------------------------------------------------+
//|                                           Most_Common_Classes.mqh|
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

CTrade Trading;
CPositionInfo Position;

void close_All_Orders()
{
      do
      {
         PositionSelectByTicket(PositionGetTicket(0));
         Trading.PositionClose(PositionGetInteger(POSITION_TICKET));   
      }while(PositionsTotal()!=0);     

}





double OptimumLotSize(string symbol,double EntryPoint, double StoppLoss, double RiskPercent)
{
      int            Diigit         =SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double         OneLotValue    =MathPow(10,Diigit);
      
      double         ask            =SymbolInfoDouble("GBPUSD",SYMBOL_ASK);
      
      double         bid            =SymbolInfoDouble(symbol,SYMBOL_BID);
      
      string         BaseCurrency   =SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);
      string         ProfitCurency  =SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT); 
      string         AccountCurency =AccountInfoString(ACCOUNT_CURRENCY);
      
      double         AllowedLoss    =RiskPercent*AccountInfoDouble(ACCOUNT_EQUITY);
      double         LossPoint      =MathAbs(EntryPoint-StoppLoss);
      double         Lotsize;
      
      
      
      
      
      if (ProfitCurency==AccountCurency) 
         { 
         Lotsize=AllowedLoss/LossPoint; 
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
          
         return(Lotsize); 
         }
         
      else if (BaseCurrency==AccountCurency)
         {
         AllowedLoss=ask*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
         Lotsize=AllowedLoss/LossPoint; 
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2); 
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
                
               return(Lotsize); 
               }
                  
         return Lotsize; 
         }
          

}



///////////////// Is new candlle////////////

bool IsNewCanddle (ENUM_TIMEFRAMES TimeFrame)
{

   static datetime LastCandleTime;
   datetime CurrentCandleTime=iTime(NULL,TimeFrame,0);//////// Current Candle Time=Time[0]
   if(LastCandleTime==CurrentCandleTime) return(false);
   else

      {
      LastCandleTime=CurrentCandleTime;
      return(true);
      }


}


////////////////////////////////////////Symbol Open Orders//////////////////////////////////////////////////////////


int SymbolOpenOrders (string Symbolname)
 
  {
  int OpenOrders=0;
  for(int t=0;t<PositionsTotal();t++)
   
    {
         PositionSelectByTicket(PositionGetTicket(t));
         
            if (Position.Symbol()==Symbolname) OpenOrders=OpenOrders+1;
 
 
    }
   
    return(OpenOrders);

  }
  
 
 ////////////////// Close orders ///////////

 void CloseOrders (string Symboll, bool AllOrders)
  
  {
         for(int t=0;t<=PositionsTotal();t++)
      
            {
            PositionSelectByTicket(PositionGetTicket(t));
            if(AllOrders) Trading.PositionClose(PositionGetInteger(POSITION_TICKET));
           
            if(Position.Symbol()==Symboll) Trading.PositionClose(PositionGetInteger(POSITION_TICKET));
     
            }
}
 
 
 
 
  
  /////////////////////// Calculate RSI //////////////////
  
  
  
double RSICalculator(string symbol, ENUM_TIMEFRAMES TimeFrame, int period, int shift, int BufferNumber=10)
{
   
   //Creating array for prices
   double RSIArray[];
   
   //Identying RSI properties
   int RSIDef = iRSI(symbol, TimeFrame, period, PRICE_CLOSE);
   //Sorting prices array
   ArraySetAsSeries(RSIArray,true);
   
   //Identifying EA
   CopyBuffer(RSIDef,0,0,BufferNumber,RSIArray);
   double RSIValue = NormalizeDouble(RSIArray[shift],2);
   return RSIValue;

}




////////////////////// Moving Average calculator ////////////////////




double MACalculator(string symbol, ENUM_TIMEFRAMES TimeFrame, int period, int shift,ENUM_MA_METHOD Mode,ENUM_APPLIED_PRICE ApllyedPrice,int BufferNumber=10)
{
   //Creating array for prices
   double MAArray[];
   
   int MADef=iMA(symbol,TimeFrame,period,shift,Mode,ApllyedPrice);
   //Sorting prices array
   ArraySetAsSeries(MAArray,true);
   
   //Identifying EA
   CopyBuffer(MADef,0,0,BufferNumber,MAArray);
   double MAValue = NormalizeDouble(MAArray[shift],6);
   return MAValue;
   
 }
 
 
 
 
 double MACDcalculator (bool TrueForHistogram_FalseForSignal,string symbol, ENUM_TIMEFRAMES TimeFrame,ENUM_APPLIED_PRICE aplyedPrice,int FastEMA_Period,int SlowEMA_Period,int SignalSMA_Period,int shift, int BufferNumber=10)
{

   //cretaing an array for prices for MACD main line, MACD signal line
   double MACDMainLine[];
   double MACDSignalLine[];
   
   //Defining MACD and its parameters
   int MACDDef = iMACD(symbol,TimeFrame,FastEMA_Period,SlowEMA_Period,SignalSMA_Period,aplyedPrice);
   
   //Sorting price array from current data for MACD main line, MACD signal line
   ArraySetAsSeries(MACDMainLine,true);
   ArraySetAsSeries(MACDSignalLine,true);
   
   //Storing results after defining MA, line, current data for MACD main line, MACD signal line
   CopyBuffer(MACDDef,0,0,BufferNumber,MACDMainLine);
   CopyBuffer(MACDDef,1,0,BufferNumber,MACDSignalLine);
   
   //Get values of current data for MACD main line, MACD signal line
   double MACDMainLineVal = NormalizeDouble(MACDMainLine[shift],6);
   double MACDSignalLineVal = NormalizeDouble(MACDSignalLine[shift],6);
   
   if (TrueForHistogram_FalseForSignal)
   {
      return MACDMainLineVal;
   }
   else
   {
      return MACDSignalLineVal;
   }
   

}




////////////////////// Calender check

bool Is_Important_Event(string Country_code, int Size_of_Event_List=20)
{
   ulong EventArray[10] = {999010007,840050014};
   
   
   
   MqlCalendarValue values[]; 
   datetime date_from=TimeCurrent();  // take all events from the beginning of the available history 
   datetime date_to=0; // take events not older than 2016 
   if(CalendarValueHistory(values,date_from,date_to,Country_code)) 
     { 

      ArrayResize(values,Size_of_Event_List); 
      //ArrayPrint(values); 
     } 
   else 
     { 
      PrintFormat("Error! Failed to get values for event_id=%d"); 
      PrintFormat("Error code: %d",GetLastError()); 
     }

    //////////////////////// Comparision ///////////////
    bool resault= false;
    for(int i=0; i< 10; i++)
    {
      for (int j=0; i<Size_of_Event_List; j++)
      {
         if ( values[j].event_id == EventArray[i]) resault=true;
      
      }  
           
    }
   return resault;

}


 

bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   //--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
   //--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
  
  
  
  //| Check the correctness of the order volume  
  
  
  bool CheckVolumeValue(double volume,string &description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }
  
  
//////////////////////////////////////////////////////////////////////////
////////////////////////Cascade Trading Functions//////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////    
  


struct ST_StopLoss_TakeProfit {
    double NewStopLoss;
    double NewTakeProfit;

};




 ////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////Cascade Trading////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

ST_StopLoss_TakeProfit Cascade_trading(string Symbool,double lotSize,bool IsBuy,double Ask, double Bid, double TakeProfit, double StopLoss, double StopLossPoints, double MinimumStopLossPoints, double R2R, bool TrailingAllowed, int TotalOpenOrder)
{
      ST_StopLoss_TakeProfit returning_arr;
      
      bool enough_money;
      bool enough_valume;
      string message;
      returning_arr.NewStopLoss=StopLoss;
      returning_arr.NewTakeProfit=TakeProfit;

      //Comment("NEw StopLoss "+ returning_arr.NewStopLoss);

      if(IsBuy && Ask>=TakeProfit && TrailingAllowed && TotalOpenOrder>=1)
            {  

               enough_money =CheckMoneyForTrade(Symbol(),lotSize,ORDER_TYPE_BUY);
               enough_valume=CheckVolumeValue(lotSize,message);
               returning_arr.NewStopLoss=Ask-MinimumStopLossPoints*Point();
               returning_arr.NewTakeProfit=Ask+R2R*StopLossPoints*Point();
               
               if(enough_money && enough_valume) Trading.Buy(lotSize,Symbool,Ask,0,0,"Trailing order");
                                   
            } 
            
      if(!IsBuy && Bid<=TakeProfit && TrailingAllowed && TotalOpenOrder>=1)
            {  
               enough_money =CheckMoneyForTrade(Symbol(),lotSize,ORDER_TYPE_SELL);
               enough_valume=CheckVolumeValue(lotSize,message);
               returning_arr.NewStopLoss = Bid+MinimumStopLossPoints*Point();
               returning_arr.NewTakeProfit=Bid-R2R*StopLossPoints*Point();
               if(enough_money && enough_valume) Trading.Sell(lotSize,Symbool,Bid,0,0,"Trailing order");
               
                   
            }

             if (IsBuy && Ask < returning_arr.NewStopLoss && TotalOpenOrder>=2)
             {
                while  (SymbolOpenOrders(Symbol()) !=0) CloseOrders(_Symbol,true);

             }
             if (!IsBuy && Bid >returning_arr.NewStopLoss && TotalOpenOrder>=2)
             {
                while  (SymbolOpenOrders(Symbol()) !=0) CloseOrders(_Symbol,true);

             }
     

   return returning_arr;
   
  }
