/*
*********************************************************************************************************
*                                            EXAMPLE CODE
*
*                          (c) Copyright 2009-2015; Micrium, Inc.; Weston, FL
*
*               All rights reserved.  Protected by international copyright laws.
*
*               Please feel free to use any application code labeled as 'EXAMPLE CODE' in
*               your application products.  Example code may be used as is, in whole or in
*               part, or may be used as a reference only.
*
*               Please help us continue to provide the Embedded community with the finest
*               software available.  Your honesty is greatly appreciated.
*
*               You can contact us at www.micrium.com.
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                          SETUP INSTRUCTIONS
*
*   This demonstration project illustrate a basic uC/OS-III project with simple "hello world" output.
*
*   By default some configuration steps are required to compile this example :
*
*   1. Include the require Micrium software components
*       In the BSP setting dialog in the "overview" section of the left pane the following libraries
*       should be added to the BSP :
*
*           ucos_common
*           ucos_osiii
*           ucos_standalone
*
*   2. Kernel tick source - (Not required on the Zynq-7000 PS)
*       If a suitable timer is available in your FPGA design it can be used as the kernel tick source.
*       To do so, in the "ucos" section select a timer for the "kernel_tick_src" configuration option.
*
*   3. STDOUT configuration
*       Output from the print() and UCOS_Print() functions can be redirected to a supported UART. In
*       the "ucos" section the stdout configuration will list the available UARTs.
*
*   Troubleshooting :
*       By default the Xilinx SDK may not have selected the Micrium drivers for the timer and UART.
*       If that is the case they must be manually selected in the drivers configuration section.
*
*       Finally make sure the FPGA is programmed before debugging.
*
*
*   Remember that this example is provided for evaluation purposes only. Commercial development requires
*   a valid license from Micrium.
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/

#include  <stdio.h>
#include  <Source/os.h>
#include  <ucos_bsp.h>

// User
#include "xadcps.h"
#include "xgpio.h"

/*
*********************************************************************************************************
*                                            DEFINES
*********************************************************************************************************
*/

#define	APP_TASK_START_STK_SIZE		512u
#define	APP_TASK1_STK_SIZE			512u
#define APP_TASK2_STK_SIZE			512u
#define APP_TASK3_STK_SIZE			512u
#define APP_TASK_START_PRIO			8u
#define APP_TASK1_PRIO				2u
#define APP_TASK2_PRIO				3u
#define APP_TASK3_PRIO				8u

// User defintions
#define XADC_DEVICE_ID 				XPAR_XADCPS_0_DEVICE_ID 									// "xparameters.h"
#define GPIO_DEVICE_ID 				XPAR_AXI_GPIO_0_DEVICE_ID 									// "xparameters.h"
#define BUTTONS_CHANNEL				1 															// Channel 1 of the GPIO Device
#define FREQ_CHANNEL				2 															// Channel 2 of the GPIO Device (Frequency measure)
#define FPGA_DRIVER_ADDR 			XPAR_VGA_ADC_DRIVER_1_S00_AXI_BASEADDR 						// "xparameters.h"
#define alarm_mask 					0x00000001													// Alarm "AND" bit mask
#define alarm_mask_offset 			1															// Alarm mask offset
#define temperature_mask 			0x00000FFE													// Temperature "AND" bit mask
#define temperature_mask_offset 	12															// Temperature mask offset
#define t_temperature_mask 			0x007FF000													// Temperature threshold "AND" bit mask
#define c_temperature_upper_limit	80															// Sensor Temperature upper limit
#define c_temperature_lower_limit 	0															// Sensor Temperature lower limit
#define tst_mode_mask_offset 		23															// Test Mode mask offset
#define tst_mode_axi_mask 			0x00800000													// Test Mode AXI Mask
#define tst_mode_gpio_mask 			0x04														// Test Mode GPIO Mask
#define temp_gpio_mask 				0x03														// Temperature Increment/Decrement GPIO Mask
#define scale_sense_gpio_offset 	24															// Scale sense mask offset
#define scale_sense_axi_mask 		0x01000000													// Test Mode AXI Mask
#define scale_gpio_mask 			0x18														// Scale Increment/Decrement GPIO Mask
#define scale_gpio_offset 			3															// Scale Increment/Decrement GPIO Offset
#define vscale_gpio_offset 			25															// vscale mask offset
#define vscale_axi_mask 			0x0E000000													// Test Mode AXI Mask
#define hvscale_sel_gpio_offset 	5															// vscale mask offset
#define hvscale_sel_gpio_mask 		0x20														// Test Mode AXI Mask
#define hscale_axi_offset 			28															// vscale mask offset
#define hscale_axi_mask 			0x70000000													// Test Mode AXI Mask

