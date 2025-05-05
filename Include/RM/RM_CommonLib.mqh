//+------------------------------------------------------------------+
//|                                                 RM_CommonLib.mqh |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

CTrade Trade;
CPositionInfo Position;

//+------------------------------------------------------------------+
//| CloseAllOrders                                                   |
//+------------------------------------------------------------------+
void CloseAllOrders()
  {
   do
     {
      PositionSelectByTicket(PositionGetTicket(0));
      Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
     }
   while(PositionsTotal()!=0);
  }


//+------------------------------------------------------------------+
//| OptimumLotSize                                                   |
//+------------------------------------------------------------------+
double OptimumLotSize(string symbol,double entryPoint, double StoppLoss, double riskPercent)
  {
   long           Diigit         =SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double         OneLotValue    =SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //MathPow(10,Diigit);

//double         ask            =SymbolInfoDouble("GBPUSD",SYMBOL_ASK);
   double         ask            =SymbolInfoDouble(symbol,SYMBOL_ASK);

//double         bid            =SymbolInfoDouble(symbol,SYMBOL_BID);

   string         BaseCurrency   =SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);
   string         ProfitCurency  =SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT);
   string         AccountCurency =AccountInfoString(ACCOUNT_CURRENCY);

   double         AllowedLoss    =NormalizeDouble(riskPercent*AccountInfoDouble(ACCOUNT_EQUITY),2);
   double         LossPoint      =NormalizeDouble(MathAbs(entryPoint-StoppLoss),(int)Diigit);
   double         Lotsize;

//Fix rounding with the StopLoss
   StoppLoss = NormalizeDouble(StoppLoss,(int)Diigit);

   if(ProfitCurency==AccountCurency)
     {
      Lotsize=AllowedLoss/LossPoint;
      Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);

      return(Lotsize);
     }

   else
      if(BaseCurrency==AccountCurency)
        {
         AllowedLoss=entryPoint*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
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

         if(ProfitCurency=="JPY")
           {
            Lotsize=AllowedLoss*1.5/LossPoint;
            Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
            Alert("ProfitCurency==JPY   LotSize="+DoubleToString(Lotsize,4));

            return(Lotsize);
           }

         return Lotsize;
        }

  }



//+------------------------------------------------------------------+
//| IsNewCandle                                                      |
//+------------------------------------------------------------------+
bool IsNewCandle(ENUM_TIMEFRAMES timeFrame)
  {
   static datetime LastCandleTime;
   datetime CurrentCandleTime=iTime(NULL,timeFrame,0);
   if(LastCandleTime==CurrentCandleTime)
     {
      return false;
     }
   else
     {
      LastCandleTime=CurrentCandleTime;
      return true;
     }
  }


//+------------------------------------------------------------------+
//| SymbolOpenOrders                                                 |
//+------------------------------------------------------------------+
int SymbolOpenOrders(string Symbolname)
  {
   int OpenOrders=0;
   for(int t=0;t<PositionsTotal();t++)
     {
      PositionSelectByTicket(PositionGetTicket(t));

      if(Position.Symbol()==Symbolname)
         OpenOrders=OpenOrders+1;
     }
   return(OpenOrders);
  }


//+------------------------------------------------------------------+
//| CloseOrders                                                      |
//+------------------------------------------------------------------+
void CloseOrders(string Symbolname, bool AllOrders)
  {
   for(int t=0;t<=PositionsTotal();t++)
     {
      PositionSelectByTicket(PositionGetTicket(t));
      if(AllOrders)
         Trade.PositionClose(PositionGetInteger(POSITION_TICKET));

      if(Position.Symbol()==Symbolname)
         Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
     }
  }

//+------------------------------------------------------------------+
//| RSICalculator                                                    |
//+------------------------------------------------------------------+
double RSICalculator(string symbol, ENUM_TIMEFRAMES timeFrame, int period, int shift, int BufferNumber=10)
  {
//Create array for prices
   double RSIArray[];

//Identify RSI Properties
   int RSIDef = iRSI(symbol, timeFrame, period, PRICE_CLOSE);
//Sort price array
   ArraySetAsSeries(RSIArray,true);

//Identifying EA
   CopyBuffer(RSIDef,0,0,BufferNumber,RSIArray);
   double RSIValue = NormalizeDouble(RSIArray[shift],2);

   return RSIValue;
  }


