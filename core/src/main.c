#include "stm32f4xx.h"
#include <stdio.h>
#include <string.h>

UART_HandleTypeDef huart2;

void UART2_Init(void);

const char *message = "The application is running...\n";

int main(void)
{
    HAL_Init();
    UART2_Init();

    while (1)
    {
        HAL_UART_Transmit(&huart2, (uint8_t *)message, strlen(message), HAL_MAX_DELAY);
        HAL_Delay(1000);
    }

    return 0;
}

void UART2_Init(void)
{
    huart2.Instance = USART2;
    huart2.Init.BaudRate = 115200;
    huart2.Init.HwFlowCtl = UART_WORDLENGTH_8B;
    huart2.Init.Mode = UART_MODE_TX;
    huart2.Init.Parity = UART_PARITY_NONE;
    huart2.Init.StopBits = UART_STOPBITS_1;
    huart2.Init.WordLength = UART_WORDLENGTH_8B;

    HAL_UART_Init(&huart2);
}
