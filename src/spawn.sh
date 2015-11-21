#!/bin/bash
btrfs_path='/var/bocker' && cgroups='cpu,cpuacct,memory' && repo='/home/stamf/git/.bocker-repo';

function bocker_spawn() { #HELP Create a container:\nBOCKER spawn <image_id> <env> <nix-image> <conf-file>
   uuid="ps_$(shuf -i 42002-42254 -n 1)"
   [[ "$(bocker_check "$1")" == 1 ]] && echo "No image named '$1' exists" && exit 1
   [[ "$(bocker_check "$uuid")" == 0 ]] && echo "UUID conflict, retrying..." && return #&& bocker_run "$@" && return
   ip="$(echo "${uuid: -3}" | sed 's/^0*//g')" && mac="${uuid: -3:1}:${uuid: -2}"
   ip link add dev veth0_"$uuid" type veth peer name veth1_"$uuid"
   ip link set dev veth0_"$uuid" up
   ip link set veth0_"$uuid" master bridge0
   ip netns add netns_"$uuid"
   ip link set veth1_"$uuid" netns netns_"$uuid"
   ip netns exec netns_"$uuid" ip link set dev lo up
   ip netns exec netns_"$uuid" ip link set veth1_"$uuid" address 02:42:ac:11:00"$mac"
   ip netns exec netns_"$uuid" ip addr add 11.0.0."$ip"/24 dev veth1_"$uuid"
   ip netns exec netns_"$uuid" ip link set dev veth1_"$uuid" up
   ip netns exec netns_"$uuid" ip route add default via 11.0.0.1
   btrfs subvolume snapshot "$btrfs_path/$1" "$btrfs_path/$uuid" > /dev/null
   echo nameserver 11.0.0.1 > "$btrfs_path/$uuid/etc/resolv.conf"

   service="$3"

   tar xzf "$repo/${3}.tgz" -C "$btrfs_path/$uuid"
   pushd "$repo/api-config-files" >/dev/null || exit
   mkdir -p "$btrfs_path/$uuid/etc/service-config"
   git archive master | tar -x --strip-components=2 -C "$btrfs_path/$uuid/etc/service-config" "$service/$2"
   popd >/dev/null
   echo -e "$(date +%s.%N)\t$2\t$3\t11.0.0.$ip" > "$btrfs_path/$uuid/var/tmp/instance-tag"

   echo spawn "$@" > "$btrfs_path/$uuid/$uuid.cmd"
   cgcreate -g "$cgroups:/$uuid"
   : "${BOCKER_CPU_SHARE:=512}" && cgset -r cpu.shares="$BOCKER_CPU_SHARE" "$uuid"
   : "${BOCKER_MEM_LIMIT:=512}" && cgset -r memory.limit_in_bytes="$((BOCKER_MEM_LIMIT * 1000000))" "$uuid"
   cgexec -g "$cgroups:$uuid" \
     ip netns exec netns_"$uuid" \
     unshare -fmuip --mount-proc \
     chroot "$btrfs_path/$uuid" \
     /bin/sh -c "/bin/mount -t proc proc /proc && \\
/bin/mount -t devpts devpts /dev/pts && \\
/bin/rm -f /dev/null && \\
/bin/rm -f /dev/zero && \\
/bin/rm -f /dev/random && \\
/bin/rm -f /dev/urandom && \\
/bin/mknod -m 666 /dev/null c 1 3 && \\
/bin/mknod -m 666 /dev/zero c 1 5 && \\
/bin/mknod -m 666 /dev/random c 1 8 && \\
/bin/mknod -m 666 /dev/urandom c 1 9 && \\
/bin/ln -s /proc/self/fd/0 /dev/stdin && \\
/bin/ln -s /proc/self/fd/1 /dev/stdout && \\
/bin/ln -s /proc/self/fd/2 /dev/stderr && \\
$service -c /etc/service-config/$4" 2>&1 \
  | tee "$btrfs_path/$uuid/$uuid.stdout" || true

   rm -f "$btrfs_path/$uuid/var/tmp/instance-tag"
   ip link del dev veth0_"$uuid"
   ip netns del netns_"$uuid"
}
