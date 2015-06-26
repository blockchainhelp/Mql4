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
input double   Lot = 0.01; // lot parametr
input string   TimeToSetOrders_1= 10:20;
input string   TimeToSetOrders_2= 15:15;
input string   TimeToSetOrders_3= 02:00;
input int      Distance         = 20;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- increment for terminals with 3 or 5 digits
   if(Digits = 3 || Digits=5)
     {
      Distance = *10;
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
//---
   
  }
//+------------------------------------------------------------------+
//Проверка количества отложенных ордеров условие 
//+------------------------------------------------------------------+
int CountByStop() //На покупку
{
int count=0;
for (int i=OrdersTotal()-1; i>=0; i--)
   {
	if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_BUYSTOP)
          count++;
	   }
   }
   return(count);
}
//+------------------------------------------------------------------+