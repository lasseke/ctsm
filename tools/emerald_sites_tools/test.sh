listtest=(A B C)

len=${#listtest[@]}
for (( i=0; i<$len; i++ ))
do
  echo ${listtest[i]}
done
