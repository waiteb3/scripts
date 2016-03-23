IMG=$1
shift
sudo ./rkt --insecure-options=image --dir=$HOME/rkt/data run --interactive docker://$IMG --exec="$@"
