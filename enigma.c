#include <stdio.h>

char MSG[] = "CABECAFEFACAFAD";
char GSM[] = "XXXXXXXXXXXXXXX";

int ALPHABET_SIZE = 6;

char RT1[] = {2, 4, 1, 5, 3, 0};
char RT2[] = {1, 5, 3, 2, 0, 4};
char RT3[] = {4, 0, 5, 2, 3, 1};
char RT4[] = {3, 4, 1, 5, 2, 0};
char RT5[] = {5, 2, 3, 4, 1, 0};

char CONF1 = 1;
char CONF2 = 4;
char CONF3 = 1;

char RF1[] = {3, 5, 4, 0, 2, 1};
char RF2[] = {4, 5, 3, 2, 0, 1};
char RF3[] = {3, 2, 1, 0, 5, 4};

char getRotorIndex(char rotorConfig, char msgChar)
{
  char rotorIndex;
  if (rotorConfig + msgChar < ALPHABET_SIZE)
  {
    rotorIndex = rotorConfig + msgChar;
  }
  else
  {
    rotorIndex = rotorConfig + msgChar - ALPHABET_SIZE;
  }
  return rotorIndex;
}

char applyRotor(char *rotor, char rotorConfig, char msgChar)
{
  char rotorIndex = getRotorIndex(rotorConfig, msgChar);
  return rotor[rotorIndex];
}

char inverseApplyRotor(char *rotor, char rotorConfig, char msgChar)
{
  char rotorIndex;
  for (char gsmChar = 0; gsmChar < ALPHABET_SIZE; gsmChar++)
  {
    rotorIndex = getRotorIndex(rotorConfig, gsmChar);
    if (rotor[rotorIndex] == msgChar)
    {
      return gsmChar;
    }
  }
  return -1;
}

char applyReflector(char *reflector, char msgChar)
{
  return applyRotor(reflector, 0, msgChar);
}

void enigma(char *msg, char *gsm)
{
  char *msgIt = msg;
  char *gsmIt = gsm;
  while (*msgIt != '\0')
  {
    *gsmIt = *msgIt - 'A';
    *gsmIt = applyRotor(RT2, CONF2, *gsmIt);
    *gsmIt = applyRotor(RT3, CONF3, *gsmIt);
    *gsmIt = applyReflector(RF1, *gsmIt);
    *gsmIt = inverseApplyRotor(RT3, CONF3, *gsmIt);
    *gsmIt = inverseApplyRotor(RT2, CONF2, *gsmIt);
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
  enigma(MSG, GSM);
  printChars(GSM);
  enigma(GSM, MSG);
  printChars(MSG);
  return 0;
}
