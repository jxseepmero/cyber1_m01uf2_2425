#!bin/bash

if [ $# -ne 1]
then
  echo "ERROR: El comando requiere al menos un parametro" 
  echo "Ejemplo de uso:"
  echo -e "$0 127.0.0.1"
  exit 0
fi

PORT=7777

IP_SERVER=$1

IP_CLIENT=`ip a | grep -i inet | grep -i global | awk '{print $2}' | cut -d "/" -f 1`

WORKING_DIR="client"

echo "LSTP Client (Lechuga Speaker Transfer Protocol)"

echo "1. SEND HEADER (Client: $IP_CLIENT, Server: $IP_SERVER)"

echo "LSTP_1 $IP_CLIENT" | nc $IP_SERVER $PORT

echo "2. LISTEN OK_HEADER"

DATA=nc -1 $PORT`

echo "6. CHECK OK_HEADER"

if [ "$DATA" != "OK_HEADER" ]
then
  echo "ERROR 1: Header enviado incorrectamente"
  exit 1  
fi

#cat client/lechuga.lechu | text2wave -o client/lechuga.wav #yes | ffmpeg -i client/lechuga1.wav client/FILE_NAME

echo "7.1 SEND NUM_FILES"

NUM_FILES=`ls client/*.lechu | wc -1`

echo "NUM_FILES $NUM_FILES" | nc $IP_SERVER $PORT

echo "7.2 LISTEN OK/KO_NUM_FILES"

DATA= nc -1 $PORT`

if [ "$DATA" != "OK_NUM_FILES" ]
then
  echo "ERROR: Numeros de archivos enviados no coincidentes" 
  exit 21
fi

for FILE_NAME in `ls $WORKING_DIR/*. lechu`
do

echo "7.X SEND FILE_NAME"

FILE_NAME=`basename $FILE_NAME`

echo "FILE_NAME $FILE_NAME" | nc $IP_SERVER $PORT

echo "8. LiISTEN OK_FILE_NAME"

DATA= nc -1 SPORT`

if [ "$DATA" != "OK_FILE_NAME" ]
then
  echo "ERROR 2: FILE_NAME mal enviado"
  exit 2
fi

echo "12. SEND FILE DATA"

cat $WORKING_DIR/$FILE_NAME | nc $IP_SERVER $PORT

echo "13. LISTEN OK/KO_FILE_DATA"

DATA= nc -1 $PORT`

if [ "$DATA" != "OK_FILE_DATA" ]
then
  echo "ERROR 3: Error al enviar datos"
  exit 3
fi


echo "16. SEND FILE_DATA_MD5"

echo "$FILE_NAME"

MD5=`cat client/$FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_DATA_MD5 $MD5" | nc $IP_SERVER $PORT

echo "17. LISTEN OK/KO_FILE_DATA_MD5"

DATA= nc -1 $PORT`

echo "19. CHECK OK/OK_FILE_DATA_MD5"

if [ "$DATA" != "OK_FILE_DATA_MD5" ] 
then
  echo "ERROR: HASH MAL ENVIADO" exit 4
fi

done

echo "fin"

exit 0

echo "===================================="

echo "SEND HEADER"

echo "LSTP_1.1 $IP_PROPIA" | nc $IP_SERVER $PORT

echo "LISTEN HEADER"
