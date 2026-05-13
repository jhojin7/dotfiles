# !/bin/sh
# remote:path path/to/mount/point
rclone mount OneDrive:/HJ /home/jhojin/HJ \
	--vfs-cache-mode full \
	--daemon &

rclone mount OneDrive:/Downloads /home/jhojin/Downloads \
	--vfs-cache-mode full \
	--daemon &
