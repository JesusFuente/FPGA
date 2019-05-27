/*
 * switches.h
 *
 *  Created on: 23/02/2018
 *      Author: user
 */

#ifndef SWITCHES_H_
#define SWITCHES_H_

class CSwitches
{
private:
	volatile int *gpio_DATA;
	char state;
public:
	CSwitches(int);
	bool IsON(char);
	bool Change();
};

#endif /* SWITCHES_H_ */
