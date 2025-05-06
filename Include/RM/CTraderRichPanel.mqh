//+------------------------------------------------------------------+
//|                                             CTraderRichPanel.mqh |
//|                               Copyright 2025, Richard MacKillop. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Richard MacKillop."
#property link "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Include 1                                                        |
//+------------------------------------------------------------------+
#include <Controls\Defines.mqh>
// #include <..\Experts\RM_TraderRich_v1.mq5>

//+------------------------------------------------------------------+
//| Define statements to set & change default settings               |
//+------------------------------------------------------------------+
#undef CONTROLS_FONT_NAME
// #undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#define CONTROLS_FONT_NAME "Consolas"
// #define CONTROLS_DIALOG_COLOR_CLIENT_BG C'0x20,0x20,0x20'

#define PANEL_NAME "TraderRich v1"
#define PANEL_WIDTH 300
#define PANEL_HEIGHT 300
#define PANEL_LEFT 260 // to avoid the 1-click trade button
#define PANEL_FONT_SIZE 11
#define PANEL_CONTROL_TOP_MARGIN 10
#define PANEL_CONTROL_HEIGHT 20

//+------------------------------------------------------------------+
//| Include 2                                                        |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
// input group "==== Panel Inputs ====";
// static input int InpPanelWidth = 260;
// static input int InpPanelHeight = 230;
// static input int InpPanelFontSize = 13;
// static input int InpPanelTxtColor = clrWhiteSmoke;

//+------------------------------------------------------------------+
//| Class CTradePanel                                                |
//+------------------------------------------------------------------+
class CTraderRichPanel : public CAppDialog
{

private:
   // private variables
   bool m_f_color;

   // labels
   CLabel m_lInput;
   CLabel m_lMagic;
   CLabel m_lATRCurrent;
   CLabel m_lStopLoss;
   CLabel m_lDuration;
   CLabel m_lClose;

   // buttons
   CButton m_bBuyToOpen;
   CButton m_bSellToOpen;

   // private methods
   void OnClickBuyToOpen();
   void OnClickSellToOpen();
   bool CheckInputs();
   bool CreatePanel();

public:
   void CTraderRichPanel();
   void ~CTraderRichPanel();
   bool OnInit();
   void Update(void);
   void Update(double currentATR, double currentDailyATR);

   // chart event handler
   void PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
};

//+------------------------------------------------------------------+
//| constructor                                                      |
//+------------------------------------------------------------------+
void CTraderRichPanel::CTraderRichPanel(void) {}

