

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <RM\CTraderRichPanel.mqh>
#include <RM\ATRCalculator.mqh>
#include <RM\MqlTradeDescriptions.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "==== General Inputs ====" input long InpMagicNumber = 96714; // magic number
input int InpATR = 14;
input double InpStopLossATRMultiple = 1.9;
input double InpCascadeATRLevel = 1.2;
input double InpCascadeATRStopLoss = 0.25;
input double InpLotSize = 1.0; // default trade size in lots

CTraderRichPanel panel;
ATRCalculator atr;
CTrade trade;

// global variables
ulong g_psl_ticket = 0;  // ticket of our Position-Stop-Loss pending order
int g_cascade_count = 0; // how many filled deals we’ve had
datetime m_NextTick;
datetime g_lastBarTime = 0; // tracks the time of the last-open bar

//+------------------------------------------------------------------+
//| EA initialization function                                       |
//+------------------------------------------------------------------+
int OnInit()
{

  // ATR Calculator
  atr.Init(_Symbol, PERIOD_CURRENT, InpATR); // Now valid

  //--- set up our trade helper
  trade.SetExpertMagicNumber(InpMagicNumber);

  // create panel
  if (!panel.OnInit())
  {
    return INIT_FAILED;
  }

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| EA deinitialization function                                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

  // Print("OnDeinit");

  // delete objects
  ObjectsDeleteAll(NULL, "range");

  // destroy panel
  panel.Destroy(reason);

  //--- destroy timer   EventKillTimer();
}

//+------------------------------------------------------------------+
//| EA tick function                                                 |
//+------------------------------------------------------------------+
void OnTick()
{

  // 1) detect new bar
  datetime currentBarTime = iTime(_Symbol, _Period, 0);
  if (currentBarTime != g_lastBarTime)
  {
    // previous bar has just closed
    g_lastBarTime = currentBarTime;
    OnBarClose();
  }

  atr.Update();
  panel.Update(atr.CurrentATR(), atr.CurrentDailyATR());

}

