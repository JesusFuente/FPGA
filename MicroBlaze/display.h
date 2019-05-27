/*
 * display.h
 *
 *  Created on: 12/04/2018
 *      Author: Jesus
 */

#ifndef DISPLAY_H_
#define DISPLAY_H_


class CDisplay
{
private:
	volatile int *gpio_DATA;		// Punter per l'adressa dels LEDs del Display
	char state;						// Variable per indicar quina Pantalla del Display s'ha d'encendre
	short Cnombre;					// Valor actual pel Display
	short Dnombre;					// Nombre a ensenyar pel Display
	bool ON;						// Variable per encendre el Display
	bool salt;
	bool eliminar;					// Habilitem la eliminació de 0
public:
	CDisplay(int);					// Constructor
	void Refresh();					// Displays new digit when called by a ISR
	char Config(char=1, short=0xFFFF);	// Configuration of the Display
	short Data(short);				// Data (16-bits) to visualize
};


#endif /* DISPLAY_H_ */