/*
*********************************************************************************************************
*                                            LOCAL VARIABLES
*********************************************************************************************************
*/

static  OS_TCB       AppTaskStartTCB;							// Task Control Block (TCB).
static  OS_TCB       AppTask1TCB;
static  OS_TCB       AppTask2TCB;
static  OS_TCB       AppTask3TCB;

static  CPU_STK      AppTaskStartStk[APP_TASK_START_STK_SIZE]; 	// Startup Task Stack
static  CPU_STK      AppTask1Stk[APP_TASK1_STK_SIZE];			// Task #1      Stack
static  CPU_STK      AppTask2Stk[APP_TASK2_STK_SIZE];			// Task #2      Stack
static  CPU_STK      AppTask3Stk[APP_TASK3_STK_SIZE];			// Task #3      Stack

static  OS_MUTEX     AppMutexPrint;								// App Mutex

// User HW instance declarations
static XAdcPs XAdcInst;      /* XADC driver instance */
XAdcPs *XAdcInstPtr = &XAdcInst;
static XGpio Gpio; /* The Instance of the GPIO Driver */

/*
*********************************************************************************************************
*                                            GLOBAL VARIABLES
*********************************************************************************************************
*/

// Temperature sensor variables
unsigned char hscale, scale_sense, scale_shift;
unsigned char tst_mode;
unsigned int alarm, alarm_send;
unsigned int temperature_raw, temperature, temperature_send;
unsigned int t_temperature;
unsigned int* FPGA_DRIVER = (unsigned int *) FPGA_DRIVER_ADDR; // Pointer to access the FPGA AXI Driver software register
// Usage example
/*
	temperature_raw = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
	temperature = (int) XAdcPs_RawToTemperature(temperature_raw); // Temperature in degrees [0;80] ºC
*/
const unsigned char c_hscale_limit=7;
const unsigned char c_zoom_in_limit=0, c_zoom_out_limit=5;

/*
*********************************************************************************************************
*                                      LOCAL FUNCTION PROTOTYPES
*********************************************************************************************************
*/

static void AppTaskCreate      (void);
static void AppTaskStart       (void *p_arg);
static void AppTask1           (void *p_arg);
static void AppTask2           (void *p_arg);
static void AppTask3           (void *p_arg);
static void AppPrintWelcomeMsg (void);
static void AppPrint           (char *str);
void  MainTask (void *p_arg);

// User function declarations
static void Peripheral_Init    (void);

/*
*********************************************************************************************************
*                                               main()
*
* Description : Entry point for C code.
*
*********************************************************************************************************
*/

int main()
{

	UCOSStartup(MainTask);

	return 0;
}

/*
*********************************************************************************************************
*                                          STARTUP TASK
*
* Description : This is an example of a startup task.  
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 
*********************************************************************************************************
*/
void  MainTask (void *p_arg)
{
    OS_ERR err;

    AppPrintWelcomeMsg();

    OSInit(&err);		// Initialize uC/OS-III.

    // Create the STARTUP TASK
	OSTaskCreate	((OS_TCB	*)&AppTaskStartTCB,
						(CPU_CHAR	*)"App Task Start",
						(OS_TASK_PTR )AppTaskStart,
						(void		*)0,
						(OS_PRIO	 )APP_TASK_START_PRIO,
						(CPU_STK 	*)&AppTaskStartStk[0],
						(CPU_STK_SIZE)APP_TASK_START_STK_SIZE / 10,
						(CPU_STK_SIZE)APP_TASK_START_STK_SIZE,
						(OS_MSG_QTY	 )0,
						(OS_TICK	 )0,
						(void 		*)0,
						(OS_OPT )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
						(OS_ERR *)&err);

	// Start multitasking (i.e. give control to uC/OS-II).
	OSStart(&err);
}