//+------------------------------------------------------------------+
//| Called once, immediately when a bar closes                       |
//+------------------------------------------------------------------+
void OnBarClose()
{
  // --- PUT YOUR BAR-CLOSE LOGIC HERE ---
  // int totalPositions = PositionsTotal();
  // int totalOrders = OrdersTotal();
  // Print("OnBarClose : PositionsTotal: ", totalPositions, " | OrdersTotal: ", totalOrders);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  panel.PanelChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
  // Print("OnTradeTransaction : CALLED");

  // VALIDATION: Ensure this Symbol is the one we are working with
  if (trans.symbol != _Symbol)
    return;

  // VALIDATION: Ensure there is at least one open position
  int totalPositions = PositionsTotal();
  int totalOrders = OrdersTotal();
  if (totalPositions == 0)
  {
    //--- if no positions are open, remove any unfilled cascade orders
    // loop through pending & trade orders by ticket
    for (int idx = totalOrders - 1; idx >= 0; idx--)
    {
      ulong orderTicket = OrderGetTicket(idx);
      if (!OrderSelect(orderTicket)) // SELECT_BY_TICKET
        continue;
      if (OrderGetString(ORDER_SYMBOL) != _Symbol)
        continue;
      ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      string comm = OrderGetString(ORDER_COMMENT);
      if ((otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_SELL_STOP) &&
          (comm == "CascadeBuy" || comm == "CascadeSell"))
      {
        Print("Deleting Cascade order: ", orderTicket, " | Type: ", otype, " | Comment: ", comm);
        trade.OrderDelete(orderTicket);
      }
      else
      {
        Print("Not deleting order: ", orderTicket, " | Type: ", otype, " | Comment: ", comm);
      }
    }
    return;
  }

  // VALIDATION: Ensure this deal is an entry (opening or scaling in) of a position
  if (HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_IN)
    return;

  // VALIDATION: Only proceed on new deal additions
  if (trans.type != TRADE_TRANSACTION_DEAL_ADD)
    return;

  bool isLong = (trans.deal_type == DEAL_TYPE_BUY);
  double entryPrice = trans.price;
  double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
  double currentATR = atr.CurrentATR(); // ATR value is already updated in OnTick()

  // Calculate the Cascade Offset
  double cascadeOffset = currentATR * InpCascadeATRLevel;
  cascadeOffset = NormalizeDouble(cascadeOffset, _Digits);
  // Calculate the Cascade StopLoss
  double cascadeStopLoss = currentATR * InpCascadeATRStopLoss;
  // Calculate Minimum StopLoss distance
  double minStopDistance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point; // minimum stop distance in points
  minStopDistance = MathMax(minStopDistance, MathAbs(ask - bid));
// Take the bigger of the two for our stop loss, PLUS pad the stop loss with the ATR level
  cascadeStopLoss = MathMax(cascadeStopLoss, minStopDistance) * InpCascadeATRLevel; 
  cascadeStopLoss = NormalizeDouble(cascadeStopLoss, _Digits);

  //Print((isLong ? ("LONG"):("SHORT")), " | entryPrice: ", entryPrice, " | bid: ", bid, " | ask: ", ask, " | Diff: ", MathAbs(bid - ask), " | _Point: ", _Point);
  //Print("cascadeStopLoss: ", cascadeStopLoss, " | minStopDistance: ", minStopDistance);

   // Determine new pending order price and SL
  double newOrderPrice = isLong ? (entryPrice + cascadeOffset)
                                : (entryPrice - cascadeOffset);
  newOrderPrice = NormalizeDouble(newOrderPrice, _Digits);

  double newStopLoss = isLong ? (entryPrice - cascadeStopLoss)
                              : (entryPrice + cascadeStopLoss);
  newStopLoss = NormalizeDouble(newStopLoss, _Digits);

  Print("newOrderPrice: ", newOrderPrice, " | newStopLoss: ", newStopLoss, " | Diff: ", MathAbs(newOrderPrice - newStopLoss));

  // Open pending stop order in same direction
  if (isLong)
  {
    Print("OPEN BUYStop at: ", newOrderPrice, " with SL: 0 | Positions: ", totalPositions,
          " | trans.type : ", trans.type,
          " | Current ATR: ", currentATR,
          " | Cascade Offset: ", cascadeOffset);
    // Print(TransactionDescription(trans));
    // Print(RequestDescription(request));
    // Print(TradeResultDescription(result));
    trade.BuyStop(InpLotSize, newOrderPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "CascadeBuy");
  }
  else
  {
    Print("OPEN SELLStop at: ", newOrderPrice, " with SL: 0 | Positions: ", totalPositions,
          " | trans.type : ", trans.type,
          " | Current ATR: ", currentATR,
          " | Cascade Offset: ", cascadeOffset);
    // Print(TransactionDescription(trans));
    // Print(RequestDescription(request));
    // Print(TradeResultDescription(result));
    trade.SellStop(InpLotSize, newOrderPrice, _Symbol, 0, 0, ORDER_TIME_GTC, 0, "CascadeSell");
  }

  // Update SL for all other open positions, only after Cascade has happened
  if (totalPositions > 1)
  {
    Print("Updating StopLoss(es) to: ", newStopLoss,
          " | EntryPrice: ", entryPrice,
          " | Current ATR: ", currentATR,
          " | cascadeOffset: ", cascadeOffset,
          " | cascadeStopLoss: ", cascadeStopLoss,
          " | minStopDistance: ", minStopDistance);
    for (int i = 0; i < totalPositions; i++)
    {
      if (PositionGetSymbol(i) == _Symbol)
      {
        ulong ticket = PositionGetInteger(POSITION_TICKET);
        ulong newPosTicket = trans.position;

        Print("Updating SL for ticket: ", ticket, " to: ", newStopLoss);
        if (trade.PositionModify(ticket, newStopLoss, 0))
        {
          Print("SL updated successfully for ticket: ", ticket);
        }
        else
        {
          Print("Failed to update SL for ticket: ", ticket, " Error: ", GetLastError());
        }
      }
    }
  }
  else
  {
    Print("Do NOT Update SL because there is only 1 position open.");
  }

  // Print("OnTradeTransaction : END");
}

