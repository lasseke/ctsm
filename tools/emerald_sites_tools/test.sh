listtest=(A B C)
suffix="_test"

len=${#listtest[@]}
for (( i=0; i<$len; i++ ))
do
  echo ~/${listtest[i]}$suffix/testout
done
