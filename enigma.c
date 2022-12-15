#include <stdio.h>
#include <string.h>

/** Chave = {A, B, C, D, E, F, G}
 * A = número do rotor à esquerda e B = sua configuração*;
 * C = número do rotor central e D = sua configuração*;
 * E = número do rotor à direita e F = sua configuração*;
 * G = número do refletor.
 */
char CHAVE[] = {2, 4, 5, 8, 3, 3, 2};

// Área de dados do ENIGMA (não alterar) ///////////////////////////////////////////////////////////

char RT_TAM = 26;
char RT_QTD = 5;
char RF_QTD = 3;

char RT1[] = {20, 6, 21, 25, 11, 15, 16, 18, 0, 7, 1, 22, 9, 17, 24, 5, 8, 23, 19, 13, 12, 14, 3, 2, 10, 4};
char RT2[] = {12, 18, 25, 22, 2, 23, 9, 5, 3, 6, 15, 14, 24, 11, 19, 4, 8, 21, 17, 7, 16, 1, 0, 10, 13, 20};
char RT3[] = {23, 21, 18, 2, 15, 14, 0, 25, 3, 8, 4, 17, 7, 24, 5, 10, 11, 20, 22, 1, 12, 9, 16, 6, 19, 13};
char RT4[] = {22, 21, 7, 0, 16, 3, 4, 8, 2, 9, 23, 20, 1, 11, 25, 5, 24, 14, 12, 6, 18, 13, 10, 19, 17, 15};
char RT5[] = {20, 17, 13, 11, 25, 16, 23, 3, 19, 4, 24, 5, 1, 12, 8, 9, 15, 22, 6, 0, 21, 7, 14, 18, 2, 10};

char RF1[] = {14, 11, 25, 4, 3, 22, 20, 18, 15, 13, 12, 1, 10, 9, 0, 8, 24, 23, 7, 21, 6, 19, 5, 17, 16, 2};
char RF2[] = {1, 0, 16, 25, 6, 24, 4, 23, 14, 13, 17, 18, 19, 9, 8, 22, 2, 10, 11, 12, 21, 20, 15, 7, 5, 3};
char RF3[] = {21, 7, 5, 19, 18, 2, 16, 1, 14, 22, 24, 17, 20, 25, 8, 23, 6, 11, 4, 3, 12, 0, 9, 15, 10, 13};

// Área de mensagem ////////////////////////////////////////////////////////////////////////////////

char MSG_CLARA[] = "UMA NOITE DESTAS, VINDO DA CIDADE PARA O ENGENHO NOVO,"
                   " ENCONTREI NO TREM DA CENTRAL UM RAPAZ AQUI DO BAIRRO,"
                   " QUE EU CONHECO DE VISTA E DE CHAPEU.@MACHADO\\ASSIS";
char MSG_CIFR[] =
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
char MSG_DECIFR[] =
    "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

// Área de código //////////////////////////////////////////////////////////////////////////////////

char *allRotors[] = {RT1, RT2, RT3, RT4, RT5};
char *allReflectors[] = {RF1, RF2, RF3};

char *rotors[] = {NULL, NULL, NULL};
char configs[] = {0, 0, 0};
char *reflector = NULL;
char rotations[] = {0, 0, 0};

