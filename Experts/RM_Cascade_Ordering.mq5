//+------------------------------------------------------------------+
//|                                            RM_CascadeTrading.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"



#include <RM_CommonLib.mqh>



input bool TriggerUP=false;
input bool TriggerDWN=false;
input double RSIUPTrigger=70;
input double RSILOWTrigger=30;
input double PriceChangePercent=0.0001;
input double StopLossPoints=100;
input double MinimumStopLossPoints=25;


input double RiskPercent=0.01;
input double R2R=2;
double EntryPoint;
double TakeProfit;
double TakeProfitPoints;
double StopLoss;
double StopLossNew;
int canddleCount=0;

double LotSize;
bool IsBuy;

bool TradeIsOk=true;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   double Rsi0=RSICalculator(_Symbol,PERIOD_H1,4,0,10);
   double Rsi1=RSICalculator(_Symbol,PERIOD_H1,4,1,10);
   double Rsi2=RSICalculator(_Symbol,PERIOD_H1,4,2,10);

   MqlDateTime  TimeStructure;
   datetime timee=TimeCurrent();
   TimeToStruct(timee,TimeStructure);




/////////////////////////////////////////Trail Stop loss////////////////////////////////////////////////////

   if(SymbolOpenOrders(Symbol())>=2 && IsBuy && Bid<StopLossNew)
     {
      while(SymbolOpenOrders(Symbol()) !=0)
        {
         CloseAllOrders();
        }

     }

   if(SymbolOpenOrders(Symbol())>=2 && !IsBuy && Ask>StopLossNew)
     {
      while(SymbolOpenOrders(Symbol()) !=0)
        {
         CloseOrders(Symbol(),true);
        }

     }


/////////////////////////////////////////Program////////////////////////////////////////////////////////



   if(IsNewCandle(PERIOD_H1))
     {
      TradeIsOk=true;

      if(PositionsTotal() != 0)
         canddleCount=canddleCount+1;

     }



//if(canddleCount==1 && AccountInfoDouble(ACCOUNT_PROFIT)<AccountInfoDouble(ACCOUNT_BALANCE)*0.008) close_All_Orders();

//if (AccountInfoDouble(ACCOUNT_PROFIT)<-600)close_All_Orders();

   if((MathAbs(iOpen(Symbol(),PERIOD_M1,1)-iClose(Symbol(),PERIOD_M1,1))/MathAbs(iOpen(Symbol(),PERIOD_M1,1))>PriceChangePercent) && SymbolOpenOrders(Symbol())==0 && TimeStructure.hour >6 && TimeStructure.hour<20 && TradeIsOk)
     {

      if(Rsi1<=RSIUPTrigger && Rsi0>RSIUPTrigger)   //OPEN BUY ORDER
        {
         EntryPoint=Ask;
         //StopLoss=SupportAndResistant(Symbol(),EntryPoint,PERIOD_CURRENT,true,1,MinimumStopLossPoints,10);
         StopLoss=EntryPoint-StopLossPoints*Point();
         TakeProfit=Ask+R2R*StopLossPoints*Point();
         LotSize=OptimumLotSize(_Symbol,EntryPoint,StopLoss,RiskPercent);
         // Send Buy order in this line //////////
         TradeIsOk=false;
         IsBuy=true;
         canddleCount=0;


        }


      if(Rsi1>=RSILOWTrigger && Rsi0<RSILOWTrigger)   //OPEN SELL ORDER
        {
         EntryPoint=Bid;
         //StopLoss=SupportAndResistant(Symbol(),EntryPoint,PERIOD_CURRENT,true,1,MinimumStopLossPoints,10);
         StopLoss=EntryPoint+StopLossPoints*Point();
         TakeProfit=Ask-R2R*StopLossPoints*Point();
         LotSize=OptimumLotSize(_Symbol,EntryPoint,StopLoss,RiskPercent);
         // Send Sell order in this line //////////
         TradeIsOk=false;
         IsBuy=false;
         canddleCount=0;


        }

     }


   else
     {
      if(IsBuy && Ask>=TakeProfit)
        {
         TakeProfit=TakeProfit+R2R*StopLossPoints*Point();
         // Send Buy order in this line //////////
         StopLossNew=Ask-MinimumStopLossPoints*Point();

        }

      if(!IsBuy && Bid<=TakeProfit)
        {
         TakeProfit=TakeProfit-R2R*StopLossPoints*Point();
         // Send Sell order in this line //////////
         StopLossNew=Bid+MinimumStopLossPoints*Point();

        }
     }
  }



//+------------------------------------------------------------------+
