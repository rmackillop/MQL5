//+------------------------------------------------------------------+
//|                                                      RM_Test.mq5 |
//|                               Copyright 2025, Richard MacKillop. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Richard MacKillop."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>

//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>

//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>

//--- available money management
#include <Expert\Money\MoneySizeOptimized.mqh>


//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                      ="RM_Test";   // Document name
ulong                    Expert_MagicNumber                =18975;       //
bool                     Expert_EveryTick                  =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen              =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose             =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel                 =0.0;         // Price level to execute a deal
input double             Signal_StopLevel                  =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel                  =50.0;        // Take Profit level (in points)
input int                Signal_Expiration                 =4;           // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA                =12;          // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift                   =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method                  =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied                 =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight                  =1.0;         // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast            =12;          // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow            =24;          // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal          =9;           // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied               =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight                =1.0;         // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period                =12;          // Period of MA
input int                Trailing_MA_Shift                 =0;           // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method                =MODE_SMA;    // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied               =PRICE_CLOSE; // Prices series
//--- inputs for money
input double             Money_SizeOptimized_DecreaseFactor=3.0;         // Decrease factor
input double             Money_SizeOptimized_Percent       =10.0;        // Percent


//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;


//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
   
   
   
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_MA_PeriodMA);
   filter0.Shift(Signal_MA_Shift);
   filter0.Method(Signal_MA_Method);
   filter0.Applied(Signal_MA_Applied);
   filter0.Weight(Signal_MA_Weight);
   
   
//--- Creating filter CSignalMACD
   CSignalMACD *filter1=new CSignalMACD;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodFast(Signal_MACD_PeriodFast);
   filter1.PeriodSlow(Signal_MACD_PeriodSlow);
   filter1.PeriodSignal(Signal_MACD_PeriodSignal);
   filter1.Applied(Signal_MACD_Applied);
   filter1.Weight(Signal_MACD_Weight);
   
   
//--- Creation of trailing object
   CTrailingMA *trailing=new CTrailingMA;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Period(Trailing_MA_Period);
   trailing.Shift(Trailing_MA_Shift);
   trailing.Method(Trailing_MA_Method);
   trailing.Applied(Trailing_MA_Applied);
   
   
//--- Creation of money object
   CMoneySizeOptimized *money=new CMoneySizeOptimized;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.DecreaseFactor(Money_SizeOptimized_DecreaseFactor);
   money.Percent(Money_SizeOptimized_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
     
     
     
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