char IRT1[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
char IRT2[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
char IRT3[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
char *inverseRotors[] = {IRT1, IRT2, IRT3};

void decodeChave()
{
  rotors[0] = allRotors[CHAVE[0] - 1];
  rotors[1] = allRotors[CHAVE[2] - 1];
  rotors[2] = allRotors[CHAVE[4] - 1];
  configs[0] = CHAVE[1];
  configs[1] = CHAVE[3];
  configs[2] = CHAVE[5];
  reflector = allReflectors[CHAVE[6] - 1];
}

char getRotorIndex(char index)
{
  while (index >= RT_TAM)
  {
    index -= RT_TAM;
  }
  while (index < 0)
  {
    index += RT_TAM;
  }
  return index;
}

/* gsmChar = rotor[config - rotation + msgChar] */
char applyRotor(char *rotor, char config, char rotation, char msgChar)
{
  char rotorIndex = getRotorIndex(config - rotation + msgChar);
  return rotor[rotorIndex];
}

void fillInverseRotators()
{
  for (int rotorIndex = 0; rotorIndex < 3; rotorIndex++)
  {
    for (char msgChar = 0; msgChar < RT_TAM; msgChar++)
    {
      char gsmChar = rotors[rotorIndex][msgChar];
      inverseRotors[rotorIndex][gsmChar] = msgChar;
    }
  }
}

/** msgChar = irotor[gsmChar] - config + rotation  */
char inverseApplyRotor(char *iRotor, char config, char rotation, char gsmChar)
{
  char rotorIndex = getRotorIndex(iRotor[gsmChar] - config + rotation);
  return rotorIndex;
}

char applyReflector(char msgChar)
{
  return reflector[msgChar];
}

void encodeMsg(char *msg, char *gsm)
{
  char rotations[] = {0, 0, 0};
  char *msgIt = msg;
  char *gsmIt = gsm;
  while (*msgIt != '\0')
  {
    if (*msgIt < 'A' || *msgIt > 'Z')
    {
      *gsmIt = *msgIt;
      msgIt++;
      gsmIt++;
      continue;
    }
    *gsmIt = *msgIt - 'A';
    for (int i = 0; i < 3; i++)
    {
      *gsmIt = applyRotor(rotors[i], configs[i], rotations[i], *gsmIt);
    }
    *gsmIt = applyReflector(*gsmIt);
    for (int i = 2; i >= 0; i--)
    {
      *gsmIt = inverseApplyRotor(inverseRotors[i], configs[i], rotations[i], *gsmIt);
    }
    rotations[0]++;
    if (rotations[0] == RT_TAM)
    {
      rotations[0] = 0;
      rotations[1]++;
    }
    if (rotations[1] == RT_TAM)
    {
      rotations[1] = 0;
      rotations[2]++;
    }
    if (rotations[2] == RT_TAM)
    {
      rotations[2] = 0;
    }
    *gsmIt = *gsmIt + 'A';
    msgIt++;
    gsmIt++;
  }
  *gsmIt = '\0';
}

void enigma(char *msg, char *gsm)
{
  decodeChave();
  fillInverseRotators();
  encodeMsg(msg, gsm);
}

void visto1()
{
  printf("%s\n", MSG_CLARA);
  enigma(MSG_CLARA, MSG_CIFR);
  printf("%s\n", MSG_CIFR);
  enigma(MSG_CIFR, MSG_DECIFR);
  printf("%s\n", MSG_DECIFR);
}

char CHALLENGE_CIFR[] =
    "CBI MNEXL NOLMBI, GBUKI CS NPVSWR WUYM H YXAXETV MNFI,"
    " BGVXTIAOB OP YQTR QC JCCKVBY YH GRKFT USPE CI MEZDYU,"
    " YBQ LC WHBVYRX JK GPEFC O AB FFVAUE.@KFVCKOR\\HUHTM";

void challenge()
{
  printf("%s\n", CHALLENGE_CIFR);
  for (char rot1 = 1; rot1 <= 5; rot1++)
  {
    for (char config1 = 0; config1 < RT_TAM; config1++)
    {
      for (char rot2 = 2; rot2 <= 5; rot2++)
      {
        for (char config2 = 0; config2 < RT_TAM; config2++)
        {
          for (char rot3 = 1; rot3 <= 5; rot3++)
          {
            for (char config3 = 0; config3 < RT_TAM; config3++)
            {
              for (char ref = 1; ref <= 3; ref++)
              {
                CHAVE[0] = rot1;
                CHAVE[1] = config1;
                CHAVE[2] = rot2;
                CHAVE[3] = config2;
                CHAVE[4] = rot3;
                CHAVE[5] = config3;
                CHAVE[6] = ref;
                enigma(CHALLENGE_CIFR, MSG_DECIFR);
                if (!strcmp("@MACHADO\\ASSIS", MSG_DECIFR + strlen(CHALLENGE_CIFR) - 14))
                {
                  printf("CHAVE: %d,%d,%d,%d,%d,%d,%d\n",
                         CHAVE[0], CHAVE[1], CHAVE[2], CHAVE[3], CHAVE[4], CHAVE[5], CHAVE[6]);
                  printf("%s\n", MSG_DECIFR);
                  return;
                }
              }
            }
          }
        }
      }
    }
  }
}

int main()
{
  visto1();
  // challenge();
}