/*
 * leds.h
 *
 *  Created on: 23/02/2018
 *      Author: user
 */

#ifndef LEDS_H_
#define LEDS_H_

class CLeds
{
private:
	char sequence, index;
	volatile int *gpio_DATA;
	unsigned char Seg1(),Seg2();
public:
	CLeds(int);
	void NewSequence(unsigned char);
	void NextSequence();
};


#endif /* LEDS_H_ */
