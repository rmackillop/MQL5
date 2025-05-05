//+------------------------------------------------------------------+
//|                                              Order_Send_LONG.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade myTrade;

void OnStart()
  {
  
   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   
   bool isBuy=true;
   double Price;
   double StopLoss;
   double TakeProfit;
   double RiskToReward=2;
   
   if (isBuy)
   {
      Price = Ask;
      StopLoss = Ask-100*Point();
      TakeProfit = Ask+RiskToReward*100*Point();
   }
   else
   {
      Price = Bid;
      StopLoss = Bid+100*Point();
      TakeProfit = Bid-RiskToReward*100*Point();
   }
   
  /*
   MqlTradeRequest   myRequest {};
   MqlTradeResult    myResult {};
   
   myRequest.action=TRADE_ACTION_DEAL;
   myRequest.symbol=Symbol();
   myRequest.volume=1;
   myRequest.sl=Ask-100*Point();
   myRequest.tp=Ask+R2R*100*Point();
   myRequest.type=ORDER_TYPE_BUY;
   myRequest.price=Ask;
   
   OrderSend(myRequest,myResult);
   */

   myTrade.Buy(1,Symbol(),Price,StopLoss,TakeProfit);

   /*
   int ticket = myTrade.ResultOrder();
   
   for(int i=0;i<3;i++)
   {
      PositionSelectByTicket(ticket);
      Sleep(2000);
      myTrade.PositionModify(PositionGetInteger(POSITION_TICKET),OrderGetDouble(ORDER_SL)-100*Point(),PositionGetDouble(POSITION_TP)+200*Point());
      Alert("The modification is done!");
   }
   */
   
  }
