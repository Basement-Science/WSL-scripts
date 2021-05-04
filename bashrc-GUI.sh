# setup connections to Host machine for XServer and PulseAudio. 
export HOST_IP="$(ip route |awk '/^default/{print $3}')"
export DISPLAY="$HOST_IP:0.0"
export PULSE_SERVER="tcp:$HOST_IP"

# Automatically start dbus for GUI windows
sudo /etc/init.d/dbus start &> /dev/null

# enable OpenGL graphics to work properly with remote Xserver
export LIBGL_ALWAYS_INDIRECT=0
