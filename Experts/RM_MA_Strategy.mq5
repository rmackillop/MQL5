//+------------------------------------------------------------------+
//|                                               RM_MA_Strategy.mq5 |
//+------------------------------------------------------------------+
#property version   "1.00"

#include <RM_CommonLib.mqh>



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int MAFast_period=10;
input int MASlow_period=25;
input int MAReference_period=100;
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H1;
bool isBuy=true;

double RiskPercent=0.01;
double LotSize;
bool TradeIsAllowed=true;


int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
      double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      
      double MovingAverage_Fast_1      =MACalculator(_Symbol,TimeFrame,MAFast_period,1,MODE_SMA,PRICE_CLOSE);
      double MovingAverage_Slow_1      =MACalculator(_Symbol,TimeFrame,MASlow_period,1,MODE_SMA,PRICE_CLOSE);
      double MovingAverage_Reference   =MACalculator(_Symbol,TimeFrame,MAReference_period,1,MODE_SMA,PRICE_CLOSE);
      
      double MovingAverage_Fast_2      =MACalculator(_Symbol,TimeFrame,MAFast_period,2,MODE_SMA,PRICE_CLOSE);
      double MovingAverage_Slow_2      =MACalculator(_Symbol,TimeFrame,MASlow_period,2,MODE_SMA,PRICE_CLOSE);
      
      if(IsNewCandle(TimeFrame)) TradeIsAllowed=true;
      
      if(PositionsTotal()==0 && TradeIsAllowed)
      {
         if(Ask>=MovingAverage_Reference)  //LONG or BUY
         {
            if((MovingAverage_Fast_2<=MovingAverage_Slow_2) && (MovingAverage_Fast_1>MovingAverage_Slow_1))
            {
               LotSize=OptimumLotSize(_Symbol,Ask,Ask-100*Point(),RiskPercent);
               Trade.Buy(LotSize,_Symbol,Ask,Ask-300*Point());
               isBuy=true;
               TradeIsAllowed=false;
            }         
         }
         else
         {
            if((MovingAverage_Fast_2>=MovingAverage_Slow_2) && (MovingAverage_Fast_1<MovingAverage_Slow_1))
            {
               LotSize=OptimumLotSize(_Symbol,Bid,Bid+100*Point(),RiskPercent);
               Trade.Buy(LotSize,_Symbol,Bid,Bid+300*Point());
               isBuy=false;
               TradeIsAllowed=false;
            }         
         }
      }
      
      if(PositionsTotal()>=1)
      {
         if(isBuy && iLow(_Symbol,TimeFrame,1)<MovingAverage_Slow_1)
         {
            CloseAllOrders();
         }
         
         if(!isBuy && iHigh(_Symbol,TimeFrame,1)>MovingAverage_Slow_1)
         {
            CloseAllOrders();
         }
      }   
  }
  
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

  }
  
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
  
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+