/*
*********************************************************************************************************
*                                        PRINT WELCOME THROUGH UART
*
* Description : Prints a welcome message through the UART.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : application functions.
*
* Note(s)     : Because the welcome message gets displayed before
*               the multi-tasking has started, it is safe to access
*               the shared resource directly without any mutexes.
*********************************************************************************************************
*/

static  void  AppPrintWelcomeMsg (void)
{
    UCOS_Print("\f\f\r\n");
    UCOS_Print("Micrium\r\n");
    UCOS_Print("uCOS-III\r\n\r\n");
    UCOS_Print("This application runs three different tasks:\r\n\r\n");
    UCOS_Print("1. Task Start: Initializes the OS&peripherals and crea-\r\n");
    UCOS_Print("               tes tasks and other kernel objects such \r\n");
    UCOS_Print("               as semaphores. This task remains runnin-\r\n");
    UCOS_Print("               g and printing monitoring values every 2\r\n");
    UCOS_Print("               seconds.\r\n");
    UCOS_Print("2. Task #1   : Updates -> 1)Zync temperature 2)Tempera-\r\n");
    UCOS_Print("               ture threshold 3)Alarm condition, every \r\n");
    UCOS_Print("               100ms.\r\n");
    UCOS_Print("3. Task #2   : Updates Temperature threshold value thr-\r\n");
    UCOS_Print("               ough Buttons every 100ms.\r\n");
    UCOS_Print("4. Task #3   : Reads UART commands values.\r\n\r\n");
}


