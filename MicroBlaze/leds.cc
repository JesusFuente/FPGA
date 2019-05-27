/*
 * leds.cc
 *
 *  Created on: 23/02/2018
 *      Author: user
 */

#include "leds.h"

CLeds::CLeds(int baseaddr)
{
	gpio_DATA=(volatile int*)(baseaddr+0x00);
	NewSequence(0);
}
void CLeds::NewSequence(unsigned char i)
{
	index=0;
	sequence=i;
}
void CLeds::NextSequence()
{
	char d;
	switch (sequence)
		{
		case 1: d=Seg1();break;
		case 2: d=Seg2();break;
		case 3: d=~0x0F; break;
		}
	*gpio_DATA=(int)d;
}
unsigned char CLeds::Seg1()
{
	unsigned char d=0;

	if(index==0)
	{
		d=~0xF;
	}
	else
	{
		d= (0x01)<<(index-1);
	}
	if(++index>=5)
		index=0;
	return d;
}
unsigned char CLeds::Seg2()
{
	unsigned char d=((0xF0)>>index)&0x0F;
		if(++index>=5)
		index=0;
	return d;
}

