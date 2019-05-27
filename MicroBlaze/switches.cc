/*
 * switches.cc
 *
 *  Created on: 23/02/2018
 *      Author: user
 */

#include "switches.h"

CSwitches::CSwitches(int baseaddr)
{
	gpio_DATA=(volatile int*)(baseaddr+0x00);
	Change();
}
bool CSwitches::IsON(char i)
{
	if(i<0 || i>1)
		return false;
	char d=(char)*gpio_DATA;
	char m=0x01<<i;
	return ((d&m)==0)? false:true;
}
bool CSwitches::Change()
{
	char d=(char)*gpio_DATA;
	if(state==d)
		return false;
	state=d;
	return true;
}
