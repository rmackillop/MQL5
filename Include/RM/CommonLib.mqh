//+------------------------------------------------------------------+
//|                                                CommonLibrary.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


double RSICalculator(string symbol, ENUM_TIMEFRAMES TimeFrame, int period, int shift, int BufferNumber=10)
{
   //Create array for prices
   double RSIArray[];
   
   //Identify RSI Properties
   int RSIDef = iRSI(symbol, TimeFrame, period, PRICE_CLOSE);
   //Sort price array
   ArraySetAsSeries(RSIArray,true);
   
   //Identifying EA
   CopyBuffer(RSIDef,0,0,BufferNumber,RSIArray);
   double RSIValue = NormalizeDouble(RSIArray[shift],2);
   
   return RSIValue;
}


double MACalculator(string symbol, ENUM_TIMEFRAMES TimeFrame, int period, int shift, ENUM_MA_METHOD Mode, ENUM_APPLIED_PRICE AppliedPrice, int BufferNumber=10)
{
   //Create array for prices
   double MAArray[];
   
   int MADef=iMA(symbol,TimeFrame,period,shift,Mode,AppliedPrice);
   //Sort price array
   ArraySetAsSeries(MAArray,true);
   
   //Identifying EA
   CopyBuffer(MADef,0,0,BufferNumber,MAArray);
   double MAValue = NormalizeDouble(MAArray[shift],6);
   
   return MAValue;
}


double OptimumLotSize(string symbol,double EntryPoint, double StoppLoss, double RiskPercent)
  {
      int            Diigit         =SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double         OneLotValue    =SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //MathPow(10,Diigit);
      
      double         ask            =SymbolInfoDouble(symbol,SYMBOL_ASK);
      //double         bid            =SymbolInfoDouble(symbol,SYMBOL_BID);
      
      string         BaseCurrency   =SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);
      string         ProfitCurency  =SymbolInfoString(symbol,SYMBOL_CURRENCY_PROFIT); 
      string         AccountCurency =AccountInfoString(ACCOUNT_CURRENCY);
      
      double         AllowedLoss    =NormalizeDouble(RiskPercent*AccountInfoDouble(ACCOUNT_EQUITY),2);
      double         LossPoint      =NormalizeDouble(MathAbs(EntryPoint-StoppLoss),Diigit);
      double         Lotsize;

      //Fix rounding with the StopLoss
      StoppLoss = NormalizeDouble(StoppLoss,Diigit);
      
//      Alert(symbol + " EntryPoint: " + EntryPoint + " StopLoss: " + StoppLoss);
//
//      Alert("AllowedLoss    = "+AllowedLoss);
//      Alert("Diigit         = "+Diigit);
//      Alert("OneLotValue    = "+OneLotValue);
//      Alert("BaseCurrency   = "+BaseCurrency);
//      Alert("ProfitCurency  = "+ProfitCurency);
//      Alert("AccountCurency = "+AccountCurency);
//      Alert("LossPoint      = "+LossPoint);
      
      if (ProfitCurency==AccountCurency) 
         { 
         Lotsize=AllowedLoss/LossPoint; 
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
      //Alert("ProfitCurency==AccountCurency   LotSize="+Lotsize);
         
         return(Lotsize); 
         }
         
      else if (BaseCurrency==AccountCurency)
         {
         AllowedLoss=EntryPoint*AllowedLoss;  //// Allowed loss in Profit currency Example: USDCHF-----> Return allowed loss in CHF
      //Alert("BaseCurrency==AccountCurency  AllowedLoss = "+AllowedLoss);
         Lotsize=AllowedLoss/LossPoint; 
      //Alert("BaseCurrency==AccountCurency  LossPoint   = "+LossPoint);
      //Alert("BaseCurrency==AccountCurency  Lotsize     = "+Lotsize);
         Lotsize=NormalizeDouble(Lotsize/OneLotValue,2); 
      //Alert("BaseCurrency==AccountCurency  OneLotValue = "+OneLotValue);
      //Alert("BaseCurrency==AccountCurency  LotSize     = "+Lotsize);
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
            
            if (ProfitCurency=="JPY") 
               { 
               Lotsize=AllowedLoss*1.5/LossPoint; 
               Lotsize=NormalizeDouble(Lotsize/OneLotValue,2);
               Alert("ProfitCurency==JPY   LotSize="+Lotsize);
                
               return(Lotsize); 
               }
                  
         return Lotsize; 
         }
          
  }



bool IsNewCandle(ENUM_TIMEFRAMES TimeFrame)
{
   static datetime LastCandleTime;
   datetime CurrentCandleTime=iTime(NULL,TimeFrame,0);
   if(LastCandleTime==CurrentCandleTime) 
      return false;
   else
   {
      LastCandleTime=CurrentCandleTime;
      return true;
   }
}


void CloseAllOrders()
{
   do
   {
      PositionSelectByTicket(PositionGetTicket(0));
      Trading.PositionClose(PositionGetInteger(POSITION_TICKET));
   }while(PositionsTotal()!=0);
}