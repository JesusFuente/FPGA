/*
 * timer.h
 *
 *  Created on: 23/02/2018
 *      Author: user
 */

#ifndef TIMER_H_
#define TIMER_H_

#include <xtmrctr.h>

class CTimer
{
private:
	XTmrCtr timer;
	unsigned int clk_KHz;
public:
	CTimer(int, unsigned int);
	void Wait_ms(unsigned int);
	void PeriodicInterrupt_ms(unsigned int);
	XTmrCtr* Get_XTmrCtr();
};


#endif /* TIMER_H_ */
