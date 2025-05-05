//+------------------------------------------------------------------+
//|                                             RM_MACD_Strategy.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <RM_CommonLib.mqh>




input int FastEMA_Period=12;
input int SlowEMA_Period=26;
input int SignalSMA_Period=9;

input double RiskPercent=0.01;
input int R2R=1;
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H1;
double LotSize=0.01;

double TakeProfit;
double StopLoss;
double StoplossPoint=100;

bool TradeIsAllowed=true;
bool IsBuy;


void OnTick() 
{
   double MACD_Histogram_1=MACDcalculator(true,_Symbol,PERIOD_CURRENT,PRICE_CLOSE,FastEMA_Period,SlowEMA_Period,SignalSMA_Period,1,5);
   double MACD_Histogram_2=MACDcalculator(true,_Symbol,PERIOD_CURRENT,PRICE_CLOSE,FastEMA_Period,SlowEMA_Period,SignalSMA_Period,2,5);
   
   double MACD_Signal_1=MACDcalculator(false,_Symbol,PERIOD_CURRENT,PRICE_CLOSE,FastEMA_Period,SlowEMA_Period,SignalSMA_Period,1,5);
   double MACD_Signal_2=MACDcalculator(false,_Symbol,PERIOD_CURRENT,PRICE_CLOSE,FastEMA_Period,SlowEMA_Period,SignalSMA_Period,2,5);
   
   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
        
   if(IsNewCandle(TimeFrame)) TradeIsAllowed=true; 
   
   if(PositionsTotal()==0 && TradeIsAllowed)
   {
      if(MACD_Histogram_1>0 && MACD_Signal_1>0 && (MACD_Histogram_2<MACD_Signal_2 && MACD_Histogram_1>MACD_Signal_1) && TradeIsAllowed)
      {
         StopLoss=Ask-StoplossPoint*Point();
         TakeProfit=Ask+R2R*StoplossPoint*Point();
         LotSize=OptimumLotSize(_Symbol,Ask,StopLoss,RiskPercent);
         Trade.Buy(LotSize,_Symbol,Ask,StopLoss,TakeProfit);
         IsBuy=true;
         TradeIsAllowed=false;
      }
      if(MACD_Histogram_1<0 && MACD_Signal_1<0 && (MACD_Histogram_2>MACD_Signal_2 && MACD_Histogram_1<MACD_Signal_1) && TradeIsAllowed)
      {
         StopLoss=Bid+StoplossPoint*Point();
         TakeProfit=Bid-R2R*StoplossPoint*Point();
         LotSize=OptimumLotSize(_Symbol,Bid,StopLoss,RiskPercent);
         Trade.Sell(LotSize,_Symbol,Bid,StopLoss,TakeProfit);
         IsBuy=false;
         TradeIsAllowed=false;
      }
   }   
}