/*
*********************************************************************************************************
*                                          STARTUP TASK
*
* Description : This is an example of a startup task.  As mentioned in the book's text, you MUST
*               initialize the ticker only once multitasking has started.
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  AppTaskStart (void *p_arg)
{
    OS_ERR err;
    u32 tmp=0;
    const int c_alarm = 0, c_temperature = 40, c_t_temperature = 60, c_tst_mode=0, c_hscale=0, c_scale_sense=0, c_scale_shift=0, c_clk=108000000;
    unsigned char str[50], buttons=0;
    double tmp_float=0;

	UCOS_Print("Task Start Created\r\n");

	// Initializations
	Peripheral_Init(); // Zync board temperature sensor init.
	alarm = c_alarm;
	temperature = c_temperature;
	t_temperature = c_t_temperature;
	tst_mode = c_tst_mode;
	hscale = c_hscale;
	scale_sense = c_scale_sense;
	scale_shift = c_scale_shift;
	tmp = ((alarm<<0)&(alarm_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~alarm_mask); // Alarm init.
	tmp = (((16*temperature)<<alarm_mask_offset)&(temperature_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~temperature_mask); // Temperature init.
	tmp = (((16*t_temperature)<<temperature_mask_offset)&(t_temperature_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~t_temperature_mask); // Temperature threshold init.
	tmp = (((tst_mode)<<tst_mode_mask_offset)&(tst_mode_axi_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~tst_mode_axi_mask); // Test mode init.
	tmp = (((hscale)<<hscale_axi_offset)&(hscale_axi_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~hscale_axi_mask); // hvscale Selector init.
	tmp = (((scale_sense)<<scale_sense_gpio_offset)&(scale_sense_axi_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~scale_sense_axi_mask); // Scale Sense Zoom init.
	tmp = (((scale_shift)<<vscale_gpio_offset)&(vscale_axi_mask));
	*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~vscale_axi_mask); // Scale Zoom init.

	// Main Application tasks Creation
	AppTaskCreate();

	// Mutexes Creation
    OSMutexCreate((OS_MUTEX *)&AppMutexPrint, (CPU_CHAR *)"My App. Printer Mutex", (OS_ERR *)&err);

    while(1)
    {
    	// Waits for 2s
		OSTimeDlyHMSM(0, 0, 2, 0, OS_OPT_TIME_HMSM_STRICT, &err);

		// Startup Task body start (Non critical tasks: Lowest priority)

			// General parameters emission
			// sprintf(str, "\n\rTemperature of Zync Device\t = %dºC\t (0x%x)\n\r", temperature, temperature_send);
			sprintf(str, "\n\rTemperature of Zync Device\t = %dºC\n\r", temperature);
			AppPrint(str);
			sprintf(str, "Temperature threshold\t\t = %dºC\n\r", t_temperature);
			AppPrint(str);
			sprintf(str, "Alarm signal\t\t\t = %d\n\r", alarm);
			AppPrint(str);
			sprintf(str, "Vertical scale zoom\t\t = %d\n\r", scale_shift);
			AppPrint(str);
			sprintf(str, "Horizontal scale zoom\t\t = %d\n\r", hscale);
			AppPrint(str);
			tmp = XGpio_DiscreteRead(&Gpio, FREQ_CHANNEL);
			tmp_float = c_clk/tmp;
			sprintf(str, "Frequency\t\t\t = %.3f Hz (Counts: %d; ClkRef: 108MHz)\n\r", tmp_float, tmp);
			AppPrint(str);

			// Test Mode check
			buttons = XGpio_DiscreteRead(&Gpio, BUTTONS_CHANNEL);
			if ((buttons&tst_mode_gpio_mask) == tst_mode_gpio_mask)
			{
				if (tst_mode == 0)
				{
					AppPrint("\n\r----------------Test Mode requested!----------------\n\r");
					tst_mode = 1;
					tmp = (((tst_mode)<<tst_mode_mask_offset)&(tst_mode_axi_mask));
					*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~tst_mode_axi_mask); // Test mode init.
				}
			}
			else
			{
				if (tst_mode == 1)
				{
					AppPrint("\n\r----------------Test Mode released!----------------\n\r");
					tst_mode = 0;
					tmp = (((tst_mode)<<tst_mode_mask_offset)&(tst_mode_axi_mask));
					*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~tst_mode_axi_mask); // Test mode init.
				}
			}

		// Startup Task body end
    }
}


/*
*********************************************************************************************************
*                                       CREATE APPLICATION TASKS
*
* Description : Creates the application tasks.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : AppTaskStart()
*
* Note(s)     : none.
*********************************************************************************************************
*/

