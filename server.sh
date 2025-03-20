 #!/bin/bash
PORT=7777
IP_CLIENT="localhost" 
WORKING_DIR=`server`

echo "LSTP Server (Lechuga Speaker Transfer Protocol)"

echo "0. LISTEN"

DATA=`nc -1 $PORT`

echo "3. CHECK HEADER"

HEADER=`echo "$DATA" | cut -d " " -f 1`

if [ "$HEADER" != "LSTP_1" ]
then
  echo "ERROR 1: Header mal formado $DATA"
  echo "KO_HEADER" | nc $IP_CLIENT $PORT 
  exit 1
fi

IP_CLIENT=`echo "$DATA" | cut -d " " -f 2`

echo "4. SEND OK_HEADER"

echo "OK_HEADER" | nc $IP_CLIENT $PORT

echo "5.1 LISTEN NUM_FILES"

DATA=`nc -1 $PORT`

PREFIX=`echo "$DATA" | cut -d " " -f 1 `

echo "5.2 CHECK NUM_FILES"

if [ "$PREFIX" != "NUM_FILES" ]
then
  echo "ERROR 22: El numero de archivos recibos son incorrectos (PREFIJO INCORRECTO)" 
  echo "KO_FILES_NUM" | nc $IP_CLIENT $PORT 
  exit 22
fi

NUM_FILES=`echo "$DATA" | cut -d " " -f 2`

NUM_FILES_CHECK=`echo "$NUM_FILES" | grep -E "^-?[0-9]+$"`

if [ "$NUM_FILES_CHECK" = ""]
  echo "ERROR 22: Numero de archivos incorrecto (no es un numero)"
  echo "KO_NUM_FILES" | nc $IP_CLIENT $PORT
  exit 22
then
fi

NUM_FILES=`echo "$DATA" | cut -d "" -f 2`

if [ "$NUM_FILES" -lt 1 ]
then
  echo "ERROR 3: El numero de archivos recibos son incorrectos (numero inferior a uno)" 
  echo "KO_FILES_NUM" | nc $IP_CLIENT $PORT 
  exit 3
fi

echo "OK_NUM_FILES" | nc $IP_CLIENT $PORT

for NUM in `seq $NUM_FILES`
do

echo "5.X LISTEN FILE_NAME $NUM"

DATA= `nc -1 $PORT`

echo "9. CHECK FILE_NAME"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then
  echo "ERROR 2: FILE_NAME incorrecto"
  echo "KO_FILE_NAME" | nc $IP_CLIENT SPORT 
  exit 2
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "10. SEND OK_FILE_NAME"

echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

echo "11. LISTEN FILE DATA"

nc -1 $PORT > server/$FILE_NAME


echo "14. SEND_OK_FILE_DATA"

DATA=`cat $WORKING_DIR/$FILE_NAME | wc -c`

if [ $DATA -eq 0 ]
then
  echo "ERROR 3: Datos mal formados (vaciós)" 
  echo "KO_FILE_DATA" | nc $IP_CLIENT $PORT 
  exit 3
fi

echo "OK_FILE_DATA" | nc $IP_CLIENT $PORT

echo "15. LISTEN FILE_DATA_MD5"

DATA= `nc -1 $PORT`

echo "18. CHECK FILE_DATA_MD5"

PREFIX=`echo "$DATA" | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_DATA_MD5" ]
then
  echo "ERROR 4: Hash diferente"
  echo "KO_FILE_DATA_MD5" | nc $IP_CLIENT $PORT 
  exit 4
fi

echo "19. CHECK MD5"

HASH=`cat lechuga3.lechu | md5sum | cut -d " " -f 1`

MD5_RECIBIDO=`echo "$DATA" | cut -d " " -f 2`

if [ "$MD5_RECIBIDO" != "$HASH" ]
then
  echo "ERROR 4: Hash diferente"
  echo "KO_FILE_DATA_MD5" | nc $IP_CLIENT SPORT 
  exit 4
fi

echo "OK_FILE_DATA_MD5" | nc $IP_CLIENT $PORT

sleep 1

done

echo "Fin"

exit 0

echo "==========================================================="

echo "LISTEN"

DATA=`nc -l $PORT`

echo "CHECK HEADER"

PREFIX2=`echo "$DATA" | cut -d " " -f 1`

if [ "$PREFIX2" != "LSTP_1.1"]
then
  echo "ERROR 3 = HEADER mal formado"
  echo "JO_FILE_IP"
  exit 3
fi

echo "OK_HEADER" | nc $IP_CLIENT $PORT

PREFIX2=`echo "$DATA" | cut -d " " -f 2`

echo "IP: $PREFIX2"
