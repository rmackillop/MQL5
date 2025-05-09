//+------------------------------------------------------------------+
//|                                                ATRCalculator.mqh |
//|                                Copyright 2025, Richard MacKillop |
//|                                 https://www.richardmackillop.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Richard MacKillop"
#property link      "https://www.richardmackillop.com"


//+------------------------------------------------------------------+
//| ATRCalculator.mqh — calculates ATR for current and daily TFs    |
//+------------------------------------------------------------------+
class ATRCalculator
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int m_period;
   int m_digits;  // Number of digits to round to
   int m_handleATR;
   int m_handleDailyATR;
   double m_currentATR;
   double m_currentDailyATR;

   // private methods

   // Returns the highest ATR value from the handle over m_period bars
   double BufferHigh(int handle)
   {
      double buffer[];
      if (CopyBuffer(handle, 0, 0, m_period, buffer) != m_period)
         return 0.0;
   
      double high = buffer[0];
      for (int i = 1; i < m_period; ++i)
         if (buffer[i] > high)
            high = buffer[i];
   
      return NormalizeDouble(high, m_digits);
   }
   
   // Returns the lowest ATR value from the handle over m_period bars
   double BufferLow(int handle)
   {
      double buffer[];
      if (CopyBuffer(handle, 0, 0, m_period, buffer) != m_period)
         return 0.0;
   
      double low = buffer[0];
      for (int i = 1; i < m_period; ++i)
         if (buffer[i] < low)
            low = buffer[i];
   
      return NormalizeDouble(low, m_digits);
   }
   




public:
   // Default constructor
   ATRCalculator() {}


   // public methods
   
   // Init method (instead of overloaded constructor)
   void Init(string symbol = NULL, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, int period = 14)
   {
      m_symbol = (symbol == NULL) ? _Symbol : symbol;
      m_timeframe = timeframe;
      m_period = period;
      m_digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);

      m_handleATR = iATR(m_symbol, m_timeframe, m_period);
      m_handleDailyATR = iATR(m_symbol, PERIOD_D1, m_period);
   }

   // Must be called during OnTick()
   void Update()
   {
      double atrBuffer[1];
      double dailyAtrBuffer[1];

      // Get last value of ATR on current timeframe
      if(CopyBuffer(m_handleATR, 0, 0, 1, atrBuffer) == 1)
         m_currentATR = NormalizeDouble(atrBuffer[0], m_digits);
      else
         Print("Failed to copy ATR buffer");

      // Get last value of ATR on daily timeframe
      if(CopyBuffer(m_handleDailyATR, 0, 0, 1, dailyAtrBuffer) == 1)
         m_currentDailyATR = NormalizeDouble(dailyAtrBuffer[0], m_digits);
      else
         Print("Failed to copy daily ATR buffer");
   }

   // Getters
   double CurrentATR() const { return m_currentATR; }
   double CurrentDailyATR() const { return m_currentDailyATR; }
   
   // Returns Current ATR as a formatted string
   string CurrentATRString() const
   {
      return DoubleToString(m_currentATR, m_digits);
   }
   
   // Returns Daily ATR as a formatted string
   string CurrentDailyATRString() const
   {
      return DoubleToString(m_currentDailyATR, m_digits);
   }

   // Current TF ATR Range
   double CurrentATRHigh()
   {
      return BufferHigh(m_handleATR);
   }
   
   double CurrentATRLow()
   {
      return BufferLow(m_handleATR);
   }
   
   // Daily TF ATR Range
   double CurrentDailyATRHigh()
   {
      return BufferHigh(m_handleDailyATR);
   }
   
   double CurrentDailyATRLow()
   {
      return BufferLow(m_handleDailyATR);
   }

};
