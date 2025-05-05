//+------------------------------------------------------------------+
//|                                RM_ReverseMA_Cascade_Strategy.mq5 |
//|                               Copyright 2025, Richard MacKillop. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Richard MacKillop."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <RM_CommonLib.mqh>


// Define parameters for the moving averages
input int fastMAPeriod = 10;  // Fast MA period (e.g., 10 for scalping)
input int slowMAPeriod = 20;  // Slow MA period (e.g., 20 for scalping)
input ENUM_MA_METHOD maMethod = MODE_SMA;
double LotSize;
int maShift_current = 0;
int maShift_Previous = 1;

bool Enough_money;
bool Enough_volume;
string Message;
bool IsBuy;
bool TradeIsOk;
double StopLoss;
double TakeProfit;

input double RiskPercent=0.01;
input double R2R=2;
input double StopLossPoints=100;
input double MinimumStopLossPoints=25;
ST_StopLoss_TakeProfit arr;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Cleanup code
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// No shift for moving averages
// Use Simple Moving Average (SMA)
   ENUM_APPLIED_PRICE appliedPrice = PRICE_CLOSE; // Apply to Close prices

// Get the values of the current and previous moving averages

// if (AccountInfoDouble(ACCOUNT_PROFIT)>100){close_All_Orders();}

   double fastMA_Current = MACalculator(_Symbol,PERIOD_CURRENT,fastMAPeriod,maShift_current,maMethod,appliedPrice);   // Current Fast MA
   double slowMA_Current = MACalculator(_Symbol,PERIOD_CURRENT,slowMAPeriod,maShift_current,maMethod,appliedPrice);   // Current Slow MA
   double fastMA_Previous = MACalculator(_Symbol,PERIOD_CURRENT,fastMAPeriod,maShift_Previous,maMethod,appliedPrice);  // Previous Fast MA
   double slowMA_Previous = MACalculator(_Symbol,PERIOD_CURRENT,slowMAPeriod,maShift_Previous,maMethod,appliedPrice);   // Previous Slow MA
   double Refference_MA = MACalculator(_Symbol,PERIOD_CURRENT,100,maShift_Previous,maMethod,appliedPrice);
// Get current account information
// Set lot size for trades
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits); // Current Ask price
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits); // Current Bid price


   int openOrders = SymbolOpenOrders(Symbol());
   bool isNewCandle = IsNewCandle(PERIOD_CURRENT);

   if(isNewCandle)
     {
      TradeIsOk=true;
      //if(PositionsTotal() != 0)canddleCount=canddleCount+1;
     }

   if(fastMA_Previous < slowMA_Previous && fastMA_Current > slowMA_Current && bid< Refference_MA && openOrders==0 && isNewCandle)
     {

      LotSize=OptimumLotSize(_Symbol,ask,StopLoss,RiskPercent);
      Comment("OptimumLotSize = "+ LotSize + " LotSize = 0.1");
      LotSize=0.1;
      Enough_money =CheckMoneyForTrade(Symbol(),LotSize,ORDER_TYPE_SELL);
      Enough_volume=CheckVolumeValue(LotSize,Message);
      StopLoss=bid+StopLossPoints*Point();
      TakeProfit=bid-R2R*StopLossPoints*Point();
      if(Enough_money && Enough_volume)
         Trade.Sell(LotSize, NULL, bid, StopLoss,0, "Logic Order");
      //TradeIsOk=false;
      IsBuy=false;
     }


   if(fastMA_Previous > slowMA_Previous && fastMA_Current < slowMA_Current && ask > Refference_MA && openOrders==0 && isNewCandle)
     {


      LotSize=OptimumLotSize(_Symbol,ask,StopLoss,RiskPercent);
      Comment("OptimumLotSize = "+ LotSize + " LotSize = 0.1");
      LotSize=0.1;
      Enough_money =CheckMoneyForTrade(Symbol(),LotSize,ORDER_TYPE_BUY);
      Enough_volume=CheckVolumeValue(LotSize,Message);
      StopLoss=bid-StopLossPoints*Point();
      TakeProfit=bid+R2R*StopLossPoints*Point();
      if(Enough_money && Enough_volume)
         Trade.Buy(LotSize, NULL, ask,  StopLoss,0, "Logic Order");
      //TradeIsOk=false;
      IsBuy=true;

     }   
//if(TradeIsOk && openOrders>=1)
   if(openOrders>=1)
     {
      //Alert("Ok to trade & there are open orders");
      //Comment("OptimumLotSize = "+ LotSize + " LotSize = 0.1");

      arr=Cascade_trading(_Symbol,LotSize,IsBuy,ask,bid,TakeProfit,StopLoss,StopLossPoints,MinimumStopLossPoints,R2R,true,openOrders);


      TakeProfit=arr.NewTakeProfit;
      StopLoss=arr.NewStopLoss;

     }
  }
//+------------------------------------------------------------------+
