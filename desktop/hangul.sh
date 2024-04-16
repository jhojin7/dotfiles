sudo apt install -y language-pack-ko ibus-hangul im-config
echo "ibus" | sudo tee /etc/X11/xinit/xinputrc
im-config -n ibus
im-config -c
