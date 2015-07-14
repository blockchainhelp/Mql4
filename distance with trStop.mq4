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
input double   Lot               = 0.01; // lot parametr
extern int     StopLoss          = 30;
extern int     TakeProfit        = 40;
input string   TimeToSetOrders_1 = "10:20";
input string   TimeToSetOrders_2 = "15:15";
input string   TimeToSetOrders_3 = "02:00";
extern int      Distance          = 20;
extern bool    TrailingSwitcher  = true;
extern int     TrailingStop      = 5;
extern int     TrailingStep      = 5;
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
//Проверка количества отложенных ордеров на покупку 
   CountByStop();
//Проверка количества отложенных ордеров на продажу
   CountSellStop();
  }
//+------------------------------------------------------------------+
//Проверка количества отложенных ордеров на покупку 
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
//Проверка количества отложенных ордеров на продажу 
//+------------------------------------------------------------------+
int CountSellStop() //На продажу
{
int count=0;
for (int i=OrdersTotal()-1; i>=0; i--)
   {
	if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_SELLSTOP)
          count++;
	   }
   }
   return(count);
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int TimeChecker()
{
   string Curtime = TimeToString(TimeCurrent(), TIME_MINUTES);
      if(Curtime == TimeToSetOrders_1) return(1);
      if(Curtime == TimeToSetOrders_2) return(2);
      if(Curtime == TimeToSetOrders_3) return(3); 
   return(0);
}

//+------------------------------------------------------------------+
//Функция входа в рынок
//+------------------------------------------------------------------+
void Enter_market()
{
  int Time_check      = TimeChecker();
  int STOP_OrderCheck = CountByStop() + CountSellStop();
  

}
//+------------------------------------------------------------------+
//Трейлинг стоп
//+------------------------------------------------------------------+
int Trailing()
{
   if(TrailingSwitcher)
     {
      for( int i=0; i<OrdersTotal(); i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderMagicNumber()==Magic)
            {
              if (OrderType()==OP_BUY)
               {
                  if (Bid-OrderOpenPrice()> TrailingStop*Point)
                  {
                     if (OrderStopLoss()<Bid-(TrailingStop+TrailingStep)*Point)
                     {
                        double SL=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                        if(OrderStopLoss()!=StopLoss)
                        int result = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
                     }
                  }  
               }
            
            if(OrderType()==OP_SELL)
            {
               if(OrderOpenPrice()-Ask>TrailingStop*Point)
               {
                  if (OrderStopLoss()>Ask+(TrailingStop+TrailingStep)*Point)
                  {
                    double SL=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                     if(OrderStopLoss()!=StopLoss)
                   int result = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
                  }
               }
            }
            }
         }
      }
     }
   return(0);
}