//+------------------------------------------------------------------+
//| MACalculator                                                     |
//+------------------------------------------------------------------+
double MACalculator(string symbol, ENUM_TIMEFRAMES timeFrame, int period, int shift, ENUM_MA_METHOD Mode, ENUM_APPLIED_PRICE AppliedPrice, int BufferNumber=10)
  {
//Create array for prices
   double MAArray[];

   int MADef=iMA(symbol,timeFrame,period,shift,Mode,AppliedPrice);
//Sort price array
   ArraySetAsSeries(MAArray,true);

//Identifying EA
   CopyBuffer(MADef,0,0,BufferNumber,MAArray);
   double MAValue = NormalizeDouble(MAArray[shift],6);

   return MAValue;
  }



//+------------------------------------------------------------------+
//| MACDcalculator                                                   |
//+------------------------------------------------------------------+
double MACDcalculator(bool TrueForHistogram_FalseForSignal,string symbol, ENUM_TIMEFRAMES timeFrame,ENUM_APPLIED_PRICE aplyedPrice,int fastEMA_Period,int slowEMA_Period,int signalSMA_Period,int shift, int BufferNumber=10)
  {

//cretaing an array for prices for MACD main line, MACD signal line
   double MACDMainLine[];
   double MACDSignalLine[];

//Defining MACD and its parameters
   int MACDDef = iMACD(symbol,timeFrame,fastEMA_Period,slowEMA_Period,signalSMA_Period,aplyedPrice);

//Sorting price array from current data for MACD main line, MACD signal line
   ArraySetAsSeries(MACDMainLine,true);
   ArraySetAsSeries(MACDSignalLine,true);

//Storing results after defining MA, line, current data for MACD main line, MACD signal line
   CopyBuffer(MACDDef,0,0,BufferNumber,MACDMainLine);
   CopyBuffer(MACDDef,1,0,BufferNumber,MACDSignalLine);

//Get values of current data for MACD main line, MACD signal line
   double MACDMainLineVal = NormalizeDouble(MACDMainLine[shift],6);
   double MACDSignalLineVal = NormalizeDouble(MACDSignalLine[shift],6);

   if(TrueForHistogram_FalseForSignal)
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
      for(int j=0; i<Size_of_Event_List; j++)
        {
         if(values[j].event_id == EventArray[i])
            resault=true;

        }

     }
   return resault;

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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



struct ST_StopLoss_TakeProfit
  {
   double            NewStopLoss;
   double            NewTakeProfit;

  };




////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////Cascade Trading////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ST_StopLoss_TakeProfit Cascade_trading(string Symbool,double lotSize,bool isBuy,double ask, double bid, double takeProfit, double stopLoss, double stopLossPoints, double minimumStopLossPoints, double r2R, bool TrailingAllowed, int TotalOpenOrder)
  {
   ST_StopLoss_TakeProfit returning_arr;

   bool enough_money;
   bool enough_valume;
   string message;
   returning_arr.NewStopLoss=stopLoss;
   returning_arr.NewTakeProfit=takeProfit;

Comment("NEW StopLoss "+ DoubleToString(returning_arr.NewStopLoss));

   if(isBuy && ask>=takeProfit && TrailingAllowed && TotalOpenOrder>=1)
     {

      enough_money =CheckMoneyForTrade(Symbol(),lotSize,ORDER_TYPE_BUY);
      enough_valume=CheckVolumeValue(lotSize,message);
      returning_arr.NewStopLoss=ask-minimumStopLossPoints*Point();
      returning_arr.NewTakeProfit=ask+r2R*stopLossPoints*Point();

      if(enough_money && enough_valume)
         Trade.Buy(lotSize,Symbool,ask,0,0,"Trailing order");

     }

   if(!isBuy && bid<=takeProfit && TrailingAllowed && TotalOpenOrder>=1)
     {
      enough_money =CheckMoneyForTrade(Symbol(),lotSize,ORDER_TYPE_SELL);
      enough_valume=CheckVolumeValue(lotSize,message);
      returning_arr.NewStopLoss = bid+minimumStopLossPoints*Point();
      returning_arr.NewTakeProfit=bid-r2R*stopLossPoints*Point();
      if(enough_money && enough_valume)
         Trade.Sell(lotSize,Symbool,bid,0,0,"Trailing order");


     }

   if(isBuy && ask < returning_arr.NewStopLoss && TotalOpenOrder>=2)
     {
      while(SymbolOpenOrders(Symbol()) !=0)
         CloseOrders(_Symbol,true);

     }
   if(!isBuy && bid >returning_arr.NewStopLoss && TotalOpenOrder>=2)
     {
      while(SymbolOpenOrders(Symbol()) !=0)
         CloseOrders(_Symbol,true);

     }


   return returning_arr;
  }


//+------------------------------------------------------------------+
