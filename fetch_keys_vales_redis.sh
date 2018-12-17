for each in $( redis-cli -a ozNbDXzPmtVotZ47 KEYS \* ); do
  result=$(redis-cli -a ozNbDXzPmtVotZ47 type $each)
  value=""
  if [ $result == "list" ];
  then
    value=$(redis-cli -a ozNbDXzPmtVotZ47 lrange $each 0 -1)
  elif [ $result == "string" ];
  then
    value=$(redis-cli -a ozNbDXzPmtVotZ47 get $each)
  elif [ $result == "hash" ];
  then
    value=$(redis-cli -a ozNbDXzPmtVotZ47 hgetall $each)
  elif [ $result == "set" ];
  then
    value=$(redis-cli -a ozNbDXzPmtVotZ47 smembers $each)
  fi
  printf "key %s\t\t type %s\t\t value %s.\n" $each $result $value >> /tmp/values
done
