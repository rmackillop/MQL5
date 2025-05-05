//+------------------------------------------------------------------+
//|                                             Order_Send_SHORT.mq5 |
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

   double R2R=2;
   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   
   /*
   MqlTradeRequest   myRequest {};
   MqlTradeResult    myResult {};
   
   myRequest.action=TRADE_ACTION_DEAL;
   myRequest.symbol=Symbol();
   myRequest.volume=1;
   myRequest.sl=Bid+100*Point();             //reverse the sign, use Bid instead
   myRequest.tp=Bid-R2R*100*Point();
   myRequest.type=ORDER_TYPE_SELL;
   myRequest.price=Bid;
   
   OrderSend(myRequest,myResult);
    */

   bool myConfirm = myTrade.Sell(1,Symbol(),Bid,Bid+100*Point(),Bid-R2R*100*Point());

   int ticket = myTrade.ResultOrder();
   
   for(int i=0;i<3;i++)
   {
      PositionSelectByTicket(ticket);
      
   }
   

        
  }
