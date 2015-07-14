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
 //+------------------------------------------------------------------+
//Проверка количества открытых ордеров на покупку
//+------------------------------------------------------------------+
int CountBuy() //На покупку
{
int count=0;
for (int i=OrdersTotal()-1; i>=0; i--)
   {
	if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_BUY)
          count++;
	   }
   }
   return(count);
}

//+------------------------------------------------------------------+
//Проверка количества открытых ордеров на продажу
//+------------------------------------------------------------------+
int CountSell() //На продажу
{
int count=0;
for (int i=OrdersTotal()-1; i>=0; i--)
   {
	if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_SELL)
          count++;
	   }
   }
   return(count);
}

//+------------------------------------------------------------------+
//Проверка количества отложенных ордеров на покупку 
//+------------------------------------------------------------------+
int CountBuyStop() //На покупку
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
//Функция входа в рынок
//+------------------------------------------------------------------+
void Checker () 
{  
   
       string Timer = TimeToString(TimeCurrent(),TIME_MINUTES);
       
       if((Timer == TimeToSetOrders_1 || Timer == TimeToSetOrders_2 || Timer == TimeToSetOrders_3) && (CountBuyStop() + CountSellStop()) ==0  )
         {
             TradeB = true;
             Open_BYSTOP();
   
             TradeS = true;
             Open_SELLSTOP();
         }
        else
          {
            TradeB = false;
            TradeS = false;
          }
      if(TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeToDelOrders_1||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeToDelOrders_2||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeToDelOrders_3)
        {
            DelBuyStop  = true;
            DeleteBuyStop();
            DelSellStop = true;
            DeleteSellStop();
        }
      else
        {
            DelBuyStop  = false;
            DelSellStop = false;
        }
             
        
}

//+------------------------------------------------------------------+
//Открытие ордера на покупку
//+------------------------------------------------------------------+
void Open_BYSTOP()
{
   if(TradeB)
     {
         double Price = (Ask+Distance*Point);
         double TP = (Ask+(Distance+TakeProfit)*Point);
         double SL = (Bid-StopLoss*Point);
         int ticket = OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,5,SL,TP," ",Magic,0,clrGreen);
     }
}
//+------------------------------------------------------------------+
//Открытие ордера на продажу
//+------------------------------------------------------------------+
void Open_SELLSTOP() 
{
   if(TradeS)
     {
         double Price = (Bid-Distance*Point);
         double TP = (Bid-(Distance+TakeProfit)*Point);
         double SL = (Ask+StopLoss*Point);
         int ticket = OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,5,SL,TP," ",Magic,0,clrBlue);
     }
}

//+------------------------------------------------------------------+
// Удаление отложенных ордеров
//+------------------------------------------------------------------+
void DeleteBuyStop() //На покупку
{
if(DelBuyStop)
   {
    for (int i=OrdersTotal()-1; i>=0; i--)
    {
	   if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_BUYSTOP)
        int  ticket=OrderDelete(OrderTicket(),clrRed);
	   }
     }
    }
}

//+------------------------------------------------------------------+
void DeleteSellStop() //На продажу
{
if (DelSellStop)
   {
      for (int i=OrdersTotal()-1; i>=0; i--)
         {
	      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	         {
		      if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_SELLSTOP)
           int ticket=OrderDelete(OrderTicket(),clrRed);
	         }
         }
   }
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
//+------------------------------------------------------------------+