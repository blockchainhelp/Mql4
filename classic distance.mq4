//+------------------------------------------------------------------+
//|                                               Distance+Timer.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input int      Magic            =1;
input string   TimeSetOrders    ="02:00"; 
input string   TimeCloseOrders  ="05:30";
input string   TimeSetOrders2   ="09:00"; 
input string   TimeCloseOrders2 ="11:00";
input string   TimeSetOrders3   ="15:00";
input string   TimeCloseOrders3 ="17:00";
extern int       Tp             =10;
extern int       Sl             =30;
extern int       Dist           =5;
input double    Lot             =1;
extern bool     TrailingON      =false;
extern bool     OSMA            =true;
extern int      TrailingStop    =10;
extern int      TrailingStep    =1;
double OpriceB,StopLB,TakePB,OpriceS,StopLS,TakePS,SL,SP;
int ticketBS,ticketSS;
bool ticket;
bool BuyON, SellON;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits==3 || Digits==5)
   {
     Tp             *=10;
     Sl             *=10;
     Dist           *=10;
     TrailingStop   *=10;
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
   Trailing();
   CountB();
   CountS();
   CountBS();
   CountSS();
   DeleteBS();
   DeleteSS();
   Enter();
   Osma_indicator();
   Comment(" SellON = " + SellON,"  BuyON = " + BuyON,"  Osma_data = " + Osma_indicator());
  }
//+------------------------------------------------------------------+
//Проверка количества открытых ордеров условие 
//+------------------------------------------------------------------+
int CountB() //На покупку
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
int CountS() //На продажу
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
//Проверка количества открытых ордеров условие 
//+------------------------------------------------------------------+
int CountBS() //На покупку
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
int CountSS() //На продажу
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



double Osma_indicator()
{
   if(OSMA)
   {
   double Osma_data_row =iOsMA(Symbol(),0,2,8,6,6,1);
   double Osma_data_mult = NormalizeDouble(Osma_data_row*1000,3*Digits);
   if(Osma_data_mult<0)
     {
      SellON =false;
     }
   else
     {
      SellON =true;
     }
     
   if(Osma_data_mult>0)
     {
      BuyON =false;
     }
   else
     {
      BuyON =true;
     }
     return(Osma_data_mult);
   }
   return(0);
}
//+------------------------------------------------------------------+
void Enter()
{
   if (TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeSetOrders ||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeSetOrders2||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeSetOrders3)
   { 
   if (CountB()+ CountS() == 0 && CountBS() + CountSS() == 0)
      {
   SP=(Ask-Bid);
   OpriceB =(Bid+Dist*Point); // изменить form ask to bid
   StopLB =(OpriceB-Sl*Point);
   TakePB =(OpriceB+Tp*Point);
//Открываем Отложенный ордер на покупку
if(BuyON)
{
      ticketBS=OrderSend(Symbol(),OP_BUYSTOP,Lot,OpriceB,0,StopLB,TakePB,"timer",Magic,0,clrGreen);    
}   
//Открываем Отложенный ордер на продажу
   OpriceS =(Bid-Dist*Point);
   StopLS =(OpriceS+Sl*Point);
   TakePS =(OpriceS-Tp*Point); 
if (SellON)
{
   ticketSS=OrderSend(Symbol(),OP_SELLSTOP,Lot,OpriceS,0,StopLS,TakePS,"timer",Magic,0,clrBlack);
}  
      }
   }
}

//+------------------------------------------------------------------+
int Trailing()
{
   if (TrailingON)
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
                     SL=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                     if(OrderStopLoss()!=SL)
                    int ticketr = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
                  }
               }  
            }
         
         if(OrderType()==OP_SELL)
         {
            if(OrderOpenPrice()-Ask>TrailingStop*Point)
            {
               if (OrderStopLoss()>Ask+(TrailingStop+TrailingStep)*Point)
               {
                  SL=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                  if(OrderStopLoss()!=SL)
                 int ticketr = OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
               }
            }
         }
         }
      }
   }
  }
   return(0);
}
//+------------------------------------------------------------------+/
//Проверка наличия  отложенных ордеров
//+------------------------------------------------------------------+/
void DeleteBS() //На покупку
{
if (TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders2||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders3)
   {
    for (int i=OrdersTotal()-1; i>=0; i--)
    {
	   if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	   {
		if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_BUYSTOP)
          ticket=OrderDelete(OrderTicket(),clrGray);
	   }
     }
    }
}
//+------------------------------------------------------------------+
void DeleteSS() //На продажу
{
if (TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders2||TimeToStr(TimeCurrent(), TIME_MINUTES)==TimeCloseOrders3)
   {
      for (int i=OrdersTotal()-1; i>=0; i--)
         {
	      if(OrderSelect(i,SELECT_BY_POS, MODE_TRADES))
	         {
		      if (OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic && OrderType()== OP_SELLSTOP)
            ticket=OrderDelete(OrderTicket(),clrGray);
	         }
         }
   }
 }