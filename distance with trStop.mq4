//+------------------------------------------------------------------+
//|                                         distance with trStop.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      Magic             = 1; // expert id
input double   Lot               = 1; // lot 
extern int     StopLoss          = 30; 
extern int     TakeProfit        = 40;
input string   TimeToSetOrders_1 = "02:00";
input string   TimeToDelOrders_1 = "08:00";

input string   TimeToSetOrders_2 = "09:00";
input string   TimeToDelOrders_2 = "14:00";

input string   TimeToSetOrders_3 = "15:15";
input string   TimeToDelOrders_3 = "17:00";

extern int     Distance          = 20;
extern bool    TrailingSwitcher  = true;
extern int     TrailingStop      = 10;
extern int     TrailingStep      = 50;

bool           Time_check        =false;
bool           TradeB            =false;
bool           TradeS            =false;
bool           DelSellStop       =false;
bool           DelBuyStop        =false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- increment for terminals with 3 or 5 digits
   if(Digits == 3 || Digits == 5)
     {
      Distance       *= 10;
      TrailingStop   *= 10;
      StopLoss       *= 10;
      TakeProfit     *= 10;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Активация трейлинг стоп 
   Trailing();
   CountBuy();
   CountSell();
   CountBuyStop();
   CountSellStop();
   Checker();
  }
  