static  void  AppTaskCreate (void)
{
	OS_ERR  err;

	// Create the Task #1.
    OSTaskCreate((OS_TCB     *)&AppTask1TCB,
                 (CPU_CHAR   *)"Task 1",
                 (OS_TASK_PTR ) AppTask1,
                 (void       *) 0,
                 (OS_PRIO     ) APP_TASK1_PRIO,
                 (CPU_STK    *)&AppTask1Stk[0],
                 (CPU_STK_SIZE) APP_TASK1_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_TASK1_STK_SIZE,
                 (OS_MSG_QTY  ) 0u,
                 (OS_TICK     ) 0u,
                 (void       *) 0,
                 (OS_OPT      )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    // Create the Task #2.
    OSTaskCreate((OS_TCB     *)&AppTask2TCB,
                 (CPU_CHAR   *)"Task 2",
                 (OS_TASK_PTR ) AppTask2,
                 (void       *) 0,
                 (OS_PRIO     ) APP_TASK2_PRIO,
                 (CPU_STK    *)&AppTask2Stk[0],
                 (CPU_STK_SIZE) APP_TASK2_STK_SIZE / 10u,
                 (CPU_STK_SIZE) APP_TASK2_STK_SIZE,
                 (OS_MSG_QTY  ) 0u,
                 (OS_TICK     ) 0u,
                 (void       *) 0,
                 (OS_OPT      )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                 (OS_ERR     *)&err);

    // Create the Task #3.
        OSTaskCreate((OS_TCB     *)&AppTask3TCB,
                     (CPU_CHAR   *)"Task 3",
                     (OS_TASK_PTR ) AppTask3,
                     (void       *) 0,
                     (OS_PRIO     ) APP_TASK3_PRIO,
                     (CPU_STK    *)&AppTask3Stk[0],
                     (CPU_STK_SIZE) APP_TASK3_STK_SIZE / 10u,
                     (CPU_STK_SIZE) APP_TASK3_STK_SIZE,
                     (OS_MSG_QTY  ) 0u,
                     (OS_TICK     ) 0u,
                     (void       *) 0,
                     (OS_OPT      )(OS_OPT_TASK_STK_CHK | OS_OPT_TASK_STK_CLR),
                     (OS_ERR     *)&err);
}



/*
*********************************************************************************************************
*                                              TASK #1
*
* Description : Update variables and sends their values to FPGA driver.
*
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  AppTask1 (void *p_arg)
{
	OS_ERR  err;
	(void)p_arg;
	u32 tmp=0;

    AppPrint("Task #1 Started\r\n");
    while(1) // Task body, always written as an infinite loop.
    {
    	// Waits for 100 ms
        OSTimeDlyHMSM(0, 0, 0, 100, OS_OPT_TIME_HMSM_STRICT, &err);

        // Task 1 body start

        	// Temperature update
			temperature_raw = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
			temperature = XAdcPs_RawToTemperature(temperature_raw);
			tmp = (((16*temperature)<<alarm_mask_offset)&(temperature_mask));
			temperature_send = ((*FPGA_DRIVER)|(tmp))&(tmp|~temperature_mask);
			*FPGA_DRIVER = temperature_send; // Temperature update

			// Temperature threshold update
			tmp = (((16*t_temperature)<<temperature_mask_offset)&(t_temperature_mask));
			*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~t_temperature_mask); // Temperature threshold init.

			// Alarm update
			if (temperature > t_temperature) // Evaluate Alarm conditions
			{
				alarm = 1;
			}
			else
			{
				alarm = 0;
			}
			tmp = (((alarm)<<0)&(alarm_mask));
			alarm_send = ((*FPGA_DRIVER)|(tmp))&(tmp|~alarm_mask);
			*FPGA_DRIVER = alarm_send; // Alarm update

			// Zoom update
			tmp = (((hscale)<<hscale_axi_offset)&(hscale_axi_mask));
			*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~hscale_axi_mask); // hvscale Selector init.
			tmp = (((scale_sense)<<scale_sense_gpio_offset)&(scale_sense_axi_mask));
			*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~scale_sense_axi_mask); // Scale Sense Zoom init.
			tmp = (((scale_shift)<<vscale_gpio_offset)&(vscale_axi_mask));
			*FPGA_DRIVER = ((*FPGA_DRIVER)|(tmp))&(tmp|~vscale_axi_mask); // Scale Zoom init.

        // Task 1 body end
    }
}


/*
*********************************************************************************************************
*                                               TASK #2
*
* Description : Process buttons info.
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  AppTask2 (void *p_arg)
{
	OS_ERR err;
	(void)p_arg;
	unsigned char buttons=0, buttons_old=0;
	unsigned short buttons_cnt=0;
	const short c_time_buttons_cnt=5; // 10s
	unsigned char zoom_button=0, zoom_button_old=0, hvscale_sel=0, vscale_in=0, vscale_out=0;

    AppPrint("Task #2 Started\r\n");
    while(1) // Task body, always written as an infinite loop.
	{
		// Waits for 100ms
		OSTimeDlyHMSM(0, 0, 0, 100, OS_OPT_TIME_HMSM_STRICT, &err);

		// Task 2 body start

			// (BTNR & BTNL) update
			buttons = XGpio_DiscreteRead(&Gpio, BUTTONS_CHANNEL)&(temp_gpio_mask);
			switch (buttons)
			{
				case 1:
					if ((buttons != buttons_old) || (buttons_cnt > c_time_buttons_cnt-2))
					{
						buttons_old = buttons;
						buttons_cnt = buttons_cnt + 1;
						if (t_temperature < c_temperature_upper_limit)
							t_temperature = t_temperature + 1;
					}
					else
					{
						buttons_cnt = buttons_cnt + 1;
					}
					break;
				case 2:
					if ((buttons != buttons_old) || (buttons_cnt > c_time_buttons_cnt-2))
					{
						buttons_old = buttons;
						buttons_cnt = buttons_cnt + 1;
						if (t_temperature > c_temperature_lower_limit)
							t_temperature = t_temperature - 1;
					}
					else
					{
						buttons_cnt = buttons_cnt + 1;
					}
					break;
				default:
					buttons_old = 0;
					buttons_cnt = 0;
					break;
			}

			// (Zoom IN & OUT) update
			hvscale_sel = (XGpio_DiscreteRead(&Gpio, BUTTONS_CHANNEL)&(hvscale_sel_gpio_mask))>>hvscale_sel_gpio_offset;
			buttons = (XGpio_DiscreteRead(&Gpio, BUTTONS_CHANNEL)&(scale_gpio_mask))>>scale_gpio_offset;
			zoom_button = buttons&1;
			if ((zoom_button == 1)&&(zoom_button_old == 0)) // Rising edge detection
			{
				if (buttons > 1) // Zoom in
				{
					if (hvscale_sel == 1) // hscale
					{
						if (hscale > 0)
						{
							hscale = hscale - 1;
						}
					}
					else // vscale
					{
						if ((vscale_out < 0+1)&&(vscale_in < c_zoom_in_limit))
						{
							vscale_in = vscale_in + 1;
							scale_sense = 1;
							scale_shift = vscale_in;
						}
						else
						{
							if (vscale_out > 0)
							{
								vscale_out = vscale_out - 1;
								scale_shift = vscale_out;
							}
						}
					}
				}
				else // Zoom out
				{
					if (hvscale_sel == 1) // hscale
					{
						if (hscale < c_hscale_limit)
						{
							hscale = hscale + 1;
						}
					}
					else // vscale
					{
						if ((vscale_in < 0+1)&&(vscale_out < c_zoom_out_limit))
						{
							vscale_out = vscale_out + 1;
							scale_sense = 0;
							scale_shift = vscale_out;
						}
						else
						{
							if (vscale_in > 0)
							{
								vscale_in = vscale_in - 1;
								scale_shift = vscale_in;
							}
						}
					}
				}
			}
			zoom_button_old = zoom_button;

		// Task 2 body end
	}
}

/*
*********************************************************************************************************
*                                               TASK #3
*
* Description : Receive UART commands.
*
* Arguments   : p_arg   is the argument passed to 'AppTaskStart()' by 'OSTaskCreate()'.
*
* Returns     : none
*
* Notes       : 1) The first line of code is used to prevent a compiler warning because 'p_arg' is not
*                  used.  The compiler should not generate any code for this statement.
*********************************************************************************************************
*/

static  void  AppTask3 (void *p_arg)
{
	OS_ERR err;
	(void)p_arg;
	int txt_rcv;
	char txt[20];

    AppPrint("Task #3 Started\r\n");
    while(1) // Task body, always written as an infinite loop.
	{
		// Waits for 100ms
		OSTimeDlyHMSM(0, 0, 0, 100, OS_OPT_TIME_HMSM_STRICT, &err);

		// Task 3 body start

			// UART receive
			txt_rcv = UCOS_Read (txt, sizeof(txt));

			// UART command selector
			if (strncmp(txt, ":reset", sizeof(":reset")-1) == 0)
			{
				hscale = 0;
				scale_sense = 0;
				scale_shift = 0;
			}
			else
			{
				if (strncmp(txt, ":hscale inc", sizeof(":hscale inc")-1) == 0)
				{
					if (hscale > 0)
					{
						hscale = hscale - 1;
					}
				}
				else
				{
					if (strncmp(txt, ":hscale dec", sizeof(":hscale dec")-1) == 0)
					{
						if (hscale < c_hscale_limit)
						{
							hscale = hscale + 1;
						}
					}
					else
					{
						if (strncmp(txt, ":vscale inc", sizeof(":vscale inc")-1) == 0)
						{
							if (scale_sense == 1)
							{
								if (scale_shift < c_zoom_in_limit)
								{
									scale_shift = scale_shift + 1;
								}
							}
							else
							{
								if (scale_shift > 0)
								{
									scale_shift = scale_shift - 1;
								}
								else
								{
									if (scale_shift < c_zoom_in_limit)
									{
										scale_sense = 1;
										scale_shift = scale_shift + 1;
									}
								}
							}
						}
						else
						{
							if (strncmp(txt, ":vscale dec", sizeof(":vscale dec")-1) == 0)
							{
								if (scale_sense == 0)
								{
									if (scale_shift < c_zoom_out_limit)
									{
										scale_shift = scale_shift + 1;
									}
								}
								else
								{
									if (scale_shift > 0)
									{
										scale_shift = scale_shift - 1;
									}
									else
									{
										if (scale_shift < c_zoom_out_limit)
										{
											scale_sense = 0;
											scale_shift = scale_shift + 1;
										}
									}
								}
							}
						}
					}
				}
			}

		// Task 3 body end
	}
}

/*
*********************************************************************************************************
*                                            PRINT THROUGH UART
*
* Description : Prints a string through the UART. It makes use of a mutex to
*               access this shared resource.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : application functions.
*
* Note(s)     : none.
*********************************************************************************************************
*/

static  void  AppPrint (char *str)
{
	OS_ERR  err;
    CPU_TS  ts;


                                                                /* Wait for the shared resource to be released.         */
    OSMutexPend(	(OS_MUTEX *)&AppMutexPrint,
    				(OS_TICK )0u,                                            /* No timeout.                                          */
					(OS_OPT )OS_OPT_PEND_BLOCKING,                          /* Block if not available.                              */
					(CPU_TS *)&ts,                                            /* Timestamp.                                           */
					(OS_ERR *)&err);

    UCOS_Print(str);                                                 /* Access the shared resource.                          */

                                                                /* Releases the shared resource.                        */
    OSMutexPost( 	(OS_MUTEX *)&AppMutexPrint,
    				(OS_OPT )OS_OPT_POST_NONE,                              /* No options.                                          */
					(OS_ERR *)&err);
}


/*
*********************************************************************************************************
*                                     ZYNC BOARD TEMPERATURE SENSOR INIT
*
* Description : Initializes Zync board temperature sensor to be used.
*
* Argument(s) : none
*
* Return(s)   : none
*
* Caller(s)   : application functions.
*
* Note(s)     : none.
*********************************************************************************************************
*/

void Peripheral_Init()
{
	int Status;
	XAdcPs_Config *ConfigPtr;

    /* Initialize the GPIO driver. If an error occurs then exit */
    	Status = XGpio_Initialize(&Gpio, GPIO_DEVICE_ID);
    	if (Status != XST_SUCCESS) {
    		return XST_FAILURE;
    	}

    	/*
    	 * Perform a self-test on the GPIO.  This is a minimal test and only
    	 * verifies that there is not any bus error when reading the data
    	 * register
    	 */
    	XGpio_SelfTest(&Gpio);

    	/*
    	 * Setup direction register so the switch is an input and the LED is
    	 * an output of the GPIO
    	 */
    	XGpio_SetDataDirection(&Gpio, BUTTONS_CHANNEL, 0xFF);
    	XGpio_SetDataDirection(&Gpio, FREQ_CHANNEL, 0xFF);

    	/*
    	 * Initialize the XAdc driver.
    	 */
    	ConfigPtr = XAdcPs_LookupConfig(XADC_DEVICE_ID);


    	XAdcPs_CfgInitialize(XAdcInstPtr, ConfigPtr,
    				ConfigPtr->BaseAddress);

    	/*
    	 * Self Test the XADC/ADC device
    	 */
    	Status = XAdcPs_SelfTest(XAdcInstPtr);


    	/*
    	 * Disable the Channel Sequencer before configuring the Sequence
    	 * registers.
    	 */
    	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SAFE);

}