//+------------------------------------------------------------------+
//| Returns transaction textual description                          |
//+------------------------------------------------------------------+
string TransactionDescription(const MqlTradeTransaction &trans)
{
  //---
  string desc = EnumToString(trans.type) + "\r\n";
  desc += "Symbol: " + trans.symbol + "\r\n";
  desc += "Deal ticket: " + (string)trans.deal + "\r\n";
  desc += "Deal type: " + EnumToString(trans.deal_type) + "\r\n";
  desc += "Order ticket: " + (string)trans.order + "\r\n";
  desc += "Order type: " + EnumToString(trans.order_type) + "\r\n";
  desc += "Order state: " + EnumToString(trans.order_state) + "\r\n";
  desc += "Order time type: " + EnumToString(trans.time_type) + "\r\n";
  desc += "Order expiration: " + TimeToString(trans.time_expiration) + "\r\n";
  desc += "Price: " + StringFormat("%G", trans.price) + "\r\n";
  desc += "Price trigger: " + StringFormat("%G", trans.price_trigger) + "\r\n";
  desc += "Stop Loss: " + StringFormat("%G", trans.price_sl) + "\r\n";
  desc += "Take Profit: " + StringFormat("%G", trans.price_tp) + "\r\n";
  desc += "Volume: " + StringFormat("%G", trans.volume) + "\r\n";
  desc += "Position: " + (string)trans.position + "\r\n";
  desc += "Position by: " + (string)trans.position_by + "\r\n";
  //--- return the obtained string
  return desc;
}

//+------------------------------------------------------------------+
//| Returns the trade request textual description                    |
//+------------------------------------------------------------------+
string RequestDescription(const MqlTradeRequest &request)
{
  //---
  string desc = EnumToString(request.action) + "\r\n";
  desc += "Symbol: " + request.symbol + "\r\n";
  desc += "Magic Number: " + StringFormat("%d", request.magic) + "\r\n";
  desc += "Order ticket: " + (string)request.order + "\r\n";
  desc += "Order type: " + EnumToString(request.type) + "\r\n";
  desc += "Order filling: " + EnumToString(request.type_filling) + "\r\n";
  desc += "Order time type: " + EnumToString(request.type_time) + "\r\n";
  desc += "Order expiration: " + TimeToString(request.expiration) + "\r\n";
  desc += "Price: " + StringFormat("%G", request.price) + "\r\n";
  desc += "Deviation points: " + StringFormat("%G", request.deviation) + "\r\n";
  desc += "Stop Loss: " + StringFormat("%G", request.sl) + "\r\n";
  desc += "Take Profit: " + StringFormat("%G", request.tp) + "\r\n";
  desc += "Stop Limit: " + StringFormat("%G", request.stoplimit) + "\r\n";
  desc += "Volume: " + StringFormat("%G", request.volume) + "\r\n";
  desc += "Comment: " + request.comment + "\r\n";
  //--- return the obtained string
  return desc;
}

//+------------------------------------------------------------------+
//| Returns the textual description of the request handling result   |
//+------------------------------------------------------------------+
string TradeResultDescription(const MqlTradeResult &result)
{
  //---
  string desc = "Retcode " + (string)result.retcode + "\r\n";
  desc += "Request ID: " + StringFormat("%d", result.request_id) + "\r\n";
  desc += "Order ticket: " + (string)result.order + "\r\n";
  desc += "Deal ticket: " + (string)result.deal + "\r\n";
  desc += "Volume: " + StringFormat("%G", result.volume) + "\r\n";
  desc += "Price: " + StringFormat("%G", result.price) + "\r\n";
  desc += "Ask: " + StringFormat("%G", result.ask) + "\r\n";
  desc += "Bid: " + StringFormat("%G", result.bid) + "\r\n";
  desc += "Comment: " + result.comment + "\r\n";
  //--- return the obtained string
  return desc;
}

/*
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
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
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }
//+------------------------------------------------------------------+
*/
