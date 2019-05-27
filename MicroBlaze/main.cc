/*
 * Empty C++ Application
 */

#include <stdio.h>
#include <xparameters.h>
#include <xuartlite.h>
#include "timer.h"
#include "leds.h"
#include "Display.h"
#include "switches.h"
#include <xintc.h>
#include <mb_interface.h>

#define DELAY_MIN 0
#define DELAY_MAX 1000

volatile bool Exit;
volatile unsigned int Delay;

CSwitches Switches(XPAR_SWITCHES_BASEADDR);
CDisplay Display(XPAR_LEDS_BASEADDR);
CTimer Timer(XPAR_TIMER_DEVICE_ID,XPAR_TIMER_CLOCK_FREQ_HZ);
XUartLite Uart;
XIntc Intctrl;


void config_from_switch()
{
	if(Switches.Change())							// Mirem si hi ha cap polsador polsat
	{
		if(Switches.IsON(0) == true)				// Si polsem el polsador 0
		{
			Display.Config(0);						// Apagem la pantalla
		}
		else
		{
			Display.Config(1);						// Encenem la pantalla
			if(Switches.IsON(1) == false)
			{
				Display.Config(2);						// Treiem els ceros de la pantalla
			}
			else
			{
				Display.Config(3);						// Fiquem els ceros de la pantalla
			}
		}
	}
}

void config_from_uart()
{
	unsigned char c;
	static short nombre=0, i=0;
	static bool hex=false;

	if( XUartLite_Recv(&Uart,&c,1) != 0 )
	{
		if(c == 120)
		{
			hex = true;
		}
		else
		{
			if(hex == true)
			{
				if( (c >= 48) && (c <= 57) )
				{
					c = c - 48;
					nombre = (nombre<<4) | (c);
					i++;
				}
				else
				{
					if( (c >= 97) && (c <= 102) )
					{
						c = c - 87;
						nombre = (nombre<<4) | (c);
						i++;
					}
					else
					{
						if( (c >= 65) && (c <= 70) )
						{
							c = c - 55;
							nombre = (nombre<<4) | (c);
							i++;
						}
					}
				}
			}
		}
		if(i == 4)
		{
			i = 0;
			hex = false;
			Display.Config(4,nombre);
		}
	}
}

void ISR_uart()
{
	config_from_uart();
}

void ISR_timer()
{
	config_from_switch();
	Display.Refresh();
}

int main()
{
	Exit = false;
	Delay = 5;

	XUartLite_Initialize(&Uart, XPAR_UART_DEVICE_ID);
	XIntc_Initialize(&Intctrl,XPAR_INTCTRL_DEVICE_ID);

	XUartLite_SetRecvHandler(&Uart,(XUartLite_Handler)ISR_uart, NULL);
	XIntc_Connect(&Intctrl, XPAR_INTCTRL_UART_INTERRUPT_INTR, (XInterruptHandler)XUartLite_InterruptHandler, &Uart);
	XIntc_Enable(&Intctrl, XPAR_INTCTRL_UART_INTERRUPT_INTR);

	XTmrCtr_SetHandler(Timer.Get_XTmrCtr(),(XTmrCtr_Handler)ISR_timer,NULL);
	XIntc_Connect(&Intctrl,XPAR_INTCTRL_TIMER_INTERRUPT_INTR,(XInterruptHandler)XTmrCtr_InterruptHandler,&Timer);
	XIntc_Enable(&Intctrl,XPAR_INTCTRL_TIMER_INTERRUPT_INTR);

	XIntc_Start(&Intctrl,XIN_REAL_MODE);
	XUartLite_EnableInterrupt(&Uart);
	Timer.PeriodicInterrupt_ms(Delay);
	microblaze_enable_interrupts();

	xil_printf("app1\r\n");
	while(!Exit)
	{

	}
	xil_printf("End\r\n");
}