//+------------------------------------------------------------------+
//| deconstructor                                                    |
//+------------------------------------------------------------------+
void CTraderRichPanel::~CTraderRichPanel(void) {}

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
bool CTraderRichPanel::OnInit(void)
{

   // check user inputs
   if (!CheckInputs())
   {
      return false;
   }

   // create panel
   if (!this.CreatePanel())
   {
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Check Inputs                                                     |
//+------------------------------------------------------------------+
bool CTraderRichPanel::CheckInputs(void)
{
   return true;
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CTraderRichPanel::Update(void)
{

   m_lDuration.Text("Duration: " + TimeToString(TimeCurrent(), TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| Update                                                           |
//+------------------------------------------------------------------+
void CTraderRichPanel::Update(double currentATR, double currentDailyATR)
{

   // number of digits for our symbol
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   m_lDuration.Text("Duration: " + TimeToString(TimeCurrent(), TIME_SECONDS));

   m_lATRCurrent.Text("ATR: " + DoubleToString(currentATR, digits) + "  " + DoubleToString(currentDailyATR, digits) + " daily");

   m_lStopLoss.Text("StopLoss : ");
}

//+------------------------------------------------------------------+
//| Create Panel                                                     |
//+------------------------------------------------------------------+
bool CTraderRichPanel::CreatePanel(void)
{

   // create panel dialog
   this.Create(NULL, PANEL_NAME, 0, PANEL_LEFT, 25, PANEL_LEFT + PANEL_WIDTH, PANEL_HEIGHT);

   m_lInput.Create(NULL, "lInput", 0, 10, 10, 1, 1);
   m_lInput.Text("Inputs");
   m_lInput.Color(clrLime);
   this.Add(m_lInput);

   m_lMagic.Create(NULL, "lMagic", 0, 10, 30, 1, 1);
   m_lMagic.Text("Magic : " + (string)InpMagicNumber);
   m_lMagic.Color(clrRed);
   this.Add(m_lMagic);

   m_lATRCurrent.Create(NULL, "lAtr", 0, 10, 50, 1, 1);
   m_lATRCurrent.Text("ATR :");
   m_lATRCurrent.Color(clrRed);
   this.Add(m_lATRCurrent);

   m_lStopLoss.Create(NULL, "lStopLoss", 0, 10, 70, 1, 1);
   m_lStopLoss.Text("StopLoss :");
   m_lStopLoss.Color(clrRed);
   this.Add(m_lStopLoss);

   m_lDuration.Create(NULL, "lDuration", 0, 10, 90, 1, 1);
   m_lDuration.Text("Duration");
   m_lDuration.Color(clrRed);
   this.Add(m_lDuration);

   m_lClose.Create(NULL, "lClose", 0, 10, 110, 1, 1);
   m_lClose.Text("Close");
   m_lClose.Color(clrRed);
   this.Add(m_lClose);

   m_bBuyToOpen.Create(NULL, "bBuyToOpen", 0, 10, // X coordinate of the upper left corner.
                       150,                       // Y coordinate of the upper left corner.
                       120,                       // X coordinate of the lower right corner.
                       180);                      // Y coordinate of the lower right corner.
   m_bBuyToOpen.Text("BUY to Open");
   m_bBuyToOpen.Color(clrWhite);
   m_bBuyToOpen.ColorBackground(clrGreen);
   m_bBuyToOpen.FontSize(10);
   this.Add(m_bBuyToOpen);

   m_bSellToOpen.Create(NULL, "bSellToOpen", 0, 235, // X coordinate of the upper left corner.  235-125=button width ??
                        150,                         // Y coordinate of the upper left corner.
                        125,                         // X coordinate of the lower right corner.
                        180);                        // Y coordinate of the lower right corner.
   m_bSellToOpen.Text("SELL to Open");
   m_bSellToOpen.Color(clrWhite);
   m_bSellToOpen.ColorBackground(clrRed);
   m_bSellToOpen.FontSize(10);
   this.Add(m_bSellToOpen);

   // run panel
   if (!Run())
   {
      Print("Failed to load CTradePanel1: " + PANEL_NAME);
      return false;
   }

   // refresh chart
   ChartRedraw();

   return true;
}

//+------------------------------------------------------------------+
//| Panel Chart Events                                               |
//+------------------------------------------------------------------+
void CTraderRichPanel::PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{

   // call chart event method of the base class
   ChartEvent(id, lparam, dparam, sparam);

   // check if button was pressed
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam == "bBuyToOpen")
      {
         OnClickBuyToOpen();
      }
      if (sparam == "bSellToOpen")
      {
         OnClickSellToOpen();
      }
   }
}

//+------------------------------------------------------------------+
//| Panel Chart Events                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Button - Buy To Open                                             |
//+------------------------------------------------------------------+
void CTraderRichPanel::OnClickBuyToOpen(void)
{
   // 1) get ask and compute initial stop-loss
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double initSL = ask - InpStopLossATRMultiple * atr.CurrentATR();
   initSL = NormalizeDouble(initSL, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));

   // 2) place P1 order as BUY
   MqlTradeRequest rq1;
   MqlTradeResult rs1;
   ZeroMemory(rq1);
   ZeroMemory(rs1);

   rq1.action = TRADE_ACTION_DEAL;
   rq1.symbol = _Symbol;
   rq1.volume = InpLotSize;
   rq1.type = ORDER_TYPE_BUY;
   rq1.price = ask;
   rq1.sl = 0.0; // detach the Stop Loss from the order
   rq1.tp = 0.0;
   rq1.magic = InpMagicNumber;
   rq1.deviation = 10;
   rq1.type_filling = ORDER_FILLING_IOC;
   rq1.type_time = ORDER_TIME_GTC;

   if (!OrderSend(rq1, rs1))
      PrintFormat("P1 BUY order failed (retcode=%d)", rs1.retcode);
   else
   {
      PrintFormat("P1 BUY order placed. Ticket=%I64u", rs1.order);

      // 3) place initial PSL as a SELL_STOP
      MqlTradeRequest rq2;
      MqlTradeResult rs2;
      ZeroMemory(rq2);
      ZeroMemory(rs2);
      rq2.action = TRADE_ACTION_PENDING;
      rq2.symbol = _Symbol;
      rq2.volume = InpLotSize;
      rq2.type = ORDER_TYPE_SELL_STOP;
      rq2.price = initSL;
      rq2.magic = InpMagicNumber;
      rq2.deviation = 10;
      rq2.type_time = ORDER_TIME_GTC;
      if (!OrderSend(rq2, rs2))
         PrintFormat("PSL init failed (ret=%d)", rs2.retcode);
      else
      {
         g_psl_ticket = rs2.order;
         g_cascade_count = 0;
         PrintFormat("PSL init ticket=%I64u", g_psl_ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| Button - Sell To Open                                            |
//+------------------------------------------------------------------+
void CTraderRichPanel::OnClickSellToOpen(void)
{
   // 1) get bid and compute stop-loss (above entry)
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double initSL = bid + InpStopLossATRMultiple * atr.CurrentATR();
   initSL = NormalizeDouble(initSL, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));

   // 2) place P1 order as SELL
   MqlTradeRequest rq1;
   MqlTradeResult rs1;
   ZeroMemory(rq1);
   ZeroMemory(rs1);

   rq1.action = TRADE_ACTION_DEAL;
   rq1.symbol = _Symbol;
   rq1.volume = InpLotSize;
   rq1.type = ORDER_TYPE_SELL;
   rq1.price = bid;
   rq1.sl = 0.0; // detach the Stop Loss from the order
   rq1.tp = 0.0;
   rq1.magic = InpMagicNumber;
   rq1.deviation = 10;
   rq1.type_filling = ORDER_FILLING_IOC;
   rq1.type_time = ORDER_TIME_GTC;

   if (!OrderSend(rq1, rs1))
      PrintFormat("P1 SELL order failed (retcode=%d)", rs1.retcode);
   else
   {
      PrintFormat("Sell order placed. Ticket=%I64u", rs1.order);

      // 2) place initial PSL as a BUY_STOP
      MqlTradeRequest rq2;
      MqlTradeResult rs2;
      ZeroMemory(rq2);
      ZeroMemory(rs2);
      rq2.action = TRADE_ACTION_PENDING;
      rq2.symbol = _Symbol;
      rq2.volume = InpLotSize;
      rq2.type = ORDER_TYPE_BUY_STOP;
      rq2.price = initSL;
      rq2.magic = InpMagicNumber;
      rq2.deviation = 10;
      rq2.type_time = ORDER_TIME_GTC;
      if (!OrderSend(rq2, rs2))
         PrintFormat("PSL init failed (ret=%d)", rs2.retcode);
      else
      {
         g_psl_ticket = rs2.order;
         g_cascade_count = 0;
         PrintFormat("PSL init ticket=%I64u", g_psl_ticket);
      }
   }
}
