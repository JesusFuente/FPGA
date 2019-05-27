/*
 * timer.cc
 *
 *  Created on: 23/02/2018
 *      Author: user
 */
#include "timer.h"

CTimer::CTimer(int device_id, unsigned int clk_Hz)
{
	XTmrCtr_Initialize(&timer,device_id);
	XTmrCtr_SetOptions(&timer,0,XTC_DOWN_COUNT_OPTION);
	clk_KHz=clk_Hz/1000;
}
void CTimer::Wait_ms(unsigned int i)
{
	XTmrCtr_SetResetValue(&timer,0,i*clk_KHz);
	XTmrCtr_Start(&timer,0);
	while(!XTmrCtr_IsExpired(&timer,0));
}
void CTimer::PeriodicInterrupt_ms(unsigned int i)
{
XTmrCtr_SetOptions (&timer, 0, XTC_DOWN_COUNT_OPTION|XTC_INT_MODE_OPTION|XTC_AUTO_RELOAD_OPTION);
XTmrCtr_SetResetValue(&timer, 0, i*clk_KHz);
XTmrCtr_Start(&timer, 0);
}
XTmrCtr* CTimer::Get_XTmrCtr()
{
return &timer;
}
