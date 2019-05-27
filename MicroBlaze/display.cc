/*
 * display.cc
 *
 *  Created on: 12/04/2018
 *      Author: Jesus
 */

#include "Display.h"


CDisplay::CDisplay(int baseaddr)
{
	gpio_DATA = (volatile int*)(baseaddr+0x00);
	state = 3;
	Dnombre = 0;
	*gpio_DATA = 0b1111;
	ON = false;
	salt = false;
	eliminar = false;
}

void CDisplay::Refresh()
{
	short mask;
	char unitat;

	if(ON == true)
	{
		if(state < 0 )													// Solament hi han 4 Pantalles del Display
		{
			state = 3;													// Quan hem arribat a l'última, resetejem el contador
			if(eliminar == true)
			{
				salt = true;
			}
			else
			{
				salt = false;
			}
		}
		mask = ~((0b1)<<state);											// Mascara per encendre la pantalla que volem
		unitat = (Dnombre>>(4*state))&0x0F;								// Obtenim el nombre que volem ficar per pantalla
		switch(state)
		{
			case 3: if( (unitat == 0) && (salt == true) )
					{
						salt = true;
					}
					else
					{
						salt = false;
						Cnombre = (Data(unitat))&(~0b100000000000);		// Encenem el punt
						Cnombre = (Cnombre)|(0b1111);					// Apagem totes les pantalles i Actualitzem el nombre que volem mostrar
					}
					break;

			case 2: if( (unitat == 0) && (salt == true))
					{
						salt = true;
					}
					else
					{
						salt = false;
						Cnombre = (Data(unitat))|(0b100000001111);		// Apagem totes les pantalles i Actualitzem el nombre que volem mostrar
					}
					break;

			case 1: if( (unitat == 0) && (salt == true))
					{
						salt = true;
					}
					else
					{
						salt = false;
						Cnombre = (Data(unitat))&(~0b100000000000);		// Encenem el punt
						Cnombre = (Cnombre)|(0b1111);					// Apagem totes les pantalles i Actualitzem el nombre que volem mostrar
					}
					break;

			case 0: if( (unitat == 0) && (salt == true))
					{
						salt = true;
					}
					else
					{
						salt = false;
						Cnombre = (Data(unitat))|(0b100000001111);		// Apagem totes les pantalles i Actualitzem el nombre que volem mostrar
					}
					break;

		}
		Cnombre = (Cnombre)&(mask);										// Actualitzem el valor de la variable intermitja per saber el valor del PORT
		if( (salt == false) )
		{
			*gpio_DATA = Cnombre;										// Encenem la pantalla
		}
		else
		{
			*gpio_DATA = (Cnombre)|(0b1111);							// Apagem totes les pantalles
		}
		state--;														// Passem a la següent pantalla
	}
}

short CDisplay::Data(short nombre)
{
	switch(nombre)
	{
		case 0:	nombre = ~0b01111110000;
				break;

		case 1: nombre = ~0b00001100000;
				break;

		case 2: nombre = ~0b10110110000;
				break;

		case 3: nombre = ~0b10011110000;
				break;

		case 4: nombre = ~0b11001100000;
				break;

		case 5: nombre = ~0b11011010000;
				break;

		case 6: nombre = ~0b11111010000;
				break;

		case 7: nombre = ~0b00001110000;
				break;

		case 8: nombre = ~0b11111110000;
				break;

		case 9: nombre = ~0b11001110000;
				break;

		case 10: nombre = ~0b11101110000;
				 break;

		case 11: nombre = ~0b11111000000;
				 break;

		case 12: nombre = ~0b01110010000;
				 break;

		case 13: nombre = ~0b10111100000;
				 break;

		case 14: nombre = ~0b11110010000;
				 break;

		case 15: nombre = ~0b11100010000;
				 break;
	}

	return nombre;
}

char CDisplay::Config(char Cfg, short recievednum)
{
	switch(Cfg)
	{
		case 0:	Cnombre = (Cnombre)|(0b1111);				// Apagem totes les pantalles
				*gpio_DATA = Cnombre;
				ON = false;									// Deshabilitem el Refresc de Pantalles
				break;

		case 1: ON = true;									// Habilitem el Refresc de Pantalles
				break;

		case 2: eliminar = true;							// Habilitem la eliminació de 0
				break;

		case 3: eliminar = false;							// Deshabilitem la eliminació de 0
				break;

		case 4: Dnombre = recievednum;						// Actualitzem el valor rebut que voldrem ensenyar per pantalla
				break;
	}

	return 1;
}
