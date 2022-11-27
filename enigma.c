#include <stdio.h>

char MSG[] = "CABECAFEFACAFAD";
char GSM[] = "XXXXXXXXXXXXXXX";

int ALPHABET_SIZE = 6;
char RT1[] = {2, 4, 1, 5, 3, 0};
char RF1[] = {3, 5, 4, 0, 2, 1};

char applyRotor(char msgChar)
{
  return RT1[msgChar];
}

void enigma(char *msg)
{
  char *msgIt = msg;
  char *gsmIt = GSM;
  while (*msgIt != '\0')
  {
    *gsmIt = *msgIt - 'A';
    *gsmIt = applyRotor(*gsmIt);
    *gsmIt = *gsmIt + 'A';
    msgIt++;
    gsmIt++;
  }
}

void printChars(char *msg)
{
  for (char *it = msg; *it != '\0'; it++)
  {
    printf("%c", *it);
  }
  printf("\n");
}

int main()
{
  enigma(MSG);
  printChars(GSM);
  return 0;
}
