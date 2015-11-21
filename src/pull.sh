#!/bin/bash

function bocker_pull() { #HELP Pull an image from Docker Hub:\nBOCKER pull <name> <tag>
  token="$(curl -sL -o /dev/null -D- -H 'X-Docker-Token: true' "https://index.docker.io/v1/repositories/$1/images" | tr -d '\r' | awk -F ': *' '$1 == "X-Docker-Token" { print $2 }')"
  registry='https://registry-1.docker.io/v1'
  id="$(curl -sL -H "Authorization: Token $token" "$registry/repositories/$1/tags/$2" | sed 's/"//g')"
  [[ "${#id}" -ne 64 ]] && echo "No image named '$1:$2' exists" && exit 1
  ancestry="$(curl -sL -H "Authorization: Token $token" "$registry/images/$id/ancestry")"
  IFS=',' && ancestry=(${ancestry//[\[\] \"]/}) && IFS=' \n\t'; tmp_uuid="$(uuidgen)" && mkdir /tmp/"$tmp_uuid"
  for id in "${ancestry[@]}"; do
    curl -#L -H "Authorization: Token $token" "$registry/images/$id/layer" -o /tmp/"$tmp_uuid"/layer.tar
    tar xf /tmp/"$tmp_uuid"/layer.tar -C /tmp/"$tmp_uuid" && rm /tmp/"$tmp_uuid"/layer.tar
  done
  echo "$1:$2" > /tmp/"$tmp_uuid"/img.source
  bocker_init /tmp/"$tmp_uuid" && rm -rf /tmp/"$tmp_uuid"
}
