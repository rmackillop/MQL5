//+------------------------------------------------------------------+
//|                                          Expert Advisor Test.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   double high[];

   // Copy the last 1 value from the current symbol and timeframe into the array
   if(CopyHigh(_Symbol, _Period, 0, 1, high) > 0)
   {
      Alert("The High is equal to " + DoubleToString(high[0], 5));
   }
   else
   {
      Alert("Failed to retrieve High data.");
   }
